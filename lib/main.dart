import 'package:flutter/material.dart';
import 'package:mobile_app_flutter/views/auth/signup_screen.dart';
import 'package:mobile_app_flutter/views/home/homecutomer_screen.dart';
import 'package:mobile_app_flutter/views/item/customerItem_screen.dart';
import 'package:mobile_app_flutter/views/splash_screen.dart';
import 'package:mobile_app_flutter/views/onboarding/onboarding_screen.dart';
import 'package:mobile_app_flutter/views/auth/login_screen.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Food App',
      theme: ThemeData(primaryColor: Colors.orange, fontFamily: 'Poppins'),

      /// ✅ **Set initialRoute to SplashScreen**
      initialRoute: '/splash',

      /// ✅ **Define routes properly**
      routes: {
        '/splash': (context) => SplashScreen(),
        '/onboarding': (context) => OnboardingScreen(),
        '/login': (context) => LoginScreen(),
        '/signup': (context) => SignupScreen(),
        '/customer_home': (context) => HomeCustomerScreen(),
        '/customer-item': (context) => CustomerItemScreen(title: '', image: ''),
      },
    );
  }
}
