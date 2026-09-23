import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

/// A single bottom-navigation destination.
class AppBottomNavItem {
  const AppBottomNavItem({required this.icon, required this.label});

  final IconData icon;
  final String label;
}

/// A bottom navigation bar. Wraps Forui's [FBottomNavigationBar] and
/// [FBottomNavigationBarItem] behind plain data ([AppBottomNavItem]) so
/// screens build with data, not Forui widgets, directly.
class AppBottomNav extends StatelessWidget {
  const AppBottomNav({required this.items, required this.currentIndex, required this.onChanged, super.key});

  final List<AppBottomNavItem> items;
  final int currentIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) => FBottomNavigationBar(
    index: currentIndex,
    onChange: onChanged,
    children: [for (final item in items) FBottomNavigationBarItem(icon: Icon(item.icon), label: Text(item.label))],
  );
}
