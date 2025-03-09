package com.example.sankalp

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Service
import android.content.Intent
import android.os.Build
import android.os.IBinder
import androidx.core.app.NotificationCompat
import android.os.Handler
import android.os.Looper
import java.text.SimpleDateFormat
import java.util.*

class ForegroundService : Service() {
  companion object {
    const val CHANNEL_ID = "ForegroundServiceChannel"
    var timerDuration = 0L;

    var handler = Handler(Looper.getMainLooper())
    var runnable: Runnable? = null

    fun getTimeDifferenceInMillis(endTime: String): Long {
      val dateFormat = SimpleDateFormat("yyyy-MM-dd HH:mm:ss", Locale.getDefault())
      dateFormat.timeZone = TimeZone.getDefault() // Ensure it's in the correct timezone
  
      return try {
        val endDate = dateFormat.parse(endTime) // Parse end time
        val currentDate = Date() // Get current time
        endDate?.time?.minus(currentDate.time) ?: 0L // Difference in milliseconds
      } catch (e: Exception) {
        e.printStackTrace()
        0L // Return 0 if there's an error
      }
    } 

    fun startTimer(value: String) {
      timerDuration = getTimeDifferenceInMillis(value)
      println("Timer Started");
      MyAccessibilityService.updateServiceStoppedState(true);

      runnable = Runnable {
        println("Timer finished!")
        MyAccessibilityService.updateServiceStoppedState(false);
      }
      handler.postDelayed(runnable!!, timerDuration)
    }

    fun updateEndTime(value: String) {
      timerDuration = getTimeDifferenceInMillis(value)
      handler.removeCallbacks(runnable!!)
      handler.postDelayed(runnable!!, timerDuration)
    }
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

    // Start MainActivity to initialize HomePage
    val mainActivityIntent = Intent(this, MainActivity::class.java)
    mainActivityIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
    startActivity(mainActivityIntent)
  }

  // Start MyAccessibilityService
  override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
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