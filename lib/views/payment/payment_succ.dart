import 'package:flutter/material.dart';

class PaymentSuccessScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100, // Light background
      // Centering everything perfectly
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min, // Prevents full screen stretch
          mainAxisAlignment: MainAxisAlignment.center, // Centers vertically
          crossAxisAlignment: CrossAxisAlignment.center, // Centers horizontally
          children: [
            // Success Icon
            Icon(
              Icons.check_circle,
              size: 100,
              color: Colors.green, // Success color
            ),
            SizedBox(height: 20),

            // Title
            Text(
              "Congratulations!",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10),

            // Subtitle
            Text(
              "You successfully made a payment,\nenjoy our service!",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
            SizedBox(height: 30),
          ],
        ),
      ),

      // Button at the bottom
      bottomNavigationBar: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                minimumSize: Size(double.infinity, 50),
              ),

              onPressed: () {
                Navigator.pushNamed(context, '/track_order');
              },
              child: Text(
                "TRACK ORDER",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
              ),
            ),
            SizedBox(height: 10),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/customer_home');
              },
              child: Text(
                "BACK HOME",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.normal,
                  color: Colors.grey[700],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
