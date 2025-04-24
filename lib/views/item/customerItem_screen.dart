import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_app_flutter/views/components/cart_button.dart';
import 'package:mobile_app_flutter/views/components/cart_modal.dart';

class CustomerItemScreen extends StatefulWidget {
  final Map<String, dynamic> product;

  const CustomerItemScreen({Key? key, required this.product}) : super(key: key);

  @override
  _CustomerItemScreenState createState() => _CustomerItemScreenState();
}

class _CustomerItemScreenState extends State<CustomerItemScreen> {
  List<Map<String, dynamic>> cartItems = [];
  List<Map<String, dynamic>> relatedProducts = [];

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  String? selectedSize;
  void addToCart() {
    if (selectedSize == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select a size."),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() {
      cartItems.add({
        "title": widget.product['name'],
        "image": widget.product['images'][0],
        "price": widget.product['price'].toString(),
        "quantity": 1,
        "restaurantName": widget.product['restaurantName'],
        "size": selectedSize,
      });
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("${widget.product['name']} added to cart!"),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> fetchProducts() async {
    const String apiUrl = "http://192.168.8.163:31201/api/products/all";
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          relatedProducts = List<Map<String, dynamic>>.from(data);
        });
      } else {
        print("Failed to fetch related products: ${response.body}");
      }
    } catch (e) {
      print("Error fetching related products: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final image =
        product['images'] != null && product['images'].isNotEmpty
            ? product['images'][0]
            : "https://via.placeholder.com/300";

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Details", style: TextStyle(color: Colors.black)),
        centerTitle: true,
        actions: [
          CartButton(
            cartItemCount: cartItems.length,
            onCartPressed:
                () => CartModal.showCartModal(context, cartItems, setState),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.network(
                image,
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Chip(
                  label: Text(product['restaurantName'] ?? 'Restaurant'),
                  backgroundColor: Colors.white,
                  shape: StadiumBorder(side: BorderSide(color: Colors.grey)),
                ),
                const SizedBox(width: 10),
                Chip(
                  label: Text("Open Now"),
                  labelStyle: TextStyle(color: Colors.white),
                  backgroundColor: Colors.green,
                ),
                const Spacer(),
                IconButton(
                  icon: Icon(Icons.favorite_border, color: Colors.grey),
                  onPressed: () {},
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              product['name'],
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            Text(
              product['description'] ?? "No description available.",
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.star, color: Colors.orange, size: 18),
                Text(" 4.7", style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(width: 10),
                Icon(Icons.delivery_dining, color: Colors.orange, size: 18),
                Text(
                  " ${product['deliveryType']}",
                  style: TextStyle(fontSize: 14),
                ),
                const SizedBox(width: 10),
                Icon(Icons.access_time, color: Colors.orange, size: 18),
                Text(
                  " ${product['time'] ?? 'N/A'}",
                  style: TextStyle(fontSize: 14),
                ),
                const SizedBox(width: 10),
                Icon(Icons.price_change_sharp, color: Colors.orange, size: 18),
                Text(
                  " ${product['price']} LKR",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              "Size",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              children:
                  product['size']
                      .toString()
                      .split(',')
                      .map<Widget>((size) => _sizeOption(size.trim()))
                      .toList(),
            ),
            const SizedBox(height: 20),
            const Text(
              "Ingredients",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                _ingredientIcon(Icons.local_pizza),
                _ingredientIcon(Icons.rice_bowl),
                _ingredientIcon(Icons.local_dining),
                _ingredientIcon(Icons.fastfood),
              ],
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: Icon(Icons.shopping_cart),
                label: Text(
                  "Add to Cart",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                onPressed: addToCart,
              ),
            ),
            const SizedBox(height: 30),

            ///  section
            if (relatedProducts.isNotEmpty) ...[
              const Text(
                "More Items",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              ...relatedProducts.take(3).map((item) {
                final itemImage =
                    item['images'] != null && item['images'].isNotEmpty
                        ? item['images'][0]
                        : 'https://via.placeholder.com/300';
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        itemImage,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      ),
                    ),
                    title: Text(item['name']),
                    subtitle: Text('${item['price']} LKR'),
                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      size: 14,
                      color: Colors.grey,
                    ),
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CustomerItemScreen(product: item),
                        ),
                      );
                    },
                  ),
                );
              }).toList(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _sizeOption(String size) {
    final isSelected = selectedSize == size;

    return ChoiceChip(
      label: Text(
        size,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: isSelected ? Colors.white : Colors.orange,
        ),
      ),
      selected: isSelected,
      selectedColor: Colors.orange,
      backgroundColor: Colors.white,
      shape: StadiumBorder(side: BorderSide(color: Colors.orange)),
      onSelected: (_) {
        setState(() {
          selectedSize = size;
        });
      },
    );
  }

  Widget _ingredientIcon(IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: CircleAvatar(
        backgroundColor: Colors.orange[100],
        radius: 20,
        child: Icon(icon, color: Colors.orange, size: 20),
      ),
    );
  }
}