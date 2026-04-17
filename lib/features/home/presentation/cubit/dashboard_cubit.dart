import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_template/features/posts/domain/entities/post_entity.dart';
import 'package:flutter_template/features/posts/domain/repositories/posts_repository.dart';

enum DashboardLoad { initial, loading, success, failure }

final class DashboardState extends Equatable {
  const DashboardState({
    this.loadState = DashboardLoad.initial,
    this.post,
    this.error,
    this.smokeBusy = false,
    this.smokeMessage,
  });

  final DashboardLoad loadState;
  final PostEntity? post;
  final String? error;
  final bool smokeBusy;
  final String? smokeMessage;

  DashboardState copyWith({
    DashboardLoad? loadState,
    PostEntity? post,
    String? error,
    bool? smokeBusy,
    String? smokeMessage,
    bool clearError = false,
    bool clearSmoke = false,
  }) {
    return DashboardState(
      loadState: loadState ?? this.loadState,
      post: post ?? this.post,
      error: clearError ? null : (error ?? this.error),
      smokeBusy: smokeBusy ?? this.smokeBusy,
      smokeMessage: clearSmoke ? null : (smokeMessage ?? this.smokeMessage),
    );
  }

  @override
  List<Object?> get props => [loadState, post, error, smokeBusy, smokeMessage];
}

class DashboardCubit extends Cubit<DashboardState> {
  DashboardCubit(this._posts) : super(const DashboardState());

  final PostsRepository _posts;

  Future<void> loadSample() async {
    emit(state.copyWith(loadState: DashboardLoad.loading, clearError: true));
    try {
      final post = await _posts.getPost(1);
      emit(state.copyWith(loadState: DashboardLoad.success, post: post));
    } catch (e) {
      emit(
        state.copyWith(
          loadState: DashboardLoad.failure,
          error: e.toString(),
        ),
      );
    }
  }

  Future<void> runHttpVerbsDemo() async {
    emit(state.copyWith(smokeBusy: true, clearSmoke: true));
    try {
      final msg = await _posts.runHttpVerbsDemo();
      emit(state.copyWith(smokeBusy: false, smokeMessage: msg));
    } catch (e) {
      emit(state.copyWith(smokeBusy: false, smokeMessage: e.toString()));
    }
  }
}
