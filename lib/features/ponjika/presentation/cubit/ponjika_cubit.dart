import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_template/core/constants/app_constants.dart';
import 'package:flutter_template/features/ponjika/data/models/ponjika_models.dart';
import 'package:flutter_template/features/ponjika/data/repositories/ponjika_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum PonjikaLoad { initial, loading, success, failure }

final class PonjikaState extends Equatable {
  PonjikaState({
    this.load = PonjikaLoad.initial,
    int? year,
    this.data,
    this.cacheSource,
    this.error,
  }) : year = year ?? PonjikaRepository.currentCalendarYear;

  final PonjikaLoad load;
  final int year;
  final PonjikaData? data;
  final PonjikaCacheSource? cacheSource;
  final String? error;

  PonjikaState copyWith({
    PonjikaLoad? load,
    int? year,
    PonjikaData? data,
    PonjikaCacheSource? cacheSource,
    String? error,
    bool clearError = false,
    bool clearCacheSource = false,
    bool clearData = false,
  }) {
    return PonjikaState(
      load: load ?? this.load,
      year: year ?? this.year,
      data: clearData ? null : (data ?? this.data),
      cacheSource: clearCacheSource ? null : (cacheSource ?? this.cacheSource),
      error: clearError ? null : (error ?? this.error),
    );
  }

  @override
  List<Object?> get props => [load, year, data, cacheSource, error];
}

class PonjikaCubit extends Cubit<PonjikaState> {
  PonjikaCubit(this._repo, this._prefs) : super(PonjikaState(year: _initialYear(_prefs)));

  final PonjikaRepository _repo;
  final SharedPreferences _prefs;
  Future<void>? _inFlight;

  static int _initialYear(SharedPreferences prefs) {
    return prefs.getInt(AppConstants.ponjikaSelectedYearKey) ?? PonjikaRepository.currentCalendarYear;
  }

  /// Switch calendar year (serves from disk/memory when cached — no extra API).
  Future<void> setYear(int year) {
    _prefs.setInt(AppConstants.ponjikaSelectedYearKey, year);
    return load(year: year);
  }

  Future<void> load({bool force = false, int? year}) {
    final y = year ?? state.year;

    if (!force && state.load == PonjikaLoad.success && state.data != null && state.year == y) {
      return Future.value();
    }

    final existing = _inFlight;
    if (existing != null) return existing;

    final yearChanged = state.year != y;
    emit(
      state.copyWith(
        load: PonjikaLoad.loading,
        year: y,
        clearError: true,
        clearCacheSource: true,
        clearData: yearChanged || state.data == null,
      ),
    );

    final requestedYear = y;
    final fut = _repo
        .fetchPonjika(year: requestedYear, forceRefresh: force)
        .then((result) {
          if (state.year != requestedYear) return;
          emit(
            state.copyWith(
              load: PonjikaLoad.success,
              year: requestedYear,
              data: result.data,
              cacheSource: result.source,
            ),
          );
        })
        .catchError((e) {
          if (state.year != requestedYear) return;
          emit(state.copyWith(load: PonjikaLoad.failure, error: e.toString()));
        })
        .whenComplete(() => _inFlight = null);

    _inFlight = fut;
    return fut;
  }
}
