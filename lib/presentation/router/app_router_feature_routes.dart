import 'package:flutter/material.dart';
import 'package:flutter_template/core/di/app_dependencies.dart';
import 'package:flutter_template/features/notifications/presentation/pages/notifications_page.dart';
import 'package:flutter_template/features/ponjika/presentation/pages/ekadashi_page.dart';
import 'package:flutter_template/features/ponjika/presentation/pages/logno_page.dart';
import 'package:flutter_template/features/ponjika/presentation/pages/ponjika_page.dart';
import 'package:flutter_template/features/settings/presentation/pages/settings_page.dart';
import 'package:flutter_template/presentation/router/app_page_transitions.dart';
import 'package:flutter_template/presentation/router/app_route_paths.dart';
import 'package:flutter_template/presentation/router/app_router_helpers.dart';
import 'package:go_router/go_router.dart';

List<RouteBase> buildFeatureRoutes({
  required AppDependencies dependencies,
  required GlobalKey<NavigatorState> navigatorKey,
}) {
  return [
    GoRoute(
      path: AppRoutePaths.notifications,
      parentNavigatorKey: navigatorKey,
      pageBuilder: (context, state) => fadeTransitionPage(key: state.pageKey, child: const NotificationsPage()),
    ),
    GoRoute(
      path: AppRoutePaths.ponjika,
      parentNavigatorKey: navigatorKey,
      pageBuilder: (context, state) => ponjikaPage(context, state, const PonjikaPage()),
    ),
    GoRoute(
      path: AppRoutePaths.logno,
      parentNavigatorKey: navigatorKey,
      pageBuilder: (context, state) => ponjikaPage(context, state, const LognoPage()),
    ),
    GoRoute(
      path: AppRoutePaths.ekadashi,
      parentNavigatorKey: navigatorKey,
      pageBuilder: (context, state) => ponjikaPage(context, state, const EkadashiPage()),
    ),
    GoRoute(
      path: AppRoutePaths.biyeLagno,
      parentNavigatorKey: navigatorKey,
      pageBuilder: (c, s) => biyeLagnoPage(dependencies, s),
    ),
    GoRoute(
      path: AppRoutePaths.pujoShopping,
      parentNavigatorKey: navigatorKey,
      pageBuilder: (c, s) => marketplacePage(dependencies, s),
    ),
    GoRoute(
      path: AppRoutePaths.marketplace,
      parentNavigatorKey: navigatorKey,
      pageBuilder: (c, s) => marketplacePage(dependencies, s),
    ),
    GoRoute(
      path: AppRoutePaths.pujoSoronjam,
      parentNavigatorKey: navigatorKey,
      pageBuilder: (c, s) => soronjamPage(dependencies, s),
    ),
    GoRoute(
      path: AppRoutePaths.budgetPlanning,
      parentNavigatorKey: navigatorKey,
      pageBuilder: (c, s) => budgetPage(dependencies, s),
    ),
    GoRoute(
      path: AppRoutePaths.debirItihash,
      parentNavigatorKey: navigatorKey,
      pageBuilder: (c, s) => featureContentPage(dependencies, s, 'itihash'),
    ),
    GoRoute(
      path: AppRoutePaths.community,
      parentNavigatorKey: navigatorKey,
      pageBuilder: (c, s) => communityPage(dependencies, s),
    ),
    GoRoute(
      path: AppRoutePaths.gallery,
      parentNavigatorKey: navigatorKey,
      pageBuilder: (c, s) => featureContentPage(dependencies, s, 'gallery'),
    ),
    GoRoute(
      path: AppRoutePaths.shareMe,
      parentNavigatorKey: navigatorKey,
      pageBuilder: (c, s) => featureContentPage(dependencies, s, 'shareme'),
    ),
    GoRoute(
      path: '${AppRoutePaths.mondopMap}/:id',
      parentNavigatorKey: navigatorKey,
      pageBuilder: (context, state) {
        final id = state.pathParameters['id'] ?? '';
        return mondopDetailPage(context, dependencies, state, id);
      },
    ),
    GoRoute(
      path: AppRoutePaths.mondopMap,
      parentNavigatorKey: navigatorKey,
      pageBuilder: (context, state) => mondopMapPage(context, dependencies, state),
    ),
    GoRoute(
      path: AppRoutePaths.settings,
      parentNavigatorKey: navigatorKey,
      pageBuilder: (context, state) => fadeTransitionPage(key: state.pageKey, child: const SettingsPage()),
    ),
  ];
}
