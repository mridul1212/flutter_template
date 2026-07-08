import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_template/features/home/data/models/home_dashboard_models.dart';
import 'package:flutter_template/features/home/data/repositories/home_dashboard_repository.dart';

enum HomeDashLoad { initial, loading, success, failure }

final class HomeDashboardState extends Equatable {
  const HomeDashboardState({
    this.load = HomeDashLoad.initial,
    this.data,
    this.now,
    this.error,
  });

  final HomeDashLoad load;
  final HomeDashboardData? data;
  final DateTime? now;
  final String? error;

  Duration? get remaining {
    final d = data;
    final n = now;
    if (d == null || n == null) return null;
    final diff = d.countdown.target.difference(n);
    return diff.isNegative ? Duration.zero : diff;
  }

  HomeDashboardState copyWith({
    HomeDashLoad? load,
    HomeDashboardData? data,
    DateTime? now,
    String? error,
    bool clearError = false,
  }) {
    return HomeDashboardState(
      load: load ?? this.load,
      data: data ?? this.data,
      now: now ?? this.now,
      error: clearError ? null : (error ?? this.error),
    );
  }

  @override
  List<Object?> get props => [load, data, now, error];
}

class HomeDashboardCubit extends Cubit<HomeDashboardState> {
  HomeDashboardCubit(this._repo) : super(const HomeDashboardState());

  final HomeDashboardRepository _repo;
  Future<void>? _inFlight;
  Timer? _ticker;

  Future<void> load({bool force = false}) {
    if (!force && state.load == HomeDashLoad.success && state.data != null) {
      _ensureTicker();
      return Future.value();
    }
    final existing = _inFlight;
    if (existing != null) return existing;

    emit(state.copyWith(load: HomeDashLoad.loading, clearError: true));

    final fut = _repo.fetchDashboard().then((data) {
      emit(state.copyWith(load: HomeDashLoad.success, data: data, now: DateTime.now()));
      _ensureTicker();
    }).catchError((e) {
      emit(state.copyWith(load: HomeDashLoad.failure, error: e.toString()));
    }).whenComplete(() => _inFlight = null);

    _inFlight = fut;
    return fut;
  }

  void _ensureTicker() {
    _ticker ??= Timer.periodic(const Duration(seconds: 1), (_) {
      if (isClosed) return;
      if (state.load != HomeDashLoad.success || state.data == null) return;
      emit(state.copyWith(now: DateTime.now()));
    });
  }

  @override
  Future<void> close() async {
    _ticker?.cancel();
    _ticker = null;
    return super.close();
  }
}

