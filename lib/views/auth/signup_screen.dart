import 'package:flutter/material.dart';

class SignupScreen extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  String? selectedRole;
  final List<String> roles = ["Customer", "Restaurant", "Delivery"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E2D), // Dark background color
      body: Stack(
        children: [
          /// ✅ **Top Section (Dark Background)**
          Container(
            height: 280, // Height of the dark background
            decoration: const BoxDecoration(
              color: Color(0xFF1E1E2D), // Dark theme background
            ),
          ),

          /// ✅ **White Form Container on Top**
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height:
                  MediaQuery.of(context).size.height * 0.75, // Adjusted height
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white, // White background
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20), // ✅ Apply consistent padding
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// ✅ **Role Selection Dropdown**
                      const Text(
                        "ROLE",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.grey[200],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        value: selectedRole,
                        items:
                            roles.map((role) {
                              return DropdownMenuItem(
                                value: role,
                                child: Text(role),
                              );
                            }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedRole = value;
                          });
                        },
                        hint: const Text("Select Role"),
                      ),
                      const SizedBox(height: 15),

                      /// ✅ **Show Dynamic Fields Based on Role**
                      if (selectedRole == "Restaurant") ...[
                        buildTextField(
                          "Restaurant Name",
                          "Enter restaurant name",
                        ),
                      ] else ...[
                        buildTextField("Full Name", "Enter full name"),
                      ],

                      buildTextField("Email", "example@gmail.com"),
                      buildTextField("Password", "********", isPassword: true),
                      buildTextField(
                        "Confirm Password",
                        "********",
                        isPassword: true,
                      ),

                      const SizedBox(height: 20),

                      /// ✅ **Sign Up Button**
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () {
                            Navigator.pushNamed(context, '/login');
                          },
                          child: const Text(
                            "SIGN UP",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ),
                      ),

                      /// ✅ **Already have an account? Log In**
                      const SizedBox(height: 15),
                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("Already have an account? "),
                            TextButton(
                              onPressed: () {
                                Navigator.pushNamed(context, '/login');
                              },
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

          /// ✅ **Title Above White Container**
          Positioned(
            top: 100,
            left: 0,
            right: 0,
            child: Column(
              children: const [
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
        ],
      ),
    );
  }

  /// ✅ **Reusable Text Field**
  Widget buildTextField(String label, String hint, {bool isPassword = false}) {
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
}
