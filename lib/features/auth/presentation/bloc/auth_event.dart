import 'package:equatable/equatable.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

final class AuthLoginEmailSubmitted extends AuthEvent {
  const AuthLoginEmailSubmitted({required this.email, required this.password});
  final String email;
  final String password;

  @override
  List<Object?> get props => [email, password];
}

final class AuthRegisterEmailSubmitted extends AuthEvent {
  const AuthRegisterEmailSubmitted({
    required this.name,
    required this.email,
    required this.password,
  });
  final String name;
  final String email;
  final String password;

  @override
  List<Object?> get props => [name, email, password];
}

final class AuthGoogleDummySubmitted extends AuthEvent {
  const AuthGoogleDummySubmitted();
}

final class AuthPhoneDummySubmitted extends AuthEvent {
  const AuthPhoneDummySubmitted(this.phone);
  final String phone;

  @override
  List<Object?> get props => [phone];
}

final class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}

final class AuthErrorCleared extends AuthEvent {
  const AuthErrorCleared();
}

/// Clears success state after router handled navigation (keeps forms fresh).
final class AuthSessionConsumed extends AuthEvent {
  const AuthSessionConsumed();
}
