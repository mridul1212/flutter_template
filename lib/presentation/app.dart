import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_template/core/di/app_dependencies.dart';
import 'package:flutter_template/core/navigation/app_navigator.dart';
import 'package:flutter_template/core/theme/app_theme.dart';
import 'package:flutter_template/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter_template/features/auth/presentation/pages/login_page.dart';
import 'package:flutter_template/features/auth/presentation/pages/register_page.dart';
import 'package:flutter_template/features/home/presentation/pages/home_shell.dart';
import 'package:flutter_template/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:flutter_template/features/splash/presentation/pages/splash_page.dart';
import 'package:flutter_template/presentation/connectivity/connectivity_cubit.dart';
import 'package:flutter_template/presentation/router/app_router_cubit.dart';
import 'package:flutter_template/presentation/theme/theme_cubit.dart';
import 'package:flutter_template/presentation/version/force_update_page.dart';
import 'package:flutter_template/presentation/version/version_gate_cubit.dart';

class AppBootstrap extends StatelessWidget {
  const AppBootstrap({super.key, required this.dependencies});

  final AppDependencies dependencies;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => ThemeCubit(dependencies.sharedPreferences)),
        BlocProvider(
          create: (_) => ConnectivityCubit(
            gate: dependencies.networkGate,
            monitoringEnabled: dependencies.enableConnectivityMonitoring,
          ),
        ),
        BlocProvider(
          create: (_) => VersionGateCubit(
            dependencies.versionPolicyRepository,
            enabled: dependencies.enableVersionGate,
          ),
        ),
        BlocProvider(create: (_) => AppRouterCubit(dependencies.authRepository)),
        BlocProvider(create: (_) => AuthBloc(dependencies.authRepository)),
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return MaterialApp(
            navigatorKey: AppNavigator.rootKey,
            scaffoldMessengerKey: AppNavigator.scaffoldMessengerKey,
            title: 'Flutter Template',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            themeMode: themeMode,
            builder: (context, child) {
              return BlocListener<ConnectivityCubit, bool>(
                listenWhen: (previous, current) => previous != current,
                listener: (context, online) {
                  final messenger = AppNavigator.scaffoldMessengerKey.currentState;
                  if (!online) {
                    messenger?.showSnackBar(
                      const SnackBar(
                        content: Text(
                          'No network connection. API calls are paused until you reconnect.',
                        ),
                        behavior: SnackBarBehavior.floating,
                        duration: Duration(seconds: 5),
                      ),
                    );
                  } else {
                    messenger?.hideCurrentSnackBar();
                  }
                },
                child: BlocBuilder<VersionGateCubit, VersionGateState>(
                  builder: (context, versionState) {
                    return Stack(
                      fit: StackFit.expand,
                      children: [
                        child ?? const SizedBox.shrink(),
                        if (versionState.isBlocking)
                          Positioned.fill(
                            child: ForceUpdatePage(
                              storeUrl: versionState.storeUrl ?? Uri.parse('about:blank'),
                              message: versionState.message,
                            ),
                          ),
                      ],
                    );
                  },
                ),
              );
            },
            home: _RootNavigator(dependencies: dependencies),
          );
        },
      ),
    );
  }
}

class _RootNavigator extends StatelessWidget {
  const _RootNavigator({required this.dependencies});

  final AppDependencies dependencies;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppRouterCubit, AppRouterState>(
      buildWhen: (p, c) => p.destination != c.destination || p.user?.id != c.user?.id,
      builder: (context, state) {
        final user = state.user;
        return switch (state.destination) {
          AppDestination.splash => const SplashPage(),
          AppDestination.onboarding => const OnboardingPage(),
          AppDestination.login => const LoginPage(),
          AppDestination.register => const RegisterPage(),
          AppDestination.home when user != null => HomeShell(dependencies: dependencies, user: user),
          AppDestination.home => const LoginPage(),
        };
      },
    );
  }
}
