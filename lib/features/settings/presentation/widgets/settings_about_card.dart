import 'package:flutter/material.dart';
import 'package:flutter_template/l10n/app_localizations.dart';

class SettingsAboutCard extends StatelessWidget {
  const SettingsAboutCard({super.key, required this.version});

  final String? version;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(t.about, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900)),
            const SizedBox(height: 6),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(t.version),
              trailing: Text(version ?? '—'),
            ),
            ListTile(
              leading: const Icon(Icons.share_outlined),
              title: Text(t.shareApp),
              trailing: Text(t.share),
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}
