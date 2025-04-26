import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_app_flutter/common-const/api_constants.dart';
import 'package:mobile_app_flutter/views/components/bottom_nav_bar.dart';
import 'package:mobile_app_flutter/views/components/location_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

class RestaurantHomeScreen extends StatefulWidget {
  @override
  _RestaurantHomeScreenState createState() => _RestaurantHomeScreenState();
}

class _RestaurantHomeScreenState extends State<RestaurantHomeScreen> {
  String? selectedDuration = "Daily";
  String greetingMessage = "Hey there!";
  final List<String> durations = ["Daily", "Weekly", "Monthly"];
  List<Map<String, dynamic>> popularItems = [];

  @override
  void initState() {
    super.initState();
    loadGreeting();
    fetchOrderStats();
    fetchPopularItems();
    fetchRevenueChartData();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<LocationProvider>(
        context,
        listen: false,
      ).fetchCurrentLocation();
    });
  }

  String? restaurantInitial = "";
  Future<void> loadGreeting() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('restaurantName') ?? "Restaurant";

    final hour = DateTime.now().hour;
    String greeting;
    if (hour < 12) {
      greeting = "Good Morning";
    } else if (hour < 17) {
      greeting = "Good Afternoon";
    } else {
      greeting = "Good Evening";
    }

    setState(() {
      greetingMessage = "Hey, $name, $greeting!";
      restaurantInitial = name.isNotEmpty ? name[0].toUpperCase() : "R";
    });
  }

  int runningOrders = 0;
  int orderRequests = 0;
  double totalIncome = 0.0;

  Future<void> fetchOrderStats() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('restaurantName') ?? '';
    final encodedName = Uri.encodeComponent(name);
    final url = "$baseURL:32189/api/orders/by-restaurant/$encodedName";

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        int running = 0;
        int requests = 0;
        double income = 0.0;

        for (var order in data) {
          final status = order['orderStatus'];
          final amountStr = order['totalAmount'] ?? "0";
          final amount = double.tryParse(amountStr) ?? 0.0;

          if (status == "Preparing" || status == "Picked for Delivery") {
            running++;
          } else if (status == "Order Received") {
            requests++;
          }

          income += amount;
        }
        print("💰 Total Income Fetched: $income");
        setState(() {
          runningOrders = running;
          orderRequests = requests;
          totalIncome = income;
        });
      }
    } catch (e) {
      print("⚠️ Error fetching order stats: $e");
    }
  }

  List<FlSpot> revenueSpots = [];
  Map<String, double> revenueByDay = {};

  Future<void> fetchRevenueChartData() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('restaurantName') ?? '';
    final encodedName = Uri.encodeComponent(name);
    final url = "$baseURL:32189/api/orders/by-restaurant/$encodedName";

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        Map<String, double> tempMap = {};

        for (var order in data) {
          final amountStr = order["totalAmount"] ?? "0";
          final amount = double.tryParse(amountStr) ?? 0.0;
          final dateStr = order["createdAt"]; // ISO String
          final date = DateTime.tryParse(dateStr);

          if (date != null) {
            final day = "${date.year}-${date.month}-${date.day}";
            tempMap[day] = (tempMap[day] ?? 0) + amount;
          }
        }

        final sortedKeys = tempMap.keys.toList()..sort();
        List<FlSpot> spots = [];
        for (int i = 0; i < sortedKeys.length; i++) {
          spots.add(FlSpot(i.toDouble(), tempMap[sortedKeys[i]]!));
        }

        setState(() {
          revenueSpots = spots;
          revenueByDay = tempMap;
        });
      }
    } catch (e) {
      print("❌ Error loading revenue chart: $e");
    }
  }

  Future<void> fetchPopularItems() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('restaurantName') ?? '';
    final encodedName = Uri.encodeComponent(name);
    final url = "$baseURL:31201/api/products/by-restaurant/$encodedName";

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          popularItems = List<Map<String, dynamic>>.from(data);
        });
      }
    } catch (e) {
      print("\u26a0\ufe0f Error fetching popular items: $e");
    }
  }

  Future<void> _promptAndFetchLocation(BuildContext context) async {
    final locationProvider = Provider.of<LocationProvider>(
      context,
      listen: false,
    );

    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text("Enable Location"),
            content: const Text(
              "We need your location to assign delivery agents. Proceed?",
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  locationProvider.fetchCurrentLocation();
                },
                child: const Text("Allow"),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final locationProvider = Provider.of<LocationProvider>(context);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        automaticallyImplyLeading: false,

        backgroundColor: Colors.grey[100],
        elevation: 0,
        title: Row(
          children: [
            const Icon(Icons.menu, color: Colors.black),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    greetingMessage,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    locationProvider.currentAddress,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            CircleAvatar(
              backgroundColor: Colors.orange,
              radius: 18,
              child: Text(
                restaurantInitial ?? "R",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Row(
                children: [
                  _infoCard(runningOrders.toString(), "RUNNING ORDERS"),
                  const SizedBox(width: 10),
                  _infoCard(orderRequests.toString(), "ORDER REQUESTS"),
                ],
              ),
              const SizedBox(height: 20),
              _buildRevenueCard(),
              const SizedBox(height: 20),
              _buildReviewCard(),
              const SizedBox(height: 20),
              _buildPopularItems(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(currentIndex: 0),
    );
  }

  Widget _infoCard(String count, String label) {
    return Expanded(
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          color: Colors.orange[300],
          borderRadius: BorderRadius.circular(15),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                count,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                label,
                style: const TextStyle(fontSize: 12, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRevenueCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                "Total Revenue",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const Spacer(),
              DropdownButton<String>(
                value: selectedDuration,
                icon: const Icon(Icons.keyboard_arrow_down),
                underline: const SizedBox(),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedDuration = newValue;
                  });
                },
                items:
                    durations.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
              ),
              const SizedBox(width: 8),
              const Text("See Details", style: TextStyle(color: Colors.orange)),
            ],
          ),
          const SizedBox(height: 8),

          /// 💰 Display Total Income
          Text(
            "LKR ${totalIncome.toStringAsFixed(2)}",
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.orange,
            ),
          ),

          const SizedBox(height: 20),

          /// 📊 Revenue Chart
          revenueSpots.isEmpty
              ? const Center(child: Text("No revenue data available"))
              : SizedBox(
                height: 150,
                child: LineChart(
                  LineChartData(
                    borderData: FlBorderData(show: false),

                    titlesData: FlTitlesData(
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, _) {
                            final index = value.toInt();
                            final keys = revenueByDay.keys.toList()..sort();
                            if (index < keys.length) {
                              return Text(keys[index].split("-").last);
                            }
                            return const Text("");
                          },
                          interval: 1,
                        ),
                      ),

                      topTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                    ),
                    lineBarsData: [
                      LineChartBarData(
                        spots: revenueSpots,
                        isCurved: true,
                        dotData: FlDotData(
                          show: true,
                          getDotPainter:
                              (spot, percent, bar, index) => FlDotCirclePainter(
                                radius: 2,
                                color: Colors.orange,
                                strokeWidth: 0,
                              ),
                        ),
                        color: Colors.orange,
                        belowBarData: BarAreaData(
                          show: true,
                          color: Colors.orange.withOpacity(0.3),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
        ],
      ),
    );
  }

  Widget _buildReviewCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: const [
          Icon(Icons.star, color: Colors.orange),
          SizedBox(width: 5),
          Text("4.9", style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(width: 5),
          Text("Total 20 Reviews"),
          Spacer(),
          Text("See All Reviews", style: TextStyle(color: Colors.orange)),
        ],
      ),
    );
  }

  Widget _buildPopularItems() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text(
              "Popular Items This Week",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text("See All", style: TextStyle(color: Colors.orange)),
          ],
        ),
        const SizedBox(height: 10),
        popularItems.isEmpty
            ? const Text("No items found")
            : Column(
              children:
                  popularItems.map((item) {
                    final name = item['name'] ?? 'Unnamed';
                    final imageUrl =
                        (item['images'] != null && item['images'].isNotEmpty)
                            ? item['images'][0]
                            : 'https://via.placeholder.com/150';

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                imageUrl,
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                                errorBuilder:
                                    (context, error, stackTrace) => Container(
                                      width: 60,
                                      height: 60,
                                      color: Colors.grey[300],
                                      child: Icon(Icons.image_not_supported),
                                    ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
            ),
      ],
    );
  }
}
