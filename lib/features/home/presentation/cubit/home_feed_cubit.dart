import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_template/features/home/data/models/feed_models.dart';
import 'package:flutter_template/features/home/data/repositories/home_feed_repository.dart';

enum FeedLoad { initial, loading, success, failure }

final class ExploreState extends Equatable {
  const ExploreState({this.load = FeedLoad.initial, this.sections = const [], this.error});
  final FeedLoad load;
  final List<FeedSection> sections;
  final String? error;

  ExploreState copyWith({FeedLoad? load, List<FeedSection>? sections, String? error, bool clearError = false}) {
    return ExploreState(
      load: load ?? this.load,
      sections: sections ?? this.sections,
      error: clearError ? null : (error ?? this.error),
    );
  }

  @override
  List<Object?> get props => [load, sections, error];
}

final class ActivityState extends Equatable {
  const ActivityState({this.load = FeedLoad.initial, this.items = const [], this.error});
  final FeedLoad load;
  final List<FeedItem> items;
  final String? error;

  ActivityState copyWith({FeedLoad? load, List<FeedItem>? items, String? error, bool clearError = false}) {
    return ActivityState(
      load: load ?? this.load,
      items: items ?? this.items,
      error: clearError ? null : (error ?? this.error),
    );
  }

  @override
  List<Object?> get props => [load, items, error];
}

final class SavedState extends Equatable {
  const SavedState({this.load = FeedLoad.initial, this.items = const [], this.error});
  final FeedLoad load;
  final List<FeedItem> items;
  final String? error;

  SavedState copyWith({FeedLoad? load, List<FeedItem>? items, String? error, bool clearError = false}) {
    return SavedState(
      load: load ?? this.load,
      items: items ?? this.items,
      error: clearError ? null : (error ?? this.error),
    );
  }

  @override
  List<Object?> get props => [load, items, error];
}

class ExploreCubit extends Cubit<ExploreState> {
  ExploreCubit(this._repo) : super(const ExploreState());
  final HomeFeedRepository _repo;
  Future<void>? _inFlight;

  /// Idempotent load:
  /// - dedupes concurrent calls (fast tab switching / pull-to-refresh spam)
  /// - keeps current data while refreshing (no UI flicker)
  Future<void> load({bool force = false}) {
    if (!force && state.load == FeedLoad.success && state.sections.isNotEmpty) {
      return Future<void>.value();
    }
    final existing = _inFlight;
    if (existing != null) return existing;

    if (state.sections.isEmpty) {
      emit(state.copyWith(load: FeedLoad.loading, clearError: true));
    } else {
      emit(state.copyWith(clearError: true));
    }

    final fut = _repo.fetchExplore().then((sections) {
      emit(state.copyWith(load: FeedLoad.success, sections: sections));
    }).catchError((e) {
      emit(state.copyWith(load: FeedLoad.failure, error: e.toString()));
    }).whenComplete(() {
      _inFlight = null;
    });

    _inFlight = fut;
    return fut;
  }
}

class ActivityCubit extends Cubit<ActivityState> {
  ActivityCubit(this._repo) : super(const ActivityState());
  final HomeFeedRepository _repo;
  Future<void>? _inFlight;

  Future<void> load({bool force = false}) {
    if (!force && state.load == FeedLoad.success && state.items.isNotEmpty) {
      return Future<void>.value();
    }
    final existing = _inFlight;
    if (existing != null) return existing;

    if (state.items.isEmpty) {
      emit(state.copyWith(load: FeedLoad.loading, clearError: true));
    } else {
      emit(state.copyWith(clearError: true));
    }

    final fut = _repo.fetchActivity().then((items) {
      emit(state.copyWith(load: FeedLoad.success, items: items));
    }).catchError((e) {
      emit(state.copyWith(load: FeedLoad.failure, error: e.toString()));
    }).whenComplete(() {
      _inFlight = null;
    });

    _inFlight = fut;
    return fut;
  }
}

class SavedCubit extends Cubit<SavedState> {
  SavedCubit(this._repo) : super(const SavedState());
  final HomeFeedRepository _repo;
  Future<void>? _inFlight;

  Future<void> load({bool force = false}) {
    if (!force && state.load == FeedLoad.success && state.items.isNotEmpty) {
      return Future<void>.value();
    }
    final existing = _inFlight;
    if (existing != null) return existing;

    if (state.items.isEmpty) {
      emit(state.copyWith(load: FeedLoad.loading, clearError: true));
    } else {
      emit(state.copyWith(clearError: true));
    }

    final fut = _repo.fetchSaved().then((items) {
      emit(state.copyWith(load: FeedLoad.success, items: items));
    }).catchError((e) {
      emit(state.copyWith(load: FeedLoad.failure, error: e.toString()));
    }).whenComplete(() {
      _inFlight = null;
    });

    _inFlight = fut;
    return fut;
  }
}

