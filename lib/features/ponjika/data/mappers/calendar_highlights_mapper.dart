import 'package:flutter_template/features/home/data/models/home_dashboard_models.dart';
import 'package:flutter_template/features/ponjika/data/models/ponjika_models.dart';

/// Builds home dashboard calendar card from live Ponjika data.
abstract final class CalendarHighlightsMapper {
  static HomeCalendarHighlights fromPonjika(PonjikaData data) {
    final slots = data.logno.puja.slots;
    final bestSlot = slots.isEmpty
        ? null
        : slots.firstWhere((s) => s.quality == 'best', orElse: () => slots.first);

    final pujaDay = _findPujaStart(data);
    var countdown = 0;
    if (pujaDay != null) {
      final target = DateTime.tryParse(pujaDay.date);
      if (target != null) {
        final days = target.difference(DateTime.now()).inDays;
        countdown = days < 0 ? 0 : days;
      }
    }

    return HomeCalendarHighlights(
      year: data.year,
      bengaliDate: data.today.bengaliDate,
      tithi: '${data.today.tithi} • ${data.today.paksha}',
      bestLogno: bestSlot == null ? '—' : '${bestSlot.name} ${bestSlot.time}',
      nextEkadashi: data.ekadashi.upcomingName,
      nextEkadashiDate: data.ekadashi.upcomingDate,
      pujaCountdownDays: countdown,
    );
  }

  static PujaScheduleDay? _findPujaStart(PonjikaData data) {
    for (final day in data.durgaPujaDays) {
      final t = day.title.toLowerCase();
      if (t.contains('shashthi') || t.contains('ষষ্ঠী')) return day;
    }
    return data.durgaPujaDays.isEmpty ? null : data.durgaPujaDays.last;
  }
}
