import 'package:flutter/material.dart';

/// Global keys for dialogs/snackbars above nested navigators.
abstract final class AppNavigator {
  static final GlobalKey<NavigatorState> rootKey = GlobalKey<NavigatorState>();
  static final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();
}
