import 'package:flutter/material.dart';
import 'package:flutter_template/features/home/data/models/feed_models.dart';

class FeedSectionCard extends StatelessWidget {
  const FeedSectionCard({super.key, required this.section});

  final FeedSection section;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(section.title, style: text.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(height: 10),
        ...section.items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: FeedItemCard(item: item),
            )),
      ],
    );
  }
}

class FeedItemCard extends StatelessWidget {
  const FeedItemCard({super.key, required this.item, this.onTap});

  final FeedItem item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      scheme.primary.withValues(alpha: 0.9),
                      scheme.tertiary.withValues(alpha: 0.9),
                    ],
                  ),
                ),
                child: Icon(Icons.auto_awesome_rounded, color: scheme.onPrimary),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.title,
                            style: text.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                          ),
                        ),
                        if (item.time != null) ...[
                          const SizedBox(width: 10),
                          Text(item.time!, style: text.labelMedium?.copyWith(color: scheme.onSurfaceVariant)),
                        ],
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item.subtitle,
                      style: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant, height: 1.25),
                    ),
                    if (item.tag != null) ...[
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: scheme.primaryContainer.withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(color: scheme.tertiary.withValues(alpha: 0.25)),
                          ),
                          child: Text(
                            item.tag!,
                            style: text.labelMedium?.copyWith(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

