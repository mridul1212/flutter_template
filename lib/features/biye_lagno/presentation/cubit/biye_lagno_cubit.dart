import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_template/features/biye_lagno/data/models/biye_lagno_models.dart';
import 'package:flutter_template/features/biye_lagno/data/repositories/biye_lagno_repository.dart';

enum BiyeLagnoLoad { initial, loading, success, failure, matching }

final class BiyeLagnoState extends Equatable {
  const BiyeLagnoState({
    this.load = BiyeLagnoLoad.initial,
    this.data,
    this.result,
    this.error,
    this.profileAId = 'p1',
    this.profileBId = 'p2',
  });

  final BiyeLagnoLoad load;
  final BiyeLagnoData? data;
  final BiyeLagnoResult? result;
  final String? error;
  final String profileAId;
  final String profileBId;

  BiyeLagnoState copyWith({
    BiyeLagnoLoad? load,
    BiyeLagnoData? data,
    BiyeLagnoResult? result,
    String? error,
    String? profileAId,
    String? profileBId,
    bool clearResult = false,
    bool clearError = false,
  }) {
    return BiyeLagnoState(
      load: load ?? this.load,
      data: data ?? this.data,
      result: clearResult ? null : (result ?? this.result),
      error: clearError ? null : (error ?? this.error),
      profileAId: profileAId ?? this.profileAId,
      profileBId: profileBId ?? this.profileBId,
    );
  }

  @override
  List<Object?> get props => [load, data, result, error, profileAId, profileBId];
}

class BiyeLagnoCubit extends Cubit<BiyeLagnoState> {
  BiyeLagnoCubit(this._repo) : super(const BiyeLagnoState());

  final BiyeLagnoRepository _repo;

  Future<void> load() async {
    emit(state.copyWith(load: BiyeLagnoLoad.loading, clearError: true, clearResult: true));
    try {
      final data = await _repo.loadMeta();
      emit(state.copyWith(load: BiyeLagnoLoad.success, data: data));
    } catch (e) {
      emit(state.copyWith(load: BiyeLagnoLoad.failure, error: e.toString()));
    }
  }

  void selectProfileA(String id) => emit(state.copyWith(profileAId: id, clearResult: true));
  void selectProfileB(String id) => emit(state.copyWith(profileBId: id, clearResult: true));

  Future<void> runMatch() async {
    if (state.profileAId == state.profileBId) {
      emit(state.copyWith(error: 'Select two different profiles'));
      return;
    }
    emit(state.copyWith(load: BiyeLagnoLoad.matching, clearError: true));
    try {
      final result = await _repo.match(profileAKey: state.profileAId, profileBKey: state.profileBId);
      emit(state.copyWith(load: BiyeLagnoLoad.success, result: result));
    } catch (e) {
      emit(state.copyWith(load: BiyeLagnoLoad.failure, error: e.toString()));
    }
  }
}
