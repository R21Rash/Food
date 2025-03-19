import 'package:flutter/material.dart';
import 'package:mobile_app_flutter/views/payment/payment_succ.dart';

class PaymentScreen extends StatefulWidget {
  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String selectedPaymentMethod = "assets/images/master.png";
  bool hasCard = false;
  String cardNumber = "";

  void _showAddCardDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            height: 380, // Increased height for better spacing
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row (Title + Close Button)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Add Card",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: Colors.grey.shade600),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                Divider(), // Aesthetic separator
                // Card Holder Name
                TextField(
                  decoration: InputDecoration(
                    labelText: "Card Holder Name",
                    prefixIcon: Icon(Icons.person, color: Colors.orange),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                SizedBox(height: 10),

                // Card Number
                TextField(
                  decoration: InputDecoration(
                    labelText: "Card Number",
                    prefixIcon: Icon(Icons.credit_card, color: Colors.orange),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 10),

                // Expiry Date & CVC Row
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          labelText: "Expire Date",
                          prefixIcon: Icon(
                            Icons.calendar_today,
                            color: Colors.orange,
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          labelText: "CVC",
                          prefixIcon: Icon(Icons.lock, color: Colors.orange),
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),

                // Stylish Add Card Button
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    minimumSize: Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                  ),
                  onPressed: () {
                    setState(() {
                      hasCard = true;
                      cardNumber = "**** **** **** 436";
                    });
                    Navigator.pop(context);
                  },
                  child: Text(
                    "ADD & MAKE PAYMENT",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        );
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
            // Conditional UI based on selected payment method
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
              )
            else if (selectedPaymentMethod == "assets/images/visa.png" ||
                selectedPaymentMethod == "assets/images/master.png")
              !hasCard
                  ? Container(
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
                        Icon(Icons.credit_card, size: 40, color: Colors.orange),
                        SizedBox(height: 10),
                        Text(
                          "No card added",
                          style: TextStyle(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 5),
                        Text(
                          "You can add a card and save it for later",
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 10),
                        TextButton(
                          onPressed: _showAddCardDialog,
                          child: Text(
                            "+ ADD NEW",
                            style: TextStyle(color: Colors.orange),
                          ),
                        ),
                      ],
                    ),
                  )
                  : Container(
                    padding: EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(color: Colors.grey.shade200, blurRadius: 5),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.credit_card,
                              size: 30,
                              color: Colors.orange,
                            ),
                            SizedBox(width: 10),
                            Text("Master Card"),
                          ],
                        ),
                        Text(cardNumber),
                      ],
                    ),
                  ),
            Spacer(),
            // Total and confirm button
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
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PaymentSuccessScreen(),
                  ),
                );
              },
              child: Text("PAY & CONFIRM"),
            ),
          ],
        ),
      ),
    );
  }
}
