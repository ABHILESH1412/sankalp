import 'package:flutter/material.dart';
import 'package:sankalp/views/shared_preference_helper.dart';

/// Preference keys. Some are shared with the native Android code (AppPrefs.kt),
/// so keep names and value types in sync.
class PrefKeys {
  static const themeMode = 'themeMode'; // 'system' | 'light' | 'dark'
  static const legacyDarkMode = 'darkModeNotifier'; // pre-2.1 bool

  /// Epoch milliseconds at which the current break ends (read natively).
  static const breakEndMillis = 'breakEndMillis';
  static const autoUpdateEnabled = 'autoUpdateEnabled';

  // Stats. The blocked counts are written by the native accessibility service.
  static const blockedTodayCount = 'blockedTodayCount';
  static const blockedTodayDate = 'blockedTodayDate';
  static const blockedTotalCount = 'blockedTotalCount';
  static const lastBreakDate = 'lastBreakDate';
  static const firstUseDate = 'firstUseDate';
}

final ValueNotifier<ThemeMode> themeModeNotifier =
    ValueNotifier(_loadThemeMode());

/// End of the current break, or null when no break is running.
final ValueNotifier<DateTime?> breakEndNotifier =
    ValueNotifier(_loadBreakEnd());

final ValueNotifier<bool> autoUpdateNotifier = ValueNotifier(
    SharedPrefsHelper().getBool(PrefKeys.autoUpdateEnabled) ?? true);

Future<void> setThemeMode(ThemeMode mode) async {
  themeModeNotifier.value = mode;
  await SharedPrefsHelper().setString(PrefKeys.themeMode, mode.name);
}

ThemeMode _loadThemeMode() {
  final saved = SharedPrefsHelper().getString(PrefKeys.themeMode);
  for (final mode in ThemeMode.values) {
    if (mode.name == saved) return mode;
  }
  // Older versions stored a dark-mode bool that defaulted to dark.
  final legacyDark = SharedPrefsHelper().getBool(PrefKeys.legacyDarkMode);
  return legacyDark == false ? ThemeMode.light : ThemeMode.dark;
}

DateTime? _loadBreakEnd() {
  final millis = SharedPrefsHelper().getInt(PrefKeys.breakEndMillis);
  if (millis == null) return null;
  final end = DateTime.fromMillisecondsSinceEpoch(millis);
  return end.isAfter(DateTime.now()) ? end : null;
}
