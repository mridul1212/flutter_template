class HomeCountdown {
  HomeCountdown({
    required this.title,
    required this.subtitle,
    required this.target,
    required this.temperatureC,
    required this.tithi,
    required this.bengaliDate,
  });

  final String title;
  final String subtitle;
  final DateTime target;
  final int temperatureC;
  final String tithi;
  final String bengaliDate;

  factory HomeCountdown.fromJson(Map<String, dynamic> json) {
    return HomeCountdown(
      title: json['title'] as String,
      subtitle: json['subtitle'] as String,
      target: DateTime.parse(json['target'] as String),
      temperatureC: (json['temperatureC'] as num).toInt(),
      tithi: json['tithi'] as String,
      bengaliDate: json['bengaliDate'] as String,
    );
  }
}

class HomeFeature {
  HomeFeature({required this.id, required this.title, required this.subtitle, required this.icon});

  final String id;
  final String title;
  final String subtitle;
  final String icon;

  factory HomeFeature.fromJson(Map<String, dynamic> json) {
    return HomeFeature(
      id: json['id'] as String,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String,
      icon: json['icon'] as String,
    );
  }
}

class HomeCalendarHighlights {
  HomeCalendarHighlights({
    required this.year,
    required this.bengaliDate,
    required this.tithi,
    required this.bestLogno,
    required this.nextEkadashi,
    required this.nextEkadashiDate,
    required this.pujaCountdownDays,
  });

  final int year;
  final String bengaliDate;
  final String tithi;
  final String bestLogno;
  final String nextEkadashi;
  final String nextEkadashiDate;
  final int pujaCountdownDays;

  factory HomeCalendarHighlights.fromJson(Map<String, dynamic> json) {
    return HomeCalendarHighlights(
      year: (json['year'] as num).toInt(),
      bengaliDate: json['bengaliDate'] as String,
      tithi: json['tithi'] as String,
      bestLogno: json['bestLogno'] as String,
      nextEkadashi: json['nextEkadashi'] as String,
      nextEkadashiDate: json['nextEkadashiDate'] as String,
      pujaCountdownDays: (json['pujaCountdownDays'] as num).toInt(),
    );
  }
}

class HomeDashboardData {
  HomeDashboardData({
    required this.countdown,
    required this.calendarHighlights,
    required this.featuresTitle,
    required this.features,
  });

  final HomeCountdown countdown;
  final HomeCalendarHighlights? calendarHighlights;
  final String featuresTitle;
  final List<HomeFeature> features;

  factory HomeDashboardData.fromJson(Map<String, dynamic> json) {
    final highlightsJson = json['calendarHighlights'];
    return HomeDashboardData(
      countdown: HomeCountdown.fromJson(json['countdown'] as Map<String, dynamic>),
      calendarHighlights: highlightsJson is Map<String, dynamic>
          ? HomeCalendarHighlights.fromJson(highlightsJson)
          : null,
      featuresTitle: json['featuresTitle'] as String,
      features: (json['features'] as List<dynamic>)
          .map((e) => HomeFeature.fromJson(e as Map<String, dynamic>))
          .toList(growable: false),
    );
  }
}

