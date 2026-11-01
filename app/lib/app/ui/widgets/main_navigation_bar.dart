import '../../copy/app_copy.dart';

import 'package:flutter/material.dart';

class MainNavigationBar extends StatelessWidget {
  const MainNavigationBar({
    super.key,
    required this.selectedIndex,
    required this.onSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) => NavigationBar(
    selectedIndex: selectedIndex,
    onDestinationSelected: onSelected,
    destinations: const [
      NavigationDestination(
        icon: Icon(Icons.explore_outlined),
        selectedIcon: Icon(Icons.explore),
        label: AppCopy.discover,
      ),
      NavigationDestination(
        icon: Icon(Icons.chat_bubble_outline),
        selectedIcon: Icon(Icons.chat_bubble),
        label: AppCopy.chats,
      ),
      NavigationDestination(
        icon: Icon(Icons.call_outlined),
        selectedIcon: Icon(Icons.call),
        label: AppCopy.calls,
      ),
      NavigationDestination(
        icon: Icon(Icons.circle_outlined),
        selectedIcon: Icon(Icons.circle),
        label: AppCopy.status,
      ),
      NavigationDestination(
        icon: Icon(Icons.person_outline),
        selectedIcon: Icon(Icons.person),
        label: AppCopy.profile,
      ),
    ],
  );
}
