import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ForgotPasswordScreen extends StatefulWidget {
  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final List<TextEditingController> otpControllers = List.generate(
    4,
    (_) => TextEditingController(),
  );
  final TextEditingController newPasswordController = TextEditingController();

  bool isOTPSent = false;
  bool isLoading = false;
  bool isPasswordScreen = false;

  final String verifyPhoneUrl =
      "http://192.168.150.48:5001/api/password/verify-phone";
  final String sendOtpUrl = "http://192.168.150.48:5001/api/password/send-otp";
  final String verifyUsernamePhoneUrl =
      "http://192.168.150.48:5001/api/password/verify-username-phone";

  Future<void> verifyUsernameAndPhone() async {
    setState(() => isLoading = true);

    try {
      final response = await http.post(
        Uri.parse(verifyUsernamePhoneUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "username": usernameController.text.trim(),
          "phone": phoneController.text.trim(),
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data["status"] == "ok") {
        final otpResponse = await http.post(
          Uri.parse(sendOtpUrl),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({"phone": phoneController.text.trim()}),
        );

        final otpData = jsonDecode(otpResponse.body);

        if (otpResponse.statusCode == 200 && otpData["sent"] == true) {
          setState(() => isOTPSent = true);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("OTP Sent"),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(otpData["message"] ?? "Failed to send OTP"),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              data["message"] ?? "Username or phone number mismatch",
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  void verifyOTP() {
    String otp = otpControllers.map((controller) => controller.text).join();
    // Send OTP to server and validate. For now, just log it.
    print("Entered OTP: $otp");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("OTP entered: $otp"),
        backgroundColor: Colors.blue,
      ),
    );
    // Navigate to reset password screen after verifying OTP
    setState(() {
      isPasswordScreen = true;
    });
  }

  void resetPassword() async {
    String newPassword = newPasswordController.text.trim();
    if (newPassword.isNotEmpty) {
      // Call API to reset password
      try {
        final response = await http.post(
          Uri.parse('http://192.168.150.48:5001/api/password/reset-password'),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({"newPassword": newPassword}),
        );

        final data = jsonDecode(response.body);

        if (response.statusCode == 200 && data["status"] == "ok") {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Password reset successfully!"),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context); // Go back to the login screen
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(data["message"] ?? "Failed to reset password"),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter a new password"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget buildOTPBoxes() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(
        4,
        (index) => SizedBox(
          width: 60,
          child: TextField(
            controller: otpControllers[index],
            keyboardType: TextInputType.number,
            maxLength: 1,
            textAlign: TextAlign.center,
            onChanged: (val) {
              if (val.isNotEmpty && index < 3) {
                FocusScope.of(context).nextFocus();
              }
            },
            decoration: const InputDecoration(
              counterText: '',
              border: OutlineInputBorder(),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E2D),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text(
          "Forgot Password",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                "Enter your username and phone number to reset your password",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: usernameController,
                decoration: InputDecoration(
                  hintText: "Enter username",
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 15,
                    horizontal: 10,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  hintText: "Enter phone number",
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 15,
                    horizontal: 10,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              isOTPSent
                  ? Column(
                    children: [
                      const Text(
                        "Enter the OTP sent to your number",
                        style: TextStyle(color: Colors.white),
                      ),
                      const SizedBox(height: 10),
                      buildOTPBoxes(),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: verifyOTP,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                        ),
                        child: const Text("Verify OTP"),
                      ),
                    ],
                  )
                  : ElevatedButton(
                    onPressed: isLoading ? null : verifyUsernameAndPhone,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 50,
                        vertical: 15,
                      ),
                    ),
                    child:
                        isLoading
                            ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                            : const Text("Send OTP"),
                  ),
              if (isPasswordScreen) ...[
                const SizedBox(height: 20),
                TextField(
                  controller: newPasswordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: "Enter new password",
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 15,
                      horizontal: 10,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: resetPassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                  ),
                  child: const Text("Reset Password"),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
