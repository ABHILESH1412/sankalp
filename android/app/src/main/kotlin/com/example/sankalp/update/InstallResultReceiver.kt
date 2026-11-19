package com.example.sankalp.update

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.pm.PackageInstaller
import android.os.Build
import android.util.Log
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import com.example.sankalp.R

/**
 * Receives the outcome of an update install session.
 *
 * When Android needs the user to confirm the install (Android < 12, or the user has not
 * allowed Sankalp to install apps yet), we open the confirmation screen directly if the
 * user started the check from the app, or post a notification if it ran in the background.
 */
class InstallResultReceiver : BroadcastReceiver() {
  companion object {
    const val EXTRA_USER_INITIATED = "com.example.sankalp.USER_INITIATED"
    private const val TAG = "InstallResultReceiver"
    private const val CHANNEL_ID = "sankalp_updates"
    private const val NOTIFICATION_ID = 2
  }

  override fun onReceive(context: Context, intent: Intent) {
    val status = intent.getIntExtra(PackageInstaller.EXTRA_STATUS, PackageInstaller.STATUS_FAILURE)
    when (status) {
      PackageInstaller.STATUS_PENDING_USER_ACTION -> {
        val confirm = confirmationIntent(intent) ?: return
        confirm.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        val userInitiated = intent.getBooleanExtra(EXTRA_USER_INITIATED, false)
        if (userInitiated) {
          try {
            context.startActivity(confirm)
            return
          } catch (e: Exception) {
            Log.w(TAG, "Could not open install confirmation, falling back to notification", e)
          }
        }
        notifyUpdateReady(context, confirm)
      }
      PackageInstaller.STATUS_SUCCESS -> Log.i(TAG, "Update installed")
      else -> Log.w(
        TAG,
        "Update install failed ($status): ${intent.getStringExtra(PackageInstaller.EXTRA_STATUS_MESSAGE)}"
      )
    }
  }

  private fun confirmationIntent(intent: Intent): Intent? =
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
      intent.getParcelableExtra(Intent.EXTRA_INTENT, Intent::class.java)
    } else {
      @Suppress("DEPRECATION")
      intent.getParcelableExtra(Intent.EXTRA_INTENT)
    }

  private fun notifyUpdateReady(context: Context, confirm: Intent) {
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
      val manager = context.getSystemService(NotificationManager::class.java) ?: return
      manager.createNotificationChannel(
        NotificationChannel(CHANNEL_ID, "App updates", NotificationManager.IMPORTANCE_DEFAULT)
      )
    }
    val pending = PendingIntent.getActivity(
      context, 0, confirm, PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
    )
    val notification = NotificationCompat.Builder(context, CHANNEL_ID)
      .setSmallIcon(R.drawable.ic_notification)
      .setContentTitle("Sankalp update ready")
      .setContentText("Tap to install the new version")
      .setContentIntent(pending)
      .setAutoCancel(true)
      .build()
    try {
      NotificationManagerCompat.from(context).notify(NOTIFICATION_ID, notification)
    } catch (e: SecurityException) {
      // Notification permission not granted; the next check will try again.
      Log.w(TAG, "Cannot post update notification", e)
    }
  }
}
