package com.example.sankalp

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.content.Intent
import android.provider.Settings
import android.content.Context
import android.accessibilityservice.AccessibilityServiceInfo
import android.view.accessibility.AccessibilityManager
import android.os.Bundle

class MainActivity: FlutterActivity() {
    private val ACCESSIBILITY_CHANNEL = "com.example.sankalp/accessibility"
    private val SHARED_PREFERENCES_CHANNEL = "com.example.sankalp/timerChannel"
    private val TAG = "MainActivity" // TAG is a class property
    private lateinit var channel: MethodChannel

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, ACCESSIBILITY_CHANNEL)
        channel.setMethodCallHandler { call, result ->
            when (call.method) {
                "openAccessibilitySettings" -> {
                    openAccessibilitySettings()
                    result.success(null)
                }
                "isAccessibilityEnabled" -> {
                    val isEnabled = isAccessibilityServiceEnabled()
                    result.success(isEnabled)
                }
                "updateToggleState" -> {
                    val platform = call.argument<String>("platform")
                    val isBlocked = call.argument<Boolean>("isBlocked")
                    if (platform != null && isBlocked != null) {
                        MyAccessibilityService.updatePlatformBlockedState(platform, isBlocked)
                        result.success(null)  // Acknowledge receipt
                    } else {
                        result.error("INVALID_ARGUMENTS", "Platform or isBlocked is null", null)
                    }
                }
                "isServiceStopped" -> {
                    val isStopped = call.argument<Boolean>("isStopped")
                    if (isStopped != null) {
                        MyAccessibilityService.updateServiceStoppedState(isStopped)
                        result.success(null)  // Acknowledge receipt
                    } else {
                        result.error("INVALID_ARGUMENTS", "isStopped is null", null)
                    }
                }
                else -> result.notImplemented()
            }
        }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, SHARED_PREFERENCES_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "timerStarted" -> {
                    val endTime = call.argument<String>("endTime")
                    if (endTime != null) {
                        ForegroundService.startTimer(endTime)
                        result.success(null)
                    } else {
                        result.error("INVALID_ARGUMENTS", "endTime is null", null)
                    }
                }
                "endTimeUpdated" -> {
                    val endTime = call.argument<String>("endTime")
                    if (endTime != null) {
                        ForegroundService.updateEndTime(endTime)
                        result.success(null)
                    } else {
                        result.error("INVALID_ARGUMENTS", "endTime is null", null)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        val serviceIntent = Intent(this, ForegroundService::class.java)
        startForegroundService(serviceIntent)
    }

    override fun onResume() {
        super.onResume()
        // Check accessibility status and notify Flutter
        checkAccessibilityAndNotify()
    }

    private fun checkAccessibilityAndNotify() {
        val isEnabled = isAccessibilityServiceEnabled()

        // Use 'runOnUiThread' because 'invokeMethod' needs to run on the UI thread
        runOnUiThread {
            channel.invokeMethod("onAccessibilityStatusChanged", isEnabled)
        }
    }

    private fun openAccessibilitySettings() {
        val intent = Intent(Settings.ACTION_ACCESSIBILITY_SETTINGS)
        startActivity(intent)
    }

    private fun isAccessibilityServiceEnabled(): Boolean {
        val service = "${packageName}/${packageName}.MyAccessibilityService"
        val enabledServices = Settings.Secure.getString(contentResolver, Settings.Secure.ENABLED_ACCESSIBILITY_SERVICES)
        val accessibilityEnabled = Settings.Secure.getInt(contentResolver, Settings.Secure.ACCESSIBILITY_ENABLED, 0)

        return accessibilityEnabled == 1 && enabledServices?.contains(service) == true
    }
}