import 'package:flutter/material.dart';

// Custom bottom navigation bar for tracking screens
class CustomBottomNavBarForTracking extends StatelessWidget {
  final int currentIndex; // Current selected tab index
  final void Function(int) onTap; // Callback for tab selection

  const CustomBottomNavBarForTracking({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // Styling for the navigation bar container
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07), // Subtle shadow effect
            blurRadius: 10,
            offset: const Offset(0, -2), // Shadow positioned above
          ),
        ],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20), // Rounded top-left corner
          topRight: Radius.circular(20), // Rounded top-right corner
        ),
      ),
      child: ClipRRect(
        // Clip the content to match the rounded corners
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        child: BottomNavigationBar(
          currentIndex: currentIndex, // Highlight the current tab
          onTap: onTap, // Handle tap events
          backgroundColor: Colors.white, // Background color of the bar
          type: BottomNavigationBarType.fixed, // Fixed layout for items
          selectedItemColor: Colors.orange, // Color for selected item
          unselectedItemColor: Colors.grey, // Color for unselected items
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600), // Style for selected label
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w400), // Style for unselected label
          showUnselectedLabels: true, // Show labels for all items
          items: [
            // Home tab
            BottomNavigationBarItem(
              icon: Icon(
                currentIndex == 0 ? Icons.home_rounded : Icons.home_outlined, // Toggle icon based on selection
              ),
              label: 'Home',
            ),
            // Tracking tab
            BottomNavigationBarItem(
              icon: Icon(
                currentIndex == 1
                    ? Icons.delivery_dining
                    : Icons.local_shipping_outlined, // Toggle icon based on selection
              ),
              label: 'Tracking',
            ),
            // Profile tab
            BottomNavigationBarItem(
              icon: Icon(
                currentIndex == 2 ? Icons.person_rounded : Icons.person_outline, // Toggle icon based on selection
              ),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
