import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_template/features/auth/domain/entities/user_entity.dart';
import 'package:flutter_template/features/home/presentation/widgets/home_profile_stat_tile.dart';
import 'package:flutter_template/l10n/app_localizations.dart';
import 'package:flutter_template/presentation/locale/locale_cubit.dart';
import 'package:flutter_template/presentation/router/app_route_paths.dart';
import 'package:flutter_template/presentation/router/app_router_cubit.dart';
import 'package:flutter_template/presentation/theme/theme_cubit.dart';
import 'package:go_router/go_router.dart';

class HomeProfileTab extends StatelessWidget {
  const HomeProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.select<AppRouterCubit, UserEntity?>((c) => c.state.user);
    if (user == null) {
      return const Center(child: CircularProgressIndicator());
    }
    final t = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final avatar = user.avatarUrl ?? '';

    return ListView(
      padding: const EdgeInsets.all(24),
      scrollCacheExtent: const ScrollCacheExtent.pixels(400.0),
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
        Text(t.appearance, style: text.titleMedium),
        const SizedBox(height: 8),
        RepaintBoundary(
          child: BlocBuilder<ThemeCubit, ThemeMode>(
            buildWhen: (p, c) => p != c,
            builder: (context, mode) {
              return SegmentedButton<ThemeMode>(
                segments: [
                  ButtonSegment(value: ThemeMode.system, label: Text(t.system), icon: const Icon(Icons.brightness_auto)),
                  ButtonSegment(value: ThemeMode.light, label: Text(t.light), icon: const Icon(Icons.light_mode_outlined)),
                  ButtonSegment(value: ThemeMode.dark, label: Text(t.dark), icon: const Icon(Icons.dark_mode_outlined)),
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
        const SizedBox(height: 16),
        Text(t.language, style: text.titleMedium),
        const SizedBox(height: 8),
        RepaintBoundary(
          child: BlocBuilder<LocaleCubit, Locale?>(
            buildWhen: (p, c) => p != c,
            builder: (context, locale) {
              final code = locale?.languageCode;
              final selected = code ?? 'system';
              return SegmentedButton<String>(
                segments: [
                  ButtonSegment(value: 'system', label: Text(t.system), icon: const Icon(Icons.language_rounded)),
                  ButtonSegment(value: 'en', label: Text(t.english)),
                  ButtonSegment(value: 'bn', label: Text(t.bengali)),
                ],
                selected: {selected},
                onSelectionChanged: (selection) {
                  if (selection.isEmpty) return;
                  final v = selection.first;
                  context.read<LocaleCubit>().setLocale(v == 'system' ? null : Locale(v));
                },
              );
            },
          ),
        ),
        const SizedBox(height: 20),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.settings_outlined),
          title: Text(t.settingsTitle),
          subtitle: Text(t.settingsProfileHint),
          trailing: const Icon(Icons.chevron_right_rounded),
          onTap: () => context.push(AppRoutePaths.settings),
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.notifications_outlined),
          title: Text(t.notifications),
          subtitle: const Text('Permission, channels, test local alert'),
          trailing: const Icon(Icons.chevron_right_rounded),
          onTap: () => context.push(AppRoutePaths.notifications),
        ),
        const SizedBox(height: 28),
        Text('Dummy stats', style: text.titleMedium),
        const SizedBox(height: 12),
        const HomeProfileStatTile(title: 'Projects', value: '12', icon: Icons.folder_special_outlined),
        const HomeProfileStatTile(title: 'Tasks done', value: '128', icon: Icons.check_circle_outline),
        const HomeProfileStatTile(title: 'Streak', value: '7 days', icon: Icons.local_fire_department_outlined),
        const SizedBox(height: 24),
        FilledButton.tonalIcon(
          onPressed: () => context.read<AppRouterCubit>().logout(),
          icon: const Icon(Icons.logout_rounded),
          label: Text(t.logOut),
        ),
      ],
    );
  }
}
