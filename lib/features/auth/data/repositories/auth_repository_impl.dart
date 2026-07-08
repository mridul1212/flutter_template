import 'dart:convert';

import 'package:flutter_template/core/constants/app_constants.dart';
import 'package:flutter_template/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:flutter_template/features/auth/domain/entities/user_entity.dart';
import 'package:flutter_template/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._local);

  final AuthLocalDataSource _local;

  @override
  Future<bool> isSessionValid() async => _local.isTokenValid();

  @override
  Future<bool> hasCompletedOnboarding() async => _local.readOnboardingCompleted();

  @override
  Future<void> setOnboardingCompleted() => _local.writeOnboardingCompleted();

  @override
  Future<UserEntity> loginWithGoogleDummy() async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    final user = UserEntity(
      id: 'user_google',
      name: 'Google User',
      email: 'puja.bandhu@gmail.com',
      avatarUrl: AppConstants.dummyAvatarUrl,
      isProfileComplete: false,
    );
    await _persistDummyToken(user);
    return user;
  }

  @override
  Future<UserEntity> completeProfile({
    required String name,
    required String district,
    required String dateOfBirth,
    String? timeOfBirth,
    String? birthPlace,
    String? gender,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    final current = await getCachedUser();
    if (current == null) throw Exception('No active session');
    final updated = current.copyWith(
      name: name.trim(),
      district: district.trim(),
      dateOfBirth: dateOfBirth,
      timeOfBirth: timeOfBirth?.trim().isEmpty == true ? null : timeOfBirth?.trim(),
      birthPlace: birthPlace?.trim().isEmpty == true ? null : birthPlace?.trim(),
      gender: gender,
      isProfileComplete: true,
    );
    await updateCachedUser(updated);
    return updated;
  }

  @override
  Future<void> logout() => _local.clearSession();

  @override
  Future<UserEntity?> getCachedUser() async => _local.readUser();

  @override
  Future<void> updateCachedUser(UserEntity user) async {
    final token = _local.readAccessToken();
    final expMs = _local.readTokenExpiryMs();
    if (token == null || expMs == null) {
      await _persistDummyToken(user);
      return;
    }
    await _local.persistSession(
      token: token,
      expiresAt: DateTime.fromMillisecondsSinceEpoch(expMs),
      user: user,
    );
  }

  Future<void> _persistDummyToken(UserEntity user) async {
    final expiresAt = DateTime.now().add(AppConstants.tokenTtl);
    final token = base64Url.encode(utf8.encode('dummy|${user.id}|${expiresAt.millisecondsSinceEpoch}'));
    await _local.persistSession(token: token, expiresAt: expiresAt, user: user);
  }
}
