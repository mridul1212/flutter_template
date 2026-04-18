import 'package:flutter/material.dart';
import 'package:flutter_template/core/telemetry/client_telemetry_poster.dart';

/// Logs stack changes from [GoRouter] / [Navigator] (covers `go`, `push`, `pop`, etc.).
final class NavigationAuditObserver extends NavigatorObserver {
  NavigationAuditObserver({
    required ClientTelemetryPoster poster,
    required String? Function() userIdResolver,
  })  : _poster = poster,
        _userIdResolver = userIdResolver;

  final ClientTelemetryPoster _poster;
  final String? Function() _userIdResolver;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _poster.recordNavigation(
      navAction: 'didPush',
      userIdResolver: _userIdResolver,
      toLocation: _routeLabel(route),
      fromLocation: _routeLabel(previousRoute),
    );
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _poster.recordNavigation(
      navAction: 'didPop',
      userIdResolver: _userIdResolver,
      toLocation: _routeLabel(previousRoute),
      fromLocation: _routeLabel(route),
    );
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    _poster.recordNavigation(
      navAction: 'didReplace',
      userIdResolver: _userIdResolver,
      toLocation: _routeLabel(newRoute),
      fromLocation: _routeLabel(oldRoute),
    );
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _poster.recordNavigation(
      navAction: 'didRemove',
      userIdResolver: _userIdResolver,
      toLocation: _routeLabel(previousRoute),
      fromLocation: _routeLabel(route),
    );
  }

  static String? _routeLabel(Route<dynamic>? route) {
    if (route == null) return null;
    final name = route.settings.name;
    if (name != null && name.isNotEmpty) return name;
    return route.settings.arguments?.toString();
  }
}
