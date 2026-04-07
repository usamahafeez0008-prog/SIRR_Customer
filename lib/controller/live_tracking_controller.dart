import 'dart:async';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:customer/constant/collection_name.dart';
import 'package:customer/constant/constant.dart';
import 'package:customer/constant/show_toast_dialog.dart';
import 'package:customer/themes/app_colors.dart';
import 'package:customer/model/driver_user_model.dart';
import 'package:customer/model/intercity_order_model.dart';
import 'package:customer/model/order_model.dart';
import 'package:customer/utils/fire_store_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:http/http.dart' as http;

class LiveTrackingController extends GetxController {
  GoogleMapController? mapController;
  RxString title = 'Map view'.obs;
  RxString distance = "".obs;
  LatLng? lastDriverLocation;

  StreamSubscription? orderSubscription;
  StreamSubscription? driverSubscription;

  Rx<DriverUserModel> driverUserModel = DriverUserModel().obs;
  Rx<OrderModel> orderModel = OrderModel().obs;
  Rx<InterCityOrderModel> intercityOrderModel = InterCityOrderModel().obs;

  RxBool isLoading = true.obs;
  RxString type = "".obs;
  dynamic argumentData = Get.arguments;

  @override
  void onInit() {
    getArgument();
    super.onInit();
  }

  @override
  void onClose() {
    orderSubscription?.cancel();
    driverSubscription?.cancel();
    ShowToastDialog.closeLoader();
    super.onClose();
  }

  Future<void> getArgument() async {
    try {
      if (argumentData != null) {
        type.value = argumentData['type'];
        String orderId = "";
        String? initialDriverId;

        if (type.value == "orderModel") {
          OrderModel o = argumentData['orderModel'];
          orderId = o.id ?? "";
          initialDriverId = o.driverId;
          orderModel.value = o;
        } else {
          InterCityOrderModel o = argumentData['interCityOrderModel'];
          orderId = o.id ?? "";
          initialDriverId = o.driverId;
          intercityOrderModel.value = o;
        }

        // Setup base markers (Source/Destination) before waiting for driver
        await addMarkerSetup();
        _addBaseMarkers();

        if (initialDriverId != null) {
          _listenToDriver(initialDriverId);
        }

        orderSubscription = FireStoreUtils.fireStore
            .collection(type.value == "orderModel" ? CollectionName.orders : CollectionName.ordersIntercity)
            .doc(orderId)
            .snapshots()
            .listen((event) {
          if (event.data() != null) {
            if (type.value == "orderModel") {
              orderModel.value = OrderModel.fromJson(event.data()!);
              if (orderModel.value.status == Constant.rideComplete) Get.back();
              if (driverSubscription == null && orderModel.value.driverId != null) {
                _listenToDriver(orderModel.value.driverId!);
              }
            } else {
              intercityOrderModel.value = InterCityOrderModel.fromJson(event.data()!);
              if (intercityOrderModel.value.status == Constant.rideComplete) Get.back();
              if (driverSubscription == null && intercityOrderModel.value.driverId != null) {
                _listenToDriver(intercityOrderModel.value.driverId!);
              }
            }
            _addBaseMarkers();
            _updateTrackingLogic();
          }
        });
      }
    } catch (e) {
      debugPrint("Error in getArgument: $e");
    } finally {
      isLoading.value = false;
      update();
    }
  }

  void _addBaseMarkers() {
    double? lat;
    double? lon;
    String status = type.value == "orderModel" ? orderModel.value.status ?? "" : intercityOrderModel.value.status ?? "";

    if (type.value == "orderModel") {
      if (status == Constant.rideInProgress) {
        lat = orderModel.value.destinationLocationLAtLng?.latitude;
        lon = orderModel.value.destinationLocationLAtLng?.longitude;
        if (lat != null && lon != null) addMarker(latitude: lat, longitude: lon, id: "Destination", descriptor: destinationIcon!, rotation: 0.0);
      } else {
        lat = orderModel.value.sourceLocationLAtLng?.latitude;
        lon = orderModel.value.sourceLocationLAtLng?.longitude;
        if (lat != null && lon != null) addMarker(latitude: lat, longitude: lon, id: "Departure", descriptor: departureIcon!, rotation: 0.0);
      }
    } else {
      if (status == Constant.rideInProgress) {
        lat = intercityOrderModel.value.destinationLocationLAtLng?.latitude;
        lon = intercityOrderModel.value.destinationLocationLAtLng?.longitude;
        if (lat != null && lon != null) addMarker(latitude: lat, longitude: lon, id: "Destination", descriptor: destinationIcon!, rotation: 0.0);
      } else {
        lat = intercityOrderModel.value.sourceLocationLAtLng?.latitude;
        lon = intercityOrderModel.value.sourceLocationLAtLng?.longitude;
        if (lat != null && lon != null) addMarker(latitude: lat, longitude: lon, id: "Departure", descriptor: departureIcon!, rotation: 0.0);
      }
    }

    // If driver is not yet available, at least center on the target
    if (driverUserModel.value.location == null && lat != null && lon != null) {
      if (mapController != null) {
        mapController!.animateCamera(CameraUpdate.newLatLngZoom(LatLng(lat, lon), 15));
      }
    }
  }

