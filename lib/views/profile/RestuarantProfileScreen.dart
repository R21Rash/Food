import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile_app_flutter/views/components/bottom_nav_bar.dart';

class RestuarantProfileScreen extends StatefulWidget {
  @override
  State<RestuarantProfileScreen> createState() =>
      _RestuarantProfileScreenState();
}

class _RestuarantProfileScreenState extends State<RestuarantProfileScreen> {
  String name = "Loading...";
  String email = "Loading...";
  bool isOpen = true;

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      name = prefs.getString("name") ?? "Restaurant";
      email = prefs.getString("email") ?? "Not available";
      isOpen = prefs.getBool("isOpen") ?? true; // Static toggle
    });
  }

  void _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
  }

  void toggleOpenStatus() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isOpen = !isOpen;
      prefs.setBool("isOpen", isOpen); // Save locally only
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],

      appBar: AppBar(
        centerTitle: true,
        title: const Text("Profile"),
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/restaurant_home');
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundColor: Colors.orange,
              child: Icon(Icons.restaurant, size: 50, color: Colors.white),
            ),
            const SizedBox(height: 20),
            Text(
              name,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              email,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            Chip(
              label: Text(isOpen ? "OPEN" : "CLOSED"),
              backgroundColor:
                  isOpen ? Colors.green.shade100 : Colors.red.shade100,
              labelStyle: TextStyle(
                color: isOpen ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
              ),
              avatar: Icon(
                isOpen ? Icons.check_circle : Icons.close,
                color: isOpen ? Colors.green : Colors.red,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            ),
            const SizedBox(height: 20),
            SwitchListTile(
              value: isOpen,
              onChanged: (val) => toggleOpenStatus(),
              title: const Text("Toggle Availability"),
              activeColor: Colors.green,
              inactiveThumbColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              tileColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 4,
              ),
            ),
            const Spacer(),
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
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 4),
    );
  }
}
