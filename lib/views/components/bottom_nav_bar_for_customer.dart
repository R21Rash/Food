import 'package:flutter/material.dart';

class BottomNavBarForCustomer extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavBarForCustomer({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

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
        onTap: onTap,
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.grey[500],
        showUnselectedLabels: false,
        type: BottomNavigationBarType.fixed,
        selectedFontSize: 0,
        unselectedFontSize: 0,
        items: [
          _buildBarItem(Icons.home_rounded, 0), // Home
          _buildBarItem(Icons.list_alt_rounded, 1), // Order List
          _buildBarItem(Icons.track_changes, 2), // Track Order
          _buildBarItem(Icons.person_outline, 3), // Profile
        ],
      ),
    );
  }

  BottomNavigationBarItem _buildBarItem(
    IconData icon,
    int index, {
    bool isCenter = false,
  }) {
    final bool isSelected = index == currentIndex;
    return BottomNavigationBarItem(
      label: '',
      icon: Container(
        decoration: BoxDecoration(
          color:
              isSelected ? Colors.orange.withOpacity(0.1) : Colors.transparent,
          shape: BoxShape.circle,
        ),
        padding: const EdgeInsets.all(8),
        child: Icon(
          icon,
          size: isSelected ? 28 : 24,
          color: isSelected ? Colors.orange : Colors.grey[500],
        ),
      ),
    );
  }
}
