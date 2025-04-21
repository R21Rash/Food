import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LocationProvider with ChangeNotifier {
  LatLng _currentLocation = LatLng(6.9271, 79.8612); // Default (Colombo)
  String _currentAddress = "Fetching location...";

  LatLng get currentLocation => _currentLocation;
  String get currentAddress => _currentAddress;

  Future<void> fetchCurrentLocation() async {
    if (await Permission.location.request().isGranted) {
      try {
        Position? position = await Geolocator.getLastKnownPosition();

        if (position == null) {
          position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.best,
            timeLimit: const Duration(seconds: 5),
          );
        }

        final address = await getAddressFromLatLng(
          position.latitude,
          position.longitude,
        );

        _currentLocation = LatLng(position.latitude, position.longitude);
        _currentAddress = address;
        notifyListeners();
      } catch (e) {
        _currentAddress = "Failed to fetch location.";
        notifyListeners();
      }
    } else {
      _currentAddress = "Location permission denied.";
      notifyListeners();
    }
  }

  void updateLocation(LatLng newLocation, String newAddress) {
    _currentLocation = newLocation;
    _currentAddress = newAddress;
    notifyListeners();
  }

  Future<String> getAddressFromLatLng(double lat, double lng) async {
    try {
      final url = Uri.parse(
        "https://nominatim.openstreetmap.org/reverse?format=json&lat=$lat&lon=$lng",
      );
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['display_name'] ?? "Address not found";
      } else {
        return "Failed to fetch address";
      }
    } catch (e) {
      return "Failed to fetch address";
    }
  }
}
