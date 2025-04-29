import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Screen for editing an existing order
class EditOrderScreen extends StatefulWidget {
  final Map<String, dynamic> order; // Order data to be edited

  const EditOrderScreen({super.key, required this.order});

  @override
  State<EditOrderScreen> createState() => _EditOrderScreenState();
}

class _EditOrderScreenState extends State<EditOrderScreen> {
  late TextEditingController _locationController; // Controller for delivery address input
  late List<TextEditingController> _sizeControllers; // Controllers for item size inputs

  // Initialize controllers with order data
  @override
  void initState() {
    super.initState();
    // Set initial address from order data
    _locationController = TextEditingController(
      text: widget.order['deliveryLocation']['address'] ?? '',
    );
    // Create controllers for each item's size
    _sizeControllers = List.generate(
      widget.order['items'].length,
      (index) => TextEditingController(
        text: widget.order['items'][index]['size'] ?? '',
      ),
    );
  }

  // Send updated order data to the server
  Future<void> updateOrder() async {
    // Prepare updated items with modified sizes
    final updatedItems = List.generate(widget.order['items'].length, (index) {
      final item = widget.order['items'][index];
      return {
        "title": item["title"],
        "price": item["price"],
        "quantity": item["quantity"],
        "image": item["image"],
        "restaurantName": item["restaurantName"],
        "size": _sizeControllers[index].text.trim(),
      };
    });

    // Construct updated order payload
    final updatedOrder = {
      "items": updatedItems,
      "deliveryLocation": {
        "lat": widget.order["deliveryLocation"]["lat"],
        "lng": widget.order["deliveryLocation"]["lng"],
        "address": _locationController.text.trim(),
      },
    };

    // Make HTTP PUT request to update order
    final response = await http.put(
      Uri.parse(
        "http://192.168.8.163:32189/api/orders/edit/${widget.order['_id']}",
      ),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(updatedOrder),
    );

    // Handle response
    if (response.statusCode == 200) {
      Navigator.pop(context, true); // Return success
    } else {
      // Show error message if update fails
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to update order: ${response.body}")),
      );
    }
  }

  // Build the UI for editing order
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Order"),
        backgroundColor: Colors.orange,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Section header for item sizes
          const Text(
            "Update Sizes",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          // Generate input fields for each item's size
          ...List.generate(widget.order['items'].length, (index) {
            final item = widget.order['items'][index];
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Display item title
                Text(
                  "Item: ${item['title']}",
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 5),
                // Input field for item size
                TextField(
                  controller: _sizeControllers[index],
                  decoration: const InputDecoration(
                    labelText: "Size",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            );
          }),

          // Section header for delivery address
          const SizedBox(height: 20),
          const Text(
            "Update Address",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          // Input field for delivery address
          TextField(
            controller: _locationController,
            maxLines: 2,
            decoration: const InputDecoration(
              labelText: "Delivery Address",
              border: OutlineInputBorder(),
            ),
          ),

          // Save button
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: updateOrder,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: const Text("Save Changes", style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }
}
