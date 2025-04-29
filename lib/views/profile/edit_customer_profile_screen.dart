import 'package:flutter/material.dart';
import 'package:mobile_app_flutter/common-const/api_constants.dart';
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
  String? role;

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      nameController.text = prefs.getString("name") ?? "";
      emailController.text = prefs.getString("email") ?? "";
      phoneController.text = prefs.getString("phone") ?? "";
      role = prefs.getString("role");
    });
  }

  Future<void> updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString("user_id");
    final role = prefs.getString("role");

    if (userId == null) {
      showSnack("User ID not found. Please login again.", isError: true);
      return;
    }

    final url = Uri.parse("$baseURL:30409/api/auth/updateProfile");

    try {
      final response = await http.put(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "userId": userId,
          "newName": role == "Restaurant" ? null : nameController.text.trim(),
          "newEmail": emailController.text.trim(),
          "newPhone": phoneController.text.trim(),
        }),
      );

      final result = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (role != "Restaurant") {
          await prefs.setString("name", nameController.text.trim());
        }
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
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: EdgeInsets.all(20),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        foregroundColor: Colors.black,
        centerTitle: true,
        title: const Text(
          "Edit Profile",
          style: TextStyle(fontWeight: FontWeight.normal),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body:
          role == null
              ? Center(
                child: CircularProgressIndicator(),
              ) // Wait till role loads
              : SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.orange.withOpacity(0.1),
                            child: const Icon(
                              Icons.person,
                              size: 60,
                              color: Colors.orange,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              role ?? '',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),

                      // 🔥 Only show Full Name field if NOT restaurant
                      if (role != "Restaurant")
                        buildTextField(
                          controller: nameController,
                          label: "Full Name",
                          icon: Icons.person_outline,
                          validator:
                              (value) =>
                                  value == null || value.isEmpty
                                      ? "Enter your name"
                                      : null,
                        ),

                      if (role != "Restaurant") const SizedBox(height: 20),

                      // Email
                      buildTextField(
                        controller: emailController,
                        label: "Email",
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        validator:
                            (value) =>
                                value == null || !value.contains("@")
                                    ? "Enter a valid email"
                                    : null,
                      ),

                      const SizedBox(height: 20),

                      // Phone
                      buildTextField(
                        controller: phoneController,
                        label: "Phone Number",
                        icon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                        validator:
                            (value) =>
                                value == null || value.length < 9
                                    ? "Enter valid phone number"
                                    : null,
                      ),

                      const SizedBox(height: 40),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[700],
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 6,
                spreadRadius: 2,
              ),
            ],
          ),
          child: TextFormField(
            controller: controller,
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(15),
              prefixIcon: Icon(icon, color: Colors.grey[600]),
              errorStyle: const TextStyle(fontSize: 12),
            ),
            keyboardType: keyboardType,
            validator: validator,
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ],
    );
  }
}
