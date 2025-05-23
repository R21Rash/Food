import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_app_flutter/common-const/api_constants.dart';
import 'package:mobile_app_flutter/views/components/bottom_nav_bar_for_customer.dart';
import 'package:mobile_app_flutter/views/components/cart_button.dart';
import 'package:mobile_app_flutter/views/components/cart_modal.dart';
import 'package:mobile_app_flutter/views/item/customerItem_screen.dart';
import 'package:mobile_app_flutter/views/item/restaurant_details_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeCustomerScreen extends StatefulWidget {
  @override
  _HomeCustomerScreenState createState() => _HomeCustomerScreenState();
}

class _HomeCustomerScreenState extends State<HomeCustomerScreen> {
  String greetingMessage = "Hey there!";
  List<Map<String, dynamic>> cartItems = [];
  List<Map<String, dynamic>> products = [];

  @override
  void initState() {
    super.initState();
    loadGreeting();
    fetchProducts();
  }

  Future<void> loadGreeting() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('name') ?? "User";
    final hour = DateTime.now().hour;
    String greeting =
        hour < 12
            ? "Good Morning"
            : hour < 17
            ? "Good Afternoon"
            : "Good Evening";
    setState(() {
      greetingMessage = "Hey $name, $greeting!";
    });
  }

  Future<void> fetchProducts() async {
    const String apiUrl = "$baseURL:31201/api/products/all";
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          products = List<Map<String, dynamic>>.from(data);
        });
      } else {
        print("Failed to fetch products: ${response.body}");
      }
    } catch (e) {
      print("Error fetching products: $e");
    }
  }

  TextEditingController searchController = TextEditingController();
  String searchQuery = "";

  @override
  Widget build(BuildContext context) {
    final filteredCategories =
        products
            .where(
              (p) => p['name'].toString().toLowerCase().contains(searchQuery),
            )
            .map((p) => p['name'])
            .toSet()
            .toList();

    final filteredRestaurants =
        products
            .where(
              (p) =>
                  p['restaurantName'] != null &&
                  p['images'] != null &&
                  p['images'].isNotEmpty &&
                  p['restaurantName'].toString().toLowerCase().contains(
                    searchQuery,
                  ),
            )
            .map((p) => p['restaurantName'])
            .toSet()
            .map(
              (name) => products.firstWhere((p) => p['restaurantName'] == name),
            )
            .toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: PopupMenuButton<String>(
          icon: const Icon(Icons.menu, color: Colors.black),
          onSelected: (value) {},
          itemBuilder: (context) => const [],
        ),
        actions: [
          CartButton(
            cartItemCount: cartItems.length,
            onCartPressed:
                () => CartModal.showCartModal(context, cartItems, setState),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: TextSpan(
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  children: [
                    const TextSpan(text: "Hey "),
                    TextSpan(
                      text: greetingMessage
                          .split(',')[0]
                          .replaceAll('Hey ', ''),
                      style: const TextStyle(color: Colors.orange),
                    ),
                    TextSpan(
                      text: ", ${greetingMessage.split(',').last.trim()}",
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 15),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextField(
                  controller: searchController,
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value.toLowerCase();
                    });
                  },
                  decoration: const InputDecoration(
                    icon: Icon(Icons.search, color: Colors.grey),
                    hintText: "Search dishes, restaurants",
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _sectionTitle("All Categories"),
              SizedBox(
                height: 130,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: filteredCategories.length,
                  itemBuilder: (context, index) {
                    final category = products.firstWhere(
                      (p) => p['name'] == filteredCategories[index],
                    );
                    return _categoryCard(product: category, context: context);
                  },
                ),
              ),
              const SizedBox(height: 20),
              _sectionTitle("Open Restaurants"),
              filteredRestaurants.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : Column(
                    children:
                        filteredRestaurants
                            .map((restaurant) => _restaurantCard(restaurant))
                            .toList(),
                  ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavBarForCustomer(
        currentIndex: 0, // Home is index 0
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacementNamed(context, '/customer_home');
          } else if (index == 1) {
            Navigator.pushReplacementNamed(
              context,
              '/order_list',
            ); // 👈 your order list screen
          } else if (index == 2) {
            Navigator.pushReplacementNamed(context, '/track_order');
          } else if (index == 3) {
            Navigator.pushReplacementNamed(context, '/customer_profile');
          }
        },
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const Text(
            "See All >",
            style: TextStyle(
              fontSize: 14,
              color: Colors.orange,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _categoryCard({
    required Map<String, dynamic> product,
    required BuildContext context,
  }) {
    final String title = product['name'];
    final String image = product['images']?[0] ?? "";

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CustomerItemScreen(product: product),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(right: 15),
        child: Column(
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    blurRadius: 5,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.network(image, fit: BoxFit.cover),
              ),
            ),
            const SizedBox(height: 5),
            Text(
              title,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _restaurantCard(Map<String, dynamic> restaurant) {
    final name = restaurant['restaurantName'] ?? 'Unknown';
    final desc = restaurant['description'] ?? 'No description';
    final delivery = restaurant['deliveryType'] ?? 'Free';
    final time = restaurant['time'] ?? '20 min';
    final image =
        (restaurant['images'] != null && restaurant['images'].isNotEmpty)
            ? restaurant['images'][0]
            : "https://via.placeholder.com/300";

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 5,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
              ),
              child: Image.network(
                image,
                width: double.infinity,
                height: 150,
                fit: BoxFit.cover,
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (_) => RestaurantDetailsScreen(restaurantName: name),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      desc,
                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.orange, size: 18),
                        const Text(
                          " 4.7",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Icon(
                          Icons.delivery_dining,
                          color: Colors.orange,
                          size: 18,
                        ),
                        Text(
                          " $delivery",
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(width: 10),
                        const Icon(
                          Icons.access_time,
                          color: Colors.orange,
                          size: 18,
                        ),
                        Text(" $time", style: const TextStyle(fontSize: 14)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}