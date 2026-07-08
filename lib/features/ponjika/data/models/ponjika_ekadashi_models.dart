class EkadashiDay {
  EkadashiDay({
    required this.name,
    required this.date,
    required this.paksha,
    required this.parana,
    required this.vrataType,
    required this.note,
  });

  final String name;
  final String date;
  final String paksha;
  final String parana;
  final String vrataType;
  final String note;

  factory EkadashiDay.fromJson(Map<String, dynamic> json) {
    return EkadashiDay(
      name: json['name'] as String,
      date: json['date'] as String,
      paksha: json['paksha'] as String,
      parana: json['parana'] as String,
      vrataType: json['vrataType'] as String,
      note: json['note'] as String,
    );
  }

  String get monthLabel {
    final parts = date.split('-');
    if (parts.length < 2) return '';
    const months = [
      '', 'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    final m = int.tryParse(parts[1]) ?? 0;
    return m >= 1 && m <= 12 ? months[m] : '';
  }
}

class PonjikaEkadashi {
  PonjikaEkadashi({
    required this.year,
    required this.upcomingName,
    required this.upcomingDate,
    required this.items,
  });

  final int year;
  final String upcomingName;
  final String upcomingDate;
  final List<EkadashiDay> items;

  factory PonjikaEkadashi.fromJson(Map<String, dynamic> json) {
    return PonjikaEkadashi(
      year: (json['year'] as num).toInt(),
      upcomingName: json['upcomingName'] as String,
      upcomingDate: json['upcomingDate'] as String,
      items: (json['items'] as List<dynamic>)
          .map((e) => EkadashiDay.fromJson(e as Map<String, dynamic>))
          .toList(growable: false),
    );
  }
}
