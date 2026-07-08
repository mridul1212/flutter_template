import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_template/features/auth/domain/exceptions/auth_exception.dart';
import 'package:flutter_template/features/auth/domain/repositories/auth_repository.dart';
import 'package:flutter_template/features/auth/presentation/bloc/auth_event.dart';
import 'package:flutter_template/features/auth/presentation/bloc/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(this._repository) : super(const AuthState()) {
    on<AuthGoogleDummySubmitted>(_onGoogle);
    on<AuthProfileCompletionSubmitted>(_onProfileComplete);
    on<AuthLogoutRequested>(_onLogout);
    on<AuthErrorCleared>(_onClear);
    on<AuthSessionConsumed>(_onSessionConsumed);
  }

  final AuthRepository _repository;

  Future<void> _onGoogle(AuthGoogleDummySubmitted event, Emitter<AuthState> emit) async {
    emit(state.copyWith(status: AuthStatus.loading, clearError: true));
    try {
      final user = await _repository.loginWithGoogleDummy();
      emit(state.copyWith(status: AuthStatus.success, user: user));
    } catch (e) {
      emit(state.copyWith(status: AuthStatus.idle, errorMessage: e.toString()));
    }
  }

  Future<void> _onProfileComplete(AuthProfileCompletionSubmitted event, Emitter<AuthState> emit) async {
    emit(state.copyWith(status: AuthStatus.loading, clearError: true));
    try {
      final user = await _repository.completeProfile(
        name: event.name,
        district: event.district,
        dateOfBirth: event.dateOfBirth,
        timeOfBirth: event.timeOfBirth,
        birthPlace: event.birthPlace,
        gender: event.gender,
      );
      emit(state.copyWith(status: AuthStatus.success, user: user));
    } on AuthException catch (e) {
      emit(state.copyWith(status: AuthStatus.idle, errorMessage: e.message));
    } catch (e) {
      emit(state.copyWith(status: AuthStatus.idle, errorMessage: e.toString()));
    }
  }

  Future<void> _onLogout(AuthLogoutRequested event, Emitter<AuthState> emit) async {
    await _repository.logout();
    emit(const AuthState());
  }

  void _onClear(AuthErrorCleared event, Emitter<AuthState> emit) {
    emit(state.copyWith(clearError: true));
  }

  void _onSessionConsumed(AuthSessionConsumed event, Emitter<AuthState> emit) {
    emit(const AuthState());
  }
}
