import 'package:flutter_template/core/cache/year_cache_policy.dart';
import 'package:flutter_template/features/ponjika/data/datasources/ponjika_local_store.dart';
import 'package:flutter_template/features/ponjika/data/datasources/ponjika_remote_datasource.dart';
import 'package:flutter_template/features/ponjika/data/models/ponjika_models.dart';

enum PonjikaCacheSource { memory, disk, network, staleDisk }

/// Ponjika + Logno + Ekadashi share one year-wise payload (minimize API calls).
abstract class PonjikaRepository {
  static int get currentCalendarYear => YearCachePolicy.currentYear;

  Future<PonjikaResult> fetchPonjika({int? year, bool forceRefresh = false});
}

final class PonjikaResult {
  const PonjikaResult({required this.data, required this.source});

  final PonjikaData data;
  final PonjikaCacheSource source;
}

final class PonjikaRepositoryImpl implements PonjikaRepository {
  PonjikaRepositoryImpl({
    required PonjikaLocalStore localStore,
    PonjikaRemoteDataSource? remote,
  })  : _local = localStore,
        _remote = remote ?? PonjikaRemoteDataSource();

  final PonjikaLocalStore _local;
  final PonjikaRemoteDataSource _remote;

  final Map<int, PonjikaData> _memory = {};
  final Map<int, Future<PonjikaResult>> _inFlight = {};

  @override
  Future<PonjikaResult> fetchPonjika({int? year, bool forceRefresh = false}) {
    final y = year ?? PonjikaRepository.currentCalendarYear;

    if (!forceRefresh) {
      final mem = _memory[y];
      if (mem != null) {
        return Future.value(PonjikaResult(data: mem, source: PonjikaCacheSource.memory));
      }
    } else {
      _memory.remove(y);
    }

    final existing = _inFlight[y];
    if (existing != null) return existing;

    final fut = _loadYear(y, forceRefresh: forceRefresh).whenComplete(() => _inFlight.remove(y));
    _inFlight[y] = fut;
    return fut;
  }

  Future<PonjikaResult> _loadYear(int year, {required bool forceRefresh}) async {
    if (!forceRefresh) {
      final disk = await _local.read(year);
      if (disk != null && disk.year == year) {
        _memory[year] = disk;
        return PonjikaResult(data: disk, source: PonjikaCacheSource.disk);
      }
    }

    try {
      final json = await _remote.fetchYearJson(year);
      await _local.write(year, json);
      final data = PonjikaData.fromJson(json);
      _memory[year] = data;
      return PonjikaResult(data: data, source: PonjikaCacheSource.network);
    } catch (_) {
      final stale = await _local.read(year, allowStale: true);
      if (stale != null) {
        _memory[year] = stale;
        return PonjikaResult(data: stale, source: PonjikaCacheSource.staleDisk);
      }
      rethrow;
    }
  }
}
