class FeedSection {
  FeedSection({required this.title, required this.items});

  final String title;
  final List<FeedItem> items;

  factory FeedSection.fromJson(Map<String, dynamic> json) {
    return FeedSection(
      title: json['title'] as String,
      items: (json['items'] as List<dynamic>)
          .map((e) => FeedItem.fromJson(e as Map<String, dynamic>))
          .toList(growable: false),
    );
  }
}

class FeedItem {
  FeedItem({
    required this.id,
    required this.title,
    required this.subtitle,
    this.tag,
    this.time,
  });

  final String id;
  final String title;
  final String subtitle;
  final String? tag;
  final String? time;

  factory FeedItem.fromJson(Map<String, dynamic> json) {
    return FeedItem(
      id: json['id'] as String,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String,
      tag: json['tag'] as String?,
      time: json['time'] as String?,
    );
  }
}

