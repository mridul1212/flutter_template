import 'package:flutter_template/features/auth/presentation/pages/login_page.dart';
import 'package:flutter_template/features/auth/presentation/pages/profile_completion_page.dart';
import 'package:flutter_template/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:flutter_template/features/splash/presentation/pages/splash_page.dart';
import 'package:flutter_template/presentation/router/app_page_transitions.dart';
import 'package:flutter_template/presentation/router/app_route_paths.dart';
import 'package:go_router/go_router.dart';

List<RouteBase> buildAuthRoutes() {
  return [
    GoRoute(
      path: AppRoutePaths.root,
      redirect: (context, state) => AppRoutePaths.splash,
    ),
    GoRoute(
      path: AppRoutePaths.splash,
      pageBuilder: (context, state) => fadeTransitionPage(key: state.pageKey, child: const SplashPage()),
    ),
    GoRoute(
      path: AppRoutePaths.onboarding,
      pageBuilder: (context, state) => fadeTransitionPage(key: state.pageKey, child: const OnboardingPage()),
    ),
    GoRoute(
      path: AppRoutePaths.login,
      pageBuilder: (context, state) => fadeTransitionPage(key: state.pageKey, child: const LoginPage()),
    ),
    GoRoute(
      path: AppRoutePaths.profileComplete,
      pageBuilder: (context, state) => fadeTransitionPage(key: state.pageKey, child: const ProfileCompletionPage()),
    ),
  ];
}
