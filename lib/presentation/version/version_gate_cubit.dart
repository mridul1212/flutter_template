import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_template/features/update/domain/entities/version_policy.dart';
import 'package:flutter_template/features/update/domain/repositories/version_policy_repository.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pub_semver/pub_semver.dart';

enum VersionGateStatus { checking, ok, forced }

final class VersionGateState extends Equatable {
  const VersionGateState({
    this.status = VersionGateStatus.checking,
    this.storeUrl,
    this.message,
  });

  final VersionGateStatus status;
  final Uri? storeUrl;
  final String? message;

  bool get isBlocking => status == VersionGateStatus.forced;

  VersionGateState copyWith({
    VersionGateStatus? status,
    Uri? storeUrl,
    String? message,
  }) {
    return VersionGateState(
      status: status ?? this.status,
      storeUrl: storeUrl ?? this.storeUrl,
      message: message ?? this.message,
    );
  }

  @override
  List<Object?> get props => [status, storeUrl, message];
}

class VersionGateCubit extends Cubit<VersionGateState> {
  VersionGateCubit(this._repository, {required this.enabled}) : super(const VersionGateState()) {
    if (!enabled) {
      emit(const VersionGateState(status: VersionGateStatus.ok));
      return;
    }
    Future.microtask(evaluate);
  }

  final VersionPolicyRepository _repository;
  final bool enabled;

  Future<void> evaluate() async {
    if (!enabled) return;
    emit(const VersionGateState(status: VersionGateStatus.checking));
    try {
      final info = await PackageInfo.fromPlatform();
      final current = _parseVersion(info.version);
      final policy = await _repository.loadEffectivePolicy();
      final minV = _parseVersion(policy.minSupportedVersion);
      final latestV = _parseVersion(policy.latestVersion);

      final belowMin = current.compareTo(minV) < 0;
      final belowLatest = current.compareTo(latestV) < 0;

      final mustForce = belowMin || (policy.forceIfBelowLatest && belowLatest);
      if (mustForce) {
        emit(
          VersionGateState(
            status: VersionGateStatus.forced,
            storeUrl: _safeStoreUri(policy),
            message: 'A newer version is required to continue using this app.',
          ),
        );
        return;
      }
      emit(const VersionGateState(status: VersionGateStatus.ok));
    } catch (e, st) {
      debugPrint('VersionGateCubit: $e\n$st');
      emit(const VersionGateState(status: VersionGateStatus.ok));
    }
  }

  Version _parseVersion(String raw) {
    final normalized = raw.split('+').first.trim();
    return Version.parse(normalized);
  }

  Uri _safeStoreUri(VersionPolicy policy) {
    final raw = switch (defaultTargetPlatform) {
      TargetPlatform.iOS => policy.iosStoreUrl,
      _ => policy.androidStoreUrl,
    }.trim();
    if (raw.isEmpty) return Uri();
    try {
      return Uri.parse(raw);
    } catch (_) {
      return Uri();
    }
  }
}
