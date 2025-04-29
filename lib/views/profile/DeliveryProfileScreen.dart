import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_app_flutter/common-const/api_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile_app_flutter/views/components/CustomBottomNavBarForDriver.dart';
import 'package:mobile_app_flutter/views/profile/edit_customer_profile_screen.dart';

/// DeliveryProfileScreen displays the delivery driver's profile information and provides
/// options for profile management such as editing, logging out, and deactivation.
class DeliveryProfileScreen extends StatefulWidget {
  @override
  State<DeliveryProfileScreen> createState() => _DeliveryProfileScreenState();
}

class _DeliveryProfileScreenState extends State<DeliveryProfileScreen> {
  // Driver information properties with default loading values
  String name = "Loading...";
  String email = "Loading...";
  String phone = "Loading...";
  String lastRide = "No recent rides";
  String status = "active";

  @override
  void initState() {
    super.initState();
    // Load driver profile information when screen initializes
    loadProfileDetails();
  }

  /// Retrieves driver profile information from SharedPreferences storage
  /// and updates the state with the retrieved values
  Future<void> loadProfileDetails() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      // Retrieve stored driver data with fallback values if not found
      name = prefs.getString("fullName") ?? "Delivery Partner";
      email = prefs.getString("email") ?? "driver@example.com";
      phone = prefs.getString("phone") ?? "+94 77 123 4567";
      lastRide = prefs.getString("lastRide") ?? "No recent rides";
      status = prefs.getString("status") ?? "active";
    });
  }

  /// Handles bottom navigation bar item selection
  /// and navigates to the appropriate screen
  void _onNavTapped(int index) {
    if (index == 0) {
      // Navigate to delivery home screen
      Navigator.pushReplacementNamed(context, '/delivery_home');
    } else if (index == 1) {
      // Navigate to delivery tracking screen
      Navigator.pushReplacementNamed(context, '/track_delivery');
    } else if (index == 2) {
      // Already on profile screen - do nothing
    }
  }

  /// Handles account deactivation process
  /// Displays confirmation dialog, validates user input, and makes API call to deactivate account
  Future<void> _deactivateAccount() async {
    // Show confirmation dialog with text input validation
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
                // Validate the input text
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

    // If user cancelled, exit the function
    if (confirmation == null) return;

    // Get user email from SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString("email");

    // Validate email existence
    if (email == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Email not found. Try logging in again.")),
      );
      return;
    }

    // API endpoint for account deactivation
    final url = Uri.parse("$baseURL:5001/api/auth/deactivate");

    try {
      // Send deactivation request to server
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      if (response.statusCode == 200) {
        // Update local status
        await prefs.setString("status", "inactive");
        setState(() => status = "inactive");

        // Notify user of successful deactivation
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Account deactivated successfully")),
        );

        // Clear shared preferences and log the user out
        await prefs.clear();
        Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
      } else {
        // Handle error response from server
        final body = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed: ${body['message'] ?? 'Try again'}")),
        );
      }
    } catch (e) {
      // Handle network or other exceptions
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  /// Handles user logout functionality
  /// Shows a confirmation dialog and clears session data on confirmation
  Future<void> _logout() async {
    // Display confirmation dialog and get user response
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

    // If user confirmed logout
    if (confirmed == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear(); // Clear all shared preferences
      // Navigate to login screen and remove all previous routes
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
            // Driver avatar with badge showing driver status
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                // Driver avatar
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.orange.withOpacity(0.1),
                  child: const Icon(
                    Icons.delivery_dining,
                    size: 60,
                    color: Colors.orange,
                  ),
                ),
                // Status badge overlay
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
            // Driver name display
            Text(
              name,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            // Driver contact information
            Text(email, style: TextStyle(color: Colors.grey[700])),
            const SizedBox(height: 2),
            Text(phone, style: TextStyle(color: Colors.grey[700])),
            const SizedBox(height: 12),
            // Last delivery information
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
            // Profile action options
            // Edit profile option
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
            // About app option
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
            // Conditional rendering of action buttons based on account status
            if (status == "active")
              Row(
                children: [
                  // Deactivate account button
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
                  // Logout button
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
            // Only show logout button if account is inactive
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
      // Bottom navigation bar for driver app-wide navigation
      bottomNavigationBar: CustomBottomNavBarForTracking(
        currentIndex: 2, // Profile tab is selected (index 2)
        onTap: _onNavTapped,
      ),
    );
  }
}
