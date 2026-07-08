import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_template/features/ponjika/presentation/cubit/ponjika_cubit.dart';

/// Shows which calendar year is loaded (updates when year changes).
class PonjikaYearBanner extends StatelessWidget {
  const PonjikaYearBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PonjikaCubit, PonjikaState>(
      buildWhen: (p, c) => p.year != c.year || p.load != c.load || p.data?.year != c.data?.year,
      builder: (context, state) {
        final loadedYear = state.data?.year;
        final syncing = state.load == PonjikaLoad.loading || loadedYear != state.year;
        final scheme = Theme.of(context).colorScheme;
        return Material(
          color: scheme.primaryContainer.withValues(alpha: 0.35),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                Icon(Icons.calendar_month_rounded, size: 20, color: scheme.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    syncing
                        ? 'Loading calendar ${state.year}…'
                        : 'Calendar year ${loadedYear ?? state.year}',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                  ),
                ),
                if (syncing)
                  SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: scheme.primary),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
