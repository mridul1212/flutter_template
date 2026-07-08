class PonjikaToday {
  PonjikaToday({
    required this.date,
    required this.bengaliDate,
    required this.tithi,
    required this.paksha,
    required this.nakshatra,
    required this.sunrise,
    required this.sunset,
    required this.moonrise,
  });

  final String date;
  final String bengaliDate;
  final String tithi;
  final String paksha;
  final String nakshatra;
  final String sunrise;
  final String sunset;
  final String moonrise;

  factory PonjikaToday.fromJson(Map<String, dynamic> json) {
    return PonjikaToday(
      date: json['date'] as String,
      bengaliDate: json['bengaliDate'] as String,
      tithi: json['tithi'] as String,
      paksha: json['paksha'] as String,
      nakshatra: json['nakshatra'] as String,
      sunrise: json['sunrise'] as String,
      sunset: json['sunset'] as String,
      moonrise: json['moonrise'] as String,
    );
  }
}
