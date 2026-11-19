import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sankalp/data/notifiers.dart';

/// Shows the remaining break time while a "+5 mins of rest" break is running.
class TimerWidget extends StatefulWidget {
  const TimerWidget({super.key});

  @override
  State<TimerWidget> createState() => _TimerWidgetState();
}

class _TimerWidgetState extends State<TimerWidget> {
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    breakEndNotifier.addListener(_onBreakChanged);
    _startTickerIfNeeded();
  }

  void _startTickerIfNeeded() {
    if (breakEndNotifier.value != null && _ticker == null) {
      _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
    }
  }

  @override
  void dispose() {
    breakEndNotifier.removeListener(_onBreakChanged);
    _ticker?.cancel();
    super.dispose();
  }

  void _onBreakChanged() {
    _startTickerIfNeeded();
    _tick();
  }

  void _tick() {
    final end = breakEndNotifier.value;
    if (end != null && !end.isAfter(DateTime.now())) {
      // Break is over. The native blocker checks the stored end time itself,
      // so there is nothing else to notify.
      breakEndNotifier.value = null;
      return;
    }
    if (end == null) {
      _ticker?.cancel();
      _ticker = null;
    }
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final end = breakEndNotifier.value;
    final remaining = end?.difference(DateTime.now());
    return AnimatedSize(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      child: remaining == null || remaining.isNegative
          ? const SizedBox.shrink()
          : Container(
              width: double.infinity,
              padding: const EdgeInsets.all(40),
              margin: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: Theme.of(context).colorScheme.inversePrimary,
                    width: 3),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "You can watch reels for:",
                    style: TextStyle(fontSize: 20),
                  ),
                  Text(
                    formatRemaining(remaining),
                    style: const TextStyle(
                        fontSize: 30, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
    );
  }
}

String formatRemaining(Duration remaining) {
  final formatter = NumberFormat("00");
  final days = remaining.inDays;
  final hours = remaining.inHours % 24;
  final minutes = remaining.inMinutes % 60;
  final seconds = remaining.inSeconds % 60;

  if (days != 0) {
    return "${formatter.format(days)} Days : ${formatter.format(hours)} Hrs : ${formatter.format(minutes)} Mins : ${formatter.format(seconds)} Secs";
  }
  if (hours != 0) {
    return "${formatter.format(hours)} Hrs : ${formatter.format(minutes)} Mins : ${formatter.format(seconds)} Secs";
  }
  return "${formatter.format(minutes)} Mins : ${formatter.format(seconds)} Secs";
}
