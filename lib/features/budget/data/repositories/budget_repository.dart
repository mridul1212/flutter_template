import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_template/features/budget/data/datasources/budget_local_store.dart';
import 'package:flutter_template/features/budget/data/models/budget_models.dart';

abstract class BudgetRepository {
  Future<BudgetData> fetch({bool force = false});
  Future<void> updateSpent(String id, int spent);
}

final class BudgetRepositoryImpl implements BudgetRepository {
  BudgetRepositoryImpl(this._local);

  final BudgetLocalStore _local;
  BudgetData? _cache;

  @override
  Future<BudgetData> fetch({bool force = false}) async {
    if (!force && _cache != null) return _cache!;
    await Future<void>.delayed(const Duration(milliseconds: 150));
    final raw = await rootBundle.loadString('assets/mock/budget_plan.json');
    final json = jsonDecode(raw);
    if (json is! Map<String, dynamic>) throw StateError('Invalid budget JSON');

    final defaults = (json['entries'] as List<dynamic>)
        .map((e) => BudgetEntry.fromJson(e as Map<String, dynamic>))
        .toList(growable: false);
    final overrides = _local.readOverrides();
    final merged = _merge(defaults, overrides);
    _cache = BudgetData.fromJson(json, merged);
    return _cache!;
  }

  @override
  Future<void> updateSpent(String id, int spent) async {
    final data = await fetch();
    final next = data.entries.map((e) => e.id == id ? e.copyWith(spent: spent.clamp(0, e.planned)) : e).toList(growable: false);
    await _local.writeOverrides(next);
    _cache = data.copyWith(entries: next);
  }

  List<BudgetEntry> _merge(List<BudgetEntry> defaults, List<BudgetEntry>? overrides) {
    if (overrides == null) return defaults;
    final map = {for (final o in overrides) o.id: o};
    return defaults.map((d) {
      final o = map[d.id];
      if (o == null) return d;
      return d.copyWith(spent: o.spent);
    }).toList(growable: false);
  }
}
