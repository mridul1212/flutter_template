import 'package:equatable/equatable.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

final class AuthGoogleDummySubmitted extends AuthEvent {
  const AuthGoogleDummySubmitted();
}

final class AuthProfileCompletionSubmitted extends AuthEvent {
  const AuthProfileCompletionSubmitted({
    required this.name,
    required this.district,
    required this.dateOfBirth,
    this.timeOfBirth,
    this.birthPlace,
    this.gender,
  });

  final String name;
  final String district;
  final String dateOfBirth;
  final String? timeOfBirth;
  final String? birthPlace;
  final String? gender;

  @override
  List<Object?> get props => [name, district, dateOfBirth, timeOfBirth, birthPlace, gender];
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
