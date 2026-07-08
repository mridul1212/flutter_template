import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_template/features/mondop/presentation/cubit/mondop_map_cubit.dart';

class MondopSearchBar extends StatelessWidget {
  const MondopSearchBar({super.key, required this.onFilterTap});

  final VoidCallback onFilterTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          children: [
            const Icon(Icons.search_rounded),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                decoration: const InputDecoration(
                  hintText: 'Search mondop, theme, city…',
                  border: InputBorder.none,
                  isDense: true,
                ),
                onChanged: (v) => context.read<MondopMapCubit>().setQuery(v),
              ),
            ),
            IconButton(onPressed: onFilterTap, icon: const Icon(Icons.tune_rounded)),
          ],
        ),
      ),
    );
  }
}

class MondopAreaChips extends StatelessWidget {
  const MondopAreaChips({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MondopMapCubit, MondopMapState>(
      buildWhen: (p, c) => p.areas != c.areas || p.areaFilter != c.areaFilter,
      builder: (context, state) {
        if (state.areas.isEmpty) return const SizedBox.shrink();
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              FilterChip(
                label: const Text('All'),
                selected: state.areaFilter == null,
                onSelected: (_) => context.read<MondopMapCubit>().setAreaFilter(null),
              ),
              const SizedBox(width: 8),
              ...state.areas.map(
                (area) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(area),
                    selected: state.areaFilter == area,
                    onSelected: (_) => context.read<MondopMapCubit>().setAreaFilter(area),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
