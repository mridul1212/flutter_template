import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_template/core/theme/app_colors.dart';
import 'package:flutter_template/features/budget/data/models/budget_models.dart';
import 'package:flutter_template/features/budget/presentation/cubit/budget_cubit.dart';
import 'package:flutter_template/l10n/app_localizations.dart';

class BudgetPage extends StatefulWidget {
  const BudgetPage({super.key});

  @override
  State<BudgetPage> createState() => _BudgetPageState();
}

class _BudgetPageState extends State<BudgetPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => context.read<BudgetCubit>().load());
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('বাজেট পরিকল্পনা')),
      body: BlocBuilder<BudgetCubit, BudgetState>(
        builder: (context, state) {
          final data = state.data;
          if (data == null && state.load == BudgetLoad.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.load == BudgetLoad.failure && data == null) {
            return ListView(
              padding: const EdgeInsets.all(24),
              children: [
                Text(state.error ?? 'Error', style: TextStyle(color: Theme.of(context).colorScheme.error)),
                FilledButton.tonal(
                  onPressed: () => context.read<BudgetCubit>().load(force: true),
                  child: Text(t.retry),
                ),
              ],
            );
          }
          if (data == null) return const SizedBox.shrink();

          return RefreshIndicator(
            onRefresh: () => context.read<BudgetCubit>().load(force: true),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
              children: [
                _SummaryCard(data: data),
                const SizedBox(height: 16),
                Text(data.subtitle, style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 12),
                ...data.entries.map(
                  (entry) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _BudgetEntryCard(
                      entry: entry,
                      currency: data.currency,
                      busy: state.busyId == entry.id,
                      onSpentChanged: (v) => context.read<BudgetCubit>().setSpent(entry.id, v.round()),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.data});

  final BudgetData data;

  @override
  Widget build(BuildContext context) {
    final ratio = data.totalPlanned <= 0 ? 0.0 : data.totalSpent / data.totalPlanned;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(data.title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _Stat(label: 'Planned', value: '${data.currency}${data.totalPlanned}')),
                Expanded(child: _Stat(label: 'Spent', value: '${data.currency}${data.totalSpent}')),
                Expanded(
                  child: _Stat(
                    label: 'Left',
                    value: '${data.currency}${data.totalPlanned - data.totalSpent}',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: ratio.clamp(0, 1),
              minHeight: 8,
              borderRadius: BorderRadius.circular(8),
              color: ratio > 0.9 ? AppColors.warmOrange : AppColors.brandPrimary,
            ),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelMedium),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
      ],
    );
  }
}

class _BudgetEntryCard extends StatelessWidget {
  const _BudgetEntryCard({
    required this.entry,
    required this.currency,
    required this.busy,
    required this.onSpentChanged,
  });

  final BudgetEntry entry;
  final String currency;
  final bool busy;
  final ValueChanged<double> onSpentChanged;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(entry.title, style: const TextStyle(fontWeight: FontWeight.w800)),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(entry.category, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(entry.note, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('$currency${entry.spent} / $currency${entry.planned}'),
                Text('Left: $currency${entry.remaining}', style: const TextStyle(fontWeight: FontWeight.w700)),
              ],
            ),
            Slider(
              value: entry.spent.toDouble(),
              min: 0,
              max: entry.planned.toDouble().clamp(1, double.infinity),
              divisions: entry.planned >= 100 ? entry.planned ~/ 100 : null,
              label: '$currency${entry.spent}',
              onChanged: busy ? null : onSpentChanged,
            ),
          ],
        ),
      ),
    );
  }
}
