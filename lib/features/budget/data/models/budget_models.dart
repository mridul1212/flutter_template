class BudgetEntry {
  BudgetEntry({
    required this.id,
    required this.title,
    required this.category,
    required this.planned,
    required this.spent,
    required this.note,
  });

  final String id;
  final String title;
  final String category;
  final int planned;
  final int spent;
  final String note;

  int get remaining => planned - spent;
  double get spentRatio => planned <= 0 ? 0 : (spent / planned).clamp(0, 1);

  BudgetEntry copyWith({int? planned, int? spent}) {
    return BudgetEntry(
      id: id,
      title: title,
      category: category,
      planned: planned ?? this.planned,
      spent: spent ?? this.spent,
      note: note,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'category': category,
        'planned': planned,
        'spent': spent,
        'note': note,
      };

  factory BudgetEntry.fromJson(Map<String, dynamic> json) {
    return BudgetEntry(
      id: json['id'] as String,
      title: json['title'] as String,
      category: json['category'] as String,
      planned: (json['planned'] as num).toInt(),
      spent: (json['spent'] as num).toInt(),
      note: json['note'] as String? ?? '',
    );
  }
}

class BudgetData {
  BudgetData({
    required this.title,
    required this.subtitle,
    required this.year,
    required this.currency,
    required this.entries,
  });

  final String title;
  final String subtitle;
  final int year;
  final String currency;
  final List<BudgetEntry> entries;

  int get totalPlanned => entries.fold(0, (s, e) => s + e.planned);
  int get totalSpent => entries.fold(0, (s, e) => s + e.spent);

  BudgetData copyWith({List<BudgetEntry>? entries}) {
    return BudgetData(
      title: title,
      subtitle: subtitle,
      year: year,
      currency: currency,
      entries: entries ?? this.entries,
    );
  }

  factory BudgetData.fromJson(Map<String, dynamic> json, List<BudgetEntry> entries) {
    return BudgetData(
      title: json['title'] as String,
      subtitle: json['subtitle'] as String,
      year: (json['year'] as num?)?.toInt() ?? DateTime.now().year,
      currency: json['currency'] as String? ?? '৳',
      entries: entries,
    );
  }
}
