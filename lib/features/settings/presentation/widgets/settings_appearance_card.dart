import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_template/l10n/app_localizations.dart';
import 'package:flutter_template/presentation/locale/locale_cubit.dart';
import 'package:flutter_template/presentation/theme/theme_cubit.dart';

class SettingsAppearanceCard extends StatelessWidget {
  const SettingsAppearanceCard({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(t.appearance, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900)),
            const SizedBox(height: 6),
            BlocBuilder<ThemeCubit, ThemeMode>(
              builder: (context, mode) {
                final isDark = mode == ThemeMode.dark;
                return SwitchListTile.adaptive(
                  value: isDark,
                  onChanged: (v) => context.read<ThemeCubit>().setTheme(v ? ThemeMode.dark : ThemeMode.light),
                  title: Text(t.darkMode),
                  subtitle: Text(isDark ? t.darkEnabled : t.lightEnabled),
                );
              },
            ),
            const Divider(),
            BlocBuilder<LocaleCubit, Locale?>(
              builder: (context, locale) {
                final code = locale?.languageCode ?? 'system';
                return ListTile(
                  leading: const Icon(Icons.language_rounded),
                  title: Text(t.language),
                  subtitle: Text(t.chooseLanguage),
                  trailing: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: code,
                      items: [
                        DropdownMenuItem(value: 'system', child: Text(t.system)),
                        DropdownMenuItem(value: 'en', child: Text(t.english)),
                        DropdownMenuItem(value: 'bn', child: Text(t.bengali)),
                      ],
                      onChanged: (v) {
                        if (v == null) return;
                        context.read<LocaleCubit>().setLocale(v == 'system' ? null : Locale(v));
                      },
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
