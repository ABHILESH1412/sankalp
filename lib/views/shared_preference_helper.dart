import 'package:shared_preferences/shared_preferences.dart';

/// Thin wrapper around [SharedPreferences].
///
/// Note: the Android accessibility service reads some of these keys directly
/// (see android/.../AppPrefs.kt), so keep key names and value types in sync.
class SharedPrefsHelper {
  static final SharedPrefsHelper _instance = SharedPrefsHelper._internal();
  SharedPreferences? _prefs;

  SharedPrefsHelper._internal();

  factory SharedPrefsHelper() => _instance;

  /// Call once in main() before runApp.
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<void> setBool(String key, bool value) async {
    await _prefs?.setBool(key, value);
  }

  Future<void> setInt(String key, int value) async {
    await _prefs?.setInt(key, value);
  }

  Future<void> setString(String key, String value) async {
    await _prefs?.setString(key, value);
  }

  bool? getBool(String key) => _prefs?.getBool(key);

  int? getInt(String key) => _prefs?.getInt(key);

  String? getString(String key) => _prefs?.getString(key);

  Future<void> remove(String key) async {
    await _prefs?.remove(key);
  }
}
