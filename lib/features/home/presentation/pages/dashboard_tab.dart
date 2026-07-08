import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_template/features/home/presentation/cubit/home_dashboard_cubit.dart';
import 'package:flutter_template/features/home/presentation/widgets/dashboard_calendar_highlights_card.dart';
import 'package:flutter_template/features/home/presentation/widgets/dashboard_countdown_card.dart';
import 'package:flutter_template/features/home/presentation/widgets/dashboard_features_grid.dart';
import 'package:flutter_template/l10n/app_localizations.dart';

class DashboardTab extends StatefulWidget {
  const DashboardTab({super.key});

  @override
  State<DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<DashboardTab> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final scheme = Theme.of(context).colorScheme;
    final t = AppLocalizations.of(context);

    return BlocBuilder<HomeDashboardCubit, HomeDashboardState>(
      builder: (context, state) {
        final data = state.data;
        if (state.load == HomeDashLoad.loading && data == null) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state.load == HomeDashLoad.failure && data == null) {
          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Text(state.error ?? 'Unknown error', style: TextStyle(color: scheme.error)),
              const SizedBox(height: 12),
              FilledButton.tonal(
                onPressed: () => context.read<HomeDashboardCubit>().load(force: true),
                child: Text(t.retry),
              ),
            ],
          );
        }

        final countdown = data?.countdown;
        final remaining = state.remaining;

        return RefreshIndicator(
          onRefresh: () => context.read<HomeDashboardCubit>().load(force: true),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            children: [
              if (countdown != null && remaining != null)
                DashboardCountdownCard(countdown: countdown, remaining: remaining),
              const SizedBox(height: 16),
              DashboardCalendarHighlightsCard(fallback: data?.calendarHighlights),
              const SizedBox(height: 18),
              Text(
                data?.featuresTitle ?? 'Explore Features',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 12),
              DashboardFeaturesGrid(features: data?.features ?? const []),
            ],
          ),
        );
      },
    );
  }
}
