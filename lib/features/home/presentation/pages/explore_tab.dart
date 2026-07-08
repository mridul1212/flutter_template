import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_template/features/home/presentation/cubit/home_feed_cubit.dart';
import 'package:flutter_template/features/home/data/models/feed_models.dart';
import 'package:flutter_template/features/home/presentation/widgets/feed_cards.dart';
import 'package:flutter_template/l10n/app_localizations.dart';

class ExploreTab extends StatefulWidget {
  const ExploreTab({super.key});

  @override
  State<ExploreTab> createState() => _ExploreTabState();
}

sealed class _ExploreRow {
  const _ExploreRow();
}

final class _ExploreHeaderRow extends _ExploreRow {
  const _ExploreHeaderRow(this.title);
  final String title;
}

final class _ExploreItemRow extends _ExploreRow {
  const _ExploreItemRow(this.item);
  final FeedItem item;
}

class _ExploreTabState extends State<ExploreTab> with AutomaticKeepAliveClientMixin {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => context.read<ExploreCubit>().load());
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final scheme = Theme.of(context).colorScheme;
    final t = AppLocalizations.of(context);
    return BlocBuilder<ExploreCubit, ExploreState>(
      builder: (context, state) {
        final showSpinner = state.sections.isEmpty && (state.load == FeedLoad.loading || state.load == FeedLoad.initial);
        if (showSpinner) return const Center(child: CircularProgressIndicator());
        if (state.load == FeedLoad.failure) {
          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Text(state.error ?? 'Unknown error', style: TextStyle(color: scheme.error)),
              const SizedBox(height: 12),
              FilledButton.tonal(
                onPressed: state.load == FeedLoad.loading ? null : () => context.read<ExploreCubit>().load(force: true),
                child: Text(t.retry),
              ),
            ],
          );
        }

        final rows = <_ExploreRow>[];
        for (final s in state.sections) {
          rows.add(_ExploreHeaderRow(s.title));
          for (final item in s.items) {
            rows.add(_ExploreItemRow(item));
          }
        }
        return RefreshIndicator(
          onRefresh: () => context.read<ExploreCubit>().load(force: true),
          child: ListView.builder(
            padding: const EdgeInsets.all(24),
            itemCount: rows.length,
            itemBuilder: (context, index) {
              final r = rows[index];
              if (r is _ExploreHeaderRow) {
                return Padding(
                  padding: EdgeInsets.only(top: index == 0 ? 0 : 18, bottom: 10),
                  child: Text(
                    r.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                  ),
                );
              }
              final item = (r as _ExploreItemRow).item;
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: FeedItemCard(item: item),
              );
            },
          ),
        );
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}

