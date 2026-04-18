import 'package:flutter_template/presentation/router/app_route_paths.dart';

/// Maps incoming URIs (custom scheme or optional HTTPS host) to in-app locations.
abstract final class DeepLinkParser {
  /// Host used for universal / app links (configure Android intent + iOS associated domains separately).
  static const universalLinkHost = 'fluttertemplate.app';

  static String? toLocation(Uri uri) {
    final scheme = uri.scheme.toLowerCase();
    if (scheme == 'https' || scheme == 'http') {
      final host = uri.host.toLowerCase();
      if (host == universalLinkHost || host == 'www.$universalLinkHost') {
        final path = uri.path.isEmpty || uri.path == '/' ? AppRoutePaths.home : uri.path;
        return _normalize(path);
      }
      return null;
    }
    if (scheme == 'fluttertemplate') {
      if (uri.path.isNotEmpty) {
        return _normalize(uri.path);
      }
      if (uri.host.isNotEmpty) {
        final combined = '/${uri.host}${uri.path}';
        return _normalize(combined);
      }
      return null;
    }
    return null;
  }

  static String _normalize(String path) {
    if (path.isEmpty) return AppRoutePaths.home;
    return path.startsWith('/') ? path : '/$path';
  }

  static bool isKnownAuthenticatedPath(String location) {
    const paths = <String>{
      AppRoutePaths.home,
      AppRoutePaths.homeExplore,
      AppRoutePaths.homeActivity,
      AppRoutePaths.homeSaved,
      AppRoutePaths.homeProfile,
      AppRoutePaths.notifications,
    };
    return paths.contains(location.split('?').first);
  }

  /// Maps local-notification payloads to a [GoRouter] location (`route:/path` or legacy `demo`).
  static String? notificationPayloadToLocation(String? payload) {
    if (payload == null) return null;
    if (payload.startsWith('route:')) {
      final path = payload.substring(6);
      if (path.isEmpty) return null;
      return path.startsWith('/') ? path : '/$path';
    }
    if (payload == 'demo') return AppRoutePaths.notifications;
    return null;
  }
}
