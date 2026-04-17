import 'package:flutter_template/features/update/domain/entities/version_policy.dart';

abstract class VersionPolicyRepository {
  /// Asset defaults merged with optional remote policy (if configured).
  Future<VersionPolicy> loadEffectivePolicy();
}
