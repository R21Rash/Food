import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class SignupSuccessScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pushReplacementNamed(context, '/login');
    });

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Lottie.network(
          'https://assets10.lottiefiles.com/packages/lf20_jbrw3hcz.json',
          repeat: false,
          width: 200,
        ),
      ),
    );
  }
}
