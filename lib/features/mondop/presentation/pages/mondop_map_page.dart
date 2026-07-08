import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_template/features/mondop/data/models/mondop_models.dart';
import 'package:flutter_template/features/mondop/presentation/cubit/mondop_map_cubit.dart';
import 'package:flutter_template/features/mondop/presentation/widgets/mondop_list_panel.dart';
import 'package:flutter_template/features/mondop/presentation/widgets/mondop_offline_map.dart';
import 'package:flutter_template/features/mondop/presentation/widgets/mondop_search_bar.dart';
import 'package:flutter_template/l10n/app_localizations.dart';
import 'package:flutter_template/presentation/router/app_route_paths.dart';
import 'package:go_router/go_router.dart';

class MondopMapPage extends StatefulWidget {
  const MondopMapPage({super.key});

  @override
  State<MondopMapPage> createState() => _MondopMapPageState();
}

class _MondopMapPageState extends State<MondopMapPage> {
  String? _selectedId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MondopMapCubit>().load();
    });
  }

  void _selectMondop(MondopItem item) => setState(() => _selectedId = item.id);

  void _openDetail(MondopItem item) {
    context.push(AppRoutePaths.mondopDetailPath(item.id));
  }

  void _showFilterSheet() {
    final cubit = context.read<MondopMapCubit>();
    final areas = cubit.state.areas;
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Filter by city', style: Theme.of(ctx).textTheme.titleMedium),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: [
                  ActionChip(
                    label: const Text('All cities'),
                    onPressed: () {
                      cubit.setAreaFilter(null);
                      Navigator.pop(ctx);
                    },
                  ),
                  ...areas.map(
                    (a) => ActionChip(
                      label: Text(a),
                      onPressed: () {
                        cubit.setAreaFilter(a);
                        Navigator.pop(ctx);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Puja Mondops — Bangladesh'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Chip(
              avatar: const Icon(Icons.cloud_off_outlined, size: 18),
              label: const Text('Offline demo'),
            ),
          ),
        ],
      ),
      floatingActionButton: _selectedId == null
          ? null
          : FloatingActionButton.extended(
              onPressed: () {
                final item = context.read<MondopMapCubit>().state.mondops
                    .map((m) => m.mondop)
                    .where((m) => m.id == _selectedId)
                    .firstOrNull;
                if (item != null) _openDetail(item);
              },
              icon: const Icon(Icons.info_outline_rounded),
              label: const Text('Details'),
            ),
      body: BlocBuilder<MondopMapCubit, MondopMapState>(
        buildWhen: (p, c) =>
            p.load != c.load ||
            p.mondops != c.mondops ||
            p.query != c.query ||
            p.areaFilter != c.areaFilter ||
            p.userPosition != c.userPosition ||
            p.selectedRouteIds != c.selectedRouteIds ||
            p.plannedRoute != c.plannedRoute ||
            p.sort != c.sort,
        builder: (context, state) {
          final filtered = state.filtered;
          final cubit = context.read<MondopMapCubit>();

          if (state.mondops.isEmpty && state.load == MondopLoad.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.load == MondopLoad.failure && state.mondops.isEmpty) {
            return ListView(
              padding: const EdgeInsets.all(24),
              children: [
                Text(state.error ?? 'Unknown error', style: TextStyle(color: Theme.of(context).colorScheme.error)),
                const SizedBox(height: 12),
                FilledButton.tonal(
                  onPressed: () => context.read<MondopMapCubit>().load(force: true),
                  child: Text(t.retry),
                ),
              ],
            );
          }

          return Stack(
            children: [
              Positioned.fill(
                child: MondopOfflineMap(
                  mondops: filtered,
                  userPosition: state.userPosition,
                  selectedId: _selectedId,
                  onMondopTap: _selectMondop,
                ),
              ),
              Positioned(
                left: 16,
                right: 16,
                top: 12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    MondopSearchBar(onFilterTap: _showFilterSheet),
                    const SizedBox(height: 8),
                    const MondopAreaChips(),
                    const SizedBox(height: 6),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          FilterChip(
                            label: const Text('Nearest'),
                            selected: state.sort == MondopSort.nearest,
                            onSelected: (_) => cubit.setSort(MondopSort.nearest),
                          ),
                          const SizedBox(width: 6),
                          FilterChip(
                            label: const Text('Highest rated'),
                            selected: state.sort == MondopSort.highestRated,
                            onSelected: (_) => cubit.setSort(MondopSort.highestRated),
                          ),
                          const SizedBox(width: 6),
                          if (state.selectedRouteIds.isNotEmpty)
                            ActionChip(
                              avatar: const Icon(Icons.alt_route, size: 18),
                              label: Text('Plan (${state.selectedRouteIds.length})'),
                              onPressed: cubit.planRoute,
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (state.userPosition == null && state.load == MondopLoad.success)
                Positioned(
                  left: 16,
                  right: 16,
                  top: 120,
                  child: Card(
                    child: ListTile(
                      leading: const Icon(Icons.location_off_outlined),
                      title: Text(state.locationDenied ? t.locationPermissionDenied : t.locationSharing),
                      subtitle: const Text('Optional — map works offline with dummy data'),
                      trailing: TextButton(
                        onPressed: () => context.push(AppRoutePaths.settings),
                        child: Text(t.settingsTitle),
                      ),
                    ),
                  ),
                ),
              Positioned(
                left: 16,
                right: 16,
                bottom: 16,
                child: MondopListPanel(
                  mondops: filtered,
                  selectedId: _selectedId,
                  onTap: _selectMondop,
                  onOpenDetail: _openDetail,
                  routeHintKm: state.routeTotalKm,
                  selectedRouteIds: state.selectedRouteIds,
                  onToggleRoute: (item) => cubit.toggleRouteSelection(item.id),
                  plannedRoute: state.plannedRoute,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

extension _FirstOrNull<E> on Iterable<E> {
  E? get firstOrNull {
    final it = iterator;
    if (!it.moveNext()) return null;
    return it.current;
  }
}
