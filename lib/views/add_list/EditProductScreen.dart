import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class EditProductScreen extends StatefulWidget {
  final Map<String, dynamic> product;

  const EditProductScreen({Key? key, required this.product}) : super(key: key);

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  late TextEditingController nameController;
  late TextEditingController priceController;
  late TextEditingController descController;
  late String status;
  late String deliveryType;
  String? imageUrl;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.product['name']);
    priceController = TextEditingController(
      text: widget.product['price'].toString(),
    );
    descController = TextEditingController(text: widget.product['description']);
    status = widget.product['status'] ?? 'Available';
    deliveryType = widget.product['deliveryType'] ?? 'Free';
    imageUrl =
        widget.product['images'] != null && widget.product['images'].isNotEmpty
            ? widget.product['images'][0]
            : null;
  }

  Future<void> updateProduct() async {
    final id = widget.product['_id'];
    final uri = Uri.parse("http://192.168.8.163:5000/api/products/$id");

    final response = await http.put(
      uri,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        'name': nameController.text,
        'price': double.tryParse(priceController.text),
        'description': descController.text,
        'status': status,
        'deliveryType': deliveryType,
      }),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("✅ Product updated"),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("❌ Failed: ${response.body}"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> deleteProduct() async {
    final id = widget.product['_id'];
    final uri = Uri.parse("http://192.168.8.163:5000/api/products/$id");

    final response = await http.delete(uri);

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("🗑️ Product deleted"),
          backgroundColor: Colors.orange,
        ),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("❌ Delete Failed: ${response.body}"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Product"),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            if (imageUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  imageUrl!,
                  height: 200,
                  fit: BoxFit.cover,
                  errorBuilder:
                      (context, error, stackTrace) => Container(
                        height: 200,
                        color: Colors.grey[300],
                        alignment: Alignment.center,
                        child: const Icon(Icons.broken_image, size: 40),
                      ),
                ),
              ),
            const SizedBox(height: 20),
            _buildTextField("Name", nameController),
            _buildTextField(
              "Price",
              priceController,
              keyboardType: TextInputType.number,
            ),
            _buildTextField("Description", descController, maxLines: 4),
            _buildDropdown("Status", ["Available", "Not Available"], status, (
              val,
            ) {
              setState(() => status = val!);
            }),
            _buildDropdown("Delivery Type", ["Free", "Paid"], deliveryType, (
              val,
            ) {
              setState(() => deliveryType = val!);
            }),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: updateProduct,
              icon: const Icon(Icons.save),
              label: const Text("SAVE CHANGES"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: deleteProduct,
              icon: const Icon(Icons.delete, color: Colors.red),
              label: const Text(
                "DELETE PRODUCT",
                style: TextStyle(color: Colors.red),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }

  Widget _buildDropdown(
    String label,
    List<String> options,
    String currentValue,
    ValueChanged<String?> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        value: currentValue,
        items:
            options
                .map((val) => DropdownMenuItem(value: val, child: Text(val)))
                .toList(),
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }
}
