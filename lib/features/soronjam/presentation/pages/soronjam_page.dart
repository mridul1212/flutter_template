import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_template/core/theme/app_colors.dart';
import 'package:flutter_template/features/soronjam/data/models/soronjam_models.dart';
import 'package:flutter_template/features/soronjam/presentation/cubit/soronjam_cubit.dart';
import 'package:flutter_template/l10n/app_localizations.dart';

class SoronjamPage extends StatefulWidget {
  const SoronjamPage({super.key});

  @override
  State<SoronjamPage> createState() => _SoronjamPageState();
}

class _SoronjamPageState extends State<SoronjamPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => context.read<SoronjamCubit>().load());
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('পূজো সরঞ্জাম')),
      body: BlocBuilder<SoronjamCubit, SoronjamState>(
        builder: (context, state) {
          final data = state.data;
          if (data == null && state.load == SoronjamLoad.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.load == SoronjamLoad.failure && data == null) {
            return ListView(
              padding: const EdgeInsets.all(24),
              children: [
                Text(state.error ?? 'Error', style: TextStyle(color: Theme.of(context).colorScheme.error)),
                FilledButton.tonal(
                  onPressed: () => context.read<SoronjamCubit>().load(force: true),
                  child: Text(t.retry),
                ),
              ],
            );
          }
          if (data == null) return const SizedBox.shrink();

          return RefreshIndicator(
            onRefresh: () => context.read<SoronjamCubit>().load(force: true),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
              children: [
                _ProgressCard(data: data),
                const SizedBox(height: 16),
                Text(data.subtitle, style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 12),
                ...data.items.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _ChecklistTile(
                      item: item,
                      busy: state.busyId == item.id,
                      onChanged: (v) => context.read<SoronjamCubit>().toggle(item.id, v),
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

class _ProgressCard extends StatelessWidget {
  const _ProgressCard({required this.data});

  final SoronjamData data;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(data.title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: data.progress,
              minHeight: 8,
              borderRadius: BorderRadius.circular(8),
              color: AppColors.brandPrimary,
            ),
            const SizedBox(height: 8),
            Text(
              '${data.checkedCount} / ${data.items.length} items ready',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChecklistTile extends StatelessWidget {
  const _ChecklistTile({required this.item, required this.busy, required this.onChanged});

  final SoronjamItem item;
  final bool busy;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final tagColor = switch (item.priority) {
      'must' => AppColors.danger,
      'daily' => scheme.primary,
      _ => scheme.tertiary,
    };
    return Card(
      child: CheckboxListTile(
        value: item.checked,
        onChanged: busy ? null : (v) => onChanged(v ?? false),
        secondary: busy
            ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
            : null,
        title: Text(
          item.title,
          style: TextStyle(
            fontWeight: FontWeight.w800,
            decoration: item.checked ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('${item.category} • ${item.detail}'),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: tagColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(item.priority.toUpperCase(), style: TextStyle(fontSize: 10, color: tagColor, fontWeight: FontWeight.w800)),
            ),
          ],
        ),
        controlAffinity: ListTileControlAffinity.leading,
        isThreeLine: true,
      ),
    );
  }
}
