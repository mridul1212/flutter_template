import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_template/core/di/app_dependencies.dart';
import 'package:flutter_template/features/home/presentation/cubit/home_dashboard_cubit.dart';
import 'package:flutter_template/features/home/presentation/cubit/home_feed_cubit.dart';
import 'package:flutter_template/features/home/presentation/pages/activity_tab.dart';
import 'package:flutter_template/features/home/presentation/pages/dashboard_tab.dart';
import 'package:flutter_template/features/home/presentation/pages/explore_tab.dart';
import 'package:flutter_template/features/home/presentation/pages/home_profile_tab.dart';
import 'package:flutter_template/features/home/presentation/pages/home_shell.dart';
import 'package:flutter_template/features/home/presentation/pages/saved_tab.dart';
import 'package:flutter_template/presentation/router/app_route_paths.dart';
import 'package:go_router/go_router.dart';

StatefulShellRoute buildHomeShellRoute(AppDependencies dependencies) {
  return StatefulShellRoute.indexedStack(
    builder: (context, state, navigationShell) {
      return MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => HomeDashboardCubit(dependencies.homeDashboardRepository)..load()),
          BlocProvider(create: (_) => ExploreCubit(dependencies.homeFeedRepository)),
          BlocProvider(create: (_) => ActivityCubit(dependencies.homeFeedRepository)),
          BlocProvider(create: (_) => SavedCubit(dependencies.homeFeedRepository)),
        ],
        child: HomeShellView(navigationShell: navigationShell),
      );
    },
    branches: [
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: AppRoutePaths.home,
            pageBuilder: (context, state) => NoTransitionPage<void>(key: state.pageKey, child: const DashboardTab()),
          ),
        ],
      ),
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: AppRoutePaths.homeExplore,
            pageBuilder: (context, state) => NoTransitionPage<void>(key: state.pageKey, child: const ExploreTab()),
          ),
        ],
      ),
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: AppRoutePaths.homeActivity,
            pageBuilder: (context, state) => NoTransitionPage<void>(key: state.pageKey, child: const ActivityTab()),
          ),
        ],
      ),
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: AppRoutePaths.homeSaved,
            pageBuilder: (context, state) => NoTransitionPage<void>(key: state.pageKey, child: const SavedTab()),
          ),
        ],
      ),
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: AppRoutePaths.homeProfile,
            pageBuilder: (context, state) => NoTransitionPage<void>(key: state.pageKey, child: const HomeProfileTab()),
          ),
        ],
      ),
    ],
  );
}
