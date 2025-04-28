import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_app_flutter/common-const/api_constants.dart';
import 'package:mobile_app_flutter/views/components/bottom_nav_bar_for_customer.dart';
import 'package:mobile_app_flutter/views/item/customerItem_screen.dart';

// Screen to display details of a selected restaurant and its products (menu items)
class RestaurantDetailsScreen extends StatefulWidget {
  final String restaurantName;

  const RestaurantDetailsScreen({Key? key, required this.restaurantName})
    : super(key: key);

  @override
  State<RestaurantDetailsScreen> createState() =>
      _RestaurantDetailsScreenState();
}

class _RestaurantDetailsScreenState extends State<RestaurantDetailsScreen> {
  List<Map<String, dynamic>> products = []; // List to hold restaurant products
  bool isLoading = true; // Loading state

  @override
  void initState() {
    super.initState();
    fetchRestaurantProducts(); // Fetch products when the screen loads
  }

  // Function to fetch products of a restaurant from the backend
  Future<void> fetchRestaurantProducts() async {
    final url =
        "$baseURL:31201/api/products/by-restaurant/${Uri.encodeComponent(widget.restaurantName)}";
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          products = List<Map<String, dynamic>>.from(data);
          isLoading = false;
        });
      } else {
        print("Error: ${response.body}");
        setState(() => isLoading = false);
      }
    } catch (e) {
      print("Fetch error: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get first product to use its image as the restaurant image
    final restaurant = products.isNotEmpty ? products[0] : null;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(widget.restaurantName), // Set restaurant name as title
        backgroundColor: Colors.orange,
        leading: BackButton(
          onPressed: () => Navigator.pop(context),
        ), // Back button
      ),
      body:
          isLoading
              ? const Center(
                child: CircularProgressIndicator(),
              ) // Show loader while fetching data
              : products.isEmpty
              ? const Center(
                child: Text("No products found"),
              ) // Show if no products
              : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Show restaurant's main image if available
                    if (restaurant != null &&
                        restaurant['images'] != null &&
                        restaurant['images'].isNotEmpty)
                      ClipRRect(
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(15),
                          bottomRight: Radius.circular(15),
                        ),
                        child: Image.network(
                          restaurant['images'][0],
                          width: double.infinity,
                          height: 200,
                          fit: BoxFit.cover,
                        ),
                      ),
                    const SizedBox(height: 20),

                    // Menu title
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        "Menu",
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // List of menu items
                    ListView.builder(
                      itemCount: products.length,
                      shrinkWrap: true,
                      physics:
                          const NeverScrollableScrollPhysics(), // Disable scroll inside list
                      itemBuilder: (context, index) {
                        final item = products[index];
                        final img =
                            item['images']?.isNotEmpty == true
                                ? item['images'][0]
                                : 'https://via.placeholder.com/300'; // Placeholder image
                        return ListTile(
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              img,
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                            ),
                          ),
                          title: Text(item['name']),
                          subtitle: Text("LKR ${item['price']}"),
                          trailing: const Icon(
                            Icons.arrow_forward_ios,
                            size: 14,
                          ),
                          onTap: () {
                            // Navigate to item details screen
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (_) => CustomerItemScreen(product: item),
                              ),
                            );
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
      // Bottom navigation bar
      bottomNavigationBar: BottomNavBarForCustomer(
        currentIndex: 0, // Current index (Home)
        onTap: (index) {
          if (index == 1) {
            Navigator.pushReplacementNamed(context, '/track_order');
          } else if (index == 2) {
            Navigator.pushReplacementNamed(context, '/customer_profile');
          }
        },
      ),
    );
  }
}
