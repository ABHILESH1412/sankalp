import 'package:sankalp/views/accessibility_service_manager.dart';
import 'package:sankalp/views/shared_preference_helper.dart';
import 'package:sankalp/views/pages/home_page.dart';
import 'package:sankalp/views/pages/loading_page.dart';
import 'package:sankalp/views/pages/settings_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sankalp/data/notifiers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure Flutter is ready
  await SharedPrefsHelper().init();
  runApp(
    ChangeNotifierProvider(
      create: (context) => AccessibilityServiceManager(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: darkModeNotifier,
      builder: (context, darkMode, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color.fromARGB(255, 93, 135, 54),
              brightness: darkMode ? Brightness.dark : Brightness.light,
              // brightness: Brightness.dark
            ),
            useMaterial3: true,
          ),
          home: Consumer<AccessibilityServiceManager>(
            builder: (context, accessibilityService, child) {
              if (accessibilityService.isLoading) {
                return const LoadingPage();
              } else if (accessibilityService.isAccessibilityServiceEnabled) {
                return HomePage();
              } else {
                return const SettingsPage();
              }
            },
          ),
        );
      },
    );
  }
}
