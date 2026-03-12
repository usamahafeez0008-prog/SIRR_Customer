import 'dart:async';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:customer/constant/collection_name.dart';
import 'package:customer/constant/constant.dart';
import 'package:customer/constant/show_toast_dialog.dart';
import 'package:customer/model/driver_user_model.dart';
import 'package:customer/model/intercity_order_model.dart';
import 'package:customer/model/order_model.dart';
import 'package:customer/utils/fire_store_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_map/flutter_map.dart' as flutterMap;
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:latlong2/latlong.dart' as location;
import 'package:geolocator/geolocator.dart' as geo;
import 'package:http/http.dart' as http;

class LiveTrackingController extends GetxController {
  GoogleMapController? mapController;
  final flutterMap.MapController osmMapController = flutterMap.MapController();
  RxString title = 'Map view'.obs;

  Rx<location.LatLng> current = location.LatLng(21.1800, 72.8400).obs;
  Rx<location.LatLng> source = location.LatLng(21.1702, 72.8311).obs;
  Rx<location.LatLng> destination = location.LatLng(21.2000, 72.8600).obs;
  RxString distance = "".obs;

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
    await addMarkerSetup();
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
          _updateTrackingLogic();
        }
      });
    }
    isLoading.value = false;
    update();
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
      if (Constant.selectedMapType == 'osm') {
        current.value = location.LatLng(driverLat, driverLon);
        source.value = location.LatLng(driverLat, driverLon);
        destination.value = location.LatLng(targetLat, targetLon);
        fetchRoute(source.value, destination.value);
      } else {
        getPolyline(sourceLatitude: driverLat, sourceLongitude: driverLon, destinationLatitude: targetLat, destinationLongitude: targetLon);
      }
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

      if (Constant.selectedMapType != 'osm') {
        final Uint8List departure = await Constant().getBytesFromAsset('assets/images/pickup.png', 120);
        final Uint8List destination = await Constant().getBytesFromAsset('assets/images/dropoff.png', 120);
        final Uint8List driver =
            serviceMarkerIcon.value == '' ? await Constant().getBytesFromAsset('assets/images/ic_cab.png', 50) : await Constant().getBytesFromUrl(serviceMarkerIcon.value, width: 120);
        departureIcon = BitmapDescriptor.fromBytes(departure);
        destinationIcon = BitmapDescriptor.fromBytes(destination);
        driverIcon = BitmapDescriptor.fromBytes(driver);
      }
    }
  }

  RxMap<PolylineId, Polyline> polyLines = <PolylineId, Polyline>{}.obs;
  PolylinePoints polylinePoints = PolylinePoints(apiKey: Constant.mapAPIKey);

  void getPolyline({required double? sourceLatitude, required double? sourceLongitude, required double? destinationLatitude, required double? destinationLongitude}) async {
    if (sourceLatitude != null && sourceLongitude != null && destinationLatitude != null && destinationLongitude != null) {
      List<LatLng> polylineCoordinates = [];
      PolylineRequest polylineRequest = PolylineRequest(
        origin: PointLatLng(sourceLatitude, sourceLongitude),
        destination: PointLatLng(destinationLatitude, destinationLongitude),
        mode: TravelMode.driving,
      );

      PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(request: polylineRequest);
      if (result.points.isNotEmpty) {
        for (var point in result.points) {
          polylineCoordinates.add(LatLng(point.latitude, point.longitude));
        }
        double totalDistance = geo.Geolocator.distanceBetween(sourceLatitude, sourceLongitude, destinationLatitude, destinationLongitude);
        distance.value = (totalDistance / 1000).toStringAsFixed(2);
      }
      
      markers.clear();
      String status = type.value == "orderModel" ? orderModel.value.status ?? "" : intercityOrderModel.value.status ?? "";

      if (status == Constant.rideActive) {
        addMarker(latitude: destinationLatitude, longitude: destinationLongitude, id: "Departure", descriptor: departureIcon!, rotation: 0.0);
      } else {
        addMarker(latitude: destinationLatitude, longitude: destinationLongitude, id: "Destination", descriptor: destinationIcon!, rotation: 0.0);
      }
      
      addMarker(latitude: sourceLatitude, longitude: sourceLongitude, id: "Driver", descriptor: driverIcon!, rotation: driverUserModel.value.rotation);
      _addPolyLine(polylineCoordinates);
    }
  }

  RxMap<MarkerId, Marker> markers = <MarkerId, Marker>{}.obs;

  void addMarker({required double? latitude, required double? longitude, required String id, required BitmapDescriptor descriptor, required double? rotation}) {
    MarkerId markerId = MarkerId(id);
    Marker marker = Marker(markerId: markerId, icon: descriptor, position: LatLng(latitude ?? 0.0, longitude ?? 0.0), rotation: rotation ?? 0.0);
    markers[markerId] = marker;
  }

  void _addPolyLine(List<LatLng> polylineCoordinates) {
    PolylineId id = const PolylineId("poly");
    Polyline polyline = Polyline(polylineId: id, points: polylineCoordinates, consumeTapEvents: true, startCap: Cap.roundCap, width: 6);
    polyLines[id] = polyline;
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
    CameraUpdate cameraUpdate = CameraUpdate.newLatLngBounds(bounds, 10);
    return checkCameraLocation(cameraUpdate, mapController);
  }

  Future<void> checkCameraLocation(CameraUpdate cameraUpdate, GoogleMapController mapController) async {
    mapController.animateCamera(cameraUpdate);
    LatLngBounds l1 = await mapController.getVisibleRegion();
    if (l1.southwest.latitude == -90) return checkCameraLocation(cameraUpdate, mapController);
  }

  RxList<location.LatLng> routePoints = <location.LatLng>[].obs;

  Future<void> fetchRoute(location.LatLng source, location.LatLng destination) async {
    final url = Uri.parse('https://router.project-osrm.org/route/v1/driving/${source.longitude},${source.latitude};${destination.longitude},${destination.latitude}?overview=full&geometries=geojson');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      final geometry = decoded['routes'][0]['geometry']['coordinates'];
      routePoints.clear();
      for (var coord in geometry) {
        routePoints.add(location.LatLng(coord[1], coord[0]));
      }
      double distInMeters = decoded['routes'][0]['distance'].toDouble();
      distance.value = (distInMeters / 1000).toStringAsFixed(2);
      fitOSMBounds();
    }
  }

  void fitOSMBounds() {
    if (routePoints.isNotEmpty) {
      osmMapController.fitCamera(flutterMap.CameraFit.bounds(bounds: flutterMap.LatLngBounds.fromPoints(routePoints), padding: const EdgeInsets.all(50)));
    }
  }
}
