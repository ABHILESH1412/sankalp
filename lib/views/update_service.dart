import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Result of a manual update check.
class UpdateCheckResult {
  const UpdateCheckResult(this.status, {this.latestVersion, this.message});

  /// One of: up_to_date, installing, already_running, error.
  final String status;
  final String? latestVersion;
  final String? message;
}

/// Talks to the native self-updater (android/.../update/UpdateManager.kt).
class UpdateService {
  static const _channel = MethodChannel('com.example.sankalp/update');

  static Future<String> appVersion() async {
    try {
      return await _channel.invokeMethod<String>('getAppVersion') ?? '';
    } on PlatformException catch (e) {
      debugPrint('getAppVersion failed: $e');
      return '';
    } on MissingPluginException {
      return '';
    }
  }

  static Future<bool> canInstallPackages() async {
    try {
      return await _channel.invokeMethod<bool>('canInstallPackages') ?? false;
    } on PlatformException catch (e) {
      debugPrint('canInstallPackages failed: $e');
      return false;
    } on MissingPluginException {
      return false;
    }
  }

  static Future<void> openInstallPermissionSettings() async {
    try {
      await _channel.invokeMethod('openInstallPermissionSettings');
    } on PlatformException catch (e) {
      debugPrint('openInstallPermissionSettings failed: $e');
    } on MissingPluginException {
      // Not on Android.
    }
  }

  /// Tells the native side to schedule or cancel the background update check.
  static Future<void> autoUpdateChanged() async {
    try {
      await _channel.invokeMethod('autoUpdateChanged');
    } on PlatformException catch (e) {
      debugPrint('autoUpdateChanged failed: $e');
    } on MissingPluginException {
      // Not on Android.
    }
  }

  static Future<UpdateCheckResult> checkForUpdate() async {
    try {
      final result =
          await _channel.invokeMapMethod<String, dynamic>('checkForUpdate');
      return UpdateCheckResult(
        result?['status'] as String? ?? 'error',
        latestVersion: result?['latestVersion'] as String?,
        message: result?['message'] as String?,
      );
    } on PlatformException catch (e) {
      return UpdateCheckResult('error', message: e.message);
    } on MissingPluginException {
      return const UpdateCheckResult('error', message: 'Not supported');
    }
  }
}
