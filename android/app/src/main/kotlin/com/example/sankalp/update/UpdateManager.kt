package com.example.sankalp.update

import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.content.pm.PackageInstaller
import android.content.pm.PackageManager
import android.os.Build
import android.util.Log
import com.example.sankalp.AppPrefs
import org.json.JSONObject
import java.io.File
import java.net.HttpURLConnection
import java.net.URL

/**
 * Self-updater backed by GitHub Releases.
 *
 * The release workflow (.github/workflows/release.yml) publishes a release tagged
 * `vX.Y.Z` with a signed `Sankalp.apk` asset. This class compares that tag with the
 * installed version, downloads the APK and installs it with [PackageInstaller].
 *
 * On Android 12+ the update installs silently once the user has allowed Sankalp to
 * "install unknown apps" (an app may update itself without a prompt). Otherwise Android
 * asks the user to confirm, see [InstallResultReceiver].
 */
object UpdateManager {
  private const val TAG = "UpdateManager"
  private const val REPO = "ABHILESH1412/sankalp"
  private const val APK_ASSET_NAME = "Sankalp.apk"
  private const val LATEST_RELEASE_URL = "https://api.github.com/repos/$REPO/releases/latest"

  enum class Status(val wire: String) {
    UP_TO_DATE("up_to_date"),
    INSTALLING("installing"),
    ALREADY_RUNNING("already_running"),
    ERROR("error"),
  }

  data class Result(val status: Status, val latestVersion: String? = null, val message: String? = null) {
    fun toMap(): Map<String, Any?> =
      mapOf("status" to status.wire, "latestVersion" to latestVersion, "message" to message)
  }

  private data class Release(val version: String, val apkUrl: String)

  @Volatile private var running = false

  fun currentVersion(context: Context): String =
    try {
      context.packageManager.getPackageInfo(context.packageName, 0).versionName ?: "0.0.0"
    } catch (e: PackageManager.NameNotFoundException) {
      "0.0.0"
    }

  /** Whether the user has allowed this app to install packages (needed for silent updates). */
  fun canInstallPackages(context: Context): Boolean =
    Build.VERSION.SDK_INT < Build.VERSION_CODES.O || context.packageManager.canRequestPackageInstalls()

  /**
   * Checks for a newer release and starts installing it. Blocking, run it off the main thread.
   * [userInitiated] is true when the user tapped "Check for updates" with the app open.
   */
  fun checkAndInstall(context: Context, userInitiated: Boolean): Result {
    if (running) return Result(Status.ALREADY_RUNNING)
    running = true
    try {
      val app = context.applicationContext
      val release = fetchLatestRelease()
      AppPrefs.putLong(app, AppPrefs.KEY_LAST_UPDATE_CHECK, System.currentTimeMillis())

      if (!isNewer(release.version, currentVersion(app))) {
        return Result(Status.UP_TO_DATE, release.version)
      }
      Log.i(TAG, "Updating ${currentVersion(app)} -> ${release.version}")
      val apk = download(app, release.apkUrl)
      install(app, apk, userInitiated)
      return Result(Status.INSTALLING, release.version)
    } catch (e: Exception) {
      Log.w(TAG, "Update failed", e)
      return Result(Status.ERROR, message = e.message ?: e.javaClass.simpleName)
    } finally {
      running = false
    }
  }

  private fun fetchLatestRelease(): Release {
    val conn = (URL(LATEST_RELEASE_URL).openConnection() as HttpURLConnection).apply {
      connectTimeout = 15_000
      readTimeout = 15_000
      setRequestProperty("Accept", "application/vnd.github+json")
      setRequestProperty("User-Agent", "Sankalp-Updater")
    }
    try {
      if (conn.responseCode != HttpURLConnection.HTTP_OK) {
        throw IllegalStateException("GitHub returned HTTP ${conn.responseCode}")
      }
      val json = JSONObject(conn.inputStream.bufferedReader().use { it.readText() })
      val tag = json.getString("tag_name")
      val assets = json.getJSONArray("assets")
      var apkUrl: String? = null
      for (i in 0 until assets.length()) {
        val asset = assets.getJSONObject(i)
        val name = asset.getString("name")
        if (name.equals(APK_ASSET_NAME, ignoreCase = true)) {
          apkUrl = asset.getString("browser_download_url")
          break
        }
        if (apkUrl == null && name.endsWith(".apk", ignoreCase = true)) {
          apkUrl = asset.getString("browser_download_url")
        }
      }
      return Release(tag.removePrefix("v").removePrefix("V"), apkUrl ?: throw IllegalStateException("Release $tag has no APK"))
    } finally {
      conn.disconnect()
    }
  }

  /** Compares dotted versions numerically, ignoring any "-suffix" or "+build" part. */
  fun isNewer(remote: String, local: String): Boolean {
    fun parse(v: String) = v.substringBefore('+').substringBefore('-')
      .split('.').map { it.toIntOrNull() ?: 0 }
    val a = parse(remote)
    val b = parse(local)
    for (i in 0 until maxOf(a.size, b.size)) {
      val x = a.getOrElse(i) { 0 }
      val y = b.getOrElse(i) { 0 }
      if (x != y) return x > y
    }
    return false
  }

  private fun download(context: Context, url: String): File {
    val dir = File(context.cacheDir, "updates").apply { mkdirs() }
    val target = File(dir, "update.apk")
    val partial = File(dir, "update.apk.part")
    val conn = (URL(url).openConnection() as HttpURLConnection).apply {
      connectTimeout = 15_000
      readTimeout = 60_000
      instanceFollowRedirects = true
      setRequestProperty("User-Agent", "Sankalp-Updater")
    }
    try {
      if (conn.responseCode != HttpURLConnection.HTTP_OK) {
        throw IllegalStateException("APK download returned HTTP ${conn.responseCode}")
      }
      conn.inputStream.use { input -> partial.outputStream().use { input.copyTo(it) } }
    } finally {
      conn.disconnect()
    }
    if (!partial.renameTo(target)) {
      partial.copyTo(target, overwrite = true)
      partial.delete()
    }
    return target
  }

  private fun install(context: Context, apk: File, userInitiated: Boolean) {
    val installer = context.packageManager.packageInstaller
    val params = PackageInstaller.SessionParams(PackageInstaller.SessionParams.MODE_FULL_INSTALL).apply {
      setAppPackageName(context.packageName)
      setSize(apk.length())
      if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
        setRequireUserAction(PackageInstaller.SessionParams.USER_ACTION_NOT_REQUIRED)
      }
    }
    val sessionId = installer.createSession(params)
    try {
      installer.openSession(sessionId).use { session ->
        apk.inputStream().use { input ->
          session.openWrite("sankalp.apk", 0, apk.length()).use { out ->
            input.copyTo(out)
            session.fsync(out)
          }
        }
        val resultIntent = Intent(context, InstallResultReceiver::class.java)
          .putExtra(InstallResultReceiver.EXTRA_USER_INITIATED, userInitiated)
        // Must be mutable: the installer adds the status extras to this intent.
        val flags = PendingIntent.FLAG_UPDATE_CURRENT or
          (if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) PendingIntent.FLAG_MUTABLE else 0)
        val pending = PendingIntent.getBroadcast(context, sessionId, resultIntent, flags)
        session.commit(pending.intentSender)
      }
    } catch (e: Exception) {
      try { installer.abandonSession(sessionId) } catch (_: Exception) {}
      throw e
    }
  }
}
