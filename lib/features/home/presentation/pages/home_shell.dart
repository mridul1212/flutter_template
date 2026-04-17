import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_template/core/di/app_dependencies.dart';
import 'package:flutter_template/features/auth/domain/entities/user_entity.dart';
import 'package:flutter_template/features/home/presentation/cubit/dashboard_cubit.dart';
import 'package:flutter_template/features/home/presentation/cubit/home_nav_cubit.dart';
import 'package:flutter_template/features/home/presentation/pages/dashboard_tab.dart';
import 'package:flutter_template/presentation/router/app_router_cubit.dart';
import 'package:flutter_template/presentation/theme/theme_cubit.dart';

class HomeShell extends StatelessWidget {
  const HomeShell({super.key, required this.dependencies, required this.user});

  final AppDependencies dependencies;
  final UserEntity user;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => HomeNavCubit()),
        BlocProvider(
          create: (_) => DashboardCubit(dependencies.postsRepository)..loadSample(),
        ),
      ],
      child: _HomeBody(user: user),
    );
  }
}

class _HomeBody extends StatelessWidget {
  const _HomeBody({required this.user});

  final UserEntity user;

  static const _titles = ['Home', 'Explore', 'Activity', 'Saved', 'Profile'];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeNavCubit, int>(
      builder: (context, index) {
        return Scaffold(
          appBar: AppBar(
            title: Text(_titles[index]),
            actions: [
              IconButton(
                tooltip: 'Notifications',
                onPressed: () {},
                icon: const Icon(Icons.notifications_none_rounded),
              ),
            ],
          ),
          body: IndexedStack(
            index: index,
            sizing: StackFit.expand,
            children: [
              const RepaintBoundary(child: DashboardTab()),
              const RepaintBoundary(
                child: _PlaceholderTab(
                  icon: Icons.travel_explore_rounded,
                  text: 'Explore lists, maps, or discovery — boilerplate ready.',
                ),
              ),
              const RepaintBoundary(
                child: _PlaceholderTab(
                  icon: Icons.timeline_rounded,
                  text: 'Recent activity feed — hook your API later.',
                ),
              ),
              const RepaintBoundary(
                child: _PlaceholderTab(
                  icon: Icons.bookmark_outline_rounded,
                  text: 'Saved items — swap with real persistence.',
                ),
              ),
              RepaintBoundary(child: _ProfileTab(user: user)),
            ],
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: index,
            onDestinationSelected: context.read<HomeNavCubit>().setTab,
            destinations: const [
              NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home_rounded), label: 'Home'),
              NavigationDestination(icon: Icon(Icons.explore_outlined), selectedIcon: Icon(Icons.explore), label: 'Explore'),
              NavigationDestination(
                icon: Icon(Icons.insights_outlined),
                selectedIcon: Icon(Icons.show_chart_rounded),
                label: 'Activity',
              ),
              NavigationDestination(icon: Icon(Icons.bookmark_border), selectedIcon: Icon(Icons.bookmark_rounded), label: 'Saved'),
              NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person_rounded), label: 'Profile'),
            ],
          ),
        );
      },
    );
  }
}

class _PlaceholderTab extends StatelessWidget {
  const _PlaceholderTab({required this.icon, required this.text});

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

class _ProfileTab extends StatelessWidget {
  const _ProfileTab({required this.user});

  final UserEntity user;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final avatar = user.avatarUrl ?? '';
    return ListView(
      padding: const EdgeInsets.all(24),
      cacheExtent: 400,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RepaintBoundary(
              child: CircleAvatar(
                radius: 48,
                backgroundColor: scheme.surfaceContainerHighest,
                child: ClipOval(
                  child: avatar.isEmpty
                      ? Icon(Icons.person, size: 48, color: scheme.primary)
                      : CachedNetworkImage(
                          imageUrl: avatar,
                          width: 96,
                          height: 96,
                          fit: BoxFit.cover,
                          filterQuality: FilterQuality.low,
                          fadeInDuration: Duration.zero,
                          fadeOutDuration: Duration.zero,
                          memCacheWidth: 192,
                          memCacheHeight: 192,
                          placeholder: (context, url) => const Padding(
                            padding: EdgeInsets.all(20),
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          errorWidget: (context, url, error) =>
                              Icon(Icons.broken_image_outlined, color: scheme.error),
                        ),
                ),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(user.name, style: text.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 6),
                  Text(user.email, style: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant)),
                  if (user.phone != null) ...[
                    const SizedBox(height: 4),
                    Text(user.phone!, style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant)),
                  ],
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Text('Appearance', style: text.titleMedium),
        const SizedBox(height: 8),
        RepaintBoundary(
          child: BlocBuilder<ThemeCubit, ThemeMode>(
            buildWhen: (p, c) => p != c,
            builder: (context, mode) {
              return SegmentedButton<ThemeMode>(
                segments: const [
                  ButtonSegment(value: ThemeMode.system, label: Text('System'), icon: Icon(Icons.brightness_auto)),
                  ButtonSegment(value: ThemeMode.light, label: Text('Light'), icon: Icon(Icons.light_mode_outlined)),
                  ButtonSegment(value: ThemeMode.dark, label: Text('Dark'), icon: Icon(Icons.dark_mode_outlined)),
                ],
                selected: {mode},
                onSelectionChanged: (selection) {
                  if (selection.isEmpty) return;
                  context.read<ThemeCubit>().setTheme(selection.first);
                },
              );
            },
          ),
        ),
        const SizedBox(height: 28),
        Text('Dummy stats', style: text.titleMedium),
        const SizedBox(height: 12),
        const _StatTile(title: 'Projects', value: '12', icon: Icons.folder_special_outlined),
        const _StatTile(title: 'Tasks done', value: '128', icon: Icons.check_circle_outline),
        const _StatTile(title: 'Streak', value: '7 days', icon: Icons.local_fire_department_outlined),
        const SizedBox(height: 24),
        FilledButton.tonalIcon(
          onPressed: () async {
            await context.read<AppRouterCubit>().logout();
          },
          icon: const Icon(Icons.logout_rounded),
          label: const Text('Log out'),
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.title, required this.value, required this.icon});

  final String title;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        trailing: Text(value, style: Theme.of(context).textTheme.titleMedium),
      ),
    );
  }
}
