import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_template/core/theme/app_colors.dart';
import 'package:flutter_template/features/mondop/data/models/mondop_models.dart';
import 'package:flutter_template/features/mondop/presentation/cubit/mondop_detail_cubit.dart';
import 'package:flutter_template/features/mondop/presentation/widgets/mondop_reviews_section.dart';
import 'package:flutter_template/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

class MondopDetailPage extends StatefulWidget {
  const MondopDetailPage({super.key, required this.mondopId});

  final String mondopId;

  @override
  State<MondopDetailPage> createState() => _MondopDetailPageState();
}

class _MondopDetailPageState extends State<MondopDetailPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MondopDetailCubit>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return BlocBuilder<MondopDetailCubit, MondopDetailState>(
      builder: (context, state) {
        final item = state.item;
        return Scaffold(
          appBar: AppBar(title: Text(item?.name ?? 'Mondop details')),
          body: switch (state.load) {
            MondopDetailLoad.loading => const Center(child: CircularProgressIndicator()),
            MondopDetailLoad.failure => ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  Text(state.error ?? 'Error', style: TextStyle(color: Theme.of(context).colorScheme.error)),
                  const SizedBox(height: 12),
                  FilledButton.tonal(
                    onPressed: () => context.read<MondopDetailCubit>().load(),
                    child: Text(t.retry),
                  ),
                ],
              ),
            MondopDetailLoad.success when item != null => _DetailBody(item: item, reviews: state.reviews),
            _ => const SizedBox.shrink(),
          },
        );
      },
    );
  }
}

class _DetailBody extends StatelessWidget {
  const _DetailBody({required this.item, this.reviews});

  final MondopItem item;
  final MondopReviewSummary? reviews;

  Future<void> _openInMaps(BuildContext context) async {
    final uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=${item.lat},${item.lng}');
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not open Maps')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final detail = item.detail;
    final scheme = Theme.of(context).colorScheme;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
      children: [
        Card(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                colors: AppColors.brandGradient.map((c) => c.withValues(alpha: 0.92)).toList(growable: false),
              ),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.area, style: TextStyle(color: scheme.onPrimary.withValues(alpha: 0.9))),
                Text(
                  item.name,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: scheme.onPrimary,
                        fontWeight: FontWeight.w900,
                      ),
                ),
                const SizedBox(height: 6),
                Text(item.theme, style: TextStyle(color: scheme.onPrimary.withValues(alpha: 0.92))),
                if (item.rating != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded, color: AppColors.brandTertiary, size: 18),
                      Text(
                        ' ${item.rating!.toStringAsFixed(1)} (${item.reviewCount ?? 0})',
                        style: TextStyle(color: scheme.onPrimary.withValues(alpha: 0.95), fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
        if (detail != null) ...[
          const SizedBox(height: 16),
          _InfoSection(
            title: 'About',
            children: [
              Text(detail.description, style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 12),
              _InfoRow(icon: Icons.location_on_outlined, label: 'Address', value: detail.address),
              _InfoRow(icon: Icons.groups_outlined, label: 'Organizer', value: detail.organizer),
              _InfoRow(icon: Icons.phone_outlined, label: 'Contact', value: detail.phone),
              const SizedBox(height: 6),
              FilledButton.tonal(
                onPressed: () => _openInMaps(context),
                child: const Text('Open in Maps'),
              ),
              if (detail.capacity != null)
                _InfoRow(icon: Icons.people_outline, label: 'Capacity', value: detail.capacity!),
              if (detail.parking != null)
                _InfoRow(icon: Icons.local_parking_outlined, label: 'Parking', value: detail.parking!),
            ],
          ),
          if (detail.timings.isNotEmpty) ...[
            const SizedBox(height: 16),
            _InfoSection(
              title: 'Puja timings',
              children: detail.timings
                  .map(
                    (timing) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.schedule_rounded),
                      title: Text(timing.label, style: const TextStyle(fontWeight: FontWeight.w800)),
                      trailing: Text(timing.time, style: const TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  )
                  .toList(growable: false),
            ),
          ],
          if (detail.highlights.isNotEmpty) ...[
            const SizedBox(height: 16),
            _InfoSection(
              title: 'Highlights',
              children: detail.highlights
                  .map(
                    (h) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Icon(Icons.check_circle_outline, size: 18, color: scheme.primary),
                          const SizedBox(width: 8),
                          Expanded(child: Text(h)),
                        ],
                      ),
                    ),
                  )
                  .toList(growable: false),
            ),
          ],
        ] else
          const Padding(
            padding: EdgeInsets.all(24),
            child: Text('No extra details available for this mondop.'),
          ),
        const SizedBox(height: 12),
        if (reviews != null) MondopReviewsSection(summary: reviews!, mondopId: item.id),
        Card(
          child: ListTile(
            leading: const Icon(Icons.map_outlined),
            title: const Text('Coordinates'),
            subtitle: Text('${item.lat.toStringAsFixed(4)}, ${item.lng.toStringAsFixed(4)}'),
          ),
        ),
      ],
    );
  }
}

class _InfoSection extends StatelessWidget {
  const _InfoSection({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900)),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: Theme.of(context).textTheme.labelMedium),
                Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
