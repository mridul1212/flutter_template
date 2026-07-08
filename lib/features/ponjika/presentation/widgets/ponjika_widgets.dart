import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_template/core/theme/app_colors.dart';
import 'package:flutter_template/features/ponjika/data/models/ponjika_models.dart';
import 'package:flutter_template/features/ponjika/presentation/cubit/ponjika_cubit.dart';
import 'package:flutter_template/l10n/app_localizations.dart';

/// Shared load / error / refresh wrapper for Ponjika feature screens.
class PonjikaLoadBody extends StatefulWidget {
  const PonjikaLoadBody({super.key, required this.builder});

  final Widget Function(BuildContext context, PonjikaData data) builder;

  @override
  State<PonjikaLoadBody> createState() => _PonjikaLoadBodyState();
}

class _PonjikaLoadBodyState extends State<PonjikaLoadBody> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<PonjikaCubit>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return BlocBuilder<PonjikaCubit, PonjikaState>(
      buildWhen: (p, c) =>
          p.load != c.load ||
          p.year != c.year ||
          p.data != c.data ||
          p.error != c.error,
      builder: (context, state) {
        final data = state.data;
        final ready = data != null && data.year == state.year && state.load == PonjikaLoad.success;

        if (data == null && state.load == PonjikaLoad.loading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state.load == PonjikaLoad.failure && data == null) {
          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Text(state.error ?? 'Unknown error', style: TextStyle(color: Theme.of(context).colorScheme.error)),
              const SizedBox(height: 12),
              FilledButton.tonal(
                onPressed: () => context.read<PonjikaCubit>().load(force: true),
                child: Text(t.retry),
              ),
            ],
          );
        }
        if (!ready) {
          return const Center(child: CircularProgressIndicator());
        }
        return RefreshIndicator(
          key: ValueKey<int>(state.year),
          onRefresh: () => context.read<PonjikaCubit>().load(force: true),
          child: widget.builder(context, data),
        );
      },
    );
  }
}

class PonjikaTodayCard extends StatelessWidget {
  const PonjikaTodayCard({super.key, required this.today, required this.year, required this.bengaliYear});

  final PonjikaToday today;
  final int year;
  final String bengaliYear;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: AppColors.brandGradient.map((c) => c.withValues(alpha: 0.95)).toList(growable: false),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'বাংলা পঞ্জিকা $year',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(color: scheme.onPrimary.withValues(alpha: 0.9)),
              ),
              Text(
                'বাংলা সাল $bengaliYear',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: scheme.onPrimary.withValues(alpha: 0.85)),
              ),
              const SizedBox(height: 10),
              Text(
                today.bengaliDate,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(color: scheme.onPrimary, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 6),
              Text(
                '${today.tithi} • ${today.paksha} Paksha • ${today.nakshatra}',
                style: TextStyle(color: scheme.onPrimary.withValues(alpha: 0.92)),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _MiniChip(icon: Icons.wb_sunny_outlined, label: 'Sunrise', value: today.sunrise)),
                  const SizedBox(width: 8),
                  Expanded(child: _MiniChip(icon: Icons.nights_stay_outlined, label: 'Sunset', value: today.sunset)),
                ],
              ),
              const SizedBox(height: 8),
              _MiniChip(icon: Icons.nightlight_round, label: 'Moonrise', value: today.moonrise),
            ],
          ),
        ),
      ),
    );
  }
}

class _MiniChip extends StatelessWidget {
  const _MiniChip({required this.icon, required this.label, required this.value});
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: scheme.onPrimary.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: scheme.onPrimary),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(color: scheme.onPrimary.withValues(alpha: 0.9), fontSize: 12)),
                Text(value, style: TextStyle(color: scheme.onPrimary, fontWeight: FontWeight.w800, fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.title, this.subtitle, this.trailing});

  final String title;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 8, 4, 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900)),
                if (subtitle != null) Text(subtitle!, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

Color lognoQualityColor(String quality) {
  return switch (quality) {
    'best' => AppColors.success,
    'good' => AppColors.brandTertiary,
    _ => AppColors.warmOrange,
  };
}

String lognoQualityLabel(String quality) {
  return switch (quality) {
    'best' => 'Best',
    'good' => 'Good',
    _ => 'Fair',
  };
}
