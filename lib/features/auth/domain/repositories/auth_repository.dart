import 'package:flutter_template/features/auth/domain/entities/user_entity.dart';

abstract class AuthRepository {
  Future<bool> isSessionValid();

  Future<bool> hasCompletedOnboarding();

  Future<void> setOnboardingCompleted();

  Future<UserEntity> loginWithEmail({required String email, required String password});

  Future<UserEntity> registerWithEmail({
    required String name,
    required String email,
    required String password,
  });

  Future<UserEntity> loginWithGoogleDummy();

  Future<UserEntity> loginWithPhoneDummy({required String phone});

  Future<void> logout();

  Future<UserEntity?> getCachedUser();
}
