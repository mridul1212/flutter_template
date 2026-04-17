import 'package:equatable/equatable.dart';
import 'package:flutter_template/features/auth/domain/entities/user_entity.dart';

enum AuthStatus { idle, loading, success }

final class AuthState extends Equatable {
  const AuthState({
    this.status = AuthStatus.idle,
    this.user,
    this.errorMessage,
  });

  final AuthStatus status;
  final UserEntity? user;
  final String? errorMessage;

  AuthState copyWith({
    AuthStatus? status,
    UserEntity? user,
    String? errorMessage,
    bool clearError = false,
    bool clearUser = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: clearUser ? null : (user ?? this.user),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [status, user, errorMessage];
}
