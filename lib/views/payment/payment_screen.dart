import 'package:flutter/material.dart';
import 'package:payhere_mobilesdk_flutter/payhere_mobilesdk_flutter.dart';
import 'package:mobile_app_flutter/views/payment/payment_succ.dart';

class PaymentScreen extends StatefulWidget {
  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String selectedPaymentMethod = "assets/images/master.png";

  void _makePayHerePayment() {
    final payment = {
      "sandbox": true,
      "merchant_id": "1229906",
      "notify_url": "https://sandbox.payhere.lk/notify", // ✅ Required!
      "order_id": "ORDER_${DateTime.now().millisecondsSinceEpoch}",
      "items": "Food Order",
      "amount": "10.00",
      "currency": "LKR",
      "first_name": "Fahmy",
      "last_name": "Sehu",
      "email": "youremail@example.com",
      "phone": "0771234567",
      "address": "Colombo 01",
      "city": "Colombo",
      "country": "Sri Lanka",
    };

    PayHere.startPayment(
      payment,
      (paymentId) {
        print("✅ Payment Success. ID: $paymentId");
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => PaymentSuccessScreen()),
        );
      },
      (error) {
        print("❌ Payment Failed: $error");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Payment Failed: $error"),
            backgroundColor: Colors.red,
          ),
        );
      },
      () {
        print("ℹ️ Payment Dismissed");
      },
    );
  }

  Widget _buildPaymentMethod(String imagePath) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedPaymentMethod = imagePath;
        });
      },
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color:
                  selectedPaymentMethod == imagePath
                      ? Colors.orange.withOpacity(0.2)
                      : Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Image.asset(
              imagePath,
              width: 50,
              height: 30,
              fit: BoxFit.contain,
            ),
          ),
          SizedBox(height: 5),
          if (selectedPaymentMethod == imagePath)
            Icon(Icons.check_circle, color: Colors.orange, size: 20),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Payment",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Payment method selection
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildPaymentMethod("assets/images/cash.png"),
                _buildPaymentMethod("assets/images/visa.png"),
                _buildPaymentMethod("assets/images/master.png"),
              ],
            ),
            SizedBox(height: 20),
            if (selectedPaymentMethod == "assets/images/cash.png")
              Container(
                padding: EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(color: Colors.grey.shade200, blurRadius: 5),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.money, size: 40, color: Colors.orange),
                    SizedBox(height: 10),
                    Text(
                      "Cash Payment Selected",
                      style: TextStyle(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 5),
                    Text(
                      "Please have the exact amount ready upon delivery.",
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            Spacer(),
            Text(
              "TOTAL: \$96",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.start,
            ),
            SizedBox(height: 10),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                minimumSize: Size(double.infinity, 50),
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed:
                  selectedPaymentMethod == "assets/images/cash.png"
                      ? () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PaymentSuccessScreen(),
                          ),
                        );
                      }
                      : _makePayHerePayment,
              child: Text("PAY & CONFIRM"),
            ),
          ],
        ),
      ),
    );
  }
}