  void _listenToDriver(String driverId) {
    if (driverSubscription != null) driverSubscription!.cancel();
    driverSubscription = FireStoreUtils.fireStore.collection(CollectionName.driverUsers).doc(driverId).snapshots().listen((event) {
      if (event.data() != null) {
        driverUserModel.value = DriverUserModel.fromJson(event.data()!);
        _updateTrackingLogic();
      }
    });
  }

  void _updateTrackingLogic() {
    double? driverLat = driverUserModel.value.location?.latitude;
    double? driverLon = driverUserModel.value.location?.longitude;

    if (driverLat == null || driverLon == null) return;

    // Throttle: Only update if driver has moved significantly (e.g., > 10 meters)
    if (lastDriverLocation != null) {
      double moved = geo.Geolocator.distanceBetween(
        lastDriverLocation!.latitude,
        lastDriverLocation!.longitude,
        driverLat,
        driverLon,
      );
      if (moved < 10) return; // Ignore small movements to save API calls and reduce blink
    }
    lastDriverLocation = LatLng(driverLat, driverLon);
    double? targetLat;
    double? targetLon;

    String status = type.value == "orderModel" ? orderModel.value.status ?? "" : intercityOrderModel.value.status ?? "";

    if (type.value == "orderModel") {
      if (status == Constant.rideInProgress) {
        targetLat = orderModel.value.destinationLocationLAtLng?.latitude;
        targetLon = orderModel.value.destinationLocationLAtLng?.longitude;
      } else if (status == Constant.rideActive) {
        targetLat = orderModel.value.sourceLocationLAtLng?.latitude;
        targetLon = orderModel.value.sourceLocationLAtLng?.longitude;
      }
    } else {
      if (status == Constant.rideInProgress) {
        targetLat = intercityOrderModel.value.destinationLocationLAtLng?.latitude;
        targetLon = intercityOrderModel.value.destinationLocationLAtLng?.longitude;
      } else if (status == Constant.rideActive) {
        targetLat = intercityOrderModel.value.sourceLocationLAtLng?.latitude;
        targetLon = intercityOrderModel.value.sourceLocationLAtLng?.longitude;
      }
    }

    if (targetLat != null && targetLon != null && targetLat != 0.0) {
      updateCameraLocation(LatLng(driverLat, driverLon), LatLng(targetLat, targetLon), mapController);
      getPolyline(sourceLatitude: driverLat, sourceLongitude: driverLon, destinationLatitude: targetLat, destinationLongitude: targetLon);
    }
  }

  Rx<String> serviceMarkerIcon = ''.obs;
  BitmapDescriptor? departureIcon;
  BitmapDescriptor? destinationIcon;
  BitmapDescriptor? driverIcon;

  Future<void> addMarkerSetup() async {
    if (argumentData != null) {
      type.value = argumentData['type'];
      if (type.value == "orderModel") {
        OrderModel argumentOrderModel = argumentData['orderModel'];
        serviceMarkerIcon.value = argumentOrderModel.service?.markerIcon ?? '';
      } else {
        InterCityOrderModel argumentOrderCityModel = argumentData['interCityOrderModel'];
        final drivermodel = await FireStoreUtils.getDriver(argumentOrderCityModel.driverId!);
        final service = await FireStoreUtils.getServiceById(drivermodel!.serviceId!);
        serviceMarkerIcon.value = service.markerIcon ?? "";
      }

      final Uint8List departure = await Constant().getBytesFromAsset('assets/images/pickup.png', 120);
      final Uint8List destination = await Constant().getBytesFromAsset('assets/images/dropoff.png', 120);
      final Uint8List driver =
          serviceMarkerIcon.value == '' ? await Constant().getBytesFromAsset('assets/images/ic_cab.png', 50) : await Constant().getBytesFromUrl(serviceMarkerIcon.value, width: 120);
      departureIcon = BitmapDescriptor.fromBytes(departure);
      destinationIcon = BitmapDescriptor.fromBytes(destination);
      driverIcon = BitmapDescriptor.fromBytes(driver);
    }
  }

  RxMap<PolylineId, Polyline> polyLines = <PolylineId, Polyline>{}.obs;
  PolylinePoints polylinePoints = PolylinePoints(apiKey: Constant.mapAPIKey);

