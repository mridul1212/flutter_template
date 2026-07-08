import 'package:flutter/material.dart';
import 'package:flutter_template/core/navigation/feature_navigation.dart';
import 'package:flutter_template/features/home/data/models/home_dashboard_models.dart';

class DashboardFeaturesGrid extends StatelessWidget {
  const DashboardFeaturesGrid({super.key, required this.features});

  final List<HomeFeature> features;

  static IconData iconFor(String key) {
    return switch (key) {
      'temple' => Icons.temple_hindu_rounded,
      'pin' => Icons.location_on_rounded,
      'calendar' => Icons.calendar_month_rounded,
      'clock' => Icons.access_time_rounded,
      'date_range' => Icons.date_range_rounded,
      'favorite' => Icons.favorite_rounded,
      'bag' => Icons.shopping_bag_rounded,
      'list' => Icons.checklist_rounded,
      'wallet' => Icons.account_balance_wallet_rounded,
      'book' => Icons.menu_book_rounded,
      'group' => Icons.groups_rounded,
      'photo' => Icons.photo_library_rounded,
      'share' => Icons.share_location_rounded,
      _ => Icons.auto_awesome_rounded,
    };
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.82,
      ),
      itemCount: features.length,
      itemBuilder: (context, index) {
        final f = features[index];
        return Card(
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => FeatureNavigation.open(context, f.id),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          scheme.primary.withValues(alpha: 0.95),
                          scheme.tertiary.withValues(alpha: 0.95),
                        ],
                      ),
                    ),
                    child: Icon(iconFor(f.icon), color: scheme.onPrimary),
                  ),
                  const SizedBox(height: 8),
                  Flexible(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          f.title,
                          textAlign: TextAlign.center,
                          style: text.labelLarge?.copyWith(fontWeight: FontWeight.w800),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          f.subtitle,
                          textAlign: TextAlign.center,
                          style: text.labelSmall?.copyWith(color: scheme.onSurfaceVariant, height: 1.15),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
