import 'dart:convert';

import 'package:customer/utils/utils.dart';
import 'package:customer/widget/osm_map/place_model.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class OSMMapController extends GetxController {
  final mapController = MapController();
  // Store only one picked place instead of multiple
  var pickedPlace = Rxn<PlaceModel>(); // Use Rxn to hold a nullable value
  var countryCode = ''.obs;
  var searchResults = [].obs;

  Future<void> searchPlace(String query) async {
    if (query.length < 1) {
      searchResults.clear();
      return;
    }

    // Worldwide search URL (commented out as requested)
    // final url = Uri.parse('https://nominatim.openstreetmap.org/search?q=$query&format=json&addressdetails=1&limit=10');

    // Refined localized search for more results exactly like Google Maps
    String restrictParams = "";
    if (pickedPlace.value != null) {
      final lat = pickedPlace.value!.coordinates.latitude;
      final lon = pickedPlace.value!.coordinates.longitude;
      // Using moderate viewbox (approx 50km radius) for stronger biasing
      // bounded=0 allows results slightly further away but still prioritizes local
      restrictParams = "&lat=$lat&lon=$lon&viewbox=${lon - 0.5},${lat + 0.5},${lon + 0.5},${lat - 0.5}";
    }

    // Strictly restrict to country to avoid worldwide spam
    if (countryCode.value.isNotEmpty) {
      restrictParams += "&countrycodes=${countryCode.value}";
    }

    // Use jsonv2 for richer results, increase limit to 50
    final url = Uri.parse('https://nominatim.openstreetmap.org/search?q=$query&format=jsonv2&addressdetails=1&limit=50$restrictParams');

    final response = await http.get(url, headers: {
      'User-Agent': 'SiRR_App/1.0 (customer_app)',
    });

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      searchResults.value = data;
    }
  }

  void selectSearchResult(Map<String, dynamic> place) {
    final lat = double.parse(place['lat']);
    final lon = double.parse(place['lon']);
    final address = place['display_name'];

    String city = '';
    if (place['address'] != null) {
      final addressMap = place['address'] as Map<String, dynamic>;
      city = addressMap['city'] ?? addressMap['town'] ?? addressMap['village'] ?? addressMap['state_district'] ?? addressMap['county'] ?? '';
      if (addressMap['country_code'] != null) {
        countryCode.value = addressMap['country_code'];
      }
    }

    // Store only the selected place
    pickedPlace.value = PlaceModel(coordinates: LatLng(lat, lon), address: address, city: city);
    searchResults.clear();
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
    // TODO: implement onInit
    super.onInit();
    getCurrentLocation();
  }

  getCurrentLocation() async {
    Position? location = await Utils.getCurrentLocation();
    LatLng latlng = LatLng(location.latitude, location.longitude);
    // Set coordinates immediately so search has context even while address is loading
    pickedPlace.value = PlaceModel(coordinates: latlng, address: "Loading address...", city: "");
    addLatLngOnly(latlng);
    mapController.move(latlng, mapController.camera.zoom);
  }
}
