import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_template/features/notifications/presentation/cubit/notification_cubit.dart';
import 'package:flutter_template/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:flutter_template/l10n/app_localizations.dart';
import 'package:flutter_template/presentation/router/app_route_paths.dart';
import 'package:go_router/go_router.dart';

class SettingsNotificationsCard extends StatelessWidget {
  const SettingsNotificationsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(t.notifications, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900)),
            const SizedBox(height: 6),
            BlocBuilder<SettingsCubit, SettingsState>(
              builder: (context, s) {
                return Column(
                  children: [
                    SwitchListTile.adaptive(
                      value: s.pushNotifications,
                      onChanged: (v) async {
                        final settingsCubit = context.read<SettingsCubit>();
                        final notificationCubit = context.read<NotificationCubit>();
                        await settingsCubit.setPushNotifications(v);
                        if (v) {
                          if (!context.mounted) return;
                          await notificationCubit.requestPermission();
                        }
                      },
                      title: Text(t.pushNotifications),
                      subtitle: Text(t.pushNotificationsHint),
                    ),
                    SwitchListTile.adaptive(
                      value: s.anjaliReminders,
                      onChanged: (v) => context.read<SettingsCubit>().setAnjaliReminders(v),
                      title: Text(t.anjaliReminders),
                    ),
                    SwitchListTile.adaptive(
                      value: s.eventAlerts,
                      onChanged: (v) => context.read<SettingsCubit>().setEventAlerts(v),
                      title: Text(t.eventAlerts),
                    ),
                    SwitchListTile.adaptive(
                      value: s.nearbyPujaAlerts,
                      onChanged: (v) => context.read<SettingsCubit>().setNearbyPujaAlerts(v),
                      title: Text(t.nearbyPujaAlerts),
                    ),
                    SwitchListTile.adaptive(
                      value: s.groupUpdates,
                      onChanged: (v) => context.read<SettingsCubit>().setGroupUpdates(v),
                      title: Text(t.groupUpdates),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerLeft,
              child: OutlinedButton.icon(
                onPressed: () => context.push(AppRoutePaths.notifications),
                icon: const Icon(Icons.open_in_new_rounded),
                label: Text(t.openNotificationTools),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
