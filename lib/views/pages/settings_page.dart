import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sankalp/views/accessibility_service_manager.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Accessibility Required'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '1) Please enable Accessibility Services to use this App\n\n2) If it is already enabled disable it and enable it again',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Provider.of<AccessibilityServiceManager>(context, listen: false)
                    .openAccessibilitySettings();
              },
              child: const Text(
                'Open Accessibility Settings',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
