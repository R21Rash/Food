import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile_app_flutter/views/components/CustomBottomNavBarForDriver.dart';

class DeliveryProfileScreen extends StatefulWidget {
  @override
  State<DeliveryProfileScreen> createState() => _DeliveryProfileScreenState();
}

class _DeliveryProfileScreenState extends State<DeliveryProfileScreen> {
  String name = "Loading...";
  String lastRide = "No recent rides";

  @override
  void initState() {
    super.initState();
    loadProfileDetails();
  }

  Future<void> loadProfileDetails() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      name = prefs.getString("fullName") ?? "Delivery Partner";
      lastRide = prefs.getString("lastRide") ?? "No recent rides";
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

  void _changePassword() {
    // Navigate to change password screen or show dialog
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Change Password"),
            content: const Text("Feature coming soon."),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("OK"),
              ),
            ],
          ),
    );
  }

  void _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Clear saved user session
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(Icons.person, size: 100, color: Colors.orange),
            const SizedBox(height: 20),
            Text(
              name,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              "🚚 Last Ride: $lastRide",
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: _changePassword,
              icon: const Icon(Icons.lock_reset),
              label: const Text("Change Password"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                minimumSize: const Size.fromHeight(45),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _logout,
              icon: const Icon(Icons.logout),
              label: const Text("Logout"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                minimumSize: const Size.fromHeight(45),
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
