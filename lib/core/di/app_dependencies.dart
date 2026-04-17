import 'package:flutter_template/core/network/api_client.dart';
import 'package:flutter_template/core/network/dio_factory.dart';
import 'package:flutter_template/core/network/network_gate.dart';
import 'package:flutter_template/core/network/plain_dio_factory.dart';
import 'package:flutter_template/features/auth/data/auth_token_provider_impl.dart';
import 'package:flutter_template/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:flutter_template/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:flutter_template/features/auth/domain/repositories/auth_repository.dart';
import 'package:flutter_template/features/posts/data/datasources/posts_remote_datasource.dart';
import 'package:flutter_template/features/posts/data/repositories/posts_repository_impl.dart';
import 'package:flutter_template/features/posts/domain/repositories/posts_repository.dart';
import 'package:flutter_template/features/update/data/datasources/version_policy_datasource.dart';
import 'package:flutter_template/features/update/data/repositories/version_policy_repository_impl.dart';
import 'package:flutter_template/features/update/domain/repositories/version_policy_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppDependencies {
  AppDependencies._({
    required this.authRepository,
    required this.authLocalDataSource,
    required this.apiClient,
    required this.postsRepository,
    required this.sharedPreferences,
    required this.networkGate,
    required this.versionPolicyRepository,
    required this.enableConnectivityMonitoring,
    required this.enableVersionGate,
  });

  final AuthRepository authRepository;
  final AuthLocalDataSource authLocalDataSource;
  final ApiClient apiClient;
  final PostsRepository postsRepository;
  final SharedPreferences sharedPreferences;
  final NetworkGate networkGate;
  final VersionPolicyRepository versionPolicyRepository;
  final bool enableConnectivityMonitoring;
  final bool enableVersionGate;

  static Future<AppDependencies> create({
    bool enableConnectivityMonitoring = true,
    bool enableVersionGate = true,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final local = AuthLocalDataSource(prefs);
    final authRepository = AuthRepositoryImpl(local);

    final networkGate = NetworkGate();
    final tokenProvider = AuthTokenProviderImpl(local);
    final dio = DioFactory.create(
      tokenProvider: tokenProvider,
      networkGate: networkGate,
    );
    final apiClient = ApiClient(dio);
    final postsRemote = PostsRemoteDataSource(apiClient);
    final postsRepository = PostsRepositoryImpl(postsRemote);

    final plainDio = PlainDioFactory.create();
    final versionDataSource = VersionPolicyDataSource(plainDio);
    final versionPolicyRepository = VersionPolicyRepositoryImpl(versionDataSource);

    return AppDependencies._(
      authRepository: authRepository,
      authLocalDataSource: local,
      apiClient: apiClient,
      postsRepository: postsRepository,
      sharedPreferences: prefs,
      networkGate: networkGate,
      versionPolicyRepository: versionPolicyRepository,
      enableConnectivityMonitoring: enableConnectivityMonitoring,
      enableVersionGate: enableVersionGate,
    );
  }
}
