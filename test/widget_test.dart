import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sankalp/data/notifiers.dart';
import 'package:sankalp/views/shared_preference_helper.dart';
import 'package:sankalp/views/widgets/global_start_stop_button_widget.dart';
import 'package:sankalp/views/widgets/timer_widget.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await SharedPrefsHelper().init();
    breakEndNotifier.value = null;
  });

  group('formatRemaining', () {
    test('minutes and seconds', () {
      expect(formatRemaining(const Duration(minutes: 4, seconds: 9)),
          '04 Mins : 09 Secs');
    });

    test('hours', () {
      expect(formatRemaining(const Duration(hours: 1, minutes: 2, seconds: 3)),
          '01 Hrs : 02 Mins : 03 Secs');
    });

    test('days', () {
      expect(formatRemaining(const Duration(days: 2, hours: 3)),
          '02 Days : 03 Hrs : 00 Mins : 00 Secs');
    });
  });

  testWidgets('+5 mins button starts and then extends the break',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: TimerWidget(),
        floatingActionButton: GlobalStartStopButtonWidget(),
      ),
    ));

    final before = DateTime.now();
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pump();

    final firstEnd = breakEndNotifier.value!;
    expect(firstEnd.difference(before).inMinutes, closeTo(5, 1));
    expect(SharedPrefsHelper().getInt(PrefKeys.breakEndMillis),
        firstEnd.millisecondsSinceEpoch);
    expect(find.text('You can watch reels for:'), findsOneWidget);

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pump();
    expect(breakEndNotifier.value!.difference(firstEnd),
        const Duration(minutes: 5));

    // Unmount so the periodic ticker is cancelled before the test ends.
    await tester.pumpWidget(const SizedBox());
  });
}
