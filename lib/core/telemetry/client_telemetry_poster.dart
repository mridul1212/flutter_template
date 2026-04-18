import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_template/core/network/api_client.dart';
import 'package:flutter_template/core/network/api_endpoints.dart';
import 'package:flutter_template/core/telemetry/public_ip_service.dart';

/// Fire-and-forget client events (navigation, actions) to your API.
///
/// Design: never throw; never block UI. Resolve IP once per burst (cached in [PublicIpService]).
final class ClientTelemetryPoster {
  ClientTelemetryPoster(
    this._apiClient,
    this._publicIp, {
    this.enabled = true,
  });

  final ApiClient _apiClient;
  final PublicIpService _publicIp;
  final bool enabled;

  void recordNavigation({
    required String navAction,
    required String? Function() userIdResolver,
    String? toLocation,
    String? fromLocation,
  }) {
    if (!enabled) return;
    unawaited(
      _send(
        <String, dynamic>{
          'type': 'navigation',
          'navAction': navAction,
          'toLocation': toLocation,
          'fromLocation': fromLocation,
        },
        userIdResolver: userIdResolver,
      ),
    );
  }

  void recordAction({
    required String name,
    required String? Function() userIdResolver,
    Map<String, Object?> meta = const {},
  }) {
    if (!enabled) return;
    unawaited(
      _send(
        <String, dynamic>{
          'type': 'action',
          'name': name,
          if (meta.isNotEmpty) 'meta': meta,
        },
        userIdResolver: userIdResolver,
      ),
    );
  }

  Future<void> _send(
    Map<String, dynamic> event, {
    required String? Function() userIdResolver,
  }) async {
    final userId = userIdResolver();
    final ip = await _publicIp.getPublicIpv4();
    final body = <String, dynamic>{
      ...event,
      'userId': userId,
      'clientPublicIp': ip,
      'occurredAt': DateTime.now().toUtc().toIso8601String(),
      'platform': _platformLabel(),
    };
    try {
      await _apiClient.post<void>(ApiEndpoints.clientTelemetryPath, data: body);
    } catch (e, st) {
      debugPrint('[ClientTelemetryPoster] $e\n$st');
    }
  }
}

String _platformLabel() {
  if (kIsWeb) return 'web';
  return defaultTargetPlatform.name;
}
