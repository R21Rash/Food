import 'package:flutter/material.dart';

class TrackOrderScreen extends StatelessWidget {
  final List<String> steps = [
    "Your order has been received",
    "The restaurant is preparing your food",
    "Your order has been picked up for delivery",
    "Order arriving soon!",
  ];

  final int currentStep = 1; // 👈 Change this to reflect the real progress

  // Sample courier name
  final String courierName = "Rashad Cader";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("Track Order"),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Text(
              "20 min",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              "ESTIMATED DELIVERY TIME",
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 30),
            ...List.generate(steps.length, (index) {
              return _buildStep(index, steps[index], index == currentStep);
            }),
            const Spacer(),
            _buildCourierInfo(),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/customer_home');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                minimumSize: const Size(double.infinity, 48),
              ),
              child: const Text("Return Home"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep(int index, String text, bool isCurrent) {
    Color getDotColor() {
      if (index <= currentStep) return Colors.orange;
      return Colors.grey[300]!;
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Icon(
              index == 0
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: getDotColor(),
              size: 20,
            ),
            if (index != steps.length - 1)
              Container(height: 30, width: 2, color: Colors.grey[300]),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 2.0),
            child: Text(
              text,
              style: TextStyle(
                color: isCurrent ? Colors.black : Colors.grey,
                fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCourierInfo() {
    final initials =
        courierName
            .split(" ")
            .map((e) => e.isNotEmpty ? e[0].toUpperCase() : '')
            .take(2)
            .join();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: Colors.orange,
            child: Text(
              initials,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              courierName,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.phone, color: Colors.orange),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.message, color: Colors.orange),
          ),
        ],
      ),
    );
  }
}
