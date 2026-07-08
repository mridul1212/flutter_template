import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_template/features/feature_content/data/feature_content_repository.dart';

enum FeatureContentLoad { initial, loading, success, failure }

final class FeatureContentState extends Equatable {
  const FeatureContentState({this.load = FeatureContentLoad.initial, this.data, this.error});

  final FeatureContentLoad load;
  final FeatureContentData? data;
  final String? error;

  FeatureContentState copyWith({
    FeatureContentLoad? load,
    FeatureContentData? data,
    String? error,
    bool clearError = false,
  }) {
    return FeatureContentState(
      load: load ?? this.load,
      data: data ?? this.data,
      error: clearError ? null : (error ?? this.error),
    );
  }

  @override
  List<Object?> get props => [load, data, error];
}

class FeatureContentCubit extends Cubit<FeatureContentState> {
  FeatureContentCubit(this._repo, this.featureId) : super(const FeatureContentState());

  final FeatureContentRepository _repo;
  final String featureId;
  Future<void>? _inFlight;

  Future<void> load({bool force = false}) {
    if (!force && state.load == FeatureContentLoad.success && state.data != null) {
      return Future.value();
    }
    final existing = _inFlight;
    if (existing != null) return existing;

    if (state.data == null) {
      emit(state.copyWith(load: FeatureContentLoad.loading, clearError: true));
    }

    final fut = _repo.fetch(featureId).then((data) {
      emit(state.copyWith(load: FeatureContentLoad.success, data: data));
    }).catchError((e) {
      emit(state.copyWith(load: FeatureContentLoad.failure, error: e.toString()));
    }).whenComplete(() => _inFlight = null);

    _inFlight = fut;
    return fut;
  }
}
