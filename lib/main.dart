import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mobile_app_flutter/views/components/location_provider.dart';
import 'package:mobile_app_flutter/views/components/location_widget.dart';
import 'package:mobile_app_flutter/views/auth/login_screen.dart';
import 'package:mobile_app_flutter/views/auth/signup_screen.dart';
import 'package:mobile_app_flutter/views/onboarding/onboarding_screen.dart';
import 'package:mobile_app_flutter/views/splash_screen.dart';
import 'package:mobile_app_flutter/views/home/homecutomer_screen.dart';
import 'package:mobile_app_flutter/views/home/restaurant_home_screen.dart';
import 'package:mobile_app_flutter/views/home/delivery_home_screen.dart';
import 'package:mobile_app_flutter/views/trackorder/track_order_screen.dart';
import 'package:mobile_app_flutter/views/trackorder/DeliveryTrackingScreen.dart';

import 'package:mobile_app_flutter/views/add_list/restaurant_add_screen.dart';
import 'package:mobile_app_flutter/views/add_list/restaurant_list_screen.dart';
import 'package:mobile_app_flutter/views/add_list/notification_screen.dart';

import 'package:mobile_app_flutter/views/profile/CustomerProfileScreen.dart';
import 'package:mobile_app_flutter/views/profile/DeliveryProfileScreen.dart';
import 'package:mobile_app_flutter/views/profile/RestuarantProfileScreen.dart';

import 'package:mobile_app_flutter/views/item/restaurant_details_screen.dart';
import 'package:mobile_app_flutter/views/item/order_list_screen.dart';
import 'package:mobile_app_flutter/views/item/edit_order_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();

  final bool seenOnboarding = prefs.getBool('seenOnboarding') ?? false;
  final bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

  String initialRoute;
  if (!seenOnboarding) {
    initialRoute = AppRoutes.onboarding;
  } else if (isLoggedIn) {
    final role = prefs.getString("role");
    if (role == "Customer") {
      initialRoute = AppRoutes.customerHome;
    } else if (role == "Restaurant") {
      initialRoute = AppRoutes.restaurantHome;
    } else if (role == "Delivery") {
      initialRoute = AppRoutes.deliveryHome;
    } else {
      initialRoute = AppRoutes.login;
    }
  } else {
    initialRoute = AppRoutes.login;
  }

  runApp(MyApp(initialRoute: initialRoute));
}

class MyApp extends StatelessWidget {
  final String initialRoute;
  const MyApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => LocationProvider())],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Food App',
        theme: ThemeData(primaryColor: Colors.orange, fontFamily: 'Poppins'),
        initialRoute: initialRoute,
        routes: AppRoutes.staticRoutes,
        onGenerateRoute: AppRoutes.onGenerateRoute,
      ),
    );
  }
}

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
  static const String restaurantProfile = '/restaurant_profile';
  static const String trackDelivery = '/track_delivery';
  static const String deliveryProfile = '/delivery_profile';
  static const String customerProfile = '/customer_profile';

  static const String customerOrders = '/order_list';
  static const String editOrder = '/edit_order';
  static const String restaurantDetails = '/restaurant_details';
  static const String testLocation = '/location_widget';

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
    restaurantProfile: (context) => RestuarantProfileScreen(),
    customerOrders: (context) => const OrderListScreen(),
    testLocation:
        (context) => Scaffold(
          appBar: AppBar(title: const Text("Test Location Widget")),
          body: const LocationWidget(),
        ),
  };

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    if (settings.name == trackDelivery) {
      final order = settings.arguments as Map<String, dynamic>?;
      if (order != null) {
        return MaterialPageRoute(
          builder: (_) => DeliveryTrackingScreen(order: order),
        );
      }
    }

    if (settings.name == restaurantDetails) {
      final restaurantName = settings.arguments as String?;
      if (restaurantName != null) {
        return MaterialPageRoute(
          builder:
              (_) => RestaurantDetailsScreen(restaurantName: restaurantName),
        );
      }
    }

    if (settings.name == editOrder) {
      final order = settings.arguments as Map<String, dynamic>?;
      if (order != null) {
        return MaterialPageRoute(builder: (_) => EditOrderScreen(order: order));
      }
    }

    return null;
  }
}

Future<void> logoutUser(BuildContext context) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.clear();
  Navigator.pushReplacementNamed(context, AppRoutes.login);
}
