import 'package:flutter/material.dart';
import 'package:flutter_template/core/theme/app_colors.dart';
import 'package:flutter_template/features/home/data/models/home_dashboard_models.dart';
import 'package:flutter_template/features/home/presentation/widgets/dashboard_alpana_painter.dart';

class DashboardCountdownCard extends StatelessWidget {
  const DashboardCountdownCard({super.key, required this.countdown, required this.remaining});

  final HomeCountdown countdown;
  final Duration remaining;

  String _two(int v) => v.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final days = remaining.inDays;
    final hours = remaining.inHours.remainder(24);
    final minutes = remaining.inMinutes.remainder(60);
    final seconds = remaining.inSeconds.remainder(60);

    return Card(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: AppColors.countdownGradient.map((c) => c.withValues(alpha: 0.95)).toList(growable: false),
          ),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: Opacity(
                opacity: 0.10,
                child: CustomPaint(painter: DashboardAlpanaPainter(color: AppColors.goldGlow)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    countdown.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: scheme.onPrimary,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          countdown.subtitle,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: scheme.onPrimary,
                                fontWeight: FontWeight.w900,
                              ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: scheme.onPrimary.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: AppColors.goldGlow.withValues(alpha: 0.35)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.wb_sunny_rounded, size: 16, color: scheme.onPrimary),
                            const SizedBox(width: 6),
                            Text(
                              '${countdown.temperatureC}°C',
                              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                    color: scheme.onPrimary,
                                    fontWeight: FontWeight.w800,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(child: DashboardTimePill(value: days.toString(), label: 'Days')),
                      const SizedBox(width: 10),
                      Expanded(child: DashboardTimePill(value: _two(hours), label: 'Hours')),
                      const SizedBox(width: 10),
                      Expanded(child: DashboardTimePill(value: _two(minutes), label: 'Minutes')),
                      const SizedBox(width: 10),
                      Expanded(child: DashboardTimePill(value: _two(seconds), label: 'Seconds')),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    countdown.bengaliDate,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: scheme.onPrimary.withValues(alpha: 0.92),
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tithi: ${countdown.tithi}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: scheme.onPrimary.withValues(alpha: 0.86),
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DashboardTimePill extends StatelessWidget {
  const DashboardTimePill({super.key, required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: scheme.onPrimary.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.goldGlow.withValues(alpha: 0.22)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: scheme.onPrimary,
                  fontWeight: FontWeight.w900,
                ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: scheme.onPrimary.withValues(alpha: 0.9),
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}
