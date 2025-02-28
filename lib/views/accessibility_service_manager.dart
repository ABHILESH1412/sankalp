import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

class AccessibilityServiceManager with ChangeNotifier {
  static const _platform = MethodChannel('com.example.sankalp/accessibility');
  bool _isAccessibilityServiceEnabled = false;
  bool _isLoading = true; // Add a loading state

  bool get isAccessibilityServiceEnabled => _isAccessibilityServiceEnabled;
  bool get isLoading => _isLoading;

  AccessibilityServiceManager() {
    _init();
  }

  Future<void> _init() async {
    _platform.setMethodCallHandler(_handleMethodCall);
    await checkAccessibilityStatus(); // Check status immediately
  }

  Future<void> _handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'onAccessibilityStatusChanged':
        _isAccessibilityServiceEnabled = call.arguments as bool;
        _isLoading = false; // Set loading to false after status update
        notifyListeners();
        break;
      default:
        print('Unknown method call received from native side: ${call.method}');
    }
  }

  Future<void> checkAccessibilityStatus() async {
    _isLoading = true;
    notifyListeners(); //show the loading screen
    try {
      _isAccessibilityServiceEnabled =
          await _platform.invokeMethod('isAccessibilityEnabled');
      _isLoading = false;
      notifyListeners(); // Update UI after checking
    } on PlatformException catch (e) {
      print("Error checking accessibility status: $e");
      _isAccessibilityServiceEnabled = false;
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> openAccessibilitySettings() async {
    try {
      await _platform.invokeMethod('openAccessibilitySettings');
    } on PlatformException catch (e) {
      print("Failed to open accessibility settings: '${e.message}'.");
      // Consider showing a dialog or snackbar to inform the user.
    }
  }
}
