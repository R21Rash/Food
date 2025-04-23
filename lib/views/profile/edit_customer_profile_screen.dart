import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EditCustomerProfileScreen extends StatefulWidget {
  @override
  State<EditCustomerProfileScreen> createState() =>
      _EditCustomerProfileScreenState();
}

class _EditCustomerProfileScreenState extends State<EditCustomerProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    nameController.text = prefs.getString("name") ?? "";
    emailController.text = prefs.getString("email") ?? "";
    phoneController.text = prefs.getString("phone") ?? "";
  }

  Future<void> updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString("user_id");

    if (userId == null) {
      showSnack("User ID not found. Please login again.", isError: true);
      return;
    }

    final url = Uri.parse("http://192.168.150.48:5001/api/auth/updateProfile");

    try {
      final response = await http.put(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "userId": userId,
          "newName": nameController.text.trim(),
          "newEmail": emailController.text.trim(),
          "newPhone": phoneController.text.trim(),
        }),
      );

      final result = jsonDecode(response.body);

      if (response.statusCode == 200) {
        await prefs.setString("name", nameController.text.trim());
        await prefs.setString("email", emailController.text.trim());
        await prefs.setString("phone", phoneController.text.trim());

        showSnack("Profile updated successfully!");
        Navigator.pop(context);
      } else {
        showSnack(result['message'] ?? "Update failed", isError: true);
      }
    } catch (e) {
      showSnack("Error: $e", isError: true);
    } finally {
      setState(() => isLoading = false);
    }
  }

  void showSnack(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.redAccent : Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Edit Profile"),
        centerTitle: true,
        backgroundColor: Colors.orange,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 20),
              const Icon(Icons.account_circle, size: 100, color: Colors.orange),
              const SizedBox(height: 30),

              buildTextField(
                controller: nameController,
                label: "Full Name",
                icon: Icons.person,
                validator:
                    (value) =>
                        value == null || value.isEmpty
                            ? "Enter your name"
                            : null,
              ),

              const SizedBox(height: 20),
              buildTextField(
                controller: emailController,
                label: "Email",
                icon: Icons.email,
                keyboardType: TextInputType.emailAddress,
                validator:
                    (value) =>
                        value == null || !value.contains("@")
                            ? "Enter a valid email"
                            : null,
              ),

              const SizedBox(height: 20),
              buildTextField(
                controller: phoneController,
                label: "Phone Number",
                icon: Icons.phone,
                keyboardType: TextInputType.phone,
                validator:
                    (value) =>
                        value == null || value.length < 9
                            ? "Enter valid phone number"
                            : null,
              ),

              const SizedBox(height: 40),
              ElevatedButton.icon(
                icon:
                    isLoading
                        ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                        : const Icon(Icons.save),
                label: Text(
                  isLoading ? "Saving..." : "Save Changes",
                  style: const TextStyle(fontSize: 16),
                ),
                onPressed: isLoading ? null : updateProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      keyboardType: keyboardType,
      validator: validator,
    );
  }
}
