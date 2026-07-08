import 'package:flutter_template/core/constants/app_constants.dart';

/// TTL rules for year-keyed calendar caches (Ponjika, etc.).
abstract final class YearCachePolicy {
  static int get currentYear => DateTime.now().year;

  static Duration ttlForYear(int year) {
    if (year == currentYear) {
      return Duration(hours: AppConstants.ponjikaCacheTtlCurrentYearHours);
    }
    return Duration(days: AppConstants.ponjikaCacheTtlPastYearDays);
  }

  static bool isFresh(int year, DateTime savedAt) {
    return DateTime.now().difference(savedAt) < ttlForYear(year);
  }
}
