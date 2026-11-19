import 'package:flutter/material.dart';
import 'package:sankalp/views/shared_preference_helper.dart';

/// Preference keys shared with the native Android code (AppPrefs.kt).
class PrefKeys {
  static const darkMode = 'darkModeNotifier';

  /// Epoch milliseconds at which the current "+5 mins of rest" break ends.
  static const breakEndMillis = 'breakEndMillis';
  static const autoUpdateEnabled = 'autoUpdateEnabled';
}

final ValueNotifier<bool> darkModeNotifier =
    ValueNotifier(SharedPrefsHelper().getBool(PrefKeys.darkMode) ?? true);

/// End of the current break, or null when no break is running.
final ValueNotifier<DateTime?> breakEndNotifier =
    ValueNotifier(_loadBreakEnd());

final ValueNotifier<bool> autoUpdateNotifier =
    ValueNotifier(SharedPrefsHelper().getBool(PrefKeys.autoUpdateEnabled) ?? true);

DateTime? _loadBreakEnd() {
  final millis = SharedPrefsHelper().getInt(PrefKeys.breakEndMillis);
  if (millis == null) return null;
  final end = DateTime.fromMillisecondsSinceEpoch(millis);
  return end.isAfter(DateTime.now()) ? end : null;
}
