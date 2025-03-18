import 'package:flutter/material.dart';
import 'dart:async';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize fade animation
    _fadeController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2), // Fade in duration
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );

    // Start the fade animation after a delay
    Future.delayed(Duration(milliseconds: 800), () {
      _fadeController.forward();
    });

    // ⏳ Navigate to Onboarding after 3 seconds
    Timer(Duration(seconds: 3), () {
      Navigator.pushReplacementNamed(context, '/onboarding');
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          /// ✅ **Top Left Decoration (Animated Fade-In)**
          Positioned(
            top: 0,
            left: 0,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Image.asset(
                'assets/images/BottomLeft.png', // Update with your correct path
                width: 120, // Adjust size as needed
              ),
            ),
          ),

          /// ✅ **Bottom Right Decoration (Animated Fade-In)**
          Positioned(
            bottom: 0,
            right: 0,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Image.asset(
                'assets/images/BottomRight.png', // Update with your correct path
                width: 150, // Adjust size as needed
              ),
            ),
          ),

          /// ✅ **Logo at Center**
          Center(
            child: Image.asset(
              'assets/images/Logo.png', // Your logo
              width: 150,
            ),
          ),
        ],
      ),
    );
  }
}
