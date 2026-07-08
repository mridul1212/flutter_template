import 'package:flutter/material.dart';
import 'package:flutter_template/l10n/app_localizations.dart';
import 'package:flutter_template/presentation/router/app_route_paths.dart';
import 'package:go_router/go_router.dart';

/// Bottom navigation + [StatefulNavigationShell] from [go_router].
class HomeShellView extends StatelessWidget {
  const HomeShellView({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final index = navigationShell.currentIndex;
    final t = AppLocalizations.of(context);
    final titles = [t.home, t.explore, t.activity, t.saved, t.profile];
    return Scaffold(
      appBar: AppBar(
        title: Text(titles[index]),
        actions: [
          IconButton(
            tooltip: t.notifications,
            onPressed: () => context.push(AppRoutePaths.notifications),
            icon: const Icon(Icons.notifications_none_rounded),
          ),
          IconButton(
            tooltip: t.settingsTitle,
            onPressed: () => context.push(AppRoutePaths.settings),
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
      body: RepaintBoundary(child: navigationShell),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: navigationShell.goBranch,
        destinations: [
          NavigationDestination(icon: const Icon(Icons.home_outlined), selectedIcon: const Icon(Icons.home_rounded), label: t.home),
          NavigationDestination(icon: const Icon(Icons.explore_outlined), selectedIcon: const Icon(Icons.explore), label: t.explore),
          NavigationDestination(
            icon: const Icon(Icons.insights_outlined),
            selectedIcon: const Icon(Icons.show_chart_rounded),
            label: t.activity,
          ),
          NavigationDestination(icon: const Icon(Icons.bookmark_border), selectedIcon: const Icon(Icons.bookmark_rounded), label: t.saved),
          NavigationDestination(icon: const Icon(Icons.person_outline), selectedIcon: const Icon(Icons.person_rounded), label: t.profile),
        ],
      ),
    );
  }
}

class HomePlaceholderTab extends StatelessWidget {
  const HomePlaceholderTab({super.key, required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 56, color: scheme.primary.withValues(alpha: 0.85)),
              const SizedBox(height: 16),
              Text(
                text,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: scheme.onSurfaceVariant, height: 1.35),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
