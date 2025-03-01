import 'package:flutter/material.dart';
import 'package:sankalp/views/shared_preference_helper.dart';
import 'package:flutter/services.dart';

class DoomScrollToggleWidget extends StatefulWidget {
  const DoomScrollToggleWidget({
    super.key,
    required this.title,
    required this.spKey,
    required this.iconPath,
  });
  final String spKey; // Shared Preference Key
  final String title;
  final String iconPath;

  @override
  State<DoomScrollToggleWidget> createState() => _DoomScrollToggleWidgetState();
}

class _DoomScrollToggleWidgetState extends State<DoomScrollToggleWidget> {
  late bool _isBlocked = SharedPrefsHelper().getBool(widget.spKey) ?? false;
  static const platformChannel = MethodChannel('com.example.sankalp/accessibility');

  @override
  void initState() {
    super.initState();

    // Send initial value on initialization to the myAccessibilityServices.kt file
    _sendToggleState();
  }

  Future<void> _sendToggleState() async {
    try {
      await platformChannel.invokeMethod('updateToggleState', {
        'platform': widget.spKey,
        'isBlocked': _isBlocked,
      });
    } on PlatformException catch (e) {
      print("Failed to update toggle state: ${e.message}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 10),
        ListTile(
          leading: Image.asset(widget.iconPath,
              width: 40, height: 40, fit: BoxFit.contain),
          title: Text(
            widget.title,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          trailing: Switch(
            value: _isBlocked,
            onChanged: (value) {
              SharedPrefsHelper().setBool(widget.spKey, value);
              setState(() {
                _isBlocked = value;
              });
              _sendToggleState();
            },
          ),
          onTap: () {
            // Optional: Handle tap on the entire tile (excluding the switch)
            // setState(() {
            //   _switchValue = !_switchValue;
            // });
          },
        ),
        // const SizedBox(height: 5),
      ],
    );
  }
}
