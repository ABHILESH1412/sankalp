import 'package:flutter/material.dart';
import 'package:sankalp/data/notifiers.dart';

class TimerWidget extends StatefulWidget {
  const TimerWidget({super.key});

  @override
  State<TimerWidget> createState() => _TimerWidgetState();
}

class _TimerWidgetState extends State<TimerWidget> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: isTimerRunningNotifier,
      builder: (context, isTimerRunning, child) {
        return ValueListenableBuilder(
          valueListenable: timerDurationNotifier,
          builder: (context, timerDuration, child) {
            return AnimatedSize(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut, // Smooth transition
              child: isTimerRunning
                  ? Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(40),
                      margin: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        // color: Theme.of(context).colorScheme.inversePrimary,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: Theme.of(context).colorScheme.inversePrimary,
                            width: 3),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // const SizedBox(height: 30,),
                          const Text(
                            "You can watch reels for:",
                            style: TextStyle(fontSize: 20),
                          ),
                          Text(
                            timerDuration,
                            style: const TextStyle(
                                fontSize: 30, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  : const SizedBox
                      .shrink(), // Hidden state when timer isn't running
            );
          },
        );
      },
    );
  }
}
