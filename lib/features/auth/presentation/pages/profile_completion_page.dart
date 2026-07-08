import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_template/core/theme/app_colors.dart';
import 'package:flutter_template/core/utils/validators.dart';
import 'package:flutter_template/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter_template/features/auth/presentation/bloc/auth_event.dart';
import 'package:flutter_template/features/auth/presentation/bloc/auth_state.dart';
import 'package:flutter_template/l10n/app_localizations.dart';
import 'package:flutter_template/presentation/router/app_router_cubit.dart';
import 'package:flutter_template/shared/widgets/app_text_field.dart';

/// SRS §3 — one-time profile completion after Google Sign-In.
class ProfileCompletionPage extends StatefulWidget {
  const ProfileCompletionPage({super.key});

  @override
  State<ProfileCompletionPage> createState() => _ProfileCompletionPageState();
}

class _ProfileCompletionPageState extends State<ProfileCompletionPage> {
  final _nameCtrl = TextEditingController();
  final _dobCtrl = TextEditingController();
  final _timeCtrl = TextEditingController();
  final _birthPlaceCtrl = TextEditingController();
  String _district = 'Dhaka';
  String? _gender;
  String? _nameErr;
  String? _dobErr;
  String? _timeErr;

  static const _districts = [
    'Dhaka', 'Khulna', 'Barishal', 'Chattogram', 'Rajshahi', 'Sylhet',
    'Rangpur', 'Mymensingh', 'Gopalganj', 'Dinajpur', 'Jessore', 'Comilla',
  ];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _dobCtrl.dispose();
    _timeCtrl.dispose();
    _birthPlaceCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    setState(() {
      _nameErr = Validators.name(_nameCtrl.text);
      _dobErr = Validators.dateOfBirth(_dobCtrl.text);
      _timeErr = Validators.birthTime(_timeCtrl.text);
    });
    if (_nameErr != null || _dobErr != null || _timeErr != null) return;
    context.read<AuthBloc>().add(
          AuthProfileCompletionSubmitted(
            name: _nameCtrl.text,
            district: _district,
            dateOfBirth: _dobCtrl.text.trim(),
            timeOfBirth: _timeCtrl.text.trim().isEmpty ? null : _timeCtrl.text.trim(),
            birthPlace: _birthPlaceCtrl.text.trim().isEmpty ? null : _birthPlaceCtrl.text.trim(),
            gender: _gender,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (p, c) => p.status != c.status || p.errorMessage != c.errorMessage,
      listener: (context, state) {
        if (state.status == AuthStatus.success && state.user != null) {
          context.read<AppRouterCubit>().onProfileCompleted(state.user!);
          context.read<AuthBloc>().add(const AuthSessionConsumed());
        }
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Complete your profile'),
          automaticallyImplyLeading: false,
        ),
        body: BlocBuilder<AuthBloc, AuthState>(
          buildWhen: (p, c) => p.status != c.status,
          builder: (context, state) {
            final loading = state.status == AuthStatus.loading;
            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              children: [
                Card(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                        colors: AppColors.brandGradient.map((c) => c.withValues(alpha: 0.9)).toList(growable: false),
                      ),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Almost there!', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18)),
                        const SizedBox(height: 6),
                        Text(
                          'We need a few details for Panjika, Lagno & Biye Lagno matching.',
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.9)),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                AppTextField(controller: _nameCtrl, label: 'Full name', errorText: _nameErr),
                const SizedBox(height: 12),
                DropdownMenu<String>(
                  initialSelection: _district,
                  expandedInsets: EdgeInsets.zero,
                  enabled: !loading,
                  label: const Text('District'),
                  dropdownMenuEntries: _districts
                      .map((d) => DropdownMenuEntry<String>(value: d, label: d))
                      .toList(growable: false),
                  onSelected: (v) {
                    if (v == null) return;
                    setState(() => _district = v);
                  },
                ),
                const SizedBox(height: 12),
                AppTextField(
                  controller: _dobCtrl,
                  label: 'Date of birth (YYYY-MM-DD)',
                  keyboardType: TextInputType.datetime,
                  errorText: _dobErr,
                  hint: '1995-08-15',
                ),
                const SizedBox(height: 12),
                AppTextField(
                  controller: _timeCtrl,
                  label: 'Time of birth (optional, HH:MM)',
                  errorText: _timeErr,
                  hint: '14:30',
                ),
                const SizedBox(height: 12),
                AppTextField(controller: _birthPlaceCtrl, label: 'Birth place (optional)', hint: 'Dhaka, Bangladesh'),
                const SizedBox(height: 12),
                Text('Gender (optional)', style: Theme.of(context).textTheme.labelLarge),
                const SizedBox(height: 8),
                SegmentedButton<String?>(
                  segments: const [
                    ButtonSegment(value: 'male', label: Text('Male')),
                    ButtonSegment(value: 'female', label: Text('Female')),
                    ButtonSegment(value: 'other', label: Text('Other')),
                  ],
                  selected: {_gender},
                  emptySelectionAllowed: true,
                  onSelectionChanged: loading ? null : (s) => setState(() => _gender = s.firstOrNull),
                ),
                const SizedBox(height: 28),
                FilledButton(
                  onPressed: loading ? null : _submit,
                  child: loading
                      ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : Text(t.continueAction),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
