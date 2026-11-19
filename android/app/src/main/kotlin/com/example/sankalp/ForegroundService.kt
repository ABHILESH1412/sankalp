package com.example.sankalp

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.content.pm.ServiceInfo
import android.os.Build
import android.os.IBinder
import android.util.Log
import androidx.core.app.NotificationCompat

/**
 * Keeps the app process at foreground priority so aggressive OEM battery savers are
 * less likely to kill the accessibility service.
 *
 * It no longer holds any state (the break timer and the per-app toggles are read from
 * SharedPreferences by [MyAccessibilityService]) and it no longer launches MainActivity,
 * which Android blocks from the background anyway.
 */
class ForegroundService : Service() {
  companion object {
    private const val TAG = "ForegroundService"
    private const val CHANNEL_ID = "sankalp_background"
    private const val NOTIFICATION_ID = 1

    /** Starts the service, never throwing if Android refuses to start it right now. */
    fun start(context: Context) {
      try {
        val intent = Intent(context, ForegroundService::class.java)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
          context.startForegroundService(intent)
        } else {
          context.startService(intent)
        }
      } catch (e: Exception) {
        // e.g. ForegroundServiceStartNotAllowedException when started from the background.
        Log.w(TAG, "Could not start foreground service", e)
      }
    }
  }

  override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
    try {
      createNotificationChannel()
      val notification = buildNotification()
      if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
        startForeground(NOTIFICATION_ID, notification, ServiceInfo.FOREGROUND_SERVICE_TYPE_SPECIAL_USE)
      } else {
        startForeground(NOTIFICATION_ID, notification)
      }
    } catch (e: Exception) {
      Log.w(TAG, "Could not enter foreground state", e)
      stopSelf()
      return START_NOT_STICKY
    }
    return START_STICKY
  }

  // Android 15+ calls this when a time-limited foreground service runs out of time.
  // specialUse has no limit, but stop cleanly instead of crashing if it ever happens.
  override fun onTimeout(startId: Int, fgsType: Int) {
    stopSelf()
  }

  override fun onBind(intent: Intent?): IBinder? = null

  private fun buildNotification(): Notification {
    val openApp = PendingIntent.getActivity(
      this,
      0,
      Intent(this, MainActivity::class.java),
      PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
    )
    return NotificationCompat.Builder(this, CHANNEL_ID)
      .setContentTitle("Sankalp is active")
      .setContentText("Blocking short videos in the background")
      .setSmallIcon(R.drawable.ic_notification)
      .setContentIntent(openApp)
      .setOngoing(true)
      .setPriority(NotificationCompat.PRIORITY_LOW)
      .build()
  }

  private fun createNotificationChannel() {
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
      val manager = getSystemService(NotificationManager::class.java) ?: return
      // Remove the old, louder channel used by earlier versions.
      manager.deleteNotificationChannel("ForegroundServiceChannel")
      val channel = NotificationChannel(
        CHANNEL_ID,
        "Background service",
        NotificationManager.IMPORTANCE_LOW
      ).apply { setShowBadge(false) }
      manager.createNotificationChannel(channel)
    }
  }
}
