import 'package:flutter/material.dart';
import 'package:sankalp/views/shared_preference_helper.dart';
import 'package:flutter/services.dart';

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
      MethodChannel('com.example.sankalp/accessibility');

  @override
  void initState() {
    super.initState();
    _sendIsServiceStopped(_isStopped);
  }

  Future<void> _sendIsServiceStopped(val) async {
    try {
      await platformChannel.invokeMethod('isServiceStopped', {
        'isStopped': val,
      });
    } on PlatformException catch (e) {
      print("Failed to send isStopped State: ${e.message}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(10),
      width: 80,
      height: 80,
      // padding: EdgeInsets.all(30),
      child: FloatingActionButton(
        shape: CircleBorder(),
        onPressed: () {
          SharedPrefsHelper().setBool("isStopped", !_isStopped);
          _sendIsServiceStopped(!_isStopped);
          setState(() {
            _isStopped = !_isStopped;
          });
        },
        backgroundColor: _isStopped
            ? const Color.fromARGB(255, 11, 104, 14)
            : Colors.redAccent,
        splashColor: const Color.fromARGB(78, 255, 255, 255),
        child: _isStopped
            ? Text(
                "Start",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Colors.white),
              )
            : Text(
                "Stop",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Colors.white),
              ),
      ),
    );
  }
}
