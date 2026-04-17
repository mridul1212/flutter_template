/// Synchronous gate read by [ConnectivityInterceptor] on every request.
///
/// Updated by [ConnectivityCubit] when device connectivity / reachability changes.
final class NetworkGate {
  bool _online = true;

  bool get isOnline => _online;

  void setOnline(bool value) {
    _online = value;
  }
}
