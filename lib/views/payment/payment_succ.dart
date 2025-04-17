import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_app_flutter/views/components/location_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PaymentSuccessScreen extends StatelessWidget {
  final List<Map<String, dynamic>> cartItems;

  PaymentSuccessScreen({required this.cartItems});

  Future<void> sendOrderToBackend(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final locationProvider = Provider.of<LocationProvider>(
      context,
      listen: false,
    );

    final userId = prefs.getString("user_id") ?? "unknown";
    final username = prefs.getString("name") ?? "Guest";
    final email = prefs.getString("email") ?? "noemail@kfood.com";

    final orderId = "ORDER_${DateTime.now().millisecondsSinceEpoch}";

    ///  Add restaurantName into each cart item
    final updatedCartItems =
        cartItems.map((item) {
          return {
            ...item,
            "restaurantName": item["restaurantName"] ?? "Unknown Restaurant",
          };
        }).toList();

    final order = {
      "userId": userId,
      "username": username,
      "email": email,
      "orderId": orderId,
      "items": updatedCartItems,
      "totalAmount": _calculateTotalPrice(cartItems).toStringAsFixed(2),
      "orderStatus": "Order Received", //  added status
      "deliveryLocation": {
        "lat": locationProvider.currentLocation.latitude,
        "lng": locationProvider.currentLocation.longitude,
        "address": locationProvider.currentAddress,
      },
    };

    print("📦 Sending order to backend:");
    print(json.encode(order));

    final response = await http.post(
      Uri.parse("http://192.168.8.163:32189/api/orders/create"),
      headers: {"Content-Type": "application/json"},
      body: json.encode(order),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      print("✅ Order saved to backend successfully.");
    } else {
      print("❌ Failed to save order to backend.");
      print("🔴 Status Code: ${response.statusCode}");
      print("🔴 Response Body: ${response.body}");
    }
  }

  double _calculateTotalPrice(List<Map<String, dynamic>> cartItems) {
    double total = 0;
    for (var item in cartItems) {
      total += double.parse(item["price"]) * item["quantity"];
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      sendOrderToBackend(context);
    });

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.check_circle, size: 100, color: Colors.green),
            SizedBox(height: 20),
            Text(
              "Congratulations!",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              "You successfully made a payment,\nenjoy our service!",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/track_order'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text("TRACK ORDER"),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/customer_home'),
              child: const Text("BACK HOME"),
            ),
          ],
        ),
      ),
    );
  }
}
