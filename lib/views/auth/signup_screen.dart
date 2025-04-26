import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_app_flutter/common-const/api_constants.dart';
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
  final TextEditingController phoneController = TextEditingController(
    text: "+94",
  );

  final String backendUrl = "$baseURL:30409/api/auth/signup";
  final _formKey = GlobalKey<FormState>();

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

              Align(
                alignment: Alignment.bottomCenter,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height:
                      isKeyboardOpen
                          ? constraints.maxHeight
                          : constraints.maxHeight * 0.85,
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
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "SELECT YOUR ROLE",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children:
                                  roles.map((role) {
                                    return Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 4,
                                        ),
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                selectedRole == role
                                                    ? Colors.orange
                                                    : Colors.grey[200],
                                            foregroundColor:
                                                selectedRole == role
                                                    ? Colors.white
                                                    : Colors.black,
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 12,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                          ),
                                          onPressed:
                                              () => setState(
                                                () => selectedRole = role,
                                              ),
                                          child: Text(role),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                            ),
                            const SizedBox(height: 20),

                            if (selectedRole == "Restaurant")
                              buildTextField(
                                "Restaurant Name",
                                "Enter restaurant name",
                                controller: restaurantNameController,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter restaurant name';
                                  }
                                  return null;
                                },
                              )
                            else if (selectedRole != null)
                              buildTextField(
                                selectedRole == "Customer"
                                    ? "Full Name"
                                    : "Driver Name",
                                "Enter your full name",
                                controller: fullNameController,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your name';
                                  }
                                  return null;
                                },
                              ),

                            buildTextField(
                              "Email",
                              "example@gmail.com",
                              controller: emailController,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your email';
                                }
                                if (!RegExp(
                                  r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                                ).hasMatch(value)) {
                                  return 'Please enter a valid email';
                                }
                                return null;
                              },
                            ),

                            buildTextField(
                              "Phone Number",
                              "771234567",
                              controller: phoneController,
                              keyboardType: TextInputType.phone,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter phone number';
                                }
                                if (!RegExp(
                                  r'^\+94[0-9]{9}$',
                                ).hasMatch(value)) {
                                  return 'Enter valid Sri Lankan number (e.g. +94771234567)';
                                }
                                return null;
                              },
                            ),

                            buildTextField(
                              "Password",
                              "********",
                              isPassword: true,
                              controller: passwordController,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter password';
                                }
                                if (value.length < 8) {
                                  return 'Password must be at least 8 characters';
                                }
                                if (!RegExp(r'[A-Z]').hasMatch(value)) {
                                  return 'Include at least one uppercase letter';
                                }
                                if (!RegExp(r'[0-9]').hasMatch(value)) {
                                  return 'Include at least one number';
                                }
                                return null;
                              },
                            ),

                            buildTextField(
                              "Confirm Password",
                              "********",
                              isPassword: true,
                              controller: confirmPasswordController,
                              validator: (value) {
                                if (value != passwordController.text) {
                                  return 'Passwords do not match';
                                }
                                return null;
                              },
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
                                onPressed: () {
                                  if (_formKey.currentState!.validate()) {
                                    registerUser();
                                  }
                                },
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
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    bool obscureText = isPassword;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 5),
        TextFormField(
          obscureText: obscureText,
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.grey[200],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            suffixIcon:
                isPassword
                    ? IconButton(
                      icon: Icon(
                        obscureText ? Icons.visibility_off : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          obscureText = !obscureText;
                        });
                      },
                    )
                    : null,
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
