import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:mobile_app_flutter/common-const/api_constants.dart';

class EditOrderScreen extends StatefulWidget {
  final Map<String, dynamic> order;

  const EditOrderScreen({super.key, required this.order});

  @override
  State<EditOrderScreen> createState() => _EditOrderScreenState();
}

class _EditOrderScreenState extends State<EditOrderScreen> {
  late TextEditingController _locationController;
  late List<TextEditingController> _sizeControllers;

  @override
  void initState() {
    super.initState();
    _locationController = TextEditingController(
      text: widget.order['deliveryLocation']['address'] ?? '',
    );
    _sizeControllers = List.generate(
      widget.order['items'].length,
      (index) => TextEditingController(
        text: widget.order['items'][index]['size'] ?? '',
      ),
    );
  }

  Future<void> updateOrder() async {
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

    final updatedOrder = {
      "items": updatedItems,
      "deliveryLocation": {
        "lat": widget.order["deliveryLocation"]["lat"],
        "lng": widget.order["deliveryLocation"]["lng"],
        "address": _locationController.text.trim(),
      },
    };

    final response = await http.put(
      Uri.parse("$baseURL:32189/api/orders/edit/${widget.order['_id']}"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(updatedOrder),
    );

    if (response.statusCode == 200) {
      Navigator.pop(context, true); // success
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to update order: ${response.body}")),
      );
    }
  }

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
          const Text(
            "Update Sizes",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          ...List.generate(widget.order['items'].length, (index) {
            final item = widget.order['items'][index];
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Item: ${item['title']}",
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 5),
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

          const SizedBox(height: 20),
          const Text(
            "Update Address",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _locationController,
            maxLines: 2,
            decoration: const InputDecoration(
              labelText: "Delivery Address",
              border: OutlineInputBorder(),
            ),
          ),

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