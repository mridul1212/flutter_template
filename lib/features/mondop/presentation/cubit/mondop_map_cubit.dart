import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_template/core/permissions/location_permission_service.dart';
import 'package:flutter_template/features/mondop/data/models/mondop_models.dart';
import 'package:flutter_template/features/mondop/data/repositories/mondop_repository.dart';

enum MondopLoad { initial, loading, success, failure }
enum MondopSort { nearest, highestRated }

final class MondopMapState extends Equatable {
  const MondopMapState({
    this.load = MondopLoad.initial,
    this.mondops = const [],
    this.areas = const [],
    this.userPosition,
    this.locationDenied = false,
    this.query = '',
    this.areaFilter,
    this.radiusKm = 5.0,
    this.sort = MondopSort.nearest,
    this.selectedRouteIds = const {},
    this.plannedRoute = const [],
    this.error,
  });

  final MondopLoad load;
  final List<MondopWithDistance> mondops;
  final List<String> areas;
  final MapPosition? userPosition;
  final bool locationDenied;
  final String query;
  final String? areaFilter;
  final double radiusKm;
  final MondopSort sort;
  final Set<String> selectedRouteIds;
  final List<MondopItem> plannedRoute;
  final String? error;

  List<MondopWithDistance> get filtered {
    final q = query.trim().toLowerCase();
    var list = mondops.where((m) {
      if (areaFilter != null && areaFilter!.isNotEmpty && m.mondop.area != areaFilter) return false;
      if (m.km != null && m.km! > radiusKm) return false;
      if (q.isEmpty) return true;
      final item = m.mondop;
      return item.name.toLowerCase().contains(q) ||
          item.theme.toLowerCase().contains(q) ||
          item.area.toLowerCase().contains(q);
    }).toList(growable: false);
    if (sort == MondopSort.highestRated) {
      list = [...list]..sort((a, b) => (b.mondop.rating ?? 0).compareTo(a.mondop.rating ?? 0));
    }
    return list;
  }

  double? get routeTotalKm {
    if (plannedRoute.length < 2) return null;
    var total = 0.0;
  MapPosition? from = userPosition ?? plannedRoute.first.position;
    for (final stop in plannedRoute) {
      total += LocationPermissionService.distanceKm(
        fromLat: from!.latitude,
        fromLng: from.longitude,
        toLat: stop.lat,
        toLng: stop.lng,
      );
      from = stop.position;
    }
    return total;
  }

  MondopMapState copyWith({
    MondopLoad? load,
    List<MondopWithDistance>? mondops,
    List<String>? areas,
    MapPosition? userPosition,
    bool? locationDenied,
    String? query,
    String? areaFilter,
    double? radiusKm,
    MondopSort? sort,
    Set<String>? selectedRouteIds,
    List<MondopItem>? plannedRoute,
    String? error,
    bool clearError = false,
    bool clearUser = false,
    bool clearAreaFilter = false,
    bool clearRoute = false,
  }) {
    return MondopMapState(
      load: load ?? this.load,
      mondops: mondops ?? this.mondops,
      areas: areas ?? this.areas,
      userPosition: clearUser ? null : (userPosition ?? this.userPosition),
      locationDenied: locationDenied ?? this.locationDenied,
      query: query ?? this.query,
      areaFilter: clearAreaFilter ? null : (areaFilter ?? this.areaFilter),
      radiusKm: radiusKm ?? this.radiusKm,
      sort: sort ?? this.sort,
      selectedRouteIds: clearRoute ? const {} : (selectedRouteIds ?? this.selectedRouteIds),
      plannedRoute: clearRoute ? const [] : (plannedRoute ?? this.plannedRoute),
      error: clearError ? null : (error ?? this.error),
    );
  }

  @override
  List<Object?> get props => [
        load, mondops, areas, userPosition, locationDenied, query, areaFilter,
        radiusKm, sort, selectedRouteIds, plannedRoute, error,
      ];
}

class MondopMapCubit extends Cubit<MondopMapState> {
  MondopMapCubit(this._repo, this._location) : super(const MondopMapState());

  final MondopRepository _repo;
  final LocationPermissionService _location;

  Future<void>? _inFlight;

  Future<void> load({bool force = false}) {
    if (!force && state.load == MondopLoad.success && state.mondops.isNotEmpty) {
      return Future.value();
    }
    final existing = _inFlight;
    if (existing != null) return existing;

    if (state.mondops.isEmpty) {
      emit(state.copyWith(load: MondopLoad.loading, clearError: true));
    } else {
      emit(state.copyWith(clearError: true));
    }

    final fut = _fetch(force: force).whenComplete(() => _inFlight = null);
    _inFlight = fut;
    return fut;
  }

  void setQuery(String query) => emit(state.copyWith(query: query));

  void setAreaFilter(String? area) {
    if (area == null || area.isEmpty) {
      emit(state.copyWith(clearAreaFilter: true));
    } else {
      emit(state.copyWith(areaFilter: area));
    }
  }

  void setRadiusKm(double km) => emit(state.copyWith(radiusKm: km));
  void setSort(MondopSort sort) => emit(state.copyWith(sort: sort));

  void toggleRouteSelection(String id) {
    final next = Set<String>.from(state.selectedRouteIds);
    if (next.contains(id)) {
      next.remove(id);
    } else {
      next.add(id);
    }
    emit(state.copyWith(selectedRouteIds: next, plannedRoute: const [], clearRoute: next.isEmpty));
  }

  void planRoute() {
    final selected = state.filtered
        .where((m) => state.selectedRouteIds.contains(m.mondop.id))
        .map((m) => m.mondop)
        .toList(growable: false);
    if (selected.isEmpty) return;

    final start = state.userPosition ?? selected.first.position;
    final remaining = [...selected];
    final ordered = <MondopItem>[];
    var current = start;

    while (remaining.isNotEmpty) {
      remaining.sort((a, b) {
        final da = LocationPermissionService.distanceKm(
          fromLat: current.latitude, fromLng: current.longitude, toLat: a.lat, toLng: a.lng,
        );
        final db = LocationPermissionService.distanceKm(
          fromLat: current.latitude, fromLng: current.longitude, toLat: b.lat, toLng: b.lng,
        );
        return da.compareTo(db);
      });
      final next = remaining.removeAt(0);
      ordered.add(next);
      current = next.position;
    }
    emit(state.copyWith(plannedRoute: ordered));
  }

  void clearRoute() => emit(state.copyWith(clearRoute: true));

  Future<void> _fetch({required bool force}) async {
    try {
      final items = await _repo.fetchMondops(force: force);
      MapPosition? user;
      var denied = false;

      if (_location.isSharingEnabled) {
        final pos = await _location.getCurrentPosition();
        if (pos != null) {
          user = MapPosition(pos.latitude, pos.longitude);
        } else {
          denied = true;
        }
      }

      final withDist = items.map((m) {
        final km = user == null
            ? null
            : LocationPermissionService.distanceKm(
                fromLat: user.latitude,
                fromLng: user.longitude,
                toLat: m.lat,
                toLng: m.lng,
              );
        return MondopWithDistance(m, km);
      }).toList(growable: false)
        ..sort((a, b) => (a.km ?? double.infinity).compareTo(b.km ?? double.infinity));

      emit(
        state.copyWith(
          load: MondopLoad.success,
          mondops: withDist,
          areas: _repo.areasFrom(items),
          userPosition: user,
          locationDenied: denied,
        ),
      );
    } catch (e) {
      emit(state.copyWith(load: MondopLoad.failure, error: e.toString()));
    }
  }
}
