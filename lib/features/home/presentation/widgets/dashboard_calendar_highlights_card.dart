import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_template/features/home/data/models/home_dashboard_models.dart';
import 'package:flutter_template/features/ponjika/data/mappers/calendar_highlights_mapper.dart';
import 'package:flutter_template/features/ponjika/presentation/cubit/ponjika_cubit.dart';
import 'package:flutter_template/presentation/router/app_route_paths.dart';
import 'package:go_router/go_router.dart';

class DashboardCalendarHighlightsCard extends StatelessWidget {
  const DashboardCalendarHighlightsCard({
    super.key,
    required this.fallback,
  });

  final HomeCalendarHighlights? fallback;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PonjikaCubit, PonjikaState>(
      buildWhen: (p, c) => p.year != c.year || p.data != c.data || p.load != c.load,
      builder: (context, ponState) {
        final live = ponState.data != null && ponState.data!.year == ponState.year
            ? CalendarHighlightsMapper.fromPonjika(ponState.data!)
            : null;
        final highlights = live ?? fallback;
        if (highlights == null) return const SizedBox.shrink();

        final syncing = live == null && ponState.load == PonjikaLoad.loading;
        return _HighlightsBody(highlights: highlights, syncing: syncing);
      },
    );
  }
}

class _HighlightsBody extends StatelessWidget {
  const _HighlightsBody({required this.highlights, required this.syncing});

  final HomeCalendarHighlights highlights;
  final bool syncing;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'পঞ্জিকা ${highlights.year}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
                  ),
                ),
                if (syncing)
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  Text(
                    '${highlights.pujaCountdownDays}d to Puja',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: scheme.primary,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(highlights.bengaliDate, style: Theme.of(context).textTheme.bodySmall),
            Text(highlights.tithi, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            DashboardHighlightTile(
              icon: Icons.access_time_filled_rounded,
              label: 'Best Logno today',
              value: highlights.bestLogno,
              onTap: () => context.push(AppRoutePaths.logno),
            ),
            const SizedBox(height: 8),
            DashboardHighlightTile(
              icon: Icons.date_range_rounded,
              label: highlights.nextEkadashi,
              value: highlights.nextEkadashiDate,
              onTap: () => context.push(AppRoutePaths.ekadashi),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => context.push(AppRoutePaths.ponjika),
                    child: const Text('Ponjika'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton.tonal(
                    onPressed: () => context.push(AppRoutePaths.logno),
                    child: const Text('Logno'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class DashboardHighlightTile extends StatelessWidget {
  const DashboardHighlightTile({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Icon(icon, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: Theme.of(context).textTheme.labelMedium),
                    Text(value, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w800)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
