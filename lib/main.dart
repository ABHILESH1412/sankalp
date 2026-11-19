import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sankalp/data/notifiers.dart';
import 'package:sankalp/data/stats.dart';
import 'package:sankalp/theme.dart';
import 'package:sankalp/views/accessibility_service_manager.dart';
import 'package:sankalp/views/pages/home_page.dart';
import 'package:sankalp/views/pages/loading_page.dart';
import 'package:sankalp/views/pages/setup_page.dart';
import 'package:sankalp/views/shared_preference_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SharedPrefsHelper().init();
  await ensureFirstUseDate();
  runApp(
    ChangeNotifierProvider(
      create: (context) => AccessibilityServiceManager(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeModeNotifier,
      builder: (context, themeMode, _) => MaterialApp(
        title: 'Sankalp',
        debugShowCheckedModeBanner: false,
        theme: buildTheme(Brightness.light),
        darkTheme: buildTheme(Brightness.dark),
        themeMode: themeMode,
        home: Consumer<AccessibilityServiceManager>(
          builder: (context, accessibility, _) => AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: accessibility.isLoading
                ? const LoadingPage(key: ValueKey('loading'))
                : accessibility.isAccessibilityServiceEnabled
                    ? const HomePage(key: ValueKey('home'))
                    : const SetupPage(key: ValueKey('setup')),
          ),
        ),
      ),
    );
  }
}
