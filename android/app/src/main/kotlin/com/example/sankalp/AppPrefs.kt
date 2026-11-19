package com.example.sankalp

import android.content.Context
import android.content.SharedPreferences
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

/**
 * Reads the settings the Flutter UI writes with the `shared_preferences` plugin.
 *
 * The plugin stores everything in the native "FlutterSharedPreferences" file with a
 * "flutter." key prefix (bools as Boolean, ints as Long). Reading them here means the
 * accessibility service always knows what to block, even when Android killed and
 * restarted the process and the Flutter UI was never opened. Previously that state only
 * lived in memory and was lost on every restart, so blocking silently stopped working.
 */
object AppPrefs {
    private const val FILE_NAME = "FlutterSharedPreferences"
    private const val PREFIX = "flutter."

    const val KEY_BREAK_END_MILLIS = "breakEndMillis"
    const val KEY_AUTO_UPDATE = "autoUpdateEnabled"
    const val KEY_LAST_UPDATE_CHECK = "lastUpdateCheckMillis"

    // Block statistics shown on the home screen (lib/data/stats.dart).
    const val KEY_BLOCKED_TODAY = "blockedTodayCount"
    const val KEY_BLOCKED_DATE = "blockedTodayDate"
    const val KEY_BLOCKED_TOTAL = "blockedTotalCount"

    private fun prefs(context: Context): SharedPreferences =
        context.applicationContext.getSharedPreferences(FILE_NAME, Context.MODE_PRIVATE)

    fun getBool(context: Context, key: String, default: Boolean): Boolean =
        try {
            prefs(context).getBoolean(PREFIX + key, default)
        } catch (e: ClassCastException) {
            default
        }

    fun getLong(context: Context, key: String, default: Long): Long =
        try {
            prefs(context).getLong(PREFIX + key, default)
        } catch (e: ClassCastException) {
            default
        }

    fun putLong(context: Context, key: String, value: Long) {
        prefs(context).edit().putLong(PREFIX + key, value).apply()
    }

    fun isPlatformBlocked(context: Context, platformKey: String): Boolean =
        getBool(context, platformKey, false)

    /** True while the user's "+5 mins of rest" break is active. */
    fun isOnBreak(context: Context): Boolean =
        System.currentTimeMillis() < getLong(context, KEY_BREAK_END_MILLIS, 0L)

    fun isAutoUpdateEnabled(context: Context): Boolean =
        getBool(context, KEY_AUTO_UPDATE, true)

    /** Counts one blocked short-video visit for today's and the all-time stats. */
    @Synchronized
    fun recordBlock(context: Context) {
        val p = prefs(context)
        val today = SimpleDateFormat("yyyy-MM-dd", Locale.US).format(Date())
        val sameDay = try {
            p.getString(PREFIX + KEY_BLOCKED_DATE, null) == today
        } catch (e: ClassCastException) {
            false
        }
        val todayCount = if (sameDay) getLong(context, KEY_BLOCKED_TODAY, 0L) + 1 else 1L
        val total = getLong(context, KEY_BLOCKED_TOTAL, 0L) + 1
        p.edit()
            .putString(PREFIX + KEY_BLOCKED_DATE, today)
            .putLong(PREFIX + KEY_BLOCKED_TODAY, todayCount)
            .putLong(PREFIX + KEY_BLOCKED_TOTAL, total)
            .apply()
    }
}
