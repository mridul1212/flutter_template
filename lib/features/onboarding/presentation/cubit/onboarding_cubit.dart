import 'package:flutter_bloc/flutter_bloc.dart';

class OnboardingCubit extends Cubit<int> {
  OnboardingCubit({required this.pageCount}) : super(0);

  final int pageCount;

  void goToPage(int index) {
    if (index < 0 || index >= pageCount) return;
    emit(index);
  }

  void next() {
    if (state >= pageCount - 1) return;
    emit(state + 1);
  }

  bool get isLast => state >= pageCount - 1;
}