  void getPolyline({required double? sourceLatitude, required double? sourceLongitude, required double? destinationLatitude, required double? destinationLongitude}) async {
    if (sourceLatitude != null && sourceLongitude != null && destinationLatitude != null && destinationLongitude != null) {
      // Step 1: Calculate straight-line distance immediately as a placeholder 
      // This ensures the "Heading to destination" / "Driver is arriving" card shows up instantly
      double directDistance = geo.Geolocator.distanceBetween(sourceLatitude, sourceLongitude, destinationLatitude, destinationLongitude);
      distance.value = (directDistance / 1000).toStringAsFixed(2);

      try {
        final url = Uri.parse('https://maps.googleapis.com/maps/api/directions/json?origin=$sourceLatitude,$sourceLongitude&destination=$destinationLatitude,$destinationLongitude&key=${Constant.mapAPIKey}');
        final response = await http.get(url);
        
        if (response.statusCode == 200) {
          final decoded = json.decode(response.body);
          if (decoded['status'] == 'OK') {
            final route = decoded['routes'][0];
            final points = route['overview_polyline']['points'];
            List<LatLng> polylineCoordinates = _decodeEncodedPolyline(points);
            
            // Get distance from legs
            String distText = route['legs'][0]['distance']['text'];
            distance.value = distText.replaceAll(RegExp(r'[^0-9.]'), '');

            markers.clear();
            polyLines.clear();
            String status = type.value == "orderModel" ? orderModel.value.status ?? "" : intercityOrderModel.value.status ?? "";

            if (status == Constant.rideActive) {
              addMarker(latitude: destinationLatitude, longitude: destinationLongitude, id: "Departure", descriptor: departureIcon!, rotation: 0.0);
            } else {
              addMarker(latitude: destinationLatitude, longitude: destinationLongitude, id: "Destination", descriptor: destinationIcon!, rotation: 0.0);
            }
            
            addMarker(latitude: sourceLatitude, longitude: sourceLongitude, id: "Driver", descriptor: driverIcon!, rotation: driverUserModel.value.rotation);
            _addPolyLine(polylineCoordinates);
          } else {
            debugPrint("Google Directions API error: ${decoded['status']}");
          }
        }
      } catch (e) {
        debugPrint("Error fetching polyline using Google HTTP: $e");
      }
    }
  }

  RxMap<MarkerId, Marker> markers = <MarkerId, Marker>{}.obs;

  void addMarker({required double? latitude, required double? longitude, required String id, required BitmapDescriptor descriptor, required double? rotation}) {
    MarkerId markerId = MarkerId(id);
    Marker marker = Marker(markerId: markerId, icon: descriptor, position: LatLng(latitude ?? 0.0, longitude ?? 0.0), rotation: rotation ?? 0.0);
    markers[markerId] = marker;
  }

  void _addPolyLine(List<LatLng> polylineCoordinates) {
    if (polylineCoordinates.isEmpty) return;
    PolylineId id = const PolylineId("poly");
    Polyline polyline = Polyline(
      polylineId: id,
      points: polylineCoordinates,
      consumeTapEvents: true,
      startCap: Cap.roundCap,
      endCap: Cap.roundCap,
      width: 6,
      color: AppColors.moroccoGreen,
    );
    polyLines[id] = polyline;
    // We already moved to source/destination in _updateTrackingLogic, 
    // but the actual polyline might have slightly different bounds.
    updateCameraLocation(polylineCoordinates.first, polylineCoordinates.last, mapController);
  }

  Future<void> updateCameraLocation(LatLng source, LatLng destination, GoogleMapController? mapController) async {
    if (mapController == null) return;
    LatLngBounds bounds;
    if (source.latitude > destination.latitude && source.longitude > destination.longitude) {
      bounds = LatLngBounds(southwest: destination, northeast: source);
    } else if (source.longitude > destination.longitude) {
      bounds = LatLngBounds(southwest: LatLng(source.latitude, destination.longitude), northeast: LatLng(destination.latitude, source.longitude));
    } else if (source.latitude > destination.latitude) {
      bounds = LatLngBounds(southwest: LatLng(destination.latitude, source.longitude), northeast: LatLng(source.latitude, destination.longitude));
    } else {
      bounds = LatLngBounds(southwest: source, northeast: destination);
    }

    // Add a bit of extra padding for better framing
    CameraUpdate cameraUpdate = CameraUpdate.newLatLngBounds(bounds, 70);
    return checkCameraLocation(cameraUpdate, mapController);
  }

  Future<void> checkCameraLocation(CameraUpdate cameraUpdate, GoogleMapController mapController) async {
    mapController.animateCamera(cameraUpdate);
    LatLngBounds l1 = await mapController.getVisibleRegion();
    if (l1.southwest.latitude == -90) return checkCameraLocation(cameraUpdate, mapController);
  }

  List<LatLng> _decodeEncodedPolyline(String encoded) {
    List<LatLng> poly = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      LatLng p = LatLng(lat / 1E5, lng / 1E5);
      poly.add(p);
    }
    return poly;
  }
}
