package com.example.sankalp

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log

class BootReceiver : BroadcastReceiver() {
  override fun onReceive(context: Context, intent: Intent) {
    if (intent.action == Intent.ACTION_BOOT_COMPLETED) {
      Log.d("BootReceiver", "Device booted, starting app...")
      val serviceIntent = Intent(context, ForegroundService::class.java)
      context.startForegroundService(serviceIntent)
    }
  }
}