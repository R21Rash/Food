import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
    checkLoginStatus();
  }

  Future<void> checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('name');

    if (name != null && name.isNotEmpty) {
      // User already logged in, go to home
      Navigator.pushReplacementNamed(context, '/customer_home');
    } else {
      // No user data, proceed with splash + onboarding
      startSplashAnimation();
      Timer(Duration(seconds: 3), () {
        Navigator.pushReplacementNamed(context, '/onboarding');
      });
    }
  }

  void startSplashAnimation() {
    _fadeController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );

    Future.delayed(Duration(milliseconds: 800), () {
      _fadeController.forward();
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
          Positioned(
            top: 0,
            left: 0,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Image.asset('assets/images/BottomLeft.png', width: 120),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Image.asset('assets/images/BottomRight.png', width: 150),
            ),
          ),
          Center(child: Image.asset('assets/images/Logo.png', width: 150)),
        ],
      ),
    );
  }
}
