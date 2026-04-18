import 'dart:async';

import 'package:flutter/foundation.dart';

/// Notifies [GoRouter] when [AppRouterCubit] (or any [Stream]) emits so redirects re-run.
final class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    _subscription = stream.listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
