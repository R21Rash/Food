import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_app_flutter/common-const/api_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile_app_flutter/views/components/CustomBottomNavBarForDriver.dart';
import 'package:mobile_app_flutter/views/profile/edit_customer_profile_screen.dart';

class DeliveryProfileScreen extends StatefulWidget {
  @override
  State<DeliveryProfileScreen> createState() => _DeliveryProfileScreenState();
}

class _DeliveryProfileScreenState extends State<DeliveryProfileScreen> {
  String name = "Loading...";
  String email = "Loading...";
  String phone = "Loading...";
  String lastRide = "No recent rides";
  String status = "active";

  @override
  void initState() {
    super.initState();
    loadProfileDetails();
  }

  Future<void> loadProfileDetails() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      name = prefs.getString("fullName") ?? "Delivery Partner";
      email = prefs.getString("email") ?? "driver@example.com";
      phone = prefs.getString("phone") ?? "+94 77 123 4567";
      lastRide = prefs.getString("lastRide") ?? "No recent rides";
      status = prefs.getString("status") ?? "active";
    });
  }

  void _onNavTapped(int index) {
    if (index == 0) {
      Navigator.pushReplacementNamed(context, '/delivery_home');
    } else if (index == 1) {
      Navigator.pushReplacementNamed(context, '/track_delivery');
    } else if (index == 2) {
      // Already on profile
    }
  }

  Future<void> _deactivateAccount() async {
    String? confirmation = await showDialog<String>(
      context: context,
      builder: (context) {
        TextEditingController controller = TextEditingController();
        return AlertDialog(
          title: const Text("Confirm Deactivation"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("To confirm, type 'deactivate' below."),
              const SizedBox(height: 10),
              TextField(
                controller: controller,
                decoration: const InputDecoration(
                  hintText: "Type 'deactivate' to confirm",
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, null),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                if (controller.text.trim().toLowerCase() == "deactivate") {
                  Navigator.pop(context, controller.text);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Please type 'deactivate' to confirm."),
                    ),
                  );
                }
              },
              child: const Text("Confirm"),
            ),
          ],
        );
      },
    );

    if (confirmation == null) return;

    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString("email");

    if (email == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Email not found. Try logging in again.")),
      );
      return;
    }

    final url = Uri.parse("$baseURL:30409/api/auth/deactivate");

    try {
      // Call your deactivation API here
      // final response = await http.post(...);

      // On success:
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      if (response.statusCode == 200) {
        await prefs.setString("status", "inactive");
        setState(() => status = "inactive");

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Account deactivated successfully")),
        );

        // Clear shared preferences and log the user out
        await prefs.clear();
        Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
      } else {
        final body = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed: ${body['message'] ?? 'Try again'}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  Future<void> _logout() async {
    bool? confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Confirm Logout"),
            content: const Text("Are you sure you want to log out?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text("Logout"),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
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
          "Driver Profile",
          style: TextStyle(fontWeight: FontWeight.normal),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Driver badge on avatar with status
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.orange.withOpacity(0.1),
                  child: const Icon(
                    Icons.delivery_dining,
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
                    color: status == "active" ? Colors.orange : Colors.grey,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "DRIVER",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(
                        status == "active" ? Icons.check_circle : Icons.block,
                        size: 12,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              name,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(email, style: TextStyle(color: Colors.grey[700])),
            const SizedBox(height: 2),
            Text(phone, style: TextStyle(color: Colors.grey[700])),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Last Delivery: "),
                Text(
                  lastRide,
                  style: TextStyle(
                    color: Colors.orange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.edit, color: Colors.orange),
              title: const Text("Edit Profile"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EditCustomerProfileScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.info_outline, color: Colors.orange),
              title: const Text("About Food App"),
              onTap: () {
                showAboutDialog(
                  context: context,
                  applicationName: 'KFood Driver App',
                  applicationVersion: '1.0.0',
                  applicationLegalese: '© 2025 KFood Inc.',
                );
              },
            ),
            const Spacer(),
            if (status == "active")
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _deactivateAccount,
                      icon: const Icon(Icons.block),
                      label: const Text("Deactivate"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[800],
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _logout,
                      icon: const Icon(Icons.logout),
                      label: const Text("Logout"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
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
            if (status != "active")
              ElevatedButton.icon(
                onPressed: _logout,
                icon: const Icon(Icons.logout),
                label: const Text("Logout"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
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
      bottomNavigationBar: CustomBottomNavBarForTracking(
        currentIndex: 2, // Profile tab
        onTap: _onNavTapped,
      ),
    );
  }
}
