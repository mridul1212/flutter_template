import 'package:flutter_template/core/network/auth_token_provider.dart';
import 'package:flutter_template/features/auth/data/datasources/auth_local_datasource.dart';

final class AuthTokenProviderImpl implements AuthTokenProvider {
  AuthTokenProviderImpl(this._local);

  final AuthLocalDataSource _local;

  @override
  Future<String?> readAccessToken() async => _local.readAccessToken();
}
