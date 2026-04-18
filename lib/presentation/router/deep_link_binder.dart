import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_template/core/navigation/deep_link_parser.dart';
import 'package:flutter_template/presentation/router/app_router_cubit.dart';
import 'package:go_router/go_router.dart';

/// Subscribes to platform URIs and navigates when the session is ready.
final class DeepLinkBinder extends StatefulWidget {
  const DeepLinkBinder({
    super.key,
    required this.router,
    required this.appRouterCubit,
    required this.child,
  });

  final GoRouter router;
  final AppRouterCubit appRouterCubit;
  final Widget child;

  @override
  State<DeepLinkBinder> createState() => _DeepLinkBinderState();
}

class _DeepLinkBinderState extends State<DeepLinkBinder> {
  StreamSubscription<Uri>? _subscription;

  @override
  void initState() {
    super.initState();
    _subscription = AppLinks().uriLinkStream.listen(_onUri);
    WidgetsBinding.instance.addPostFrameCallback((_) => _readInitialLink());
  }

  Future<void> _readInitialLink() async {
    final initial = await AppLinks().getInitialLink();
    if (initial != null) _onUri(initial);
  }

  void _onUri(Uri uri) {
    final path = DeepLinkParser.toLocation(uri);
    if (path == null || !mounted) return;
    final cubit = widget.appRouterCubit;
    final authed = cubit.state.destination == AppDestination.home && cubit.state.user != null;
    if (authed) {
      widget.router.go(path);
    } else {
      cubit.queueDeepLink(path);
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
