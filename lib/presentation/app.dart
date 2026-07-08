import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_template/core/di/app_dependencies.dart';
import 'package:flutter_template/core/navigation/app_navigator.dart';
import 'package:flutter_template/core/navigation/deep_link_parser.dart';
import 'package:flutter_template/core/navigation/go_router_refresh.dart';
import 'package:flutter_template/core/theme/app_theme.dart';
import 'package:flutter_template/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter_template/features/auth/presentation/bloc/auth_state.dart';
import 'package:flutter_template/features/notifications/presentation/cubit/notification_cubit.dart';
import 'package:flutter_template/features/notifications/presentation/cubit/notification_state.dart';
import 'package:flutter_template/features/ponjika/presentation/cubit/ponjika_cubit.dart';
import 'package:flutter_template/l10n/app_localizations.dart';
import 'package:flutter_template/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:flutter_template/presentation/connectivity/connectivity_cubit.dart';
import 'package:flutter_template/presentation/locale/locale_cubit.dart';
import 'package:flutter_template/presentation/router/app_router_cubit.dart';
import 'package:flutter_template/presentation/router/deep_link_binder.dart';
import 'package:flutter_template/presentation/router/go_app_router.dart';
import 'package:flutter_template/presentation/theme/theme_cubit.dart';
import 'package:flutter_template/presentation/version/force_update_page.dart';
import 'package:flutter_template/presentation/version/version_gate_cubit.dart';
import 'package:go_router/go_router.dart';

class AppBootstrap extends StatelessWidget {
  const AppBootstrap({super.key, required this.dependencies});

  final AppDependencies dependencies;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => ThemeCubit(dependencies.sharedPreferences)),
        BlocProvider(create: (_) => LocaleCubit(dependencies.sharedPreferences)),
        BlocProvider(
          create: (_) => SettingsCubit(
            dependencies.sharedPreferences,
            dependencies.locationPermissionService,
          ),
        ),
        BlocProvider(
          create: (_) => ConnectivityCubit(
            gate: dependencies.networkGate,
            monitoringEnabled: dependencies.enableConnectivityMonitoring,
          ),
        ),
        BlocProvider(
          create: (_) => VersionGateCubit(
            dependencies.versionPolicyRepository,
            enabled: dependencies.enableVersionGate,
          ),
        ),
        BlocProvider(create: (_) => AppRouterCubit(dependencies.authRepository)),
        BlocProvider(create: (_) => AuthBloc(dependencies.authRepository)),
        BlocProvider(
          create: (_) {
            final cubit = NotificationCubit(dependencies.notificationRepository);
            cubit.bootstrap();
            return cubit;
          },
        ),
        BlocProvider(
          create: (_) {
            final cubit = PonjikaCubit(dependencies.ponjikaRepository, dependencies.sharedPreferences);
            cubit.load();
            return cubit;
          },
        ),
      ],
      child: Builder(
        builder: (context) {
          return _GoRouterApp(
            dependencies: dependencies,
            appRouterCubit: context.read<AppRouterCubit>(),
          );
        },
      ),
    );
  }
}

class _GoRouterApp extends StatefulWidget {
  const _GoRouterApp({required this.dependencies, required this.appRouterCubit});

  final AppDependencies dependencies;
  final AppRouterCubit appRouterCubit;

  @override
  State<_GoRouterApp> createState() => _GoRouterAppState();
}

class _GoRouterAppState extends State<_GoRouterApp> {
  late final GoRouterRefreshStream _refresh = GoRouterRefreshStream(widget.appRouterCubit.stream);
  late final GoRouter _router = buildAppGoRouter(
    appRouterCubit: widget.appRouterCubit,
    dependencies: widget.dependencies,
    refreshListenable: _refresh,
    navigatorKey: AppNavigator.rootKey,
  );

  @override
  void dispose() {
    _refresh.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (p, c) =>
          p.status != AuthStatus.success && c.status == AuthStatus.success && c.user != null,
      listener: (context, state) {
        final uid = state.user!.id;
        if (!widget.dependencies.enableClientTelemetry) return;
        widget.dependencies.clientTelemetryPoster.recordAction(
          name: 'auth_success',
          userIdResolver: () => uid,
          meta: const {'source': 'auth_bloc'},
        );
      },
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return BlocBuilder<LocaleCubit, Locale?>(
            builder: (context, locale) {
              return MaterialApp.router(
                routerConfig: _router,
                scaffoldMessengerKey: AppNavigator.scaffoldMessengerKey,
                title: 'Durga Utsav',
                debugShowCheckedModeBanner: false,
                theme: AppTheme.light(),
                darkTheme: AppTheme.dark(),
                themeMode: themeMode,
                locale: locale,
                supportedLocales: AppLocalizations.supportedLocales,
                localizationsDelegates: const [
                  AppLocalizations.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                ],
                builder: (context, child) {
                  return DeepLinkBinder(
                    router: _router,
                    appRouterCubit: widget.appRouterCubit,
                    child: BlocListener<AppRouterCubit, AppRouterState>(
                      listenWhen: (p, c) =>
                          c.destination == AppDestination.home &&
                          c.user != null &&
                          (p.destination != AppDestination.home || p.user?.id != c.user?.id),
                      listener: (context, state) {
                        final pending = widget.appRouterCubit.consumePendingDeepLink();
                        if (pending != null) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (!mounted) return;
                            _router.go(pending);
                          });
                        }
                      },
                      child: BlocListener<NotificationCubit, NotificationState>(
                        listenWhen: (p, c) =>
                            c.lastInteraction != p.lastInteraction && c.lastInteraction != null,
                        listener: (context, state) {
                          final interaction = state.lastInteraction;
                          if (interaction == null) return;
                          final messenger = AppNavigator.scaffoldMessengerKey.currentState;
                          final target = DeepLinkParser.notificationPayloadToLocation(interaction.payload);
                          if (target != null) {
                            _router.push(target);
                          } else {
                            final label = interaction.payload ?? interaction.notificationId ?? 'tap';
                            messenger?.showSnackBar(
                              SnackBar(
                                content: Text('Notification: $label (${interaction.source.name})'),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                          context.read<NotificationCubit>().clearLastInteraction();
                        },
                        child: BlocListener<ConnectivityCubit, bool>(
                          listenWhen: (previous, current) => previous != current,
                          listener: (context, online) {
                            final messenger = AppNavigator.scaffoldMessengerKey.currentState;
                            if (!online) {
                              messenger?.showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'No network connection. API calls are paused until you reconnect.',
                                  ),
                                  behavior: SnackBarBehavior.floating,
                                  duration: Duration(seconds: 5),
                                ),
                              );
                            } else {
                              messenger?.hideCurrentSnackBar();
                            }
                          },
                          child: BlocBuilder<VersionGateCubit, VersionGateState>(
                            builder: (context, versionState) {
                              return Stack(
                                fit: StackFit.expand,
                                children: [
                                  child ?? const SizedBox.shrink(),
                                  if (versionState.isBlocking)
                                    Positioned.fill(
                                      child: ForceUpdatePage(
                                        storeUrl: versionState.storeUrl ?? Uri.parse('about:blank'),
                                        message: versionState.message,
                                      ),
                                    ),
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
