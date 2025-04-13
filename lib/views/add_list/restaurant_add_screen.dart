import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:mobile_app_flutter/views/components/bottom_nav_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RestaurantAddScreen extends StatefulWidget {
  @override
  _RestaurantAddScreenState createState() => _RestaurantAddScreenState();
}

class _RestaurantAddScreenState extends State<RestaurantAddScreen> {
  String restaurantName = '';
  final TextEditingController itemNameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController detailsController = TextEditingController();
  final TextEditingController timeController = TextEditingController();

  List<File> selectedImages = [];
  bool isPickup = true;
  bool isDelivery = false;
  List<bool> selectedSizes = [false, false, false]; // S, M, F

  Future<void> _selectImage(ImageSource source) async {
    final picker = ImagePicker();
    final XFile? picked = await picker.pickImage(
      source: source,
      imageQuality: 80,
    );
    if (picked != null && selectedImages.length < 3) {
      setState(() {
        selectedImages.add(File(picked.path));
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadRestaurantName();
  }

  Future<void> _loadRestaurantName() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      restaurantName = prefs.getString('restaurantName') ?? '';
    });

    print("Loaded Restaurant Name: $restaurantName");
  }

  Future<void> _submitForm() async {
    final uri = Uri.parse("http://192.168.8.163:5000/api/products/add");
    var request = http.MultipartRequest('POST', uri);
    request.fields['name'] = itemNameController.text;
    request.fields['price'] = priceController.text;
    request.fields['size'] = ["S", "M", "F"]
        .asMap()
        .entries
        .where((e) => selectedSizes[e.key])
        .map((e) => e.value)
        .join(", ");
    request.fields['description'] = detailsController.text;
    request.fields['deliveryType'] = isDelivery ? "Paid" : "Free";
    request.fields['status'] = "Available";
    request.fields['time'] = isDelivery ? timeController.text : "";
    request.fields['restaurantName'] = restaurantName;

    for (File imageFile in selectedImages) {
      final mimeType = lookupMimeType(imageFile.path);
      if (mimeType != null) {
        final mimeSplit = mimeType.split('/');
        final multipart = await http.MultipartFile.fromPath(
          'images',
          imageFile.path,
          contentType: MediaType(mimeSplit[0], mimeSplit[1]),
        );
        request.files.add(multipart);
      }
    }
    print("Submitting Product...");
    print("Name: ${itemNameController.text}");
    print("Price: ${priceController.text}");
    print(
      "Size: ${["S", "M", "F"].asMap().entries.where((e) => selectedSizes[e.key]).map((e) => e.value).join(", ")}",
    );
    print("Description: ${detailsController.text}");
    print("Delivery Type: ${isDelivery ? "Paid" : "Free"}");
    print("Status: Available");
    print("Time: ${isDelivery ? timeController.text : "N/A"}");
    print("Restaurant Name (from SharedPreferences): $restaurantName");
    print("Selected Images: ${selectedImages.length}");
    for (var i = 0; i < selectedImages.length; i++) {
      print("Image $i Path: ${selectedImages[i].path}");
    }

    try {
      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);

      if (!mounted) return;

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("✅ Product added successfully!"),
            backgroundColor: Colors.green,
          ),
        );

        Future.delayed(const Duration(seconds: 1), () {
          Navigator.pushReplacementNamed(context, '/restaurant_home');
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("❌ Failed: ${response.body}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("⚠️ Error: $e"), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: const Text(
          "Add New Item",
          style: TextStyle(color: Colors.black),
        ),
        leading: const BackButton(color: Colors.black),
        actions: [
          TextButton(
            onPressed:
                () => setState(() {
                  itemNameController.clear();
                  priceController.clear();
                  detailsController.clear();
                  timeController.clear();
                  selectedImages.clear();
                  selectedSizes = [false, false, false];
                  isPickup = true;
                  isDelivery = false;
                }),
            child: const Text("RESET", style: TextStyle(color: Colors.orange)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImagePicker(),
            _buildInput("Item Name", itemNameController),
            _buildInput(
              "Price (LKR)",
              priceController,
              keyboard: TextInputType.number,
            ),
            const SizedBox(height: 8),
            const Text("Select Sizes"),
            const SizedBox(height: 6),
            Row(
              children:
                  ["S", "M", "F"].asMap().entries.map((entry) {
                    int index = entry.key;
                    String size = entry.value;
                    return Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: FilterChip(
                        label: Text(size),
                        selected: selectedSizes[index],
                        selectedColor: Colors.orange.shade300,
                        onSelected:
                            (val) => setState(() => selectedSizes[index] = val),
                      ),
                    );
                  }).toList(),
            ),
            const SizedBox(height: 16),
            const Text("Delivery Options"),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSwitch(
                  "Pickup",
                  isPickup,
                  (val) => setState(() => isPickup = val),
                ),
                _buildSwitch(
                  "Delivery",
                  isDelivery,
                  (val) => setState(() => isDelivery = val),
                ),
              ],
            ),
            if (isDelivery)
              _buildInput(
                "Time (mins)",
                timeController,
                keyboard: TextInputType.number,
              ),
            const SizedBox(height: 20),
            const Text(
              "Details",
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: detailsController,
              maxLines: 5,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                hintText: "Enter Details",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitForm,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                minimumSize: const Size.fromHeight(50),
              ),
              child: const Text(
                "SAVE CHANGES",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 2),
    );
  }

  Widget _buildInput(
    String label,
    TextEditingController controller, {
    TextInputType keyboard = TextInputType.text,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        keyboardType: keyboard,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildImagePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Upload Photos (Max 3)",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            ...selectedImages.map(
              (img) => ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  img,
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            if (selectedImages.length < 3)
              GestureDetector(
                onTap: _showImagePickerOptions,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.add_a_photo, size: 30),
                ),
              ),
          ],
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildSwitch(String label, bool value, Function(bool) onChanged) {
    return Row(
      children: [
        Text(label),
        const SizedBox(width: 10),
        Switch(value: value, onChanged: onChanged, activeColor: Colors.orange),
      ],
    );
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      builder:
          (ctx) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.camera),
                  title: const Text("Take Photo"),
                  onTap: () {
                    Navigator.pop(ctx);
                    _selectImage(ImageSource.camera);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo),
                  title: const Text("Choose from Gallery"),
                  onTap: () {
                    Navigator.pop(ctx);
                    _selectImage(ImageSource.gallery);
                  },
                ),
              ],
            ),
          ),
    );
  }
}
