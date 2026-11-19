package com.example.sankalp

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log
import com.example.sankalp.update.UpdateScheduler

/**
 * Restarts the background service after a reboot and after the app updates itself
 * (an update kills the process). Both broadcasts are exempt from Android's
 * background foreground-service start restrictions.
 */
class BootReceiver : BroadcastReceiver() {
  override fun onReceive(context: Context, intent: Intent) {
    when (intent.action) {
      Intent.ACTION_BOOT_COMPLETED, Intent.ACTION_MY_PACKAGE_REPLACED -> {
        Log.d("BootReceiver", "Received ${intent.action}, starting service")
        ForegroundService.start(context)
        UpdateScheduler.syncWithSetting(context)
      }
    }
  }
}
