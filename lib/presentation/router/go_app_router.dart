import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_template/core/di/app_dependencies.dart';
import 'package:flutter_template/features/auth/presentation/pages/login_page.dart';
import 'package:flutter_template/features/auth/presentation/pages/register_page.dart';
import 'package:flutter_template/features/home/presentation/cubit/dashboard_cubit.dart';
import 'package:flutter_template/features/home/presentation/pages/dashboard_tab.dart';
import 'package:flutter_template/features/home/presentation/pages/home_shell.dart';
import 'package:flutter_template/features/notifications/presentation/pages/notifications_page.dart';
import 'package:flutter_template/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:flutter_template/features/splash/presentation/pages/splash_page.dart';
import 'package:flutter_template/presentation/router/app_page_transitions.dart';
import 'package:flutter_template/presentation/router/app_route_paths.dart';
import 'package:flutter_template/core/telemetry/navigation_audit_observer.dart';
import 'package:flutter_template/presentation/router/app_router_cubit.dart';
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
    redirect: (context, state) {
      final cubit = context.read<AppRouterCubit>();
      final dest = cubit.state.destination;
      final path = state.uri.path;

      switch (dest) {
        case AppDestination.splash:
          if (path != AppRoutePaths.splash) return AppRoutePaths.splash;
          return null;
        case AppDestination.onboarding:
          if (path != AppRoutePaths.onboarding) return AppRoutePaths.onboarding;
          return null;
        case AppDestination.login:
          if (path == AppRoutePaths.register) return null;
          if (path != AppRoutePaths.login) return AppRoutePaths.login;
          return null;
        case AppDestination.register:
          if (path != AppRoutePaths.register) return AppRoutePaths.register;
          return null;
        case AppDestination.home:
          final user = cubit.state.user;
          if (user == null) {
            if (path == AppRoutePaths.login || path == AppRoutePaths.register) return null;
            return AppRoutePaths.login;
          }
          if (path == AppRoutePaths.splash ||
              path == AppRoutePaths.onboarding ||
              path == AppRoutePaths.login ||
              path == AppRoutePaths.register) {
            return AppRoutePaths.home;
          }
          if (path == AppRoutePaths.notifications) return null;
          if (path.startsWith('/home')) return null;
          return AppRoutePaths.home;
      }
    },
    routes: [
      GoRoute(
        path: AppRoutePaths.root,
        redirect: (context, state) => AppRoutePaths.splash,
      ),
      GoRoute(
        path: AppRoutePaths.splash,
        pageBuilder: (context, state) => fadeTransitionPage(
          key: state.pageKey,
          child: const SplashPage(),
        ),
      ),
      GoRoute(
        path: AppRoutePaths.onboarding,
        pageBuilder: (context, state) => fadeTransitionPage(
          key: state.pageKey,
          child: const OnboardingPage(),
        ),
      ),
      GoRoute(
        path: AppRoutePaths.login,
        pageBuilder: (context, state) => fadeTransitionPage(
          key: state.pageKey,
          child: const LoginPage(),
        ),
      ),
      GoRoute(
        path: AppRoutePaths.register,
        pageBuilder: (context, state) => fadeTransitionPage(
          key: state.pageKey,
          child: const RegisterPage(),
        ),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MultiBlocProvider(
            providers: [
              BlocProvider(
                create: (_) => DashboardCubit(dependencies.postsRepository)..loadSample(),
              ),
            ],
            child: HomeShellView(navigationShell: navigationShell),
          );
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutePaths.home,
                pageBuilder: (context, state) => NoTransitionPage<void>(
                  key: state.pageKey,
                  child: const DashboardTab(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutePaths.homeExplore,
                pageBuilder: (context, state) => NoTransitionPage<void>(
                  key: state.pageKey,
                  child: const HomePlaceholderTab(
                    icon: Icons.travel_explore_rounded,
                    text: 'Explore lists, maps, or discovery — boilerplate ready.',
                  ),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutePaths.homeActivity,
                pageBuilder: (context, state) => NoTransitionPage<void>(
                  key: state.pageKey,
                  child: const HomePlaceholderTab(
                    icon: Icons.timeline_rounded,
                    text: 'Recent activity feed — hook your API later.',
                  ),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutePaths.homeSaved,
                pageBuilder: (context, state) => NoTransitionPage<void>(
                  key: state.pageKey,
                  child: const HomePlaceholderTab(
                    icon: Icons.bookmark_outline_rounded,
                    text: 'Saved items — swap with real persistence.',
                  ),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutePaths.homeProfile,
                pageBuilder: (context, state) => NoTransitionPage<void>(
                  key: state.pageKey,
                  child: const HomeProfileTab(),
                ),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: AppRoutePaths.notifications,
        parentNavigatorKey: navigatorKey,
        pageBuilder: (context, state) => fadeTransitionPage(
          key: state.pageKey,
          child: const NotificationsPage(),
        ),
      ),
    ],
  );
}
