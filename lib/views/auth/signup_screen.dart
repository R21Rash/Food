import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:mobile_app_flutter/views/auth/signup_success.dart';

class SignupScreen extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  String? selectedRole;
  final List<String> roles = ["Customer", "Restaurant", "Delivery"];

  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController restaurantNameController =
      TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  final String backendUrl = "http://192.168.150.48:5001/api/auth/signup";

  @override
  Widget build(BuildContext context) {
    final isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

    return Scaffold(
      backgroundColor: const Color(0xFF1E1E2D),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              Container(height: 280, color: const Color(0xFF1E1E2D)),

              // ✅ Only show welcome message when keyboard is not open
              if (!isKeyboardOpen)
                const Positioned(
                  top: 100,
                  left: 0,
                  right: 0,
                  child: Column(
                    children: [
                      Text(
                        "Sign Up",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        "Create an account to get started",
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
                ),

              // ✅ White animated sliding container
              Align(
                alignment: Alignment.bottomCenter,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height:
                      isKeyboardOpen
                          ? constraints.maxHeight
                          : constraints.maxHeight * 0.75,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: SingleChildScrollView(
                      reverse: true,
                      padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).viewInsets.bottom,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "ROLE",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: DropdownButtonFormField<String>(
                              value: selectedRole,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                              ),
                              hint: const Text(
                                "Choose your role",
                                style: TextStyle(color: Colors.grey),
                              ),
                              icon: const Icon(
                                Icons.keyboard_arrow_down_rounded,
                              ),
                              items:
                                  roles.map((role) {
                                    return DropdownMenuItem(
                                      value: role,
                                      child: Text(
                                        role,
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                    );
                                  }).toList(),
                              onChanged:
                                  (value) =>
                                      setState(() => selectedRole = value),
                            ),
                          ),
                          const SizedBox(height: 15),
                          if (selectedRole == "Restaurant")
                            buildTextField(
                              "Restaurant Name",
                              "Enter restaurant name",
                              controller: restaurantNameController,
                            )
                          else
                            buildTextField(
                              "Full Name",
                              "Enter full name",
                              controller: fullNameController,
                            ),
                          buildTextField(
                            "Email",
                            "example@gmail.com",
                            controller: emailController,
                          ),
                          buildTextField(
                            "Phone Number",
                            "Enter your phone number",
                            controller: phoneController,
                          ),
                          buildTextField(
                            "Password",
                            "********",
                            isPassword: true,
                            controller: passwordController,
                          ),
                          buildTextField(
                            "Confirm Password",
                            "********",
                            isPassword: true,
                            controller: confirmPasswordController,
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 15,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onPressed: registerUser,
                              child: const Text(
                                "SIGN UP",
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          ),
                          const SizedBox(height: 15),
                          Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text("Already have an account? "),
                                TextButton(
                                  onPressed:
                                      () => Navigator.pushNamed(
                                        context,
                                        '/login',
                                      ),
                                  child: const Text(
                                    "LOG IN",
                                    style: TextStyle(
                                      color: Colors.orange,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget buildTextField(
    String label,
    String hint, {
    bool isPassword = false,
    TextEditingController? controller,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 5),
        TextField(
          obscureText: isPassword,
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.grey[200],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            suffixIcon: isPassword ? const Icon(Icons.visibility_off) : null,
          ),
        ),
        const SizedBox(height: 15),
      ],
    );
  }

  Future<void> registerUser() async {
    try {
      final name =
          selectedRole == "Restaurant"
              ? restaurantNameController.text
              : fullNameController.text;

      final response = await http.post(
        Uri.parse(backendUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "role": selectedRole,
          "fullName": selectedRole != "Restaurant" ? name : null,
          "restaurantName": selectedRole == "Restaurant" ? name : null,
          "email": emailController.text,
          "phone": phoneController.text,
          "password": passwordController.text,
        }),
      );

      if (response.statusCode == 201) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => SignupSuccessScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Signup Failed: ${response.body}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Connection Failed: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
