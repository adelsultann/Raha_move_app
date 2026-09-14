import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../localization/l10n/app_localizations.dart';

/// Keeps the four primary destinations available while preserving each
/// branch's state. Focused flows, including the routine player, are routed
/// outside this shell.
class AppNavigationShell extends StatelessWidget {
  const AppNavigationShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: RahaNavigationBar(
        currentIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) {
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
      ),
    );
  }
}

/// The localized primary navigation shared by the application shell.
class RahaNavigationBar extends StatelessWidget {
  const RahaNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onDestinationSelected,
  });

  final int currentIndex;
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: onDestinationSelected,
      destinations: [
        NavigationDestination(
          icon: const Icon(Icons.home_outlined),
          selectedIcon: const Icon(Icons.home),
          label: strings.navigationHome,
        ),
        NavigationDestination(
          icon: const Icon(Icons.bookmarks_outlined),
          selectedIcon: const Icon(Icons.bookmarks),
          label: strings.navigationLibrary,
        ),
        NavigationDestination(
          icon: const Icon(Icons.insights_outlined),
          selectedIcon: const Icon(Icons.insights),
          label: strings.navigationProgress,
        ),
        NavigationDestination(
          icon: const Icon(Icons.person_outline),
          selectedIcon: const Icon(Icons.person),
          label: strings.navigationProfile,
        ),
      ],
    );
  }
}
