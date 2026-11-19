import 'package:flutter/material.dart';
import 'package:sankalp/views/shared_preference_helper.dart';

/// On/off switch for blocking one platform.
///
/// The value is stored under [spKey] in SharedPreferences, which the Android
/// accessibility service reads directly.
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

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 20),
        ListTile(
          leading: Image.asset(widget.iconPath,
              width: 40, height: 40, fit: BoxFit.contain),
          title: Text(
            widget.title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          trailing: Switch(
            value: _isBlocked,
            onChanged: (value) {
              SharedPrefsHelper().setBool(widget.spKey, value);
              setState(() => _isBlocked = value);
            },
            thumbIcon: WidgetStateProperty.resolveWith<Icon?>(
              (states) => Icon(_isBlocked ? Icons.check : Icons.close),
            ),
          ),
        ),
      ],
    );
  }
}
