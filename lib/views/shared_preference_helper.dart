import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefsHelper {
  static final SharedPrefsHelper _instance = SharedPrefsHelper._internal();
  SharedPreferences? _prefs;

  // Private constructor
  SharedPrefsHelper._internal();

  // Factory constructor to return the same instance
  factory SharedPrefsHelper() {
    return _instance;
  }

  // Initialize SharedPreferences (call this in main.dart before runApp)
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Save data
  Future<void> setBool(String key, bool value) async {
    await _prefs?.setBool(key, value);
  }

  // Get data
  bool? getBool(String key) {
    return _prefs?.getBool(key);
  }

  // Remove data
  Future<void> remove(String key) async {
    await _prefs?.remove(key);
  }
}