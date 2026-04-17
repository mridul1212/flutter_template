import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_template/core/network/api_endpoints.dart';
import 'package:flutter_template/features/update/domain/entities/version_policy.dart';

class VersionPolicyDataSource {
  VersionPolicyDataSource(this._plainDio);

  final Dio _plainDio;

  static const _assetPath = 'assets/config/version_policy.json';

  Future<VersionPolicy> loadFromAsset() async {
    final raw = await rootBundle.loadString(_assetPath);
    return _parse(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<VersionPolicy?> tryLoadRemoteOverride() async {
    final url = ApiEndpoints.remoteVersionPolicyUrl.trim();
    if (url.isEmpty) return null;
    try {
      final response = await _plainDio.get<dynamic>(url);
      final data = response.data;
      if (data is Map<String, dynamic>) {
        return _parse(data);
      }
      if (data is String) {
        return _parse(jsonDecode(data) as Map<String, dynamic>);
      }
    } catch (_) {
      // Remote is best-effort; asset remains source of truth for minimums if merge fails.
    }
    return null;
  }

  VersionPolicy merge(VersionPolicy base, VersionPolicy? remote) {
    if (remote == null) return base;
    return VersionPolicy(
      minSupportedVersion: remote.minSupportedVersion.isNotEmpty ? remote.minSupportedVersion : base.minSupportedVersion,
      latestVersion: remote.latestVersion.isNotEmpty ? remote.latestVersion : base.latestVersion,
      forceIfBelowLatest: remote.forceIfBelowLatest,
      androidStoreUrl: remote.androidStoreUrl.isNotEmpty ? remote.androidStoreUrl : base.androidStoreUrl,
      iosStoreUrl: remote.iosStoreUrl.isNotEmpty ? remote.iosStoreUrl : base.iosStoreUrl,
      releaseNotesUrl: remote.releaseNotesUrl ?? base.releaseNotesUrl,
    );
  }

  VersionPolicy _parse(Map<String, dynamic> json) {
    return VersionPolicy(
      minSupportedVersion: json['min_supported_version'] as String? ?? '0.0.1',
      latestVersion: json['latest_version'] as String? ?? '0.0.1',
      forceIfBelowLatest: json['force_if_below_latest'] as bool? ?? false,
      androidStoreUrl: json['android_store_url'] as String? ?? '',
      iosStoreUrl: json['ios_store_url'] as String? ?? '',
      releaseNotesUrl: json['release_notes_url'] as String?,
    );
  }
}
