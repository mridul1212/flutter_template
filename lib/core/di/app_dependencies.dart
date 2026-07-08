import 'package:flutter_template/core/network/api_client.dart';
import 'package:flutter_template/core/network/dio_factory.dart';
import 'package:flutter_template/core/network/network_gate.dart';
import 'package:flutter_template/core/network/plain_dio_factory.dart';
import 'package:flutter_template/core/permissions/location_permission_service.dart';
import 'package:flutter_template/core/telemetry/client_telemetry_poster.dart';
import 'package:flutter_template/core/telemetry/public_ip_service.dart';
import 'package:flutter_template/features/auth/data/auth_token_provider_impl.dart';
import 'package:flutter_template/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:flutter_template/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:flutter_template/features/auth/domain/repositories/auth_repository.dart';
import 'package:flutter_template/features/home/data/repositories/home_dashboard_repository.dart';
import 'package:flutter_template/features/home/data/repositories/home_feed_repository.dart';
import 'package:flutter_template/features/biye_lagno/data/repositories/biye_lagno_repository.dart';
import 'package:flutter_template/features/community/data/repositories/community_repository.dart';
import 'package:flutter_template/features/marketplace/data/repositories/marketplace_repository.dart';
import 'package:flutter_template/features/budget/data/datasources/budget_local_store.dart';
import 'package:flutter_template/features/budget/data/repositories/budget_repository.dart';
import 'package:flutter_template/features/feature_content/data/feature_content_repository.dart';
import 'package:flutter_template/features/mondop/data/repositories/mondop_repository.dart';
import 'package:flutter_template/features/notifications/data/datasources/local_notification_datasource.dart';
import 'package:flutter_template/features/notifications/data/repositories/notification_repository_impl.dart';
import 'package:flutter_template/features/notifications/domain/repositories/notification_repository.dart';
import 'package:flutter_template/features/soronjam/data/datasources/soronjam_local_store.dart';
import 'package:flutter_template/features/soronjam/data/repositories/soronjam_repository.dart';
import 'package:flutter_template/features/ponjika/data/datasources/ponjika_local_store.dart';
import 'package:flutter_template/features/ponjika/data/repositories/ponjika_repository.dart';
import 'package:flutter_template/features/posts/data/datasources/posts_remote_datasource.dart';
import 'package:flutter_template/features/posts/data/repositories/posts_repository_mock.dart';
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
    required this.notificationRepository,
    required this.clientTelemetryPoster,
    required this.publicIpService,
    required this.homeFeedRepository,
    required this.homeDashboardRepository,
    required this.ponjikaRepository,
    required this.mondopRepository,
    required this.soronjamRepository,
    required this.budgetRepository,
    required this.featureContentRepository,
    required this.biyeLagnoRepository,
    required this.marketplaceRepository,
    required this.communityRepository,
    required this.locationPermissionService,
    required this.enableClientTelemetry,
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
  final NotificationRepository notificationRepository;
  final ClientTelemetryPoster clientTelemetryPoster;
  final PublicIpService publicIpService;
  final HomeFeedRepository homeFeedRepository;
  final HomeDashboardRepository homeDashboardRepository;
  final PonjikaRepository ponjikaRepository;
  final MondopRepository mondopRepository;
  final SoronjamRepository soronjamRepository;
  final BudgetRepository budgetRepository;
  final FeatureContentRepository featureContentRepository;
  final BiyeLagnoRepository biyeLagnoRepository;
  final MarketplaceRepository marketplaceRepository;
  final CommunityRepository communityRepository;
  final LocationPermissionService locationPermissionService;
  final bool enableClientTelemetry;
  final bool enableConnectivityMonitoring;
  final bool enableVersionGate;

  static Future<AppDependencies> create({
    bool enableConnectivityMonitoring = true,
    bool enableVersionGate = true,
    bool enableClientTelemetry = true,
    bool? useMockApi,
  }) async {
    final useMock = useMockApi ?? const bool.fromEnvironment('USE_MOCK_API', defaultValue: true);
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
    final postsRepository = useMock ? PostsRepositoryMock() : PostsRepositoryImpl(postsRemote);

    final plainDio = PlainDioFactory.create();
    final versionDataSource = VersionPolicyDataSource(plainDio);
    final versionPolicyRepository = VersionPolicyRepositoryImpl(versionDataSource);

    final localNotifications = LocalNotificationDataSource();
    final notificationRepository = NotificationRepositoryImpl(localNotifications);

    final publicIpService = PublicIpService();
    final clientTelemetryPoster = ClientTelemetryPoster(
      apiClient,
      publicIpService,
      enabled: enableClientTelemetry,
    );

    return AppDependencies._(
      authRepository: authRepository,
      authLocalDataSource: local,
      apiClient: apiClient,
      postsRepository: postsRepository,
      sharedPreferences: prefs,
      networkGate: networkGate,
      versionPolicyRepository: versionPolicyRepository,
      notificationRepository: notificationRepository,
      clientTelemetryPoster: clientTelemetryPoster,
      publicIpService: publicIpService,
      homeFeedRepository: HomeFeedRepositoryMock(),
      homeDashboardRepository: HomeDashboardRepositoryMock(),
      ponjikaRepository: PonjikaRepositoryImpl(
        localStore: PonjikaLocalStore(prefs),
      ),
      mondopRepository: MondopRepositoryImpl(),
      soronjamRepository: SoronjamRepositoryImpl(SoronjamLocalStore(prefs)),
      budgetRepository: BudgetRepositoryImpl(BudgetLocalStore(prefs)),
      featureContentRepository: FeatureContentRepositoryImpl(),
      biyeLagnoRepository: BiyeLagnoRepositoryImpl(),
      marketplaceRepository: MarketplaceRepositoryImpl(),
      communityRepository: CommunityRepositoryImpl(),
      locationPermissionService: LocationPermissionService(prefs),
      enableClientTelemetry: enableClientTelemetry,
      enableConnectivityMonitoring: enableConnectivityMonitoring,
      enableVersionGate: enableVersionGate,
    );
  }
}
