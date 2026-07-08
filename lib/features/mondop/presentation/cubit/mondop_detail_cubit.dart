import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_template/features/mondop/data/models/mondop_models.dart';
import 'package:flutter_template/features/mondop/data/repositories/mondop_repository.dart';

enum MondopDetailLoad { initial, loading, success, failure, submitting }

final class MondopDetailState extends Equatable {
  const MondopDetailState({
    this.load = MondopDetailLoad.initial,
    this.item,
    this.reviews,
    this.error,
  });

  final MondopDetailLoad load;
  final MondopItem? item;
  final MondopReviewSummary? reviews;
  final String? error;

  MondopDetailState copyWith({
    MondopDetailLoad? load,
    MondopItem? item,
    MondopReviewSummary? reviews,
    String? error,
    bool clearError = false,
  }) {
    return MondopDetailState(
      load: load ?? this.load,
      item: item ?? this.item,
      reviews: reviews ?? this.reviews,
      error: clearError ? null : (error ?? this.error),
    );
  }

  @override
  List<Object?> get props => [load, item, reviews, error];
}

class MondopDetailCubit extends Cubit<MondopDetailState> {
  MondopDetailCubit(this._repo, this._id) : super(const MondopDetailState());

  final MondopRepository _repo;
  final String _id;

  Future<void> load() async {
    emit(state.copyWith(load: MondopDetailLoad.loading, clearError: true));
    try {
      final item = await _repo.findById(_id);
      if (item == null) {
        emit(state.copyWith(load: MondopDetailLoad.failure, error: 'Mondop not found'));
        return;
      }
      final reviews = await _repo.fetchReviews(_id);
      emit(state.copyWith(load: MondopDetailLoad.success, item: item, reviews: reviews));
    } catch (e) {
      emit(state.copyWith(load: MondopDetailLoad.failure, error: e.toString()));
    }
  }

  Future<void> submitReview({required int rating, required String comment}) async {
    emit(state.copyWith(load: MondopDetailLoad.submitting, clearError: true));
    try {
      final review = await _repo.submitReview(mondopId: _id, rating: rating, comment: comment);
      final current = state.reviews ?? MondopReviewSummary(averageRating: 0, reviewCount: 0, items: const []);
      final items = [review, ...current.items];
      final nextCount = current.reviewCount + 1;
      final nextAvg = current.reviewCount <= 0
          ? rating.toDouble()
          : ((current.averageRating * current.reviewCount) + rating) / nextCount;
      emit(
        state.copyWith(
          load: MondopDetailLoad.success,
          reviews: MondopReviewSummary(
            averageRating: nextAvg,
            reviewCount: nextCount,
            items: items,
          ),
        ),
      );
    } catch (e) {
      emit(state.copyWith(load: MondopDetailLoad.success, error: e.toString()));
    }
  }
}
