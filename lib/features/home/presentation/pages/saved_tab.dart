import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_template/features/home/presentation/cubit/home_feed_cubit.dart';
import 'package:flutter_template/features/home/presentation/widgets/feed_cards.dart';
import 'package:flutter_template/l10n/app_localizations.dart';

class SavedTab extends StatefulWidget {
  const SavedTab({super.key});

  @override
  State<SavedTab> createState() => _SavedTabState();
}

class _SavedTabState extends State<SavedTab> with AutomaticKeepAliveClientMixin {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => context.read<SavedCubit>().load());
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final scheme = Theme.of(context).colorScheme;
    final t = AppLocalizations.of(context);
    return BlocBuilder<SavedCubit, SavedState>(
      builder: (context, state) {
        final showSpinner = state.items.isEmpty && (state.load == FeedLoad.loading || state.load == FeedLoad.initial);
        if (showSpinner) return const Center(child: CircularProgressIndicator());
        if (state.load == FeedLoad.failure) {
          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Text(state.error ?? 'Unknown error', style: TextStyle(color: scheme.error)),
              const SizedBox(height: 12),
              FilledButton.tonal(
                onPressed: state.load == FeedLoad.loading ? null : () => context.read<SavedCubit>().load(force: true),
                child: Text(t.retry),
              ),
            ],
          );
        }
        return RefreshIndicator(
          onRefresh: () => context.read<SavedCubit>().load(force: true),
          child: ListView.separated(
            padding: const EdgeInsets.all(24),
            itemCount: state.items.length,
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemBuilder: (context, index) => FeedItemCard(item: state.items[index]),
          ),
        );
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}

