import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile_app_flutter/views/components/bottom_nav_bar.dart';

class NotificationScreen extends StatefulWidget {
  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  List<dynamic> orders = [];
  String restaurantName = '';

  @override
  void initState() {
    super.initState();
    fetchOrders();
  }

  Future<void> fetchOrders() async {
    final prefs = await SharedPreferences.getInstance();
    final storedName = prefs.getString('restaurantName') ?? '';
    final encodedName = Uri.encodeComponent(storedName);

    final response = await http.get(
      Uri.parse(
        'http://192.168.8.163:5000/api/orders/by-restaurant/$encodedName',
      ),
    );

    if (response.statusCode == 200) {
      setState(() {
        restaurantName = storedName;
        orders = jsonDecode(response.body);
      });
    } else {
      print('❌ Failed to fetch orders: ${response.body}');
    }
  }

  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    print("🔁 Updating order: ID=$orderId, Status=$newStatus");

    final response = await http.put(
      Uri.parse('http://192.168.8.163:5000/api/orders/update/$orderId'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"orderStatus": newStatus}),
    );

    if (response.statusCode == 200) {
      print("✅ Order status updated.");
      fetchOrders(); // Refresh UI
    } else {
      print("❌ Failed to update order status: ${response.body}");
    }
  }

  String timeAgo(String dateString) {
    final date = DateTime.parse(dateString).toLocal();
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inSeconds < 60) return "just now";
    if (diff.inMinutes < 60) return "${diff.inMinutes} minutes ago";
    if (diff.inHours < 24) return "${diff.inHours} hours ago";
    if (diff.inDays == 1) return "yesterday";
    return "${diff.inDays} days ago";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          "Order Notifications",
          style: TextStyle(color: Colors.black),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
        centerTitle: true,
      ),
      body:
          orders.isEmpty
              ? const Center(child: Text("No orders found"))
              : ListView.builder(
                itemCount: orders.length,
                itemBuilder: (context, index) {
                  final order = orders[index];
                  final createdAt = timeAgo(order['createdAt']);
                  final orderId = order['orderId'];
                  final orderStatus = order['orderStatus'];

                  return Card(
                    margin: const EdgeInsets.all(12),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Order ID: $orderId",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 5),
                          Text("Customer: ${order['username']}"),
                          Text("Total: LKR ${order['totalAmount']}"),
                          Text("Time: $createdAt"),
                          const SizedBox(height: 8),
                          const Text(
                            "Items:",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          ...List<Widget>.from(
                            order['items'].map((item) {
                              return ListTile(
                                leading: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    item['image'],
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                title: Text(item['title']),
                                subtitle: Text(
                                  "Qty: ${item['quantity']} | Size: ${item['size'] ?? 'N/A'}",
                                ),
                                trailing: Text("LKR ${item['price']}"),
                              );
                            }),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Status:"),
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  value: orderStatus,
                                  decoration: InputDecoration(
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  dropdownColor: Colors.white,
                                  items:
                                      [
                                        "Order Received",
                                        "Preparing",
                                        "Picked for Delivery",
                                        "Delivered",
                                      ].map((status) {
                                        return DropdownMenuItem(
                                          value: status,
                                          child: Text(status),
                                        );
                                      }).toList(),
                                  onChanged: (newStatus) {
                                    if (newStatus != null &&
                                        newStatus != orderStatus) {
                                      updateOrderStatus(
                                        order['_id'],
                                        newStatus,
                                      );
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 3),
    );
  }
}
