import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sankalp/data/break_controller.dart';
import 'package:sankalp/data/feeds.dart';
import 'package:sankalp/data/notifiers.dart';
import 'package:sankalp/data/stats.dart';
import 'package:sankalp/theme.dart';
import 'package:sankalp/views/pages/home_page.dart';
import 'package:sankalp/views/shared_preference_helper.dart';
import 'package:sankalp/views/widgets/status_card.dart';

Future<void> resetPrefs([Map<String, Object> values = const {}]) async {
  SharedPreferences.setMockInitialValues(values);
  await SharedPrefsHelper().init();
  breakEndNotifier.value = null;
  blockedFeedsNotifier.value = {};
  statsNotifier.value = computeStats();
}

void main() {
  setUp(() => resetPrefs());

  group('formatCountdown', () {
    test('minutes and seconds', () {
      expect(formatCountdown(const Duration(minutes: 4, seconds: 9)), '04:09');
    });
    test('hours', () {
      expect(formatCountdown(const Duration(hours: 1, minutes: 2, seconds: 3)),
          '1:02:03');
    });
    test('negative clamps to zero', () {
      expect(formatCountdown(const Duration(seconds: -5)), '00:00');
    });
  });

  group('computeStats', () {
    final now = DateTime(2026, 11, 19, 15);

    test('first day of use counts as day 1', () async {
      await resetPrefs({'flutter.firstUseDate': '2026-11-19'});
      expect(computeStats(now: now).breakFreeDays, 1);
    });

    test('days since the last break', () async {
      await resetPrefs({
        'flutter.firstUseDate': '2026-11-01',
        'flutter.lastBreakDate': '2026-11-13',
      });
      expect(computeStats(now: now).breakFreeDays, 6);
    });

    test('break today resets the streak', () async {
      await resetPrefs({'flutter.lastBreakDate': '2026-11-19'});
      expect(computeStats(now: now).breakFreeDays, 0);
    });

    test("blocked count only counts today's date", () async {
      await resetPrefs({
        'flutter.blockedTodayDate': '2026-11-18',
        'flutter.blockedTodayCount': 12,
        'flutter.blockedTotalCount': 40,
      });
      final stats = computeStats(now: now);
      expect(stats.blockedToday, 0);
      expect(stats.blockedTotal, 40);
    });
  });

  test('a break starts at 5 minutes and extends by 5', () async {
    final now = DateTime(2026, 11, 19, 10);
    await BreakController.addTime(now: now);
    expect(breakEndNotifier.value, now.add(const Duration(minutes: 5)));
    expect(SharedPrefsHelper().getString(PrefKeys.lastBreakDate), '2026-11-19');

    await BreakController.addTime(now: now);
    expect(breakEndNotifier.value, now.add(const Duration(minutes: 10)));
    expect(SharedPrefsHelper().getInt(PrefKeys.breakEndMillis),
        now.add(const Duration(minutes: 10)).millisecondsSinceEpoch);

    await BreakController.end();
    expect(breakEndNotifier.value, isNull);
  });

  testWidgets('home screen reflects toggles and breaks', (tester) async {
    await tester.binding.setSurfaceSize(const Size(420, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(MaterialApp(
      theme: buildTheme(Brightness.dark),
      home: const HomePage(),
    ));
    await tester.pumpAndSettle();
    expect(find.text('Nothing blocked yet'), findsOneWidget);

    await tester.tap(find.text('YouTube Shorts'));
    await tester.pumpAndSettle();
    expect(find.text('Protection on'), findsOneWidget);
    expect(find.text('Blocking 1 of ${feeds.length} feeds'), findsOneWidget);
    expect(SharedPrefsHelper().getBool(feeds.first.key), isTrue);

    // First day of use: the streak is 1, so a confirmation is shown.
    await tester.tap(find.text('Take a 5 min break'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Take a break').last);
    await tester.pump();
    expect(find.text('On a break'), findsOneWidget);
    expect(find.text('Add 5 more minutes'), findsOneWidget);

    await tester.tap(find.text('End break'));
    await tester.pump();
    expect(find.text('Protection on'), findsOneWidget);

    // Unmount so the countdown ticker is cancelled before the test ends.
    await tester.pumpWidget(const SizedBox());
  });
}
