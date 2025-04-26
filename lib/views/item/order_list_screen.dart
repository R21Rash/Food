import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_app_flutter/common-const/api_constants.dart';
import 'package:mobile_app_flutter/views/components/bottom_nav_bar_for_customer.dart';
import 'package:mobile_app_flutter/views/item/edit_order_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OrderListScreen extends StatefulWidget {
  const OrderListScreen({Key? key}) : super(key: key);

  @override
  State<OrderListScreen> createState() => _OrderListScreenState();
}

class _OrderListScreenState extends State<OrderListScreen> {
  Map<String, List<dynamic>> groupedOrders = {
    "Order Received": [],
    "Preparing": [],
    "Picked for Delivery": [],
    "Delivered": [],
  };

  final List<String> tabs = ["Ongoing", "Completed"];
  String selectedTab = "Ongoing";

  @override
  void initState() {
    super.initState();
    fetchOrders();
  }

  Future<void> fetchOrders() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString("user_id");
    if (userId == null) return;

    final response = await http.get(
      Uri.parse("$baseURL:32189/api/orders/by-user/$userId"),
    );

    if (response.statusCode == 200) {
      final List<dynamic> orders = json.decode(response.body);
      final Map<String, List<dynamic>> temp = {
        "Order Received": [],
        "Preparing": [],
        "Picked for Delivery": [],
        "Delivered": [],
      };

      for (var order in orders) {
        final status = order['orderStatus'];
        if (temp.containsKey(status)) {
          temp[status]!.add(order);
        }
      }

      setState(() {
        groupedOrders = temp;
      });
    }
  }

  Widget buildTabBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children:
            tabs.map((tab) {
              final isSelected = tab == selectedTab;
              return GestureDetector(
                onTap: () => setState(() => selectedTab = tab),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 12,
                  ),
                  margin: const EdgeInsets.only(right: 20),
                  decoration: BoxDecoration(
                    border:
                        isSelected
                            ? const Border(
                              bottom: BorderSide(
                                color: Colors.orange,
                                width: 3,
                              ),
                            )
                            : null,
                  ),
                  child: Text(
                    tab,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.black : Colors.grey,
                      fontSize: 16,
                    ),
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }

  Widget buildOrderCard(dynamic order) {
    bool isEditable = order['orderStatus'] == "Order Received";

    return Card(
      elevation: 1,
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Order ID: ${order['orderId']}",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text("Total: LKR ${order['totalAmount']}"),
            const SizedBox(height: 6),
            Text("Status: ${order['orderStatus']}"),
            const SizedBox(height: 6),
            Text(
              "Placed: ${DateTime.parse(order['createdAt']).toLocal().toString().split('.')[0]}",
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const Divider(height: 16),
            const Text("Items:", style: TextStyle(fontWeight: FontWeight.bold)),
            ...order['items'].map<Widget>((item) {
              return ListTile(
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
              );
            }).toList(),
            const SizedBox(height: 10),
            isEditable
                ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        final updated = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditOrderScreen(order: order),
                          ),
                        );

                        if (updated == true) {
                          fetchOrders(); // Refresh the list after editing
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.orange,
                      ),
                      child: const Text("Edit Order"),
                    ),
                    TextButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder:
                              (ctx) => AlertDialog(
                                title: const Text("Cancel Order"),
                                content: const Text(
                                  "Are you sure you want to cancel this order?",
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx),
                                    child: const Text("No"),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      cancelOrder(order['_id']);
                                      Navigator.pop(ctx);
                                    },
                                    child: const Text("Yes, Cancel"),
                                  ),
                                ],
                              ),
                        );
                      },
                      child: const Text(
                        "Cancel Order",
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                )
                : const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Text(
                    "This order is being processed and cannot be modified.",
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
          ],
        ),
      ),
    );
  }

  Future<void> cancelOrder(String orderId) async {
    final response = await http.delete(
      Uri.parse("http://192.168.8.163:32189/api/orders/cancel/$orderId"),
    );

    if (response.statusCode == 200) {
      fetchOrders();
    } else {
      print("❌ Failed to cancel order: ${response.body}");
    }
  }

  List<dynamic> getFilteredOrders() {
    if (selectedTab == "Ongoing") {
      return [
        ...groupedOrders["Order Received"]!,
        ...groupedOrders["Preparing"]!,
        ...groupedOrders["Picked for Delivery"]!,
      ];
    } else {
      return groupedOrders["Delivered"]!;
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredOrders = getFilteredOrders();

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.grey.shade100,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Your Activities",
          style: TextStyle(color: Colors.black),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/customer_home');
          },
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 4),
          buildTabBar(),
          const SizedBox(height: 10),
          Expanded(
            child:
                filteredOrders.isEmpty
                    ? const Center(child: Text("No orders found"))
                    : ListView.builder(
                      itemCount: filteredOrders.length,
                      itemBuilder: (context, index) {
                        return buildOrderCard(filteredOrders[index]);
                      },
                    ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavBarForCustomer(
        currentIndex: 1,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacementNamed(context, '/customer_home');
          } else if (index == 1) {
            Navigator.pushReplacementNamed(context, '/order_list');
          } else if (index == 2) {
            Navigator.pushReplacementNamed(context, '/track_order');
          } else if (index == 3) {
            Navigator.pushReplacementNamed(context, '/customer_profile');
          }
        },
      ),
    );
  }
}
