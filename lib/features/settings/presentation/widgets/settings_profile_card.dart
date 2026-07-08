import 'package:flutter/material.dart';
import 'package:flutter_template/l10n/app_localizations.dart';

class SettingsProfileCard extends StatelessWidget {
  const SettingsProfileCard({super.key, required this.userName});

  final String? userName;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final name = userName?.trim();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              child: Text((name?.isNotEmpty ?? false) ? name!.characters.first.toUpperCase() : 'U'),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(userName ?? t.profile, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900)),
                  const SizedBox(height: 2),
                  Text(t.settingsProfileHint, style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
            OutlinedButton(onPressed: () {}, child: Text(t.edit)),
          ],
        ),
      ),
    );
  }
}
