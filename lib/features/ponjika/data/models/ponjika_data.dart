import 'package:flutter_template/features/ponjika/data/models/ponjika_ekadashi_models.dart';
import 'package:flutter_template/features/ponjika/data/models/ponjika_logno_models.dart';
import 'package:flutter_template/features/ponjika/data/models/ponjika_schedule_models.dart';
import 'package:flutter_template/features/ponjika/data/models/ponjika_today_model.dart';

class PonjikaData {
  PonjikaData({
    required this.year,
    required this.bengaliYear,
    required this.today,
    required this.durgaPujaDays,
    required this.logno,
    required this.ekadashi,
  });

  final int year;
  final String bengaliYear;
  final PonjikaToday today;
  final List<PujaScheduleDay> durgaPujaDays;
  final PonjikaLogno logno;
  final PonjikaEkadashi ekadashi;

  factory PonjikaData.fromJson(Map<String, dynamic> json) {
    return PonjikaData(
      year: (json['year'] as num).toInt(),
      bengaliYear: json['bengaliYear'] as String,
      today: PonjikaToday.fromJson(json['today'] as Map<String, dynamic>),
      durgaPujaDays: (json['durgaPujaDays'] as List<dynamic>)
          .map((e) => PujaScheduleDay.fromJson(e as Map<String, dynamic>))
          .toList(growable: false),
      logno: PonjikaLogno.fromJson(json['logno'] as Map<String, dynamic>),
      ekadashi: PonjikaEkadashi.fromJson(json['ekadashi'] as Map<String, dynamic>),
    );
  }
}
