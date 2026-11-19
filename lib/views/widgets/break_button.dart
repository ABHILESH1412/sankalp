import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sankalp/data/break_controller.dart';
import 'package:sankalp/data/notifiers.dart';
import 'package:sankalp/data/stats.dart';

/// Bottom button: starts a 5 minute break, or adds 5 more minutes to one.
class BreakButton extends StatelessWidget {
  const BreakButton({super.key});

  Future<void> _startBreak(BuildContext context) async {
    final streak = statsNotifier.value.breakFreeDays;
    if (streak > 0) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          icon: const Icon(Icons.coffee_outlined),
          title: const Text('Take a break?'),
          content: Text(
            'Short videos will be allowed for 5 minutes. '
            'This ends your ${streak == 1 ? '1-day' : '$streak-day'} streak without a break.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Stay focused'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Take a break'),
            ),
          ],
        ),
      );
      if (confirmed != true) return;
    }
    HapticFeedback.mediumImpact();
    await BreakController.addTime();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<DateTime?>(
      valueListenable: breakEndNotifier,
      builder: (context, breakEnd, _) => breakEnd == null
          ? FilledButton.icon(
              onPressed: () => _startBreak(context),
              icon: const Icon(Icons.coffee_outlined),
              label: const Text('Take a 5 min break'),
            )
          : FilledButton.tonalIcon(
              onPressed: () {
                HapticFeedback.selectionClick();
                BreakController.addTime();
              },
              icon: const Icon(Icons.add),
              label: const Text('Add 5 more minutes'),
            ),
    );
  }
}
