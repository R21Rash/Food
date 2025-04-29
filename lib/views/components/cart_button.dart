import 'package:flutter/material.dart';

// Custom cart button widget with item count badge
class CartButton extends StatelessWidget {
  final int cartItemCount; // Number of items in the cart
  final VoidCallback onCartPressed; // Callback for cart button press

  const CartButton({
    Key? key,
    required this.cartItemCount,
    required this.onCartPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Cart icon button
        IconButton(
          icon: const Icon(Icons.shopping_bag_outlined, color: Colors.black), // Shopping bag icon
          onPressed: onCartPressed, // Trigger callback on press
        ),
        // Show item count badge if cart is not empty
        if (cartItemCount > 0)
          Positioned(
            right: 8, // Position badge to the right
            top: 8, // Position badge at the top
            child: Container(
              padding: const EdgeInsets.all(4), // Padding inside badge
              decoration: BoxDecoration(
                color: Colors.orange, // Badge background color
                borderRadius: BorderRadius.circular(10), // Rounded badge
              ),
              child: Text(
                cartItemCount.toString(), // Display item count
                style: const TextStyle(fontSize: 12, color: Colors.white), // Text style for badge
              ),
            ),
          ),
      ],
    );
  }
}
