import 'package:flutter_template/features/update/data/datasources/version_policy_datasource.dart';
import 'package:flutter_template/features/update/domain/entities/version_policy.dart';
import 'package:flutter_template/features/update/domain/repositories/version_policy_repository.dart';

class VersionPolicyRepositoryImpl implements VersionPolicyRepository {
  VersionPolicyRepositoryImpl(this._dataSource);

  final VersionPolicyDataSource _dataSource;

  @override
  Future<VersionPolicy> loadEffectivePolicy() async {
    final asset = await _dataSource.loadFromAsset();
    final remote = await _dataSource.tryLoadRemoteOverride();
    return _dataSource.merge(asset, remote);
  }
}
