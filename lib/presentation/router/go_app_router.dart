import 'package:flutter/material.dart';
import 'package:flutter_template/core/di/app_dependencies.dart';
import 'package:flutter_template/core/telemetry/navigation_audit_observer.dart';
import 'package:flutter_template/presentation/router/app_router_auth_routes.dart';
import 'package:flutter_template/presentation/router/app_router_feature_routes.dart';
import 'package:flutter_template/presentation/router/app_router_shell_routes.dart';
import 'package:flutter_template/presentation/router/app_route_paths.dart';
import 'package:flutter_template/presentation/router/app_router_cubit.dart';
import 'package:flutter_template/presentation/router/go_app_redirect.dart';
import 'package:go_router/go_router.dart';

GoRouter buildAppGoRouter({
  required AppRouterCubit appRouterCubit,
  required AppDependencies dependencies,
  required Listenable refreshListenable,
  required GlobalKey<NavigatorState> navigatorKey,
}) {
  final observers = <NavigatorObserver>[
    if (dependencies.enableClientTelemetry)
      NavigationAuditObserver(
        poster: dependencies.clientTelemetryPoster,
        userIdResolver: () => appRouterCubit.state.user?.id,
      ),
  ];

  return GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: AppRoutePaths.splash,
    observers: observers,
    refreshListenable: refreshListenable,
    redirect: (context, state) => goAppRedirect(context, state.uri.path),
    routes: [
      ...buildAuthRoutes(),
      buildHomeShellRoute(dependencies),
      ...buildFeatureRoutes(dependencies: dependencies, navigatorKey: navigatorKey),
    ],
  );
}
