import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_template/presentation/router/app_auth_routes.dart';
import 'package:flutter_template/presentation/router/app_route_paths.dart';
import 'package:flutter_template/presentation/router/app_router_cubit.dart';

String? goAppRedirect(BuildContext context, String path) {
  final cubit = context.read<AppRouterCubit>();
  final dest = cubit.state.destination;

  switch (dest) {
    case AppDestination.splash:
      if (path != AppRoutePaths.splash) return AppRoutePaths.splash;
      return null;
    case AppDestination.onboarding:
      if (path != AppRoutePaths.onboarding) return AppRoutePaths.onboarding;
      return null;
    case AppDestination.login:
      if (path != AppRoutePaths.login) return AppRoutePaths.login;
      return null;
    case AppDestination.profileCompletion:
      if (path != AppRoutePaths.profileComplete) return AppRoutePaths.profileComplete;
      return null;
    case AppDestination.home:
      final user = cubit.state.user;
      if (user == null) {
        if (path == AppRoutePaths.login) return null;
        return AppRoutePaths.login;
      }
      if (!user.isProfileComplete && path != AppRoutePaths.profileComplete) {
        return AppRoutePaths.profileComplete;
      }
      if (path == AppRoutePaths.splash ||
          path == AppRoutePaths.onboarding ||
          path == AppRoutePaths.login ||
          path == AppRoutePaths.profileComplete) {
        return AppRoutePaths.home;
      }
      if (AppAuthRoutes.isAuthenticatedPath(path)) return null;
      return AppRoutePaths.home;
  }
}
