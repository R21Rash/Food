import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // Animation controller and animation for fade-in effect
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    // Check if user is already logged in
    checkLoginStatus();
  }

  // Method to check login status from shared preferences
  Future<void> checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('name');

    if (name != null && name.isNotEmpty) {
      // If user already logged in, navigate directly to home
      Navigator.pushReplacementNamed(context, '/customer_home');
    } else {
      // No user found, start splash animation and go to onboarding after delay
      startSplashAnimation();
      Timer(Duration(seconds: 3), () {
        Navigator.pushReplacementNamed(context, '/onboarding');
      });
    }
  }

  // Initialize the fade animation for splash screen elements
  void startSplashAnimation() {
    _fadeController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );

    // Start the fade animation after a slight delay
    Future.delayed(Duration(milliseconds: 800), () {
      _fadeController.forward();
    });
  }

  @override
  void dispose() {
    // Always dispose animation controller to prevent memory leaks
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Set splash screen background color
      body: Stack(
        children: [
          // Bottom left image with fade-in animation
          Positioned(
            top: 0,
            left: 0,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Image.asset('assets/images/BottomLeft.png', width: 120),
            ),
          ),
          // Bottom right image with fade-in animation
          Positioned(
            bottom: 0,
            right: 0,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Image.asset('assets/images/BottomRight.png', width: 150),
            ),
          ),
          // Center logo without animation
          Center(child: Image.asset('assets/images/Logo.png', width: 150)),
        ],
      ),
    );
  }
}
