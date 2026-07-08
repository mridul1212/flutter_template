import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_template/features/budget/data/models/budget_models.dart';
import 'package:flutter_template/features/budget/data/repositories/budget_repository.dart';

enum BudgetLoad { initial, loading, success, failure }

final class BudgetState extends Equatable {
  const BudgetState({this.load = BudgetLoad.initial, this.data, this.error, this.busyId});

  final BudgetLoad load;
  final BudgetData? data;
  final String? error;
  final String? busyId;

  BudgetState copyWith({
    BudgetLoad? load,
    BudgetData? data,
    String? error,
    String? busyId,
    bool clearBusy = false,
    bool clearError = false,
  }) {
    return BudgetState(
      load: load ?? this.load,
      data: data ?? this.data,
      error: clearError ? null : (error ?? this.error),
      busyId: clearBusy ? null : (busyId ?? this.busyId),
    );
  }

  @override
  List<Object?> get props => [load, data, error, busyId];
}

class BudgetCubit extends Cubit<BudgetState> {
  BudgetCubit(this._repo) : super(const BudgetState());

  final BudgetRepository _repo;
  Future<void>? _inFlight;

  Future<void> load({bool force = false}) {
    if (!force && state.load == BudgetLoad.success && state.data != null) return Future.value();
    final existing = _inFlight;
    if (existing != null) return existing;

    emit(state.copyWith(load: BudgetLoad.loading, clearError: true));
    final fut = _repo.fetch(force: force).then((data) {
      emit(state.copyWith(load: BudgetLoad.success, data: data));
    }).catchError((e) {
      emit(state.copyWith(load: BudgetLoad.failure, error: e.toString()));
    }).whenComplete(() => _inFlight = null);
    _inFlight = fut;
    return fut;
  }

  Future<void> setSpent(String id, int spent) async {
    if (state.busyId != null) return;
    emit(state.copyWith(busyId: id));
    try {
      await _repo.updateSpent(id, spent);
      final data = await _repo.fetch();
      emit(state.copyWith(data: data, clearBusy: true));
    } catch (e) {
      emit(state.copyWith(error: e.toString(), clearBusy: true));
    }
  }
}
