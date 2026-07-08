import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_template/core/theme/app_colors.dart';
import 'package:flutter_template/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter_template/features/auth/presentation/bloc/auth_event.dart';
import 'package:flutter_template/features/auth/presentation/bloc/auth_state.dart';
import 'package:flutter_template/l10n/app_localizations.dart';
import 'package:flutter_template/presentation/router/app_router_cubit.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (p, c) => p.status != c.status || p.errorMessage != c.errorMessage,
      listener: (context, state) {
        if (state.status == AuthStatus.success && state.user != null) {
          context.read<AppRouterCubit>().onAuthenticated(state.user!);
          context.read<AuthBloc>().add(const AuthSessionConsumed());
        }
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
        }
      },
      child: const _LoginView(),
    );
  }
}

class _LoginView extends StatelessWidget {
  const _LoginView();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final t = AppLocalizations.of(context);
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: AppColors.brandGradient,
          ),
        ),
        child: SafeArea(
          child: BlocBuilder<AuthBloc, AuthState>(
            buildWhen: (p, c) => p.status != c.status,
            builder: (context, state) {
              final loading = state.status == AuthStatus.loading;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Spacer(flex: 2),
                    Hero(
                      tag: 'app_logo',
                      child: Container(
                        width: 88,
                        height: 88,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.brandTertiary.withValues(alpha: 0.6), width: 2),
                        ),
                        child: const Icon(Icons.temple_hindu_rounded, size: 48, color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'পূজা বন্ধু',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Puja Bandhu',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.white.withValues(alpha: 0.92),
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      t.signInToContinue,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.85), height: 1.4),
                    ),
                    const Spacer(flex: 3),
                    Card(
                      elevation: 8,
                      shadowColor: AppColors.brandSecondary.withValues(alpha: 0.4),
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              t.welcomeBack,
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Continue with your Google account — the only sign-in method in v1.',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
                            ),
                            const SizedBox(height: 24),
                            FilledButton.icon(
                              style: FilledButton.styleFrom(
                                backgroundColor: scheme.surface,
                                foregroundColor: AppColors.textPrimary,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                side: BorderSide(color: scheme.outline),
                              ),
                              onPressed: loading
                                  ? null
                                  : () {
                                      context.read<AuthBloc>().add(const AuthErrorCleared());
                                      context.read<AuthBloc>().add(const AuthGoogleDummySubmitted());
                                    },
                              icon: loading
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    )
                                  : const Icon(Icons.g_mobiledata_rounded, size: 28),
                              label: Text(loading ? 'Signing in…' : t.continueWithGoogle),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'By continuing you agree to our Terms & Privacy Policy.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.75)),
                    ),
                    const Spacer(),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
