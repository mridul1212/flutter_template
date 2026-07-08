import 'package:flutter/material.dart';
import 'package:flutter_template/core/theme/app_colors.dart';
import 'package:flutter_template/features/ponjika/data/models/ponjika_models.dart';
import 'package:flutter_template/features/ponjika/presentation/widgets/ponjika_widgets.dart';

class LognoSectionTab extends StatelessWidget {
  const LognoSectionTab({super.key, required this.section, this.showTimings = false});

  final LognoSection section;
  final bool showTimings;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      children: [
        SectionHeader(title: section.title, subtitle: section.subtitle),
        if (section.tips.isNotEmpty) ...[
          ...section.tips.map(
            (tip) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.lightbulb_outline_rounded, size: 18, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(width: 8),
                  Expanded(child: Text(tip, style: Theme.of(context).textTheme.bodyMedium)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
        if (section.slots.isNotEmpty) ...[
          const SectionHeader(title: 'শুভ লগ্ন', subtitle: 'Auspicious muhurta slots'),
          ...section.slots.map(
            (s) => Padding(padding: const EdgeInsets.only(bottom: 10), child: LognoSlotCard(slot: s)),
          ),
        ],
        if (showTimings && section.timings.isNotEmpty) ...[
          const SizedBox(height: 8),
          const SectionHeader(title: 'Puja timings', subtitle: 'Daily darshan, bhog & arati'),
          ...section.timings.map(
            (p) => Padding(padding: const EdgeInsets.only(bottom: 10), child: PujaTimingCard(timing: p)),
          ),
        ],
        if (section.inauspicious.isNotEmpty) ...[
          const SizedBox(height: 8),
          const SectionHeader(title: 'অশুভ সময়', subtitle: 'Avoid these windows'),
          ...section.inauspicious.map(
            (t) => Padding(padding: const EdgeInsets.only(bottom: 10), child: InauspiciousCard(item: t)),
          ),
        ],
        if (section.slots.isEmpty && section.inauspicious.isEmpty && section.timings.isEmpty)
          const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: Text('No entries for this section yet.')),
          ),
      ],
    );
  }
}

class LognoSlotCard extends StatelessWidget {
  const LognoSlotCard({super.key, required this.slot});

  final LognoSlot slot;

  @override
  Widget build(BuildContext context) {
    final color = lognoQualityColor(slot.quality);
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.15),
          child: Icon(Icons.auto_awesome_rounded, color: color, size: 22),
        ),
        title: Text(slot.name, style: const TextStyle(fontWeight: FontWeight.w800)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(slot.time, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900)),
            const SizedBox(height: 4),
            Text(slot.note),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            lognoQualityLabel(slot.quality),
            style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 12),
          ),
        ),
        isThreeLine: true,
      ),
    );
  }
}

class InauspiciousCard extends StatelessWidget {
  const InauspiciousCard({super.key, required this.item});

  final InauspiciousTime item;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.danger.withValues(alpha: 0.06),
      child: ListTile(
        leading: Icon(Icons.block_rounded, color: AppColors.danger.withValues(alpha: 0.85)),
        title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.w800)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(item.time, style: const TextStyle(fontWeight: FontWeight.w700)),
            Text(item.note),
          ],
        ),
        isThreeLine: true,
      ),
    );
  }
}

class PujaTimingCard extends StatelessWidget {
  const PujaTimingCard({super.key, required this.timing});

  final PujaTiming timing;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: scheme.primary.withValues(alpha: 0.12),
          child: Icon(Icons.temple_hindu_rounded, color: scheme.primary),
        ),
        title: Text(timing.name, style: const TextStyle(fontWeight: FontWeight.w800)),
        subtitle: Text('${timing.deity} • ${timing.note}'),
        trailing: Text(
          timing.time,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900, color: scheme.primary),
        ),
      ),
    );
  }
}

class LognoHighlightsSection extends StatelessWidget {
  const LognoHighlightsSection({super.key, required this.year, required this.highlights});

  final int year;
  final List<LognoMonthHighlight> highlights;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      children: [
        SectionHeader(title: '$year highlights', subtitle: 'Month-wise best logno for festivals'),
        ...highlights.map(
          (m) => Card(
            margin: const EdgeInsets.only(bottom: 10),
            child: ExpansionTile(
              title: Text(m.month, style: const TextStyle(fontWeight: FontWeight.w800)),
              children: m.highlights
                  .map(
                    (h) => ListTile(
                      dense: true,
                      leading: const Icon(Icons.check_circle_outline, size: 20),
                      title: Text(h),
                    ),
                  )
                  .toList(growable: false),
            ),
          ),
        ),
      ],
    );
  }
}
