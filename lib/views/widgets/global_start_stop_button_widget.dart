import 'package:flutter/material.dart';
import 'package:sankalp/data/notifiers.dart';
import 'package:sankalp/views/shared_preference_helper.dart';

/// "+5 mins of Rest" button. Starts a 5 minute break, or extends the running one.
///
/// The break end time is saved to SharedPreferences; the Android accessibility
/// service reads it directly, so the break keeps working even if the app is
/// closed or Android restarts the process.
class GlobalStartStopButtonWidget extends StatelessWidget {
  const GlobalStartStopButtonWidget({super.key});

  static const breakStep = Duration(minutes: 5);

  void _addRest(BuildContext context) {
    final now = DateTime.now();
    final current = breakEndNotifier.value;
    final base = current != null && current.isAfter(now) ? current : now;
    final end = base.add(breakStep);

    breakEndNotifier.value = end;
    SharedPrefsHelper()
        .setInt(PrefKeys.breakEndMillis, end.millisecondsSinceEpoch);

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: const Text(
            "You added +5 mins of Rest",
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          duration: const Duration(seconds: 2),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () => _addRest(context),
      label: const Text(
        "+5 mins of Rest",
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }
}
