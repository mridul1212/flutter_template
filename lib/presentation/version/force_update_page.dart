import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ForceUpdatePage extends StatelessWidget {
  const ForceUpdatePage({
    super.key,
    required this.storeUrl,
    this.message,
  });

  final Uri storeUrl;
  final String? message;

  Future<void> _openStore() async {
    if (storeUrl.toString().isEmpty) {
      return;
    }
    final mode = LaunchMode.externalApplication;
    if (await canLaunchUrl(storeUrl)) {
      await launchUrl(storeUrl, mode: mode);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return PopScope(
      canPop: false,
      child: Material(
        color: scheme.surface,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Spacer(),
                Icon(Icons.system_update_alt_rounded, size: 72, color: scheme.primary),
                const SizedBox(height: 20),
                Text('Update required', style: text.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(height: 12),
                Text(
                  message ??
                      'Your app version is no longer supported. Install the latest release to continue.',
                  style: text.bodyLarge?.copyWith(color: scheme.onSurfaceVariant, height: 1.35),
                ),
                const SizedBox(height: 28),
                FilledButton(
                  onPressed: storeUrl.toString().isEmpty ? null : _openStore,
                  child: const Text('Open store'),
                ),
                if (storeUrl.toString().isEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    'Configure `android_store_url` / `ios_store_url` in assets/config/version_policy.json.',
                    style: text.bodySmall?.copyWith(color: scheme.error),
                  ),
                ],
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
