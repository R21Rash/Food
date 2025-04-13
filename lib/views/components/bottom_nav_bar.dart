import 'package:flutter/material.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;

  const CustomBottomNavBar({Key? key, required this.currentIndex})
    : super(key: key);

  void _navigate(BuildContext context, int index) {
    if (index == currentIndex) return; // avoid re-navigating to the same page

    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/restaurant_home');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/restaurant_list_screen');
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/restaurant_add_screen');
        break;
      case 3:
        Navigator.pushReplacementNamed(context, '/restaurant_notifications');
        break;
      case 4:
        Navigator.pushReplacementNamed(context, '/restaurant_profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) => _navigate(context, index),
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.grey[500],
        showUnselectedLabels: false,
        type: BottomNavigationBarType.fixed,
        selectedFontSize: 0,
        unselectedFontSize: 0,
        items: [
          _buildBarItem(Icons.grid_view, 0),
          _buildBarItem(Icons.menu, 1),
          _buildBarItem(Icons.add_circle, 2, isCenter: true),
          _buildBarItem(Icons.notifications_none, 3),
          _buildBarItem(Icons.person_outline, 4),
        ],
      ),
    );
  }

  BottomNavigationBarItem _buildBarItem(
    IconData icon,
    int index, {
    bool isCenter = false,
  }) {
    return BottomNavigationBarItem(
      label: '',
      icon: Container(
        decoration: BoxDecoration(
          color: isCenter ? Colors.orange.withOpacity(0.1) : Colors.transparent,
          shape: BoxShape.circle,
        ),
        padding: const EdgeInsets.all(8),
        child: Icon(icon, size: isCenter ? 30 : 24),
      ),
    );
  }
}
