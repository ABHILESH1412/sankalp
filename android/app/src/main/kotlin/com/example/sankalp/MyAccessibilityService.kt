package com.example.sankalp

import android.accessibilityservice.AccessibilityService
import android.util.Log
import android.view.accessibility.AccessibilityEvent
import android.view.accessibility.AccessibilityNodeInfo

import com.example.sankalp.app_activity_detector.*

class MyAccessibilityService : AccessibilityService() {

    companion object {
        private const val TAG = "MyAccessibilityService"
        private const val DEBOUNCE_DELAY: Long = 200 // ms between two automatic "back" presses

        private const val YOUTUBE_PACKAGE_NAME = "com.google.android.youtube"
        private const val INSTAGRAM_PACKAGE_NAME = "com.instagram.android"
        private const val TIKTOK_PACKAGE_NAME = "com.ss.android.ugc.trill"
        private const val SNAPCHAT_PACKAGE_NAME = "com.snapchat.android"
        private const val LINKEDIN_PACKAGE_NAME = "com.linkedin.android"
        private const val X_PACKAGE_NAME = "com.twitter.android"

        // Keys written by the Flutter UI (see lib/views/pages/home_page.dart).
        private const val KEY_YOUTUBE = "youtubeShortsBlockerNotifier"
        private const val KEY_INSTAGRAM = "instagramReelsBlockerNotifier"
        private const val KEY_SNAPCHAT_SPOTLIGHT = "snapchatSpotlightBlockerNotifier"
        private const val KEY_SNAPCHAT_STORIES = "snapchatStoriesBlockerNotifier"
        private const val KEY_TIKTOK = "tiktokVideosBlockerNotifier"
        private const val KEY_LINKEDIN = "linkedinVideosBlockerNotifier"
        private const val KEY_X = "xVideosBlockerNotifier"
    }

    private val youtubeShortsDetector = YouTubeShortsDetector()
    private val instagramReelsDetector = InstagramReelsDetector()
    private val snapchatSpotlightDetector = SnapchatSpotlightDetector()
    private val snapchatStoriesDetector = SnapchatStoriesDetector()
    private val tiktokVideoDetector = TiktokVideoDetector()
    private val linkedinClipsDetector = LinkedinClipsDetector()
    private val xVideosDetector = XVideosDetector()

    private var lastBackPressTime: Long = 0

    override fun onServiceConnected() {
        super.onServiceConnected()
        // Make sure the background service is up whenever the accessibility service is.
        ForegroundService.start(this)
    }

    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        // An uncaught exception here kills the whole app process (and with it the
        // blocker), so never let one escape. Node trees from other apps are often
        // half-built or stale while they are being laid out.
        try {
            handleEvent(event ?: return)
        } catch (t: Throwable) {
            Log.w(TAG, "Failed to handle accessibility event", t)
        }
    }

    private fun handleEvent(event: AccessibilityEvent) {
        if (AppPrefs.isOnBreak(this)) return

        val packageName = event.packageName?.toString() ?: return
        val rootNode: AccessibilityNodeInfo = rootInActiveWindow ?: return

        when (packageName) {
            YOUTUBE_PACKAGE_NAME ->
                if (isBlocked(KEY_YOUTUBE) && youtubeShortsDetector.isPlatformDetected(rootNode)) goBack()

            INSTAGRAM_PACKAGE_NAME ->
                if (isBlocked(KEY_INSTAGRAM) && instagramReelsDetector.isPlatformDetected(rootNode)) goBack()

            SNAPCHAT_PACKAGE_NAME ->
                if (isBlocked(KEY_SNAPCHAT_SPOTLIGHT) && snapchatSpotlightDetector.isPlatformDetected(rootNode)) {
                    goBack()
                } else if (isBlocked(KEY_SNAPCHAT_STORIES) && snapchatStoriesDetector.isPlatformDetected(rootNode)) {
                    goBack()
                }

            // Pressing back would close TikTok, so the detector taps the Friends tab
            // itself instead (see TiktokVideoDetector).
            TIKTOK_PACKAGE_NAME ->
                if (isBlocked(KEY_TIKTOK)) tiktokVideoDetector.isPlatformDetected(rootNode)

            LINKEDIN_PACKAGE_NAME ->
                if (isBlocked(KEY_LINKEDIN) && linkedinClipsDetector.isPlatformDetected(rootNode)) goBack()

            X_PACKAGE_NAME ->
                if (isBlocked(KEY_X) && xVideosDetector.isPlatformDetected(rootNode)) goBack()
        }
    }

    private fun isBlocked(key: String) = AppPrefs.isPlatformBlocked(this, key)

    private fun goBack() {
        val now = System.currentTimeMillis()
        if (now - lastBackPressTime > DEBOUNCE_DELAY) {
            lastBackPressTime = now
            performGlobalAction(GLOBAL_ACTION_BACK)
        }
    }

    override fun onInterrupt() {
        // Nothing to clean up.
    }
}
