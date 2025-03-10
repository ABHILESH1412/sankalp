import 'package:flutter/material.dart';
import 'package:sankalp/data/notifiers.dart';
import 'package:sankalp/views/shared_preference_helper.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'dart:async';

class GlobalStartStopButtonWidget extends StatefulWidget {
  const GlobalStartStopButtonWidget({super.key});

  @override
  State<GlobalStartStopButtonWidget> createState() =>
      _GlobalStartStopButtonWidgetState();
}

class _GlobalStartStopButtonWidgetState
    extends State<GlobalStartStopButtonWidget> {
  bool _isStopped = SharedPrefsHelper().getBool("isStopped") ?? false;
  static const platformChannel =
      MethodChannel('com.example.sankalp/timerChannel');

  @override
  void initState() {
    super.initState();
    // _sendIsServiceStopped(_isStopped);
    // SharedPrefsHelper().setBool("isTimerRunning", false);
    _checkTimerStatus();
  }

  Future<void> _checkTimerStatus() async {
    bool isTimerRunning =
        SharedPrefsHelper().getBool("isTimerRunning") ?? false;
    DateTime? timerEndTime =
        await SharedPrefsHelper().getDateTime("timerEndTime");
    if (isTimerRunning == true && timerEndTime != null) {
      if (timerEndTime.isAfter(DateTime.now())) {
        final Duration remainingTime = timerEndTime.difference(DateTime.now());
        setState(() {
          isTimerRunningNotifier.value = true;
          timerEndTimeNotifier.value = timerEndTime;
        });
        updateTimerUI(remainingTime);
        startTimer();
      } else {
        setState(() {
          isTimerRunningNotifier.value = false;
        });
        SharedPrefsHelper().setBool("isTimerRunning", false);
      }
    }
  }

  Future<void> _sendTimerStarted(val) async {
    String formattedDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(val);
    try {
      await platformChannel.invokeMethod('timerStarted', {
        'endTime': formattedDate,
      });
    } on PlatformException catch (e) {
      print("Failed to send isStopped State: ${e.message}");
    }
  }

  Future<void> _sendEndTimeUpdated(val) async {
    String formattedDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(val);
    try {
      await platformChannel.invokeMethod('endTimeUpdated', {
        'endTime': formattedDate,
      });
    } on PlatformException catch (e) {
      print("Failed to send isStopped State: ${e.message}");
    }
  }

  late Timer _timer;
  void startTimer() {
    // Start the timer to check every second
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (DateTime.now().isAfter(timerEndTimeNotifier.value)) {
        setState(() {
          isTimerRunningNotifier.value = false;
        });
        SharedPrefsHelper().setBool("isTimerRunning", false);
        _timer.cancel(); // Stop the timer once the time is up
      } else {
        setState(() {
          final Duration remainingTime =
              timerEndTimeNotifier.value.difference(DateTime.now());
          updateTimerUI(remainingTime);
        });
      }
    });
  }

  void updateTimerUI(Duration remainingTime) {
    int days = remainingTime.inDays;
    int hours = remainingTime.inHours%24;
    int minutes = remainingTime.inMinutes % 60;
    int seconds = remainingTime.inSeconds % 60;
    final formatter = NumberFormat("00");

    if(days != 0) {
      timerDurationNotifier.value =
          "${formatter.format(days)} Days : ${formatter.format(hours)} Hrs : ${formatter.format(minutes)} Mins : ${formatter.format(seconds)} Secs";
      return;
    }
    if (hours != 0) {
      timerDurationNotifier.value =
          "${formatter.format(hours)} Hrs : ${formatter.format(minutes)} Mins : ${formatter.format(seconds)} Secs";
      return;
    }
    timerDurationNotifier.value =
        "${formatter.format(minutes)} Mins : ${formatter.format(seconds)} Secs";
  }

  @override
  Widget build(BuildContext context) {
    // return Container(
    //   margin: EdgeInsets.all(10),
    //   width: 80,
    //   height: 80,
    //   // padding: EdgeInsets.all(30),
    //   child: FloatingActionButton(
    //     shape: CircleBorder(),
    //     onPressed: () {
    //       SharedPrefsHelper().setBool("isStopped", !_isStopped);
    //       _sendIsServiceStopped(!_isStopped);
    //       setState(() {
    //         _isStopped = !_isStopped;
    //       });
    //     },
    //     backgroundColor: _isStopped
    //         ? const Color.fromARGB(255, 11, 104, 14)
    //         : Colors.redAccent,
    //     splashColor: const Color.fromARGB(78, 255, 255, 255),
    //     child: _isStopped
    //         ? Text(
    //             "Start",
    //             style: TextStyle(
    //                 fontWeight: FontWeight.bold,
    //                 fontSize: 20,
    //                 color: Colors.white),
    //           )
    //         : Text(
    //             "Stop",
    //             style: TextStyle(
    //                 fontWeight: FontWeight.bold,
    //                 fontSize: 20,
    //                 color: Colors.white),
    //           ),
    //   ),
    // );
    return FloatingActionButton.extended(
      onPressed: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "You added +5 mins of Rest",
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            duration: Duration(seconds: 2), 
            backgroundColor: Theme.of(context).colorScheme.inversePrimary, 
            behavior: SnackBarBehavior.floating, 
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10), 
            ),
          ),
        );
        if (isTimerRunningNotifier.value == false) {
          final DateTime now = DateTime.now();
          final DateTime endTime = now.add(Duration(minutes: 5));

          setState(() {
            isTimerRunningNotifier.value = true;
            timerEndTimeNotifier.value = endTime;
          });

          timerDurationNotifier.value = "4 mins : 59 secs";
          SharedPrefsHelper().setBool("isTimerRunning", true);
          SharedPrefsHelper().setDateTime("timerEndTime", endTime);
          _sendTimerStarted(endTime);
          startTimer();
        } else {
          final DateTime endTime =
              timerEndTimeNotifier.value.add(Duration(minutes: 5));
          final Duration remainingTime = endTime.difference(DateTime.now());

          timerEndTimeNotifier.value = endTime;
          updateTimerUI(remainingTime);
          SharedPrefsHelper().setDateTime("timerEndTime", endTime);
          _sendEndTimeUpdated(endTime);
        }
      },
      label: Text(
        "+5 mins of Rest",
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }
}
