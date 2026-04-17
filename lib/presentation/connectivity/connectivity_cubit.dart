import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_template/core/network/network_gate.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

/// Tracks whether the app should allow API traffic and updates [NetworkGate].
class ConnectivityCubit extends Cubit<bool> {
  ConnectivityCubit({
    required NetworkGate gate,
    required bool monitoringEnabled,
    Connectivity? connectivity,
    InternetConnectionChecker? internetChecker,
  })  : _gate = gate,
        _monitoringEnabled = monitoringEnabled,
        _connectivity = connectivity ?? Connectivity(),
        _checker = internetChecker ?? InternetConnectionChecker.instance,
        super(true) {
    if (!_monitoringEnabled) {
      _gate.setOnline(true);
      return;
    }
    _connectivitySub = _connectivity.onConnectivityChanged.listen((_) => unawaited(_reconcile()));
    _internetSub = _checker.onStatusChange.listen((_) => unawaited(_reconcile()));
    unawaited(_reconcile());
  }

  final NetworkGate _gate;
  final bool _monitoringEnabled;
  final Connectivity _connectivity;
  final InternetConnectionChecker _checker;

  StreamSubscription<List<ConnectivityResult>>? _connectivitySub;
  StreamSubscription<InternetConnectionStatus>? _internetSub;

  Future<void> _reconcile() async {
    if (!_monitoringEnabled) return;
    try {
      final results = await _connectivity.checkConnectivity();
      final noneOnly = results.isEmpty || results.every((r) => r == ConnectivityResult.none);
      if (noneOnly) {
        _publish(false);
        return;
      }
      final reachable = await _checker.hasConnection;
      _publish(reachable);
    } catch (_) {
      _publish(false);
    }
  }

  void _publish(bool online) {
    _gate.setOnline(online);
    emit(online);
  }

  @override
  Future<void> close() async {
    await _connectivitySub?.cancel();
    await _internetSub?.cancel();
    return super.close();
  }
}
