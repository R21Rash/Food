import 'package:flutter/material.dart';

class CustomBottomNavBarForTracking extends StatelessWidget {
  final int currentIndex;
  final void Function(int) onTap;

  const CustomBottomNavBarForTracking({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: onTap,
          backgroundColor: Colors.white,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Colors.orange,
          unselectedItemColor: Colors.grey,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w400),
          showUnselectedLabels: true,
          items: [
            BottomNavigationBarItem(
              icon: Icon(
                currentIndex == 0 ? Icons.home_rounded : Icons.home_outlined,
              ),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                currentIndex == 1
                    ? Icons.delivery_dining
                    : Icons.local_shipping_outlined,
              ),
              label: 'Tracking',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                currentIndex == 2 ? Icons.person_rounded : Icons.person_outline,
              ),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
