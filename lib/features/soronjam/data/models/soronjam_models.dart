class SoronjamItem {
  SoronjamItem({
    required this.id,
    required this.title,
    required this.category,
    required this.detail,
    required this.priority,
    this.checked = false,
  });

  final String id;
  final String title;
  final String category;
  final String detail;
  final String priority;
  final bool checked;

  SoronjamItem copyWith({bool? checked}) {
    return SoronjamItem(
      id: id,
      title: title,
      category: category,
      detail: detail,
      priority: priority,
      checked: checked ?? this.checked,
    );
  }

  factory SoronjamItem.fromJson(Map<String, dynamic> json, {bool checked = false}) {
    return SoronjamItem(
      id: json['id'] as String,
      title: json['title'] as String,
      category: json['category'] as String,
      detail: json['detail'] as String,
      priority: json['priority'] as String? ?? 'optional',
      checked: checked,
    );
  }
}

class SoronjamData {
  SoronjamData({
    required this.title,
    required this.subtitle,
    required this.year,
    required this.items,
  });

  final String title;
  final String subtitle;
  final int year;
  final List<SoronjamItem> items;

  int get checkedCount => items.where((i) => i.checked).length;
  double get progress => items.isEmpty ? 0 : checkedCount / items.length;

  SoronjamData copyWith({List<SoronjamItem>? items}) {
    return SoronjamData(
      title: title,
      subtitle: subtitle,
      year: year,
      items: items ?? this.items,
    );
  }

  factory SoronjamData.fromJson(Map<String, dynamic> json, Set<String> checkedIds) {
    return SoronjamData(
      title: json['title'] as String,
      subtitle: json['subtitle'] as String,
      year: (json['year'] as num?)?.toInt() ?? DateTime.now().year,
      items: (json['items'] as List<dynamic>).map((e) {
        final m = e as Map<String, dynamic>;
        return SoronjamItem.fromJson(m, checked: checkedIds.contains(m['id']));
      }).toList(growable: false),
    );
  }
}
