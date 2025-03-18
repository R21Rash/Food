import 'package:flutter/material.dart';
import 'package:mobile_app_flutter/views/components/location_provider.dart';
import 'package:provider/provider.dart';

import 'package:mobile_app_flutter/views/auth/signup_screen.dart';
import 'package:mobile_app_flutter/views/home/homecutomer_screen.dart';
import 'package:mobile_app_flutter/views/item/customerItem_screen.dart';
import 'package:mobile_app_flutter/views/splash_screen.dart';
import 'package:mobile_app_flutter/views/onboarding/onboarding_screen.dart';
import 'package:mobile_app_flutter/views/auth/login_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => LocationProvider(),
        ), // ✅ Location Provider
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // ✅ Fetch user location once when the app starts
    context.read<LocationProvider>().fetchCurrentLocation();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Food App',
      theme: ThemeData(primaryColor: Colors.orange, fontFamily: 'Poppins'),

      /// ✅ **Set initialRoute to SplashScreen**
      initialRoute: AppRoutes.splash,

      /// ✅ **Define routes using a separate class**
      routes: AppRoutes.routes,
    );
  }
}

/// ✅ **Refactored Routes into a Separate Class for Better Organization**
class AppRoutes {
  static const String splash = '/splash';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String customerHome = '/customer_home';
  static const String customerItem = '/customer-item';

  static Map<String, WidgetBuilder> get routes => {
    splash: (context) => SplashScreen(),
    onboarding: (context) => OnboardingScreen(),
    login: (context) => LoginScreen(),
    signup: (context) => SignupScreen(),
    customerHome: (context) => HomeCustomerScreen(),
    customerItem: (context) => CustomerItemScreen(title: '', image: ''),
  };
}
