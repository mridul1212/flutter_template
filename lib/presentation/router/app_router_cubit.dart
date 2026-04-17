import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_template/features/auth/domain/entities/user_entity.dart';
import 'package:flutter_template/features/auth/domain/repositories/auth_repository.dart';

enum AppDestination { splash, onboarding, login, register, home }

class AppRouterState extends Equatable {
  const AppRouterState({
    required this.destination,
    this.user,
  });

  final AppDestination destination;
  final UserEntity? user;

  AppRouterState copyWith({
    AppDestination? destination,
    UserEntity? user,
    bool clearUser = false,
  }) {
    return AppRouterState(
      destination: destination ?? this.destination,
      user: clearUser ? null : (user ?? this.user),
    );
  }

  @override
  List<Object?> get props => [destination, user];
}

class AppRouterCubit extends Cubit<AppRouterState> {
  AppRouterCubit(this._authRepository)
      : super(const AppRouterState(destination: AppDestination.splash));

  final AuthRepository _authRepository;

  Future<void> resolveAfterSplash() async {
    final valid = await _authRepository.isSessionValid();
    if (valid) {
      final user = await _authRepository.getCachedUser();
      if (user != null) {
        emit(state.copyWith(destination: AppDestination.home, user: user));
        return;
      }
      await _authRepository.logout();
    }
    final onboarded = await _authRepository.hasCompletedOnboarding();
    if (onboarded) {
      emit(state.copyWith(destination: AppDestination.login, clearUser: true));
    } else {
      emit(state.copyWith(destination: AppDestination.onboarding, clearUser: true));
    }
  }

  Future<void> completeOnboarding() async {
    await _authRepository.setOnboardingCompleted();
    emit(state.copyWith(destination: AppDestination.login, clearUser: true));
  }

  void showLogin() {
    emit(state.copyWith(destination: AppDestination.login));
  }

  void showRegister() {
    emit(state.copyWith(destination: AppDestination.register));
  }

  void onAuthenticated(UserEntity user) {
    emit(state.copyWith(destination: AppDestination.home, user: user));
  }

  Future<void> logout() async {
    await _authRepository.logout();
    emit(state.copyWith(destination: AppDestination.login, clearUser: true));
  }
}
