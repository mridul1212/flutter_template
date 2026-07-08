import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_template/core/theme/app_colors.dart';
import 'package:flutter_template/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:flutter_template/features/settings/presentation/widgets/settings_about_card.dart';
import 'package:flutter_template/features/settings/presentation/widgets/settings_appearance_card.dart';
import 'package:flutter_template/features/settings/presentation/widgets/settings_notifications_card.dart';
import 'package:flutter_template/features/settings/presentation/widgets/settings_privacy_card.dart';
import 'package:flutter_template/features/settings/presentation/widgets/settings_profile_card.dart';
import 'package:flutter_template/l10n/app_localizations.dart';
import 'package:flutter_template/presentation/router/app_router_cubit.dart';
import 'package:package_info_plus/package_info_plus.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String? _version;

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (!mounted) return;
      setState(() => _version = info.version);
    } catch (_) {
      // ignore
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final user = context.select<AppRouterCubit, String?>((c) => c.state.user?.name);

    return Scaffold(
      appBar: AppBar(title: Text(t.settingsTitle)),
      body: MultiBlocListener(
        listeners: [
          BlocListener<SettingsCubit, SettingsState>(
            listenWhen: (p, c) => c.message != null && c.message != p.message,
            listener: (context, state) {
              final msg = state.message;
              if (msg == null) return;
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
              context.read<SettingsCubit>().clearTransient();
            },
          ),
        ],
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
          children: [
            SettingsProfileCard(userName: user),
            const SizedBox(height: 16),
            const SettingsAppearanceCard(),
            const SizedBox(height: 16),
            const SettingsNotificationsCard(),
            const SizedBox(height: 16),
            const SettingsPrivacyCard(),
            const SizedBox(height: 16),
            SettingsAboutCard(version: _version),
            const SizedBox(height: 18),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: AppColors.brandSecondary),
              onPressed: () => context.read<AppRouterCubit>().logout(),
              child: Text(t.logOut),
            ),
          ],
        ),
      ),
    );
  }
}
