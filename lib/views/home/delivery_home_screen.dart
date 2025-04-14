import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_app_flutter/views/components/CustomBottomNavBarForDriver.dart';

import 'package:shared_preferences/shared_preferences.dart';

class DeliveryHomeScreen extends StatefulWidget {
  @override
  _DeliveryHomeScreenState createState() => _DeliveryHomeScreenState();
}

class _DeliveryHomeScreenState extends State<DeliveryHomeScreen> {
  List<dynamic> orders = [];
  String deliveryName = "Delivery Partner";

  @override
  void initState() {
    super.initState();
    fetchUserName();
    fetchPendingOrders();
  }

  Future<void> fetchUserName() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      deliveryName = prefs.getString("fullName") ?? "Delivery Partner";
    });
  }

  Future<void> fetchPendingOrders() async {
    final response = await http.get(
      Uri.parse('http://192.168.8.163:5000/api/orders/pending-delivery'),
    );

    if (response.statusCode == 200) {
      setState(() {
        orders = jsonDecode(response.body);
      });
    } else {
      print("❌ Failed to fetch orders: ${response.body}");
    }
  }

  void onNavTapped(int index) {
    if (index == 0) return; // already on Home
    if (index == 1) {
      Navigator.pushNamed(context, '/track_delivery');
    } else if (index == 2) {
      Navigator.pushNamed(context, '/delivery_profile');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.orange,
        centerTitle: true,
        title: Text("Welcome, $deliveryName"),
      ),
      body:
          orders.isEmpty
              ? const Center(child: Text("No pending deliveries"))
              : ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: orders.length,
                itemBuilder: (context, index) {
                  final order = orders[index];
                  final item = order['items'][0];

                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildInfoRow("🧾 Order ID:", order['orderId']),
                          _buildInfoRow(
                            "🏪 Restaurant:",
                            item['restaurantName'],
                          ),
                          _buildInfoRow("👤 Customer:", order['username']),
                          _buildInfoRow("🍔 Item:", item['title']),
                          _buildInfoRow(
                            "📍 Delivery Address:",
                            order['deliveryLocation']['address'],
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.directions_bike),
                              label: const Text("Accept Delivery"),
                              onPressed: () {
                                Navigator.pushNamed(
                                  context,
                                  '/track_delivery',
                                  arguments: order,
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      bottomNavigationBar: CustomBottomNavBarForTracking(
        currentIndex: 0, // This is the Home tab
        onTap: onNavTapped,
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: RichText(
        text: TextSpan(
          text: "$label ",
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
          children: [
            TextSpan(
              text: value,
              style: const TextStyle(fontWeight: FontWeight.normal),
            ),
          ],
        ),
      ),
    );
  }
}
