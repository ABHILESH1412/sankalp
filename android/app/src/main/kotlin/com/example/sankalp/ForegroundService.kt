package com.example.sankalp

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Service
import android.content.Intent
import android.os.Build
import android.os.IBinder
import androidx.core.app.NotificationCompat

class ForegroundService : Service() {
  companion object {
    const val CHANNEL_ID = "ForegroundServiceChannel"
  }

  override fun onCreate() {
    super.onCreate()
    createNotificationChannel()
    val notification: Notification = NotificationCompat.Builder(this, CHANNEL_ID)
      .setContentTitle("Sankalp Service")
      .setContentText("Running in the background")
      .setSmallIcon(R.drawable.ic_notification)
      .build()
    startForeground(1, notification)
  }

  override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
    // Your background task code here
    return START_STICKY
  }

  override fun onBind(intent: Intent?): IBinder? {
      return null
  }

  private fun createNotificationChannel() {
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
      val serviceChannel = NotificationChannel(
        CHANNEL_ID,
        "Foreground Service Channel",
        NotificationManager.IMPORTANCE_DEFAULT
      )
      val manager = getSystemService(NotificationManager::class.java)
      manager.createNotificationChannel(serviceChannel)
    }
  }
}