import 'package:flutter_template/presentation/router/app_route_paths.dart';

/// Routes allowed while the user is authenticated.
abstract final class AppAuthRoutes {
  static const authenticatedLeafPaths = <String>{
    AppRoutePaths.home,
    AppRoutePaths.homeExplore,
    AppRoutePaths.homeActivity,
    AppRoutePaths.homeSaved,
    AppRoutePaths.homeProfile,
    AppRoutePaths.notifications,
    AppRoutePaths.ponjika,
    AppRoutePaths.logno,
    AppRoutePaths.ekadashi,
    AppRoutePaths.biyeLagno,
    AppRoutePaths.mondopMap,
    AppRoutePaths.settings,
    AppRoutePaths.pujoShopping,
    AppRoutePaths.marketplace,
    AppRoutePaths.pujoSoronjam,
    AppRoutePaths.budgetPlanning,
    AppRoutePaths.debirItihash,
    AppRoutePaths.community,
    AppRoutePaths.gallery,
    AppRoutePaths.shareMe,
  };

  static bool isAuthenticatedPath(String path) {
    if (authenticatedLeafPaths.contains(path)) return true;
    if (path.startsWith('${AppRoutePaths.mondopMap}/')) return true;
    return false;
  }
}
