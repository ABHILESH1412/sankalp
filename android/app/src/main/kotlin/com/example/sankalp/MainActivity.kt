package com.example.sankalp

import android.Manifest
import android.content.ComponentName
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.provider.Settings
import android.util.Log
import com.example.sankalp.update.UpdateManager
import com.example.sankalp.update.UpdateScheduler
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    companion object {
        private const val TAG = "MainActivity"
        private const val ACCESSIBILITY_CHANNEL = "com.example.sankalp/accessibility"
        private const val UPDATE_CHANNEL = "com.example.sankalp/update"
        private const val NOTIFICATION_PERMISSION_REQUEST = 1001
    }

    private var accessibilityChannel: MethodChannel? = null
    private val mainHandler = Handler(Looper.getMainLooper())

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        val messenger = flutterEngine.dartExecutor.binaryMessenger

        accessibilityChannel = MethodChannel(messenger, ACCESSIBILITY_CHANNEL).apply {
            setMethodCallHandler { call, result ->
                when (call.method) {
                    "openAccessibilitySettings" -> {
                        openSettings(Intent(Settings.ACTION_ACCESSIBILITY_SETTINGS))
                        result.success(null)
                    }
                    "openAppInfo" -> {
                        openSettings(
                            Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS, Uri.parse("package:$packageName"))
                        )
                        result.success(null)
                    }
                    "isAccessibilityEnabled" -> result.success(isAccessibilityServiceEnabled())
                    else -> result.notImplemented()
                }
            }
        }

        MethodChannel(messenger, UPDATE_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getAppVersion" -> result.success(UpdateManager.currentVersion(this))
                "canInstallPackages" -> result.success(UpdateManager.canInstallPackages(this))
                "openInstallPermissionSettings" -> {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                        openSettings(
                            Intent(Settings.ACTION_MANAGE_UNKNOWN_APP_SOURCES, Uri.parse("package:$packageName"))
                        )
                    }
                    result.success(null)
                }
                "autoUpdateChanged" -> {
                    UpdateScheduler.syncWithSetting(this)
                    result.success(null)
                }
                "checkForUpdate" -> {
                    val app = applicationContext
                    Thread {
                        val outcome = UpdateManager.checkAndInstall(app, userInitiated = true)
                        mainHandler.post { result.success(outcome.toMap()) }
                    }.start()
                }
                else -> result.notImplemented()
            }
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        ForegroundService.start(this)
        UpdateScheduler.syncWithSetting(this)
        requestNotificationPermissionIfNeeded()
    }

    override fun onResume() {
        super.onResume()
        // The user may have just enabled/disabled the service in Settings.
        accessibilityChannel?.invokeMethod("onAccessibilityStatusChanged", isAccessibilityServiceEnabled())
    }

    private fun requestNotificationPermissionIfNeeded() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU &&
            checkSelfPermission(Manifest.permission.POST_NOTIFICATIONS) != PackageManager.PERMISSION_GRANTED
        ) {
            requestPermissions(arrayOf(Manifest.permission.POST_NOTIFICATIONS), NOTIFICATION_PERMISSION_REQUEST)
        }
    }

    private fun openSettings(intent: Intent) {
        try {
            startActivity(intent)
        } catch (e: Exception) {
            Log.w(TAG, "Could not open settings screen", e)
            try {
                startActivity(Intent(Settings.ACTION_SETTINGS))
            } catch (_: Exception) {
            }
        }
    }

    /**
     * Settings may store the service as "pkg/pkg.Class" or the short "pkg/.Class" form, so
     * compare parsed component names rather than doing a substring match (the old check
     * missed the short form, leaving users stuck on the "enable accessibility" screen).
     */
    private fun isAccessibilityServiceEnabled(): Boolean {
        val expected = ComponentName(this, MyAccessibilityService::class.java)
        val enabledServices = Settings.Secure.getString(
            contentResolver, Settings.Secure.ENABLED_ACCESSIBILITY_SERVICES
        ) ?: return false
        return enabledServices.split(':').any { entry ->
            ComponentName.unflattenFromString(entry.trim()) == expected
        }
    }
}
