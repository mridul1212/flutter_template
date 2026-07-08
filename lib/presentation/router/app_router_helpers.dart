import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_template/core/di/app_dependencies.dart';
import 'package:flutter_template/features/budget/presentation/cubit/budget_cubit.dart';
import 'package:flutter_template/features/budget/presentation/pages/budget_page.dart';
import 'package:flutter_template/features/feature_content/presentation/cubit/feature_content_cubit.dart';
import 'package:flutter_template/features/feature_content/presentation/pages/feature_content_page.dart';
import 'package:flutter_template/features/biye_lagno/presentation/cubit/biye_lagno_cubit.dart';
import 'package:flutter_template/features/biye_lagno/presentation/pages/biye_lagno_page.dart';
import 'package:flutter_template/features/community/presentation/cubit/community_cubit.dart';
import 'package:flutter_template/features/community/presentation/pages/community_page.dart';
import 'package:flutter_template/features/marketplace/presentation/cubit/marketplace_cubit.dart';
import 'package:flutter_template/features/marketplace/presentation/pages/marketplace_page.dart';
import 'package:flutter_template/features/mondop/presentation/cubit/mondop_detail_cubit.dart';
import 'package:flutter_template/features/mondop/presentation/cubit/mondop_map_cubit.dart';
import 'package:flutter_template/features/mondop/presentation/pages/mondop_detail_page.dart';
import 'package:flutter_template/features/mondop/presentation/pages/mondop_map_page.dart';
import 'package:flutter_template/features/ponjika/presentation/cubit/ponjika_cubit.dart';
import 'package:flutter_template/features/soronjam/presentation/cubit/soronjam_cubit.dart';
import 'package:flutter_template/features/soronjam/presentation/pages/soronjam_page.dart';
import 'package:flutter_template/presentation/router/app_page_transitions.dart';
import 'package:go_router/go_router.dart';

Page<void> featureContentPage(AppDependencies deps, GoRouterState state, String featureId) {
  return fadeTransitionPage(
    key: state.pageKey,
    child: BlocProvider(
      create: (_) => FeatureContentCubit(deps.featureContentRepository, featureId),
      child: FeatureContentPage(featureId: featureId),
    ),
  );
}

Page<void> ponjikaPage(BuildContext context, GoRouterState state, Widget child) {
  return fadeTransitionPage(
    key: state.pageKey,
    child: BlocProvider.value(
      value: context.read<PonjikaCubit>(),
      child: child,
    ),
  );
}

Page<void> soronjamPage(AppDependencies deps, GoRouterState state) {
  return fadeTransitionPage(
    key: state.pageKey,
    child: BlocProvider(
      create: (_) => SoronjamCubit(deps.soronjamRepository),
      child: const SoronjamPage(),
    ),
  );
}

Page<void> budgetPage(AppDependencies deps, GoRouterState state) {
  return fadeTransitionPage(
    key: state.pageKey,
    child: BlocProvider(
      create: (_) => BudgetCubit(deps.budgetRepository),
      child: const BudgetPage(),
    ),
  );
}

Page<void> mondopMapPage(BuildContext context, AppDependencies deps, GoRouterState state) {
  return fadeTransitionPage(
    key: state.pageKey,
    child: BlocProvider(
      create: (_) => MondopMapCubit(deps.mondopRepository, deps.locationPermissionService),
      child: const MondopMapPage(),
    ),
  );
}

Page<void> mondopDetailPage(BuildContext context, AppDependencies deps, GoRouterState state, String id) {
  return fadeTransitionPage(
    key: state.pageKey,
    child: BlocProvider(
      create: (_) => MondopDetailCubit(deps.mondopRepository, id),
      child: MondopDetailPage(mondopId: id),
    ),
  );
}

Page<void> biyeLagnoPage(AppDependencies deps, GoRouterState state) {
  return fadeTransitionPage(
    key: state.pageKey,
    child: BlocProvider(
      create: (_) => BiyeLagnoCubit(deps.biyeLagnoRepository),
      child: const BiyeLagnoPage(),
    ),
  );
}

Page<void> marketplacePage(AppDependencies deps, GoRouterState state) {
  return fadeTransitionPage(
    key: state.pageKey,
    child: BlocProvider(
      create: (_) => MarketplaceCubit(deps.marketplaceRepository),
      child: const MarketplacePage(),
    ),
  );
}

Page<void> communityPage(AppDependencies deps, GoRouterState state) {
  return fadeTransitionPage(
    key: state.pageKey,
    child: BlocProvider(
      create: (_) => CommunityCubit(deps.communityRepository),
      child: const CommunityPage(),
    ),
  );
}
