import 'package:flutter_bloc/flutter_bloc.dart';

class HomeNavCubit extends Cubit<int> {
  HomeNavCubit() : super(0);

  void setTab(int index) {
    if (index < 0 || index > 4) return;
    emit(index);
  }
}
