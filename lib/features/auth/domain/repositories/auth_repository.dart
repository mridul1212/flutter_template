import 'package:flutter_template/features/auth/domain/entities/user_entity.dart';

abstract class AuthRepository {
  Future<bool> isSessionValid();

  Future<bool> hasCompletedOnboarding();

  Future<void> setOnboardingCompleted();

  Future<UserEntity> loginWithGoogleDummy();

  Future<UserEntity> completeProfile({
    required String name,
    required String district,
    required String dateOfBirth,
    String? timeOfBirth,
    String? birthPlace,
    String? gender,
  });

  Future<void> logout();

  Future<UserEntity?> getCachedUser();

  Future<void> updateCachedUser(UserEntity user);
}
