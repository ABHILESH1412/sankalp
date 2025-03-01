import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sankalp/views/accessibility_service_manager.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('Accessibility Required'),
      //   backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      // ),
      body: Padding(
        padding: EdgeInsets.symmetric(vertical: 30, horizontal: 20),
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset("assets/images/sankalp.png",
                      width: 150, height: 150, fit: BoxFit.contain),
                  SizedBox(
                    height: 60,
                  ),
                  const Text(
                    'Please enable Accessibility Services to use this App. If it is already enabled, disable it and then enable it again.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ],
              ),
            ),
            // Fixed button at the bottom
            Align(
              alignment: Alignment.bottomCenter,
              child: ElevatedButton(
                onPressed: () {
                  Provider.of<AccessibilityServiceManager>(context,
                          listen: false)
                      .openAccessibilitySettings();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  minimumSize: Size(double.infinity, 50),
                ),
                child: const Text(
                  'Open Accessibility Settings',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 10, 110, 14)),
                ),
              ),
            ),
          ],
        ),

        // child: Center(
        //   child: Column(
        //     mainAxisAlignment: MainAxisAlignment.center,
        //     children: [
        //       const Text(
        //         '1) Please enable Accessibility Services to use this App\n\n2) If it is already enabled disable it and enable it again',
        //         textAlign: TextAlign.center,
        //         style: TextStyle(fontSize: 18),
        //       ),
        //       const SizedBox(height: 20),
        // ElevatedButton(
        //   onPressed: () {
        //     Provider.of<AccessibilityServiceManager>(context,
        //             listen: false)
        //         .openAccessibilitySettings();
        //   },
        //   style: ElevatedButton.styleFrom(
        //     backgroundColor: Colors.white,
        //     minimumSize: Size(double.infinity, 50),
        //   ),
        //   child: const Text(
        //     'Open Accessibility Settings',
        //     style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        //   ),
        // ),
        //     ],
        //   ),
        // ),
      ),
      backgroundColor: Colors.black,
    );
  }
}
