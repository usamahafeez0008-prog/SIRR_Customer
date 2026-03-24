import 'dart:convert';

import 'package:customer/utils/utils.dart';
import 'package:customer/constant/constant.dart';
import 'package:customer/widget/osm_map/place_model.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:google_places_autocomplete/google_places_autocomplete.dart';
import 'package:flutter_google_maps_webservices/places.dart' as gmaps;
import 'package:google_maps_flutter/google_maps_flutter.dart' as gm;

class OSMMapController extends GetxController {
  // final mapController = MapController();
  gm.GoogleMapController? googleMapController;
  // Store only one picked place instead of multiple
  var pickedPlace = Rxn<PlaceModel>(); // Use Rxn to hold a nullable value
  var countryCode = ''.obs;
  var searchResults = [].obs;
  var markers = <gm.Marker>{}.obs;

  late GooglePlacesAutocomplete _places;
  late gmaps.GoogleMapsPlaces _placesDetailApi;

  Future<void> searchPlace(String query) async {
    if (query.isEmpty) {
      searchResults.clear();
      return;
    }
    
    // Using Google Places instead of Nominatim
    _places.getPredictions(query);
    
    /*
    // Refined localized search for more results exactly like Google Maps
    String restrictParams = "";
    if (pickedPlace.value != null) { ... }
    ...
    */
  }

  Future<LatLng?> selectSearchResult(Map<String, dynamic> place) async {
    final placeId = place['place_id'];
    final response = await _placesDetailApi.getDetailsByPlaceId(placeId);
    
    if (response.status == 'OK') {
      final details = response.result;
      final lat = details.geometry!.location.lat;
      final lon = details.geometry!.location.lng;
      final address = details.formattedAddress ?? details.name ?? place['display_name'];
      
      final pos = LatLng(lat, lon);
      pickedPlace.value = PlaceModel(coordinates: pos, address: address, city: "");
      
      // Update Google Markers
      markers.clear();
      markers.add(gm.Marker(
        markerId: const gm.MarkerId("picked"),
        position: gm.LatLng(lat, lon),
      ));

      if (googleMapController != null) {
        googleMapController!.animateCamera(gm.CameraUpdate.newLatLngZoom(gm.LatLng(lat, lon), 15));
      }
      
      searchResults.clear();
      return pos;
    }
    return null;
  }

  void addLatLngOnly(LatLng coords) async {
    final address = await _getAddressFromLatLng(coords);
    if (address == null || address is! Map) return;

    String city = '';
    if (address['address'] != null) {
      final addressMap = address['address'] as Map<String, dynamic>;
      city = addressMap['city'] ?? addressMap['town'] ?? addressMap['village'] ?? addressMap['state_district'] ?? addressMap['county'] ?? '';
      if (addressMap['country_code'] != null) {
        countryCode.value = addressMap['country_code'];
      }
    }

    pickedPlace.value = PlaceModel(coordinates: coords, address: address['display_name'] ?? 'Unknown location', city: city);
    
    // Update Google Markers
    markers.clear();
    markers.add(gm.Marker(
      markerId: const gm.MarkerId("picked"),
      position: gm.LatLng(coords.latitude, coords.longitude),
    ));
    
    if (googleMapController != null) {
      googleMapController!.animateCamera(gm.CameraUpdate.newLatLng(gm.LatLng(coords.latitude, coords.longitude)));
    }
  }

  Future<dynamic> _getAddressFromLatLng(LatLng coords) async {
    final url = Uri.parse('https://nominatim.openstreetmap.org/reverse?lat=${coords.latitude}&lon=${coords.longitude}&format=json');

    final response = await http.get(url, headers: {
      'User-Agent': 'FlutterMapApp/1.0 (menil.siddhiinfosoft@gmail.com)',
    });

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data;
    } else {
      return {};
    }
  }

  void clearAll() {
    pickedPlace.value = null; // Clear the selected place
    countryCode.value = '';
  }

  @override
  void onInit() {
    super.onInit();
    _places = GooglePlacesAutocomplete(
      countries: ['pk', 'ma'],
      debounceTime: 500,
      predictionsListener: (predictions) {
        searchResults.value = predictions
            .where((p) => (p.title ?? p.description ?? '').trim().isNotEmpty)
            .map((p) => {
                  'title': p.title ?? '',
                  'address': p.description ?? '',
                  'display_name': (p.title != null && p.description != null && p.description!.isNotEmpty)
                      ? "${p.title}, ${p.description}"
                      : (p.title ?? p.description ?? ''),
                  'place_id': p.placeId,
                })
            .toList();
      },
    );
    _places.initialize(apiKey: Constant.mapAPIKey);
    _placesDetailApi = gmaps.GoogleMapsPlaces(apiKey: Constant.mapAPIKey);
    getCurrentLocation();
  }

  getCurrentLocation() async {
    Position? location = await Utils.getCurrentLocation();
    LatLng latlng = LatLng(location.latitude, location.longitude);
    // Set coordinates immediately so search has context even while address is loading
    pickedPlace.value = PlaceModel(coordinates: latlng, address: "Loading address...", city: "");
    addLatLngOnly(latlng);
    _places.setOrigin(latitude: location.latitude, longitude: location.longitude);
    // mapController.move(latlng, mapController.camera.zoom);
  }
}
