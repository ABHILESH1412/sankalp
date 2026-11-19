import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:sankalp/data/notifiers.dart';
import 'package:sankalp/views/shared_preference_helper.dart';

class BlockStats {
  const BlockStats({
    required this.blockedToday,
    required this.blockedTotal,
    required this.breakFreeDays,
  });

  /// Short-video visits blocked today (counted by the native service).
  final int blockedToday;
  final int blockedTotal;

  /// Days in a row without taking a break, including today.
  final int breakFreeDays;
}

final ValueNotifier<BlockStats> statsNotifier = ValueNotifier(computeStats());

String dayKey(DateTime day) => DateFormat('yyyy-MM-dd').format(day);

DateTime _utcDay(DateTime d) => DateTime.utc(d.year, d.month, d.day);

DateTime? _parseDay(String? key) {
  if (key == null) return null;
  final parsed = DateTime.tryParse(key);
  return parsed == null ? null : _utcDay(parsed);
}

/// Remembers the first day the app was used, the start of the first streak.
Future<void> ensureFirstUseDate() async {
  final prefs = SharedPrefsHelper();
  final today = dayKey(DateTime.now());
  if (prefs.getString(PrefKeys.firstUseDate) == null) {
    await prefs.setString(PrefKeys.firstUseDate, today);
  }
  // Versions before the stats feature didn't record break days, so a break
  // that is still running after upgrading would otherwise not count.
  final breakEnd = prefs.getInt(PrefKeys.breakEndMillis) ?? 0;
  if (breakEnd > DateTime.now().millisecondsSinceEpoch &&
      prefs.getString(PrefKeys.lastBreakDate) == null) {
    await prefs.setString(PrefKeys.lastBreakDate, today);
  }
}

BlockStats computeStats({DateTime? now}) {
  final prefs = SharedPrefsHelper();
  final today = now ?? DateTime.now();

  final countedToday =
      prefs.getString(PrefKeys.blockedTodayDate) == dayKey(today);
  final blockedToday =
      countedToday ? prefs.getInt(PrefKeys.blockedTodayCount) ?? 0 : 0;

  // A break today means a streak of 0; otherwise count the days since the
  // last break day (or since the day before first use).
  final lastBreak = _parseDay(prefs.getString(PrefKeys.lastBreakDate));
  final firstUse = _parseDay(prefs.getString(PrefKeys.firstUseDate)) ??
      _utcDay(today);
  final anchor = lastBreak ?? firstUse.subtract(const Duration(days: 1));
  final days = _utcDay(today).difference(anchor).inDays;

  return BlockStats(
    blockedToday: blockedToday,
    blockedTotal: prefs.getInt(PrefKeys.blockedTotalCount) ?? 0,
    breakFreeDays: days < 0 ? 0 : days,
  );
}

/// Re-reads the counts the native blocker wrote while the app was in the background.
Future<void> refreshStats() async {
  await SharedPrefsHelper().reload();
  statsNotifier.value = computeStats();
}
