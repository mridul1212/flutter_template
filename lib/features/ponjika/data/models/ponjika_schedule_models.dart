class PujaScheduleDay {
  PujaScheduleDay({
    required this.title,
    required this.date,
    required this.tag,
    required this.bengaliDay,
    required this.events,
  });

  final String title;
  final String date;
  final String tag;
  final String bengaliDay;
  final List<PujaEvent> events;

  factory PujaScheduleDay.fromJson(Map<String, dynamic> json) {
    return PujaScheduleDay(
      title: json['title'] as String,
      date: json['date'] as String,
      tag: json['tag'] as String,
      bengaliDay: json['bengaliDay'] as String,
      events: (json['events'] as List<dynamic>)
          .map((e) => PujaEvent.fromJson(e as Map<String, dynamic>))
          .toList(growable: false),
    );
  }
}

class PujaEvent {
  PujaEvent({required this.time, required this.name, required this.badge});

  final String time;
  final String name;
  final String badge;

  factory PujaEvent.fromJson(Map<String, dynamic> json) {
    return PujaEvent(
      time: json['time'] as String,
      name: json['name'] as String,
      badge: json['badge'] as String,
    );
  }
}
