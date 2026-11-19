import 'package:sankalp/data/notifiers.dart';
import 'package:sankalp/data/stats.dart';
import 'package:sankalp/views/shared_preference_helper.dart';

/// Breaks ("+5 mins of rest") let the user watch short videos for a while.
///
/// The end time is saved to SharedPreferences; the Android accessibility
/// service reads it directly, so a break keeps working even if the app is
/// closed or Android restarts the process.
class BreakController {
  static const step = Duration(minutes: 5);

  /// Starts a break, or extends the running one by [step].
  static Future<void> addTime({DateTime? now}) async {
    final current = now ?? DateTime.now();
    final end = breakEndNotifier.value;
    final base = end != null && end.isAfter(current) ? end : current;
    final newEnd = base.add(step);

    breakEndNotifier.value = newEnd;
    await SharedPrefsHelper()
        .setInt(PrefKeys.breakEndMillis, newEnd.millisecondsSinceEpoch);
    await SharedPrefsHelper()
        .setString(PrefKeys.lastBreakDate, dayKey(current));
    statsNotifier.value = computeStats(now: current);
  }

  static Future<void> end() async {
    breakEndNotifier.value = null;
    await SharedPrefsHelper().setInt(PrefKeys.breakEndMillis, 0);
  }
}
