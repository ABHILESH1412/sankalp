package com.example.sankalp.update

import android.app.job.JobInfo
import android.app.job.JobParameters
import android.app.job.JobScheduler
import android.app.job.JobService
import android.content.ComponentName
import android.content.Context
import android.util.Log
import com.example.sankalp.AppPrefs

/** Runs the periodic background update check. */
class UpdateJobService : JobService() {
  override fun onStartJob(params: JobParameters?): Boolean {
    if (!AppPrefs.isAutoUpdateEnabled(this)) return false
    Thread {
      UpdateManager.checkAndInstall(applicationContext, userInitiated = false)
      jobFinished(params, false)
    }.start()
    return true
  }

  override fun onStopJob(params: JobParameters?): Boolean = true
}

object UpdateScheduler {
  private const val TAG = "UpdateScheduler"
  private const val JOB_ID = 4201
  private const val INTERVAL_MS = 6L * 60 * 60 * 1000 // every 6 hours

  /** Schedules or cancels the periodic check to match the user's auto-update setting. */
  fun syncWithSetting(context: Context) {
    if (AppPrefs.isAutoUpdateEnabled(context)) schedule(context) else cancel(context)
  }

  private fun schedule(context: Context) {
    val scheduler = context.getSystemService(JobScheduler::class.java) ?: return
    if (scheduler.getPendingJob(JOB_ID) != null) return
    val job = JobInfo.Builder(JOB_ID, ComponentName(context, UpdateJobService::class.java))
      .setRequiredNetworkType(JobInfo.NETWORK_TYPE_ANY)
      .setPeriodic(INTERVAL_MS)
      .setPersisted(true)
      .build()
    try {
      scheduler.schedule(job)
    } catch (e: Exception) {
      Log.w(TAG, "Could not schedule update job", e)
    }
  }

  private fun cancel(context: Context) {
    context.getSystemService(JobScheduler::class.java)?.cancel(JOB_ID)
  }
}
