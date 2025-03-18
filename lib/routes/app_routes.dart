import 'package:flutter/material.dart';
import 'package:mobile_app_flutter/views/auth/signup_screen.dart';
import 'package:mobile_app_flutter/views/splash_screen.dart';
import 'package:mobile_app_flutter/views/onboarding/onboarding_screen.dart';
import 'package:mobile_app_flutter/views/auth/login_screen.dart';

class AppRoutes {
  static Map<String, WidgetBuilder> routes = {
    '/splash': (context) => SplashScreen(), // ✅ First screen
    '/onboarding': (context) => OnboardingScreen(), // ✅ Second screen
    '/login': (context) => LoginScreen(),
    '/signup': (context) => SignupScreen(),
  };
}
