import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_template/features/soronjam/data/models/soronjam_models.dart';
import 'package:flutter_template/features/soronjam/data/repositories/soronjam_repository.dart';

enum SoronjamLoad { initial, loading, success, failure }

final class SoronjamState extends Equatable {
  const SoronjamState({this.load = SoronjamLoad.initial, this.data, this.error, this.busyId});

  final SoronjamLoad load;
  final SoronjamData? data;
  final String? error;
  final String? busyId;

  SoronjamState copyWith({
    SoronjamLoad? load,
    SoronjamData? data,
    String? error,
    String? busyId,
    bool clearBusy = false,
    bool clearError = false,
  }) {
    return SoronjamState(
      load: load ?? this.load,
      data: data ?? this.data,
      error: clearError ? null : (error ?? this.error),
      busyId: clearBusy ? null : (busyId ?? this.busyId),
    );
  }

  @override
  List<Object?> get props => [load, data, error, busyId];
}

class SoronjamCubit extends Cubit<SoronjamState> {
  SoronjamCubit(this._repo) : super(const SoronjamState());

  final SoronjamRepository _repo;
  Future<void>? _inFlight;

  Future<void> load({bool force = false}) {
    if (!force && state.load == SoronjamLoad.success && state.data != null) return Future.value();
    final existing = _inFlight;
    if (existing != null) return existing;

    emit(state.copyWith(load: SoronjamLoad.loading, clearError: true));
    final fut = _repo.fetch(force: force).then((data) {
      emit(state.copyWith(load: SoronjamLoad.success, data: data));
    }).catchError((e) {
      emit(state.copyWith(load: SoronjamLoad.failure, error: e.toString()));
    }).whenComplete(() => _inFlight = null);
    _inFlight = fut;
    return fut;
  }

  Future<void> toggle(String id, bool checked) async {
    if (state.busyId != null) return;
    emit(state.copyWith(busyId: id));
    try {
      await _repo.toggleItem(id, checked);
      final data = await _repo.fetch();
      emit(state.copyWith(data: data, clearBusy: true));
    } catch (e) {
      emit(state.copyWith(error: e.toString(), clearBusy: true));
    }
  }
}
