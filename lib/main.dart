import 'package:flutter/material.dart';
import 'package:mobile_app_flutter/views/profile/CustomerProfileScreen.dart';
import 'package:mobile_app_flutter/views/profile/DeliveryProfileScreen.dart';
import 'package:provider/provider.dart';
import 'package:mobile_app_flutter/views/add_list/notification_screen.dart';
import 'package:mobile_app_flutter/views/add_list/restaurant_add_screen.dart';
import 'package:mobile_app_flutter/views/add_list/restaurant_list_screen.dart';
import 'package:mobile_app_flutter/views/components/location_provider.dart';
import 'package:mobile_app_flutter/views/trackorder/DeliveryTrackingScreen.dart';
import 'package:mobile_app_flutter/views/trackorder/track_order_screen.dart';

import 'package:mobile_app_flutter/views/auth/signup_screen.dart';
import 'package:mobile_app_flutter/views/home/homecutomer_screen.dart';
import 'package:mobile_app_flutter/views/splash_screen.dart';
import 'package:mobile_app_flutter/views/onboarding/onboarding_screen.dart';
import 'package:mobile_app_flutter/views/auth/login_screen.dart';
import 'package:mobile_app_flutter/views/home/restaurant_home_screen.dart';
import 'package:mobile_app_flutter/views/home/delivery_home_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => LocationProvider())],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    context.read<LocationProvider>().fetchCurrentLocation();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Food App',
      theme: ThemeData(primaryColor: Colors.orange, fontFamily: 'Poppins'),
      initialRoute: AppRoutes.splash,
      routes: AppRoutes.staticRoutes,
      onGenerateRoute: AppRoutes.onGenerateRoute,
    );
  }
}

/// ✅ Routing Configuration
class AppRoutes {
  static const String splash = '/splash';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String customerHome = '/customer_home';
  static const String restaurantHome = '/restaurant_home';
  static const String deliveryHome = '/delivery_home';
  static const String trackOrder = '/track_order';

  static const String restaurantAdd = '/restaurant_add_screen';
  static const String restaurantList = '/restaurant_list_screen';
  static const String restaurantNotifications = '/restaurant_notifications';
  static const String trackDelivery = '/track_delivery';
  static const String deliveryProfile = '/delivery_profile';
  static const String customerProfile = '/customer_profile';

  /// Static Routes (no arguments needed)
  static Map<String, WidgetBuilder> get staticRoutes => {
    splash: (context) => SplashScreen(),
    onboarding: (context) => OnboardingScreen(),
    login: (context) => LoginScreen(),
    signup: (context) => SignupScreen(),
    customerHome: (context) => HomeCustomerScreen(),
    restaurantHome: (context) => RestaurantHomeScreen(),
    deliveryHome: (context) => DeliveryHomeScreen(),
    trackOrder: (context) => TrackOrderScreen(),
    restaurantAdd: (context) => RestaurantAddScreen(),
    restaurantList: (context) => RestaurantListScreen(),
    restaurantNotifications: (context) => NotificationScreen(),
    deliveryProfile: (context) => DeliveryProfileScreen(),
    customerProfile: (context) => CustomerProfileScreen(),
  };

  /// Dynamic Route with Arguments
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    if (settings.name == trackDelivery) {
      final order = settings.arguments as Map<String, dynamic>?;
      if (order != null) {
        return MaterialPageRoute(
          builder: (_) => DeliveryTrackingScreen(order: order),
        );
      }
    }

    return null; // fallback for unknown routes
  }
}
