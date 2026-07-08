import 'package:flutter/material.dart';
import 'package:flutter_template/core/theme/app_colors.dart';
import 'package:flutter_template/features/ponjika/data/datasources/ekadashi_reminder_store.dart';
import 'package:flutter_template/features/ponjika/data/models/ponjika_models.dart';
import 'package:flutter_template/features/ponjika/presentation/widgets/ponjika_widgets.dart';
import 'package:flutter_template/features/ponjika/presentation/widgets/ponjika_year_banner.dart';
import 'package:flutter_template/features/ponjika/presentation/widgets/ponjika_year_selector.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EkadashiPage extends StatelessWidget {
  const EkadashiPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('একাদশী চার্ট'),
        actions: const [PonjikaYearSelector()],
      ),
      body: Column(
        children: [
          const PonjikaYearBanner(),
          Expanded(
            child: PonjikaLoadBody(
              builder: (context, data) {
                final ek = data.ekadashi;
                final grouped = _groupByMonth(ek.items);
                return ListView(
                  key: ValueKey<int>(data.year),
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
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
                      Text(
                        'Ekadashi ${ek.year}',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Theme.of(context).colorScheme.onPrimary,
                              fontWeight: FontWeight.w900,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Next: ${ek.upcomingName}',
                        style: TextStyle(color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.92)),
                      ),
                      Text(
                        ek.upcomingDate,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary,
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${ek.items.length} ekadashi days in ${ek.year}',
                        style: TextStyle(color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.85)),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SectionHeader(
                title: 'Full year list',
                subtitle: 'Krishna & Shukla paksha with parana time',
              ),
              ...grouped.entries.map((entry) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 8, bottom: 8),
                      child: Text(
                        entry.key,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900),
                      ),
                    ),
                    ...entry.value.map(
                      (day) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _EkadashiCard(day: day),
                      ),
                    ),
                  ],
                );
              }),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Map<String, List<EkadashiDay>> _groupByMonth(List<EkadashiDay> items) {
    final map = <String, List<EkadashiDay>>{};
    for (final item in items) {
      final key = item.monthLabel.isEmpty ? 'Other' : item.monthLabel;
      map.putIfAbsent(key, () => []).add(item);
    }
    return map;
  }
}

class _EkadashiCard extends StatefulWidget {
  const _EkadashiCard({required this.day});

  final EkadashiDay day;

  @override
  State<_EkadashiCard> createState() => _EkadashiCardState();
}

class _EkadashiCardState extends State<_EkadashiCard> {
  bool _reminder = false;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _loadReminder();
  }

  Future<void> _loadReminder() async {
    final prefs = await SharedPreferences.getInstance();
    final store = EkadashiReminderStore(prefs);
    if (!mounted) return;
    setState(() {
      _reminder = store.isEnabled(widget.day.date);
      _loaded = true;
    });
  }

  Future<void> _toggle(bool v) async {
    final prefs = await SharedPreferences.getInstance();
    await EkadashiReminderStore(prefs).setEnabled(widget.day.date, v);
    if (!mounted) return;
    setState(() => _reminder = v);
    if (v) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Reminder set 1 day before ${widget.day.name}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final day = widget.day;
    final scheme = Theme.of(context).colorScheme;
    final isNirjala = day.vrataType == 'nirjala';
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isNirjala ? AppColors.warmOrange.withValues(alpha: 0.2) : scheme.tertiary.withValues(alpha: 0.2),
          child: Icon(
            isNirjala ? Icons.water_drop_outlined : Icons.date_range_rounded,
            color: isNirjala ? AppColors.warmOrange : scheme.tertiary,
          ),
        ),
        title: Text(day.name, style: const TextStyle(fontWeight: FontWeight.w800)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('${day.date} • ${day.paksha} Paksha'),
            Text('Parana: ${day.parana}'),
            if (day.note.isNotEmpty) Text(day.note, style: Theme.of(context).textTheme.bodySmall),
            if (_loaded)
              Row(
                children: [
                  const Text('Remind me', style: TextStyle(fontSize: 12)),
                  Switch(value: _reminder, onChanged: _toggle),
                ],
              ),
          ],
        ),
        trailing: day.vrataType == 'nirjala'
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.warmOrange.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text('Nirjala', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11)),
              )
            : null,
        isThreeLine: true,
      ),
    );
  }
}
