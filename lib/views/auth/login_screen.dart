import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_app_flutter/common-const/api_constants.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

// 30409

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;
  bool isPasswordVisible = false; // Track password visibility

  final String backendUrl = "$baseURL:5001/api/auth/login";

  Future<void> loginUser() async {
    print("loginUser() called");

    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      print(" Email or password is empty");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter both email and password."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => isLoading = true);

    print("📡 Sending login request to $backendUrl");
    print(
      "📤 Request Body: ${emailController.text} / ${passwordController.text}",
    );

    try {
      final response = await http.post(
        Uri.parse(backendUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": emailController.text.trim(),
          "password": passwordController.text,
        }),
      );

      print("📨 Response Code: ${response.statusCode}");
      print("📨 Response Body: ${response.body}");

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data["user"] != null) {
        final role = data["user"]["role"] ?? "";
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString("role", role);
        await prefs.setString("email", data["user"]["email"]);
        await prefs.setString("user_id", data["user"]["_id"]);
        await prefs.setString("fullName", data["user"]["fullName"] ?? "User");
        await prefs.setString(
          "name",
          data["user"]["fullName"] ?? data["user"]["restaurantName"] ?? "User",
        );
        await prefs.setString(
          "restaurantName",
          data["user"]["restaurantName"] ?? "Restaurant",
        );
        await prefs.setString("phone", data["user"]["phone"] ?? "");
        await prefs.setString("status", data["user"]["status"] ?? "");

        print("✅ Login success! Redirecting user with role: $role");

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Login Successful!"),
            backgroundColor: Colors.green,
          ),
        );

        switch (role) {
          case "Customer":
            Navigator.pushReplacementNamed(context, '/customer_home');
            break;
          case "Restaurant":
            Navigator.pushReplacementNamed(context, '/restaurant_home');
            break;
          case "Delivery":
            Navigator.pushReplacementNamed(context, '/delivery_home');
            break;
          default:
            print("❌ Unknown user role");
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Unknown user role"),
                backgroundColor: Colors.red,
              ),
            );
        }
      } else {
        print("❌ Login failed: ${data["message"]}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data["message"] ?? "Login failed"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print("❌ Connection Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Connection Error: $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

    return Scaffold(
      backgroundColor: const Color(0xFF1E1E2D),
      resizeToAvoidBottomInset: false,
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
                        "Log In",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        "Please sign in to your existing account",
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
                          : constraints.maxHeight * 0.50,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(25),
                    child: SingleChildScrollView(
                      reverse: true,
                      padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).viewInsets.bottom,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          buildTextField(
                            "EMAIL",
                            "example@gmail.com",
                            controller: emailController,
                          ),
                          buildTextField(
                            "PASSWORD",
                            "********",
                            isPassword: true,
                            controller: passwordController,
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {
                                Navigator.pushNamed(
                                  context,
                                  '/forgot_password',
                                );
                              },
                              child: const Text(
                                "Forgot Password?",
                                style: TextStyle(
                                  color: Colors.orange,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          isLoading
                              ? const Center(child: CircularProgressIndicator())
                              : SizedBox(
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
                                    print("🟠 LOGIN BUTTON PRESSED");
                                    loginUser();
                                  },
                                  child: const Text(
                                    "LOG IN",
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ),
                              ),
                          const SizedBox(height: 15),
                          Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text("Don't have an account? "),
                                TextButton(
                                  onPressed:
                                      () => Navigator.pushNamed(
                                        context,
                                        '/signup',
                                      ),
                                  child: const Text(
                                    "SIGN UP",
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
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 5),
        TextField(
          controller: controller,
          obscureText: isPassword ? !isPasswordVisible : false,
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
                        isPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          isPasswordVisible = !isPasswordVisible;
                        });
                      },
                    )
                    : null,
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}
