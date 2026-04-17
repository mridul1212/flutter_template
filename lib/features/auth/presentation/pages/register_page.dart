import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_template/core/utils/validators.dart';
import 'package:flutter_template/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter_template/features/auth/presentation/bloc/auth_event.dart';
import 'package:flutter_template/features/auth/presentation/bloc/auth_state.dart';
import 'package:flutter_template/presentation/router/app_router_cubit.dart';
import 'package:flutter_template/shared/widgets/app_text_field.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  final _phone = TextEditingController();

  String? _nameError;
  String? _emailError;
  String? _passwordError;
  String? _confirmError;
  String? _phoneError;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    _phone.dispose();
    super.dispose();
  }

  void _submitEmail() {
    FocusScope.of(context).unfocus();
    context.read<AuthBloc>().add(const AuthErrorCleared());
    final n = Validators.name(_name.text);
    final e = Validators.email(_email.text);
    final p = Validators.password(_password.text);
    final c = Validators.optionalConfirmPassword(_password.text, _confirm.text);
    setState(() {
      _nameError = n;
      _emailError = e;
      _passwordError = p;
      _confirmError = c;
    });
    if (n != null || e != null || p != null || c != null) {
      return;
    }
    context.read<AuthBloc>().add(
          AuthRegisterEmailSubmitted(
            name: _name.text.trim(),
            email: _email.text.trim(),
            password: _password.text,
          ),
        );
  }

  void _submitPhone() {
    FocusScope.of(context).unfocus();
    context.read<AuthBloc>().add(const AuthErrorCleared());
    final ph = Validators.phone(_phone.text);
    setState(() => _phoneError = ph);
    if (ph != null) return;
    context.read<AuthBloc>().add(AuthPhoneDummySubmitted(_phone.text.trim()));
  }

  void _onEmailFieldsChanged() {
    if (_nameError != null || _emailError != null || _passwordError != null || _confirmError != null) {
      setState(() {
        _nameError = null;
        _emailError = null;
        _passwordError = null;
        _confirmError = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
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
      child: BlocBuilder<AuthBloc, AuthState>(
        buildWhen: (p, c) => p.status != c.status,
        builder: (context, state) {
          final loading = state.status == AuthStatus.loading;
          return Scaffold(
            resizeToAvoidBottomInset: true,
            appBar: AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: loading ? null : () => context.read<AppRouterCubit>().showLogin(),
              ),
              title: const Text('Create account'),
              bottom: TabBar(
                controller: _tabs,
                tabs: const [
                  Tab(text: 'Email'),
                  Tab(text: 'Google'),
                  Tab(text: 'Phone'),
                ],
              ),
            ),
            body: RepaintBoundary(
              child: TabBarView(
                controller: _tabs,
                children: [
                  _EmailTab(
                    loading: loading,
                    name: _name,
                    email: _email,
                    password: _password,
                    confirm: _confirm,
                    nameError: _nameError,
                    emailError: _emailError,
                    passwordError: _passwordError,
                    confirmError: _confirmError,
                    onChanged: _onEmailFieldsChanged,
                    onSubmit: _submitEmail,
                  ),
                  _GoogleTab(
                    loading: loading,
                    scheme: scheme,
                    onPressed: () => context.read<AuthBloc>().add(const AuthGoogleDummySubmitted()),
                  ),
                  _PhoneTab(
                    loading: loading,
                    phone: _phone,
                    phoneError: _phoneError,
                    onChanged: () {
                      if (_phoneError != null) setState(() => _phoneError = null);
                    },
                    onSubmit: _submitPhone,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _EmailTab extends StatelessWidget {
  const _EmailTab({
    required this.loading,
    required this.name,
    required this.email,
    required this.password,
    required this.confirm,
    required this.nameError,
    required this.emailError,
    required this.passwordError,
    required this.confirmError,
    required this.onChanged,
    required this.onSubmit,
  });

  final bool loading;
  final TextEditingController name;
  final TextEditingController email;
  final TextEditingController password;
  final TextEditingController confirm;
  final String? nameError;
  final String? emailError;
  final String? passwordError;
  final String? confirmError;
  final VoidCallback onChanged;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return AutofillGroup(
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          AppTextField(
            controller: name,
            label: 'Full name',
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.name],
            prefixIcon: const Icon(Icons.person_outline),
            errorText: nameError,
            enabled: !loading,
            onChanged: (_) => onChanged(),
          ),
          const SizedBox(height: 16),
          AppTextField(
            controller: email,
            label: 'Email',
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.email],
            prefixIcon: const Icon(Icons.mail_outline),
            errorText: emailError,
            enabled: !loading,
            onChanged: (_) => onChanged(),
          ),
          const SizedBox(height: 16),
          AppTextField(
            controller: password,
            label: 'Password',
            obscureText: true,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.newPassword],
            prefixIcon: const Icon(Icons.lock_outline),
            errorText: passwordError,
            enabled: !loading,
            onChanged: (_) => onChanged(),
          ),
          const SizedBox(height: 16),
          AppTextField(
            controller: confirm,
            label: 'Confirm password',
            obscureText: true,
            textInputAction: TextInputAction.done,
            autofillHints: const [AutofillHints.newPassword],
            prefixIcon: const Icon(Icons.lock_person_outlined),
            errorText: confirmError,
            enabled: !loading,
            onSubmitted: (_) => onSubmit(),
            onChanged: (_) => onChanged(),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: loading ? null : onSubmit,
            child: loading
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Create account'),
          ),
        ],
      ),
    );
  }
}

class _GoogleTab extends StatelessWidget {
  const _GoogleTab({
    required this.loading,
    required this.scheme,
    required this.onPressed,
  });

  final bool loading;
  final ColorScheme scheme;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text(
          'Google registration is stubbed here. Tap below to simulate a successful OAuth result.',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: scheme.onSurfaceVariant, height: 1.4),
        ),
        const SizedBox(height: 24),
        OutlinedButton.icon(
          onPressed: loading ? null : onPressed,
          icon: const Icon(Icons.g_mobiledata_rounded, size: 28),
          label: const Text('Continue with Google'),
        ),
      ],
    );
  }
}

class _PhoneTab extends StatelessWidget {
  const _PhoneTab({
    required this.loading,
    required this.phone,
    required this.phoneError,
    required this.onChanged,
    required this.onSubmit,
  });

  final bool loading;
  final TextEditingController phone;
  final String? phoneError;
  final VoidCallback onChanged;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text(
          'Phone OTP is not wired yet — this continues with a dummy profile so you can build flows later.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                height: 1.4,
              ),
        ),
        const SizedBox(height: 20),
        AppTextField(
          controller: phone,
          label: 'Phone number',
          keyboardType: TextInputType.phone,
          textInputAction: TextInputAction.done,
          autofillHints: const [AutofillHints.telephoneNumber],
          prefixIcon: const Icon(Icons.phone_android_rounded),
          errorText: phoneError,
          enabled: !loading,
          onSubmitted: (_) => onSubmit(),
          onChanged: (_) => onChanged(),
        ),
        const SizedBox(height: 24),
        FilledButton(
          onPressed: loading ? null : onSubmit,
          child: loading
              ? const SizedBox(
                  height: 22,
                  width: 22,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Continue'),
        ),
      ],
    );
  }
}
