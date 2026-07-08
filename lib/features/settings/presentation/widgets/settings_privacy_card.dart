import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_template/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:flutter_template/l10n/app_localizations.dart';

class SettingsPrivacyCard extends StatelessWidget {
  const SettingsPrivacyCard({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(t.privacySecurity, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900)),
            const SizedBox(height: 6),
            BlocBuilder<SettingsCubit, SettingsState>(
              builder: (context, s) {
                return SwitchListTile.adaptive(
                  value: s.locationSharing,
                  onChanged: (v) async {
                    final settingsCubit = context.read<SettingsCubit>();
                    if (v) {
                      final ok = await settingsCubit.enableLocationSharing();
                      if (!ok) {
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t.locationPermissionDenied)));
                      }
                      return;
                    }
                    await settingsCubit.setLocationSharing(false);
                  },
                  title: Text(t.locationSharing),
                  subtitle: Text(t.locationSharingHint),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.policy_outlined),
              title: Text(t.privacyPolicy),
              trailing: Text(t.view),
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}
