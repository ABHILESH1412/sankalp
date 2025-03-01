package com.example.sankalp

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.content.Intent
import android.provider.Settings
import android.content.Context
import android.accessibilityservice.AccessibilityServiceInfo
import android.view.accessibility.AccessibilityManager
import android.util.Log  // Import the Log class

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.example.sankalp/accessibility"
    private val TAG = "MainActivity" // TAG is a class property
    private lateinit var channel: MethodChannel

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
        channel.setMethodCallHandler {
                call, result ->
            if (call.method == "openAccessibilitySettings") {
                openAccessibilitySettings()
                result.success(null)
            } else if(call.method == "isAccessibilityEnabled") {
                val isEnabled = isAccessibilityServiceEnabled()
                result.success(isEnabled)
            } else if (call.method == "updateToggleState") {
                val platform = call.argument<String>("platform")
                val isBlocked = call.argument<Boolean>("isBlocked")
                
                if (platform != null && isBlocked != null) {
                    MyAccessibilityService.updatePlatformBlockedState(platform, isBlocked)
                    result.success(null)  // Acknowledge receipt
                } else {
                    result.error("INVALID_ARGUMENTS", "Platform or isBlocked is null", null)
                }
            } else if (call.method == "isServiceStopped") {
                val isStopped = call.argument<Boolean>("isStopped")
                
                if (isStopped != null) {
                    MyAccessibilityService.updateServiceStoppedState(isStopped)
                    result.success(null)  // Acknowledge receipt
                } else {
                    result.error("INVALID_ARGUMENTS", "isStopped is null", null)
                }
            } else {
                result.notImplemented()
            }
        }
    }

    override fun onResume() {
        super.onResume()
        Log.d(TAG, "onResume called")
        // Check accessibility status and notify Flutter
        checkAccessibilityAndNotify()
    }

    private fun checkAccessibilityAndNotify() {
        val isEnabled = isAccessibilityServiceEnabled()
        Log.d(TAG, "Accessibility Service Enabled: $isEnabled")

          // Use 'runOnUiThread' because 'invokeMethod' needs to run on the UI thread
        runOnUiThread {
            channel?.invokeMethod("onAccessibilityStatusChanged", isEnabled)
        }

    }

    private fun openAccessibilitySettings() {
        val intent = Intent(Settings.ACTION_ACCESSIBILITY_SETTINGS)
        startActivity(intent)
    }

    private fun isAccessibilityServiceEnabled(): Boolean {
        Log.d(TAG, "Package Name: ${packageName}") // Use Log.d()

        val service = "${packageName}/${packageName}.MyAccessibilityService"
        val enabledServices = Settings.Secure.getString(contentResolver, Settings.Secure.ENABLED_ACCESSIBILITY_SERVICES)
        val accessibilityEnabled = Settings.Secure.getInt(contentResolver, Settings.Secure.ACCESSIBILITY_ENABLED, 0)

        return accessibilityEnabled == 1 && enabledServices?.contains(service) == true
    }
}