import 'package:flutter/material.dart';
import 'package:sankalp/views/shared_preference_helper.dart';

final ValueNotifier darkModeNotifier = ValueNotifier(SharedPrefsHelper().getBool('darkModeNotifier') ?? true);
final ValueNotifier isTimerRunningNotifier = ValueNotifier(SharedPrefsHelper().getBool("isTimerRunning") ?? false);
final ValueNotifier timerEndTimeNotifier = ValueNotifier(SharedPrefsHelper().getDateTime("timerEndTime") ?? DateTime.now());
final ValueNotifier timerDurationNotifier = ValueNotifier("");