import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;
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
    fetchPopularItems();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _promptAndFetchLocation(context);
    });
  }

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
    });
  }

  Future<void> fetchPopularItems() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('restaurantName') ?? '';
    final encodedName = Uri.encodeComponent(name);
    final url =
        "http://192.168.8.163:5000/api/products/by-restaurant/$encodedName";

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
            const CircleAvatar(backgroundColor: Colors.grey, radius: 18),
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
                  _infoCard("20", "RUNNING ORDERS"),
                  const SizedBox(width: 10),
                  _infoCard("05", "ORDER REQUEST"),
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
          color: Colors.white,
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
                style: const TextStyle(fontSize: 12, color: Colors.grey),
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
          const SizedBox(height: 20),
          SizedBox(
            height: 150,
            child: LineChart(
              LineChartData(
                borderData: FlBorderData(show: false),
                gridData: FlGridData(show: true),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget:
                          (value, _) => Text(
                            "${value.toInt() + 10}AM",
                            style: TextStyle(fontSize: 10),
                          ),
                      interval: 1,
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget:
                          (value, _) => Text("Rs ${value.toInt()}"),
                      interval: 100,
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
                    spots: [
                      FlSpot(0, 100),
                      FlSpot(1, 500),
                      FlSpot(2, 300),
                      FlSpot(3, 450),
                      FlSpot(4, 600),
                      FlSpot(5, 400),
                    ],
                    isCurved: true,
                    dotData: FlDotData(show: true),
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
