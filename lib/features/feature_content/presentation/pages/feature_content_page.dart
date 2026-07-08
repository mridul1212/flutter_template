import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_template/core/theme/app_colors.dart';
import 'package:flutter_template/features/feature_content/presentation/cubit/feature_content_cubit.dart';
import 'package:flutter_template/l10n/app_localizations.dart';

class FeatureContentPage extends StatefulWidget {
  const FeatureContentPage({super.key, required this.featureId});

  final String featureId;

  @override
  State<FeatureContentPage> createState() => _FeatureContentPageState();
}

class _FeatureContentPageState extends State<FeatureContentPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FeatureContentCubit>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return BlocBuilder<FeatureContentCubit, FeatureContentState>(
      builder: (context, state) {
        final data = state.data;
        if (data == null && state.load == FeatureContentLoad.loading) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: CircularProgressIndicator()),
          );
        }
        if (state.load == FeatureContentLoad.failure && data == null) {
          return Scaffold(
            appBar: AppBar(),
            body: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                Text(state.error ?? 'Error', style: TextStyle(color: Theme.of(context).colorScheme.error)),
                FilledButton.tonal(
                  onPressed: () => context.read<FeatureContentCubit>().load(force: true),
                  child: Text(t.retry),
                ),
              ],
            ),
          );
        }
        if (data == null) return const SizedBox.shrink();

        return Scaffold(
          appBar: AppBar(title: Text(data.title)),
          body: RefreshIndicator(
            onRefresh: () => context.read<FeatureContentCubit>().load(force: true),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
              children: [
                Card(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                        colors: AppColors.brandGradient.map((c) => c.withValues(alpha: 0.92)).toList(growable: false),
                      ),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${data.year}',
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.9),
                              ),
                        ),
                        Text(
                          data.subtitle,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Theme.of(context).colorScheme.onPrimary,
                                fontWeight: FontWeight.w900,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: data.items.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final item = data.items[index];
                    return Card(
                      child: ListTile(
                        title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.w800)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (item.subtitle.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(item.subtitle, style: Theme.of(context).textTheme.labelMedium),
                            ],
                            const SizedBox(height: 4),
                            Text(item.detail),
                          ],
                        ),
                        trailing: item.tag == null
                            ? null
                            : Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(item.tag!, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
                              ),
                        isThreeLine: true,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
