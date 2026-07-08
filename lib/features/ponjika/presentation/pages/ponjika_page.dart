import 'package:flutter/material.dart';
import 'package:flutter_template/features/ponjika/data/models/ponjika_models.dart';
import 'package:flutter_template/features/ponjika/presentation/widgets/ponjika_widgets.dart';
import 'package:flutter_template/features/ponjika/presentation/widgets/ponjika_year_banner.dart';
import 'package:flutter_template/features/ponjika/presentation/widgets/ponjika_year_selector.dart';
import 'package:flutter_template/presentation/router/app_route_paths.dart';
import 'package:go_router/go_router.dart';

class PonjikaPage extends StatelessWidget {
  const PonjikaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('বাংলা পঞ্জিকা'),
        actions: const [PonjikaYearSelector()],
      ),
      body: Column(
        children: [
          const PonjikaYearBanner(),
          Expanded(
            child: PonjikaLoadBody(
              builder: (context, data) {
                return ListView(
                  key: ValueKey<int>(data.year),
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
                  children: [
              PonjikaTodayCard(today: data.today, year: data.year, bengaliYear: data.bengaliYear),
              const SizedBox(height: 16),
              _QuickLinksRow(year: data.year),
              const SizedBox(height: 20),
              SectionHeader(
                title: 'Durga Puja ${data.year}',
                subtitle: 'Year-wise puja schedule & rituals',
              ),
              ...data.durgaPujaDays.map((day) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _PujaDayCard(day: day),
                  )),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickLinksRow extends StatelessWidget {
  const _QuickLinksRow({required this.year});

  final int year;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Expanded(
          child: _LinkChip(
            icon: Icons.access_time_filled_rounded,
            label: 'Logno',
            subtitle: '$year',
            color: scheme.primary,
            onTap: () => context.push(AppRoutePaths.logno),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _LinkChip(
            icon: Icons.date_range_rounded,
            label: 'Ekadashi',
            subtitle: '$year chart',
            color: scheme.tertiary,
            onTap: () => context.push(AppRoutePaths.ekadashi),
          ),
        ),
      ],
    );
  }
}

class _LinkChip extends StatelessWidget {
  const _LinkChip({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              CircleAvatar(backgroundColor: color.withValues(alpha: 0.15), child: Icon(icon, color: color)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900)),
                    Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
      ),
    );
  }
}

class _PujaDayCard extends StatelessWidget {
  const _PujaDayCard({required this.day});

  final PujaScheduleDay day;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(day.title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900)),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: scheme.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(day.tag, style: TextStyle(color: scheme.primary, fontWeight: FontWeight.w800, fontSize: 12)),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text('${day.date} • ${day.bengaliDay}', style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 12),
            ...day.events.map(
              (e) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Icon(_badgeIcon(e.badge), size: 18, color: scheme.primary),
                    const SizedBox(width: 8),
                    Text(e.time, style: Theme.of(context).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w800)),
                    const SizedBox(width: 8),
                    Expanded(child: Text(e.name)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _badgeIcon(String badge) {
    return switch (badge) {
      'anjali' => Icons.front_hand_rounded,
      'arati' => Icons.local_fire_department_rounded,
      'special' => Icons.auto_awesome_rounded,
      _ => Icons.schedule_rounded,
    };
  }
}
