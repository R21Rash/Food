// Enhanced NotificationScreen with dropdown UI, new badge, sorting, and pagination
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
  List<dynamic> allOrders = [];
  List<dynamic> visibleOrders = [];
  int currentPage = 0;
  final int itemsPerPage = 5;

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
        'http://192.168.8.163:5003/api/orders/by-restaurant/$encodedName',
      ),
    );

    if (response.statusCode == 200) {
      final List<dynamic> sorted = jsonDecode(response.body);
      sorted.sort((a, b) => b['createdAt'].compareTo(a['createdAt']));
      setState(() {
        allOrders = sorted;
        updateVisibleOrders();
      });
    } else {
      print('❌ Failed to fetch orders: ${response.body}');
    }
  }

  void updateVisibleOrders() {
    final start = currentPage * itemsPerPage;
    final end = (start + itemsPerPage).clamp(0, allOrders.length);
    setState(() {
      visibleOrders = allOrders.sublist(start, end);
    });
  }

  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    final response = await http.put(
      Uri.parse('http://192.168.8.163:5003/api/orders/update/$orderId'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"orderStatus": newStatus}),
    );

    if (response.statusCode == 200) {
      fetchOrders();
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

  Widget buildDropdown(String current, ValueChanged<String?> onChanged) {
    return InputDecorator(
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: current,
          isExpanded: true,
          icon: const Icon(Icons.arrow_drop_down, color: Colors.orange),
          items:
              [
                    "Order Received",
                    "Preparing",
                    "Picked for Delivery",
                    "Delivered",
                  ]
                  .map(
                    (status) =>
                        DropdownMenuItem(value: status, child: Text(status)),
                  )
                  .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/restaurant_home');
          },
        ),
        title: const Text(
          "Order Notifications",
          style: TextStyle(color: Colors.black),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
        centerTitle: true,
      ),
      body:
          visibleOrders.isEmpty
              ? const Center(child: Text("No orders found"))
              : ListView.builder(
                itemCount: visibleOrders.length + 1,
                itemBuilder: (context, index) {
                  if (index == visibleOrders.length) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Center(
                        child: ElevatedButton(
                          onPressed: () {
                            if ((currentPage + 1) * itemsPerPage <
                                allOrders.length) {
                              setState(() {
                                currentPage++;
                                updateVisibleOrders();
                              });
                            }
                          },
                          child: const Text("Load More"),
                        ),
                      ),
                    );
                  }

                  final order = visibleOrders[index];
                  final createdAt = timeAgo(order['createdAt']);
                  final isNew = order['orderStatus'] == "Order Received";
                  final orderId = order['orderId'];
                  final orderStatus = order['orderStatus'];

                  return Card(
                    margin: const EdgeInsets.all(12),
                    elevation: 3,
                    color: Colors.white,

                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.orange.shade200, width: 2),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Order ID: $orderId",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (isNew)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.orange.shade100,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Text(
                                    "NEW",
                                    style: TextStyle(
                                      color: Colors.orange,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "Customer: ${order['username']}",
                            style: const TextStyle(fontSize: 14),
                          ),
                          Text(
                            "Total: LKR ${order['totalAmount']}",
                            style: const TextStyle(fontSize: 14),
                          ),
                          Text(
                            "Time: $createdAt",
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            "Items:",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          ...List<Widget>.from(
                            order['items'].map(
                              (item) => ListTile(
                                contentPadding: EdgeInsets.zero,
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
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("Status:"),
                              Expanded(
                                child: buildDropdown(orderStatus, (newStatus) {
                                  if (newStatus != null &&
                                      newStatus != orderStatus) {
                                    updateOrderStatus(order['_id'], newStatus);
                                  }
                                }),
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
