import 'package:flutter/material.dart';
import 'package:sankalp/views/shared_preference_helper.dart';

final ValueNotifier darkModeNotifier = ValueNotifier(SharedPrefsHelper().getBool('darkModeNotifier') ?? true);