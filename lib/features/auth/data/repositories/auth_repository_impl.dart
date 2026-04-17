import 'dart:convert';
import 'dart:math';

import 'package:flutter_template/core/constants/app_constants.dart';
import 'package:flutter_template/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:flutter_template/features/auth/domain/entities/user_entity.dart';
import 'package:flutter_template/features/auth/domain/exceptions/auth_exception.dart';
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
  Future<UserEntity> loginWithEmail({required String email, required String password}) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    final ok =
        email.trim().toLowerCase() == AppConstants.demoEmail && password == AppConstants.demoPassword;
    if (!ok) {
      throw AuthException('Invalid email or password. Try demo@app.com / password1');
    }
    final user = UserEntity(
      id: 'user_demo',
      name: 'Demo User',
      email: AppConstants.demoEmail,
      avatarUrl: AppConstants.dummyAvatarUrl,
    );
    await _persistDummyToken(user);
    return user;
  }

  @override
  Future<UserEntity> registerWithEmail({
    required String name,
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 700));
    final user = UserEntity(
      id: 'user_${Random().nextInt(1 << 20)}',
      name: name.trim(),
      email: email.trim().toLowerCase(),
      avatarUrl: AppConstants.dummyAvatarUrl,
    );
    await _persistDummyToken(user);
    return user;
  }

  @override
  Future<UserEntity> loginWithGoogleDummy() async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    final user = UserEntity(
      id: 'user_google',
      name: 'Google User',
      email: 'google.user@app.com',
      avatarUrl: AppConstants.dummyAvatarUrl,
    );
    await _persistDummyToken(user);
    return user;
  }

  @override
  Future<UserEntity> loginWithPhoneDummy({required String phone}) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    final user = UserEntity(
      id: 'user_phone',
      name: 'Phone User',
      email: 'phone.user@app.com',
      phone: phone,
      avatarUrl: AppConstants.dummyAvatarUrl,
    );
    await _persistDummyToken(user);
    return user;
  }

  @override
  Future<void> logout() => _local.clearSession();

  @override
  Future<UserEntity?> getCachedUser() async => _local.readUser();

  Future<void> _persistDummyToken(UserEntity user) async {
    final expiresAt = DateTime.now().add(AppConstants.tokenTtl);
    final token = base64Url.encode(utf8.encode('dummy|${user.id}|${expiresAt.millisecondsSinceEpoch}'));
    await _local.persistSession(token: token, expiresAt: expiresAt, user: user);
  }
}
