import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_template/features/auth/domain/exceptions/auth_exception.dart';
import 'package:flutter_template/features/auth/domain/repositories/auth_repository.dart';
import 'package:flutter_template/features/auth/presentation/bloc/auth_event.dart';
import 'package:flutter_template/features/auth/presentation/bloc/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(this._repository) : super(const AuthState()) {
    on<AuthLoginEmailSubmitted>(_onLoginEmail);
    on<AuthRegisterEmailSubmitted>(_onRegisterEmail);
    on<AuthGoogleDummySubmitted>(_onGoogle);
    on<AuthPhoneDummySubmitted>(_onPhone);
    on<AuthLogoutRequested>(_onLogout);
    on<AuthErrorCleared>(_onClear);
    on<AuthSessionConsumed>(_onSessionConsumed);
  }

  final AuthRepository _repository;

  Future<void> _onLoginEmail(AuthLoginEmailSubmitted event, Emitter<AuthState> emit) async {
    emit(state.copyWith(status: AuthStatus.loading, clearError: true));
    try {
      final user = await _repository.loginWithEmail(email: event.email, password: event.password);
      emit(state.copyWith(status: AuthStatus.success, user: user));
    } on AuthException catch (e) {
      emit(state.copyWith(status: AuthStatus.idle, errorMessage: e.message));
    } catch (e) {
      emit(state.copyWith(status: AuthStatus.idle, errorMessage: e.toString()));
    }
  }

  Future<void> _onRegisterEmail(AuthRegisterEmailSubmitted event, Emitter<AuthState> emit) async {
    emit(state.copyWith(status: AuthStatus.loading, clearError: true));
    try {
      final user = await _repository.registerWithEmail(
        name: event.name,
        email: event.email,
        password: event.password,
      );
      emit(state.copyWith(status: AuthStatus.success, user: user));
    } on AuthException catch (e) {
      emit(state.copyWith(status: AuthStatus.idle, errorMessage: e.message));
    } catch (e) {
      emit(state.copyWith(status: AuthStatus.idle, errorMessage: e.toString()));
    }
  }

  Future<void> _onGoogle(AuthGoogleDummySubmitted event, Emitter<AuthState> emit) async {
    emit(state.copyWith(status: AuthStatus.loading, clearError: true));
    try {
      final user = await _repository.loginWithGoogleDummy();
      emit(state.copyWith(status: AuthStatus.success, user: user));
    } catch (e) {
      emit(state.copyWith(status: AuthStatus.idle, errorMessage: e.toString()));
    }
  }

  Future<void> _onPhone(AuthPhoneDummySubmitted event, Emitter<AuthState> emit) async {
    emit(state.copyWith(status: AuthStatus.loading, clearError: true));
    try {
      final user = await _repository.loginWithPhoneDummy(phone: event.phone);
      emit(state.copyWith(status: AuthStatus.success, user: user));
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
