import 'package:flutter/material.dart';

import 'package:flutter_template/presentation/router/app_route_paths.dart';

import 'package:go_router/go_router.dart';



/// Maps home dashboard feature ids to routes.

abstract final class FeatureNavigation {

  static void open(BuildContext context, String featureId) {

    final path = routeFor(featureId);

    if (path == null) {

      ScaffoldMessenger.of(context).showSnackBar(

        const SnackBar(content: Text('This feature is coming soon in the demo.')),

      );

      return;

    }

    context.push(path);

  }



  static String? routeFor(String featureId) {

    return switch (featureId) {

      'ponjika' => AppRoutePaths.ponjika,

      'logno' => AppRoutePaths.logno,

      'ekadashi' => AppRoutePaths.ekadashi,

      'biye_lagno' || 'biyelagno' => AppRoutePaths.biyeLagno,

      'nearby' || 'darshan' => AppRoutePaths.mondopMap,

      'shopping' => AppRoutePaths.marketplace,

      'soronjam' => AppRoutePaths.pujoSoronjam,

      'budget' => AppRoutePaths.budgetPlanning,

      'itihash' => AppRoutePaths.debirItihash,

      'community' => AppRoutePaths.community,

      'gallery' => AppRoutePaths.gallery,

      'shareme' => AppRoutePaths.shareMe,

      _ => null,

    };

  }

}

