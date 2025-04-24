import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_app_flutter/views/components/bottom_nav_bar_for_customer.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TrackOrderScreen extends StatefulWidget {
  @override
  _TrackOrderScreenState createState() => _TrackOrderScreenState();
}

class _TrackOrderScreenState extends State<TrackOrderScreen> {
  List<String> steps = [
    "Your order has been received",
    "The restaurant is preparing your food",
    "Your order has been picked up for delivery",
    "Order arriving soon!",
  ];

  int currentStep = 0;
  String courierName = "Your Courier";
  Timer? _pollingTimer;
  Timer? _countdownTimer;
  Duration _eta = const Duration(minutes: 20);
  Map<String, dynamic>? latestOrder;
  bool noOrders = false;

  @override
  void initState() {
    super.initState();
    _startCountdown();
    _startPolling();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _startCountdown() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_eta.inSeconds > 0) {
        if (mounted) {
          setState(() {
            _eta = _eta - const Duration(seconds: 1);
          });
        }
      } else {
        timer.cancel();
      }
    });
  }

  void _startPolling() {
    fetchLatestOrderStatus();
    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      if (latestOrder != null && latestOrder!['orderStatus'] == "Delivered") {
        timer.cancel(); // Stop polling if already delivered
      } else {
        await fetchLatestOrderStatus();
      }
    });
  }

  Future<void> fetchLatestOrderStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id') ?? '';
    final encodedUserId = Uri.encodeComponent(userId);
    final url = 'http://192.168.8.163:32189/api/orders/by-user/$encodedUserId';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final orders = jsonDecode(response.body);
        if (orders.isNotEmpty) {
          final latest = orders[0];
          final status = latest['orderStatus'] ?? "Order Received";
          if (mounted) {
            setState(() {
              noOrders = false;
              latestOrder = latest;
              currentStep = _statusToStepIndex(status);
              courierName = "Assigned Courier";
            });
          }
        } else {
          if (mounted) {
            setState(() {
              noOrders = true;
              latestOrder = null;
            });
          }
        }
      } else {
        if (mounted) setState(() => noOrders = true);
      }
    } catch (e) {
      print("❌ Error fetching orders: $e");
      if (mounted) setState(() => noOrders = true);
    }
  }

  int _statusToStepIndex(String status) {
    switch (status) {
      case "Order Received":
        return 0;
      case "Preparing":
        return 1;
      case "Picked for Delivery":
        return 2;
      case "Delivered":
        return 3;
      default:
        return 0;
    }
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }

  Future<void> _markOrderAsCompleted() async {
    final orderId = latestOrder?['_id'];
    if (orderId != null) {
      final url = Uri.parse(
        "http://192.168.8.163:32189/api/orders/mark-complete/$orderId",
      );
      final response = await http.put(url);

      if (response.statusCode == 200) {
        if (mounted) {
          setState(() {
            latestOrder = null;
            currentStep = 0;
            noOrders = true;
          });
          _startPolling(); // Restart polling for next orders
        }
      } else {
        print("❌ Failed to mark order as completed");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("Track Order"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child:
            noOrders
                ? const Center(
                  child: Text(
                    "❌ You have no orders to track.",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                )
                : Column(
                  children: [
                    const Text(
                      "20 mins",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Estimated Delivery Time",
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 20),
                    if (latestOrder != null)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Your Order",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          ...List.generate(latestOrder!['items'].length, (
                            index,
                          ) {
                            final item = latestOrder!['items'][index];
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 4.0,
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.fastfood,
                                    size: 20,
                                    color: Colors.orange,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      "${item['title']} (x${item['quantity']}) - ${item['size'] ?? 'Regular'}",
                                      style: const TextStyle(fontSize: 15),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                          const SizedBox(height: 8),
                          Text(
                            "Total: Rs. ${latestOrder!['totalAmount']}",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.green,
                            ),
                          ),
                          const SizedBox(height: 30),
                        ],
                      ),
                    ...List.generate(
                      steps.length,
                      (index) =>
                          _buildStep(index, steps[index], index == currentStep),
                    ),
                    const Spacer(),
                    _buildCourierInfo(),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed:
                          currentStep == 3
                              ? _markOrderAsCompleted
                              : () => Navigator.pushReplacementNamed(
                                context,
                                '/customer_home',
                              ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        minimumSize: const Size(double.infinity, 48),
                      ),
                      child: Text(
                        currentStep == 3 ? "Order Received" : "Return Home",
                      ),
                    ),
                  ],
                ),
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

  Widget _buildStep(int index, String text, bool isCurrent) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Icon(
              Icons.circle,
              color:
                  index <= currentStep ? Colors.orange : Colors.grey.shade300,
              size: 16,
            ),
            if (index != steps.length - 1)
              Container(height: 30, width: 2, color: Colors.grey.shade300),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 2.0),
            child: Text(
              text,
              style: TextStyle(
                color: isCurrent ? Colors.black : Colors.grey,
                fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCourierInfo() {
    final initials =
        courierName
            .split(" ")
            .map((e) => e.isNotEmpty ? e[0].toUpperCase() : '')
            .take(2)
            .join();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: Colors.orange,
            child: Text(
              initials,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              courierName,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.phone, color: Colors.orange),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.message, color: Colors.orange),
          ),
        ],
      ),
    );
  }
}