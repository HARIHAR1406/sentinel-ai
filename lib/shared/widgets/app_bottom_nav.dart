import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';

class AppBottomNav extends StatelessWidget {
  const AppBottomNav({super.key});

  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/home')) return 0;
    if (location.startsWith('/map')) return 1;
    if (location.startsWith('/alerts')) return 3;
    if (location.startsWith('/profile')) return 4;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/home');
        break;
      case 1:
        context.go('/map');
        break;
      case 2:
        // Report action is handled by FAB
        break;
      case 3:
        context.go('/alerts');
        break;
      case 4:
        context.go('/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return BottomAppBar(
      color: isDark ? AppColors.raisedSurfaceDark : AppColors.elevatedLight,
      shape: const CircularNotchedRectangle(),
      notchMargin: 8.0,
      padding: EdgeInsets.zero,
      child: BottomNavigationBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        type: BottomNavigationBarType.fixed,
        currentIndex: _calculateSelectedIndex(context),
        onTap: (index) => _onItemTapped(index, context),
        selectedItemColor: AppColors.sentinelBlue,
        unselectedItemColor: isDark ? AppColors.textSecondaryLight : AppColors.textSecondaryDark,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w400, fontSize: 12),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.map_outlined), activeIcon: Icon(Icons.map), label: 'Map'),
          BottomNavigationBarItem(icon: Icon(Icons.add, color: Colors.transparent), label: 'Report'), // Placeholder for FAB
          BottomNavigationBarItem(icon: Icon(Icons.notifications_outlined), activeIcon: Icon(Icons.notifications), label: 'Alerts'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
