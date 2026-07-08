import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_template/features/ponjika/presentation/cubit/ponjika_cubit.dart';

/// Year picker for Ponjika / Logno / Ekadashi (uses disk cache per year).
class PonjikaYearSelector extends StatelessWidget {
  const PonjikaYearSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PonjikaCubit, PonjikaState>(
      buildWhen: (p, c) => p.year != c.year,
      builder: (context, state) {
        final now = DateTime.now().year;
        final years = List<int>.generate(5, (i) => now - 2 + i);
        return PopupMenuButton<int>(
          tooltip: 'Calendar year',
          initialValue: state.year,
          onSelected: (y) => context.read<PonjikaCubit>().setYear(y),
          itemBuilder: (context) => years
              .map(
                (y) => PopupMenuItem(
                  value: y,
                  child: Text(y == now ? '$y (current)' : '$y'),
                ),
              )
              .toList(growable: false),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('${state.year}', style: const TextStyle(fontWeight: FontWeight.w800)),
                const Icon(Icons.arrow_drop_down_rounded),
              ],
            ),
          ),
        );
      },
    );
  }
}
