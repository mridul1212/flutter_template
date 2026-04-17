import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_template/core/constants/app_constants.dart';
import 'package:flutter_template/core/utils/validators.dart';
import 'package:flutter_template/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter_template/features/auth/presentation/bloc/auth_event.dart';
import 'package:flutter_template/features/auth/presentation/bloc/auth_state.dart';
import 'package:flutter_template/presentation/router/app_router_cubit.dart';
import 'package:flutter_template/shared/widgets/app_text_field.dart';

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

class _LoginView extends StatefulWidget {
  const _LoginView();

  @override
  State<_LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<_LoginView> {
  final _credentialsKey = GlobalKey<_LoginCredentialsState>();

  Future<void> _phoneFlow() async {
    final auth = context.read<AuthBloc>();
    final phoneController = TextEditingController();
    String? err;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 8,
            bottom: MediaQuery.viewInsetsOf(ctx).bottom + 24,
          ),
          child: StatefulBuilder(
            builder: (context, setModalState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Phone sign-in', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 12),
                  AppTextField(
                    controller: phoneController,
                    label: 'Phone',
                    keyboardType: TextInputType.phone,
                    errorText: err,
                    autofillHints: const [AutofillHints.telephoneNumber],
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () {
                      final e = Validators.phone(phoneController.text);
                      setModalState(() => err = e);
                      if (e != null) return;
                      Navigator.pop(ctx);
                      auth.add(AuthPhoneDummySubmitted(phoneController.text.trim()));
                    },
                    child: const Text('Continue'),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
    phoneController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: AutofillGroup(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            children: [
              const SizedBox(height: 12),
              RepaintBoundary(
                child: Hero(
                  tag: 'app_logo',
                  child: Material(
                    color: Colors.transparent,
                    child: Icon(Icons.bolt_rounded, size: 56, color: scheme.primary),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text('Welcome back', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 8),
              Text(
                'Sign in to continue. Demo: ${AppConstants.demoEmail} / ${AppConstants.demoPassword}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
              ),
              const SizedBox(height: 28),
              _LoginCredentials(key: _credentialsKey),
              const SizedBox(height: 20),
              BlocBuilder<AuthBloc, AuthState>(
                buildWhen: (p, c) => p.status != c.status,
                builder: (context, state) {
                  final loading = state.status == AuthStatus.loading;
                  return RepaintBoundary(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        FilledButton(
                          onPressed: loading
                              ? null
                              : () {
                                  FocusScope.of(context).unfocus();
                                  context.read<AuthBloc>().add(const AuthErrorCleared());
                                  _credentialsKey.currentState?.submit(context);
                                },
                          child: loading
                              ? const SizedBox(
                                  height: 22,
                                  width: 22,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Text('Sign in'),
                        ),
                        const SizedBox(height: 16),
                        OutlinedButton.icon(
                          onPressed: loading
                              ? null
                              : () => context.read<AuthBloc>().add(const AuthGoogleDummySubmitted()),
                          icon: const Icon(Icons.g_mobiledata_rounded, size: 28),
                          label: const Text('Continue with Google'),
                        ),
                        const SizedBox(height: 8),
                        OutlinedButton.icon(
                          onPressed: loading ? null : _phoneFlow,
                          icon: const Icon(Icons.phone_android_rounded),
                          label: const Text('Continue with phone'),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('No account?', style: TextStyle(color: scheme.onSurfaceVariant)),
                            TextButton(
                              onPressed: loading ? null : () => context.read<AppRouterCubit>().showRegister(),
                              child: const Text('Register'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Isolated subtree: typing only rebuilds email/password fields, not the whole screen.
class _LoginCredentials extends StatefulWidget {
  const _LoginCredentials({super.key});

  @override
  State<_LoginCredentials> createState() => _LoginCredentialsState();
}

class _LoginCredentialsState extends State<_LoginCredentials> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  String? _emailError;
  String? _passwordError;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void submit(BuildContext context) {
    final emailErr = Validators.email(_email.text);
    final passErr = Validators.password(_password.text);
    setState(() {
      _emailError = emailErr;
      _passwordError = passErr;
    });
    if (emailErr != null || passErr != null) return;
    context.read<AuthBloc>().add(
          AuthLoginEmailSubmitted(email: _email.text.trim(), password: _password.text),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      buildWhen: (p, c) => p.status != c.status,
      builder: (context, state) {
        final loading = state.status == AuthStatus.loading;
        return RepaintBoundary(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppTextField(
                controller: _email,
                label: 'Email',
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.email],
                prefixIcon: const Icon(Icons.mail_outline),
                errorText: _emailError,
                enabled: !loading,
                onChanged: (_) {
                  if (_emailError != null) setState(() => _emailError = null);
                },
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _password,
                label: 'Password',
                obscureText: true,
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.password],
                prefixIcon: const Icon(Icons.lock_outline),
                errorText: _passwordError,
                enabled: !loading,
                onSubmitted: (_) {
                  FocusScope.of(context).unfocus();
                  context.read<AuthBloc>().add(const AuthErrorCleared());
                  submit(context);
                },
                onChanged: (_) {
                  if (_passwordError != null) setState(() => _passwordError = null);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
