import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class DeliveryTrackingScreen extends StatefulWidget {
  final Map<String, dynamic> order;

  const DeliveryTrackingScreen({super.key, required this.order});

  @override
  _DeliveryTrackingScreenState createState() => _DeliveryTrackingScreenState();
}

class _DeliveryTrackingScreenState extends State<DeliveryTrackingScreen> {
  late String orderId;
  String orderStatus = "";

  final LatLng restaurantLocation = LatLng(7.1645, 80.5691); // Gampola
  late LatLng destinationLocation;
  LatLng? currentLocation;

  @override
  void initState() {
    super.initState();
    orderId = widget.order["_id"];
    orderStatus = widget.order["orderStatus"];

    final lat = widget.order["deliveryLocation"]["lat"];
    final lng = widget.order["deliveryLocation"]["lng"];
    destinationLocation = LatLng(lat, lng);

    _startTracking();
  }

  Future<void> updateOrderStatus(String newStatus) async {
    final url = 'http://192.168.8.218:5003/api/orders/update/$orderId';
    final response = await http.put(
      Uri.parse(url),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"orderStatus": newStatus}),
    );

    if (response.statusCode == 200) {
      setState(() => orderStatus = newStatus);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Order updated to $newStatus")));
      if (newStatus == "Delivered") {
        Navigator.pushReplacementNamed(context, '/delivery_home');
      }
    } else {
      print("❌ Update failed: ${response.body}");
    }
  }

  void _startTracking() {
    Geolocator.getPositionStream(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    ).listen((position) {
      setState(() {
        currentLocation = LatLng(position.latitude, position.longitude);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final items = widget.order["items"];
    final customer = widget.order["username"];
    final restaurant = widget.order["items"][0]["restaurantName"];
    final address = widget.order["deliveryLocation"]["address"];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Order Delivery"),
        backgroundColor: Colors.orange,
      ),
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: FlutterMap(
              options: MapOptions(
                initialCenter: currentLocation ?? restaurantLocation,
                initialZoom: 14,
              ),
              children: [
                TileLayer(
                  urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                  userAgentPackageName: 'com.example.mobile_app_flutter',
                ),
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: [restaurantLocation, destinationLocation],
                      strokeWidth: 4.0,
                      color: Colors.yellow,
                    ),
                  ],
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      width: 30,
                      height: 30,
                      point: restaurantLocation,
                      child: const Icon(Icons.store, color: Colors.red),
                    ),
                    Marker(
                      width: 30,
                      height: 30,
                      point: destinationLocation,
                      child: const Icon(
                        Icons.location_pin,
                        color: Colors.green,
                      ),
                    ),
                    if (currentLocation != null)
                      Marker(
                        width: 30,
                        height: 30,
                        point: currentLocation!,
                        child: const Icon(
                          Icons.delivery_dining,
                          color: Colors.orange,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Restaurant: $restaurant",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text("Customer: $customer"),
                    const SizedBox(height: 10),
                    const Text(
                      "Delivery Address:",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(address),
                    const SizedBox(height: 10),

                    const SizedBox(height: 20),
                    if (orderStatus == "Preparing")
                      ElevatedButton.icon(
                        onPressed:
                            () => updateOrderStatus("Picked for Delivery"),
                        icon: const Icon(Icons.delivery_dining),
                        label: const Text("Confirm Pickup"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          minimumSize: const Size(double.infinity, 48),
                        ),
                      ),
                    if (orderStatus == "Picked for Delivery")
                      ElevatedButton.icon(
                        onPressed: () => updateOrderStatus("Delivered"),
                        icon: const Icon(Icons.check_circle),
                        label: const Text("Mark as Delivered"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          minimumSize: const Size(double.infinity, 48),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
