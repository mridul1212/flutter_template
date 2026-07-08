class LognoSlot {
  LognoSlot({required this.name, required this.time, required this.quality, required this.note});

  final String name;
  final String time;
  final String quality;
  final String note;

  factory LognoSlot.fromJson(Map<String, dynamic> json) {
    return LognoSlot(
      name: json['name'] as String,
      time: json['time'] as String,
      quality: json['quality'] as String,
      note: json['note'] as String,
    );
  }
}

class InauspiciousTime {
  InauspiciousTime({required this.name, required this.time, required this.note, this.category});

  final String name;
  final String time;
  final String note;
  final String? category;

  factory InauspiciousTime.fromJson(Map<String, dynamic> json) {
    return InauspiciousTime(
      name: json['name'] as String,
      time: json['time'] as String,
      note: json['note'] as String,
      category: json['category'] as String?,
    );
  }
}

class PujaTiming {
  PujaTiming({required this.name, required this.time, required this.deity, required this.note});

  final String name;
  final String time;
  final String deity;
  final String note;

  factory PujaTiming.fromJson(Map<String, dynamic> json) {
    return PujaTiming(
      name: json['name'] as String,
      time: json['time'] as String,
      deity: json['deity'] as String,
      note: json['note'] as String,
    );
  }
}

class LognoMonthHighlight {
  LognoMonthHighlight({required this.month, required this.highlights});

  final String month;
  final List<String> highlights;

  factory LognoMonthHighlight.fromJson(Map<String, dynamic> json) {
    return LognoMonthHighlight(
      month: json['month'] as String,
      highlights: (json['highlights'] as List<dynamic>).map((e) => e as String).toList(growable: false),
    );
  }
}

/// One tab section: Puja logno, Marriage logno, or Beye (inauspicious).
class LognoSection {
  LognoSection({
    required this.title,
    required this.subtitle,
    required this.slots,
    required this.timings,
    required this.inauspicious,
    required this.tips,
  });

  final String title;
  final String subtitle;
  final List<LognoSlot> slots;
  final List<PujaTiming> timings;
  final List<InauspiciousTime> inauspicious;
  final List<String> tips;

  factory LognoSection.fromJson(Map<String, dynamic> json) {
    return LognoSection(
      title: json['title'] as String,
      subtitle: json['subtitle'] as String? ?? '',
      slots: (json['slots'] as List<dynamic>?)
              ?.map((e) => LognoSlot.fromJson(e as Map<String, dynamic>))
              .toList(growable: false) ??
          const [],
      timings: (json['timings'] as List<dynamic>?)
              ?.map((e) => PujaTiming.fromJson(e as Map<String, dynamic>))
              .toList(growable: false) ??
          const [],
      inauspicious: (json['inauspicious'] as List<dynamic>?)
              ?.map((e) => InauspiciousTime.fromJson(e as Map<String, dynamic>))
              .toList(growable: false) ??
          (json['items'] as List<dynamic>?)
              ?.map((e) => InauspiciousTime.fromJson(e as Map<String, dynamic>))
              .toList(growable: false) ??
          const [],
      tips: (json['tips'] as List<dynamic>?)?.map((e) => e as String).toList(growable: false) ?? const [],
    );
  }
}

class PonjikaLogno {
  PonjikaLogno({
    required this.puja,
    required this.marriage,
    required this.beye,
    required this.monthlyHighlights,
  });

  final LognoSection puja;
  final LognoSection marriage;
  final LognoSection beye;
  final List<LognoMonthHighlight> monthlyHighlights;

  factory PonjikaLogno.fromJson(Map<String, dynamic> json) {
    if (json['puja'] is Map<String, dynamic>) {
      return PonjikaLogno(
        puja: LognoSection.fromJson(json['puja'] as Map<String, dynamic>),
        marriage: LognoSection.fromJson(json['marriage'] as Map<String, dynamic>),
        beye: LognoSection.fromJson(json['beye'] as Map<String, dynamic>),
        monthlyHighlights: _parseHighlights(json),
      );
    }

    // Legacy flat JSON fallback.
    final legacySlots = (json['slots'] as List<dynamic>?)
            ?.map((e) => LognoSlot.fromJson(e as Map<String, dynamic>))
            .toList(growable: false) ??
        const [];
    final legacyBad = (json['inauspicious'] as List<dynamic>?)
            ?.map((e) => InauspiciousTime.fromJson(e as Map<String, dynamic>))
            .toList(growable: false) ??
        const [];
    final legacyTimings = (json['pujaTimings'] as List<dynamic>?)
            ?.map((e) => PujaTiming.fromJson(e as Map<String, dynamic>))
            .toList(growable: false) ??
        const [];

    return PonjikaLogno(
      puja: LognoSection(
        title: json['todayTitle'] as String? ?? 'Puja Logno',
        subtitle: 'Auspicious muhurta for puja, anjali & mandap visits',
        slots: legacySlots,
        timings: legacyTimings,
        inauspicious: const [],
        tips: const ['Best for pushpanjali and new puja work'],
      ),
      marriage: LognoSection(
        title: 'Marriage Logno',
        subtitle: 'Shubho bibaho muhurta',
        slots: const [],
        timings: const [],
        inauspicious: const [],
        tips: const [],
      ),
      beye: LognoSection(
        title: 'বেয়ে / অশুভ সময়',
        subtitle: 'Times to avoid',
        slots: const [],
        timings: const [],
        inauspicious: legacyBad,
        tips: const [],
      ),
      monthlyHighlights: _parseHighlights(json),
    );
  }

  static List<LognoMonthHighlight> _parseHighlights(Map<String, dynamic> json) {
    return (json['monthlyHighlights'] as List<dynamic>?)
            ?.map((e) => LognoMonthHighlight.fromJson(e as Map<String, dynamic>))
            .toList(growable: false) ??
        const [];
  }
}
