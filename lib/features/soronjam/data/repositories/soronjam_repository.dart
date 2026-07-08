import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_template/features/soronjam/data/datasources/soronjam_local_store.dart';
import 'package:flutter_template/features/soronjam/data/models/soronjam_models.dart';

abstract class SoronjamRepository {
  Future<SoronjamData> fetch({bool force = false});
  Future<void> toggleItem(String id, bool checked);
}

final class SoronjamRepositoryImpl implements SoronjamRepository {
  SoronjamRepositoryImpl(this._local);

  final SoronjamLocalStore _local;
  SoronjamData? _cache;

  @override
  Future<SoronjamData> fetch({bool force = false}) async {
    if (!force && _cache != null) return _cache!;
    await Future<void>.delayed(const Duration(milliseconds: 150));
    final raw = await rootBundle.loadString('assets/mock/soronjam_checklist.json');
    final json = jsonDecode(raw);
    if (json is! Map<String, dynamic>) throw StateError('Invalid soronjam JSON');
    final checked = _local.readChecked();
    _cache = SoronjamData.fromJson(json, checked);
    return _cache!;
  }

  @override
  Future<void> toggleItem(String id, bool checked) async {
    final data = await fetch();
    final checkedIds = data.items.where((i) => i.checked).map((i) => i.id).toSet();
    if (checked) {
      checkedIds.add(id);
    } else {
      checkedIds.remove(id);
    }
    await _local.writeChecked(checkedIds);
    _cache = data.copyWith(
      items: data.items.map((i) => i.id == id ? i.copyWith(checked: checked) : i).toList(growable: false),
    );
  }
}
