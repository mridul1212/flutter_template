import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_template/core/theme/app_colors.dart';
import 'package:flutter_template/features/biye_lagno/data/models/biye_lagno_models.dart';
import 'package:flutter_template/features/biye_lagno/presentation/cubit/biye_lagno_cubit.dart';
import 'package:flutter_template/l10n/app_localizations.dart';

class BiyeLagnoPage extends StatefulWidget {
  const BiyeLagnoPage({super.key});

  @override
  State<BiyeLagnoPage> createState() => _BiyeLagnoPageState();
}

class _BiyeLagnoPageState extends State<BiyeLagnoPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => context.read<BiyeLagnoCubit>().load());
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('বিয়ে লগ্ন · Guna Milan')),
      body: BlocBuilder<BiyeLagnoCubit, BiyeLagnoState>(
        builder: (context, state) {
          if (state.load == BiyeLagnoLoad.loading && state.data == null) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.load == BiyeLagnoLoad.failure && state.data == null) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(state.error ?? 'Error'),
                  FilledButton.tonal(onPressed: () => context.read<BiyeLagnoCubit>().load(), child: Text(t.retry)),
                ],
              ),
            );
          }
          final data = state.data;
          if (data == null) return const SizedBox.shrink();
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            children: [
              _DisclaimerCard(),
              const SizedBox(height: 16),
              _ProfilePicker(
                title: 'Groom / Boy profile',
                profiles: data.sampleProfiles.where((p) => p.gender == 'male').toList(growable: false),
                selectedId: state.profileAId,
                onSelected: context.read<BiyeLagnoCubit>().selectProfileA,
              ),
              const SizedBox(height: 12),
              _ProfilePicker(
                title: 'Bride / Girl profile',
                profiles: data.sampleProfiles.where((p) => p.gender == 'female').toList(growable: false),
                selectedId: state.profileBId,
                onSelected: context.read<BiyeLagnoCubit>().selectProfileB,
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: state.load == BiyeLagnoLoad.matching ? null : () => context.read<BiyeLagnoCubit>().runMatch(),
                icon: state.load == BiyeLagnoLoad.matching
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.favorite_rounded),
                label: const Text('Calculate compatibility'),
              ),
              if (state.error != null) ...[
                const SizedBox(height: 12),
                Text(state.error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
              ],
              if (state.result != null) ...[
                const SizedBox(height: 20),
                _ResultCard(result: state.result!, labels: data.factorLabels),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _DisclaimerCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.goldGlow.withValues(alpha: 0.5),
      child: const Padding(
        padding: EdgeInsets.all(14),
        child: Row(
          children: [
            Icon(Icons.info_outline, color: AppColors.brandSecondary),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Informational only (SRS BYE-05). Does not replace priest/astrologer consultation.',
                style: TextStyle(fontSize: 13, height: 1.35),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfilePicker extends StatelessWidget {
  const _ProfilePicker({
    required this.title,
    required this.profiles,
    required this.selectedId,
    required this.onSelected,
  });

  final String title;
  final List<BiyeLagnoProfile> profiles;
  final String selectedId;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: RadioGroup<String>(
          groupValue: selectedId,
          onChanged: (v) {
            if (v == null) return;
            onSelected(v);
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
              const SizedBox(height: 10),
              ...profiles.map((p) {
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Radio<String>(value: p.id),
                  title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                  subtitle: Text('${p.dateOfBirth} · ${p.nakshatra ?? ''} · ${p.rashi ?? ''}'),
                  onTap: () => onSelected(p.id),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({required this.result, required this.labels});

  final BiyeLagnoResult result;
  final Map<String, String> labels;

  @override
  Widget build(BuildContext context) {
    final pct = result.totalScore / result.maxScore;
    final color = pct >= 0.75 ? AppColors.success : (pct >= 0.55 ? AppColors.warning : AppColors.danger);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('${result.totalScore}/${result.maxScore}', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: color)),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(result.verdict, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
                    Text(result.verdictBn, style: Theme.of(context).textTheme.labelMedium),
                  ],
                ),
              ],
            ),
            if (result.nadiDosha || result.bhakootDosha) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                children: [
                  if (result.nadiDosha) const Chip(label: Text('⚠ Nadi Dosha'), backgroundColor: Color(0xFFFFE8E8)),
                  if (result.bhakootDosha) const Chip(label: Text('⚠ Bhakoot Dosha'), backgroundColor: Color(0xFFFFF3CD)),
                ],
              ),
            ],
            const SizedBox(height: 14),
            ...result.breakdown.map(
              (b) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Expanded(child: Text(labels[b.key] ?? b.key)),
                    Text('${b.points}', style: const TextStyle(fontWeight: FontWeight.w800)),
                    const SizedBox(width: 8),
                    Expanded(flex: 2, child: Text(b.note, style: Theme.of(context).textTheme.bodySmall)),
                  ],
                ),
              ),
            ),
            const Divider(height: 24),
            Text(result.summary),
          ],
        ),
      ),
    );
  }
}
