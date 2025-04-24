import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ForgotResetPasswordScreen extends StatefulWidget {
  @override
  _ForgotResetPasswordScreenState createState() => _ForgotResetPasswordScreenState();
}

class _ForgotResetPasswordScreenState extends State<ForgotResetPasswordScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController tokenController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool showResetSection = false;
  bool isLoading = false;

  final String baseUrl = "http://localhost:30409/api/password";

  Future<void> sendResetLink() async {
    setState(() => isLoading = true);

    final response = await http.post(
      Uri.parse("$baseUrl/request-reset"),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': emailController.text.trim()}),
    );

    setState(() => isLoading = false);

    final res = json.decode(response.body);
    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Reset link sent to email")));
      setState(() => showResetSection = true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res['message'] ?? "Something went wrong")));
    }
  }

  Future<void> resetPassword() async {
    setState(() => isLoading = true);

    final token = tokenController.text.trim();
    final newPassword = passwordController.text.trim();

    final response = await http.post(
      Uri.parse("$baseUrl/reset-password/$token"),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'newPassword': newPassword}),
    );

    setState(() => isLoading = false);

    final res = json.decode(response.body);
    if (response.statusCode == 200) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text("Success"),
          content: Text(res['message']),
          actions: [
            TextButton(
              child: Text("OK"),
              onPressed: () => Navigator.pop(context),
            )
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res['message'] ?? "Invalid or expired token")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Forgot / Reset Password")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (!showResetSection) ...[
              Text("🔐 Forgot Password", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              TextField(
                controller: emailController,
                decoration: InputDecoration(labelText: "Enter your email"),
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: 20),
              isLoading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: sendResetLink,
                      child: Text("Send Reset Link"),
                    ),
            ] else ...[
              Text("🔑 Reset Your Password", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              TextField(
                controller: tokenController,
                decoration: InputDecoration(labelText: "Enter token from email"),
              ),
              SizedBox(height: 10),
              TextField(
                controller: passwordController,
                decoration: InputDecoration(labelText: "Enter new password"),
                obscureText: true,
              ),
              SizedBox(height: 20),
              isLoading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: resetPassword,
                      child: Text("Reset Password"),
                    ),
              TextButton(
                onPressed: () => setState(() => showResetSection = false),
                child: Text("← Back to email input"),
              )
            ],
          ],
        ),
      ),
    );
  }
}
