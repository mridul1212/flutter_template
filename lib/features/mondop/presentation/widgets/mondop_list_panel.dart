import 'package:flutter/material.dart';
import 'package:flutter_template/features/mondop/data/models/mondop_models.dart';

class MondopListPanel extends StatelessWidget {
  const MondopListPanel({
    super.key,
    required this.mondops,
    required this.selectedId,
    required this.onTap,
    required this.onOpenDetail,
    this.routeHintKm,
    this.selectedRouteIds = const {},
    this.onToggleRoute,
    this.plannedRoute = const [],
  });

  final List<MondopWithDistance> mondops;
  final String? selectedId;
  final ValueChanged<MondopItem> onTap;
  final ValueChanged<MondopItem> onOpenDetail;
  final double? routeHintKm;
  final Set<String> selectedRouteIds;
  final ValueChanged<MondopItem>? onToggleRoute;
  final List<MondopItem> plannedRoute;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (plannedRoute.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Card(
              color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.4),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Planned route', style: TextStyle(fontWeight: FontWeight.w900)),
                    ...plannedRoute.asMap().entries.map(
                          (e) => Text('${e.key + 1}. ${e.value.name}', style: Theme.of(context).textTheme.bodySmall),
                        ),
                    if (routeHintKm != null)
                      Text('~${routeHintKm!.toStringAsFixed(2)} km total', style: const TextStyle(fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            ),
          )
        else if (routeHintKm != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Row(
                  children: [
                    const Icon(Icons.alt_route_rounded),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Nearest route hint: ${routeHintKm!.toStringAsFixed(2)} km',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        SizedBox(
          height: 260,
          child: Card(
            child: ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: mondops.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final m = mondops[index];
                final selected = m.mondop.id == selectedId;
                return MondopListTile(
                  item: m,
                  selected: selected,
                  inRoute: selectedRouteIds.contains(m.mondop.id),
                  onTap: () => onTap(m.mondop),
                  onOpenDetail: () => onOpenDetail(m.mondop),
                  onToggleRoute: onToggleRoute == null ? null : () => onToggleRoute!(m.mondop),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class MondopListTile extends StatelessWidget {
  const MondopListTile({
    super.key,
    required this.item,
    required this.selected,
    required this.onTap,
    required this.onOpenDetail,
    this.inRoute = false,
    this.onToggleRoute,
  });

  final MondopWithDistance item;
  final bool selected;
  final bool inRoute;
  final VoidCallback onTap;
  final VoidCallback onOpenDetail;
  final VoidCallback? onToggleRoute;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final m = item.mondop;
    return ListTile(
      selected: selected,
      selectedTileColor: scheme.primary.withValues(alpha: 0.08),
      onTap: onTap,
      leading: CircleAvatar(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        child: Text('${m.index}'),
      ),
      title: Text(m.name, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(
        '${m.area} • ${item.km == null ? '—' : '${item.km!.toStringAsFixed(1)} km'} • ${m.theme}'
        '${m.rating != null ? ' • ★${m.rating!.toStringAsFixed(1)}' : ''}',
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (onToggleRoute != null)
            IconButton(
              onPressed: onToggleRoute,
              icon: Icon(inRoute ? Icons.check_circle_rounded : Icons.add_location_alt_outlined),
              color: inRoute ? Theme.of(context).colorScheme.primary : null,
            ),
          IconButton(
            onPressed: onOpenDetail,
            icon: const Icon(Icons.arrow_forward_rounded),
            tooltip: 'View details',
          ),
        ],
      ),
    );
  }
}
