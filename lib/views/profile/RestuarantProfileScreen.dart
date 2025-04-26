import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:mobile_app_flutter/views/components/bottom_nav_bar.dart';
import 'package:mobile_app_flutter/views/profile/edit_customer_profile_screen.dart';

class RestuarantProfileScreen extends StatefulWidget {
  @override
  State<RestuarantProfileScreen> createState() =>
      _RestuarantProfileScreenState();
}

class _RestuarantProfileScreenState extends State<RestuarantProfileScreen> {
  String name = "Loading...";
  String email = "Loading...";
  String phone = "Loading...";
  String status = "active";
  bool isOpen = true;

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      name = prefs.getString("restaurantName") ?? "Restaurant";
      email = prefs.getString("email") ?? "restaurant@example.com";
      phone = prefs.getString("phone") ?? "+94 77 123 4567";
      status = prefs.getString("status") ?? "active";
      isOpen = prefs.getBool("isOpen") ?? true;
    });
  }

  void toggleOpenStatus() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isOpen = !isOpen;
      prefs.setBool("isOpen", isOpen);
    });
  }

  Future<void> _deactivateAccount() async {
    String? confirmation = await showDialog<String>(
      context: context,
      builder: (context) {
        TextEditingController controller = TextEditingController();
        return AlertDialog(
          title: const Text("Confirm Deactivation"),
          content: SingleChildScrollView(
            child: Column(
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

    final url = Uri.parse("http://192.168.180.48:5001/api/auth/deactivate");

    try {
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
          "Restaurant Profile",
          style: TextStyle(fontWeight: FontWeight.normal),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Restaurant badge on avatar
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.orange.withOpacity(0.1),
                  child: const Icon(
                    Icons.restaurant,
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
                        "RESTAURANT",
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
                const Text("Status: "),
                Text(
                  status == "active" ? "Active" : "Inactive",
                  style: TextStyle(
                    color: status == "active" ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Business: "),
                Text(
                  isOpen ? "OPEN" : "CLOSED",
                  style: TextStyle(
                    color: isOpen ? Colors.green : Colors.red,
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

            SwitchListTile(
              value: isOpen,
              onChanged: (val) => toggleOpenStatus(),
              title: const Text("Toggle Availability"),
              activeColor: Colors.green,
              inactiveThumbColor: Colors.red,
              secondary: const Icon(Icons.store, color: Colors.orange),
            ),
            ListTile(
              leading: const Icon(Icons.info_outline, color: Colors.orange),
              title: const Text("About KFood App"),
              onTap: () {
                showAboutDialog(
                  context: context,
                  applicationName: 'KFood Restaurant App',
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
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 4),
    );
  }
}
