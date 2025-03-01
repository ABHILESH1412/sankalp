package com.example.sankalp

import android.accessibilityservice.AccessibilityService
import android.accessibilityservice.AccessibilityServiceInfo
import android.util.Log
import android.view.accessibility.AccessibilityEvent
import android.view.accessibility.AccessibilityNodeInfo

import com.example.sankalp.app_activity_detector.*

class MyAccessibilityService : AccessibilityService() {
    private lateinit var youtubeShortsDetector: PlatformDetector
    private lateinit var instagramReelsDetector: PlatformDetector
    private lateinit var snapchatSpotlightDetector: PlatformDetector
    private lateinit var snapchatStoriesDetector: PlatformDetector
    private lateinit var tiktokVideoDetector: PlatformDetector
    private lateinit var linkedinClipsDetector: PlatformDetector
    private lateinit var redditVideosDetector: PlatformDetector

    companion object{
        private const val TAG: String = "MyAccessibilityService"

        private const val YOUTUBE_PACKAGE_NAME: String = "com.google.android.youtube"
        private const val INSTAGRAM_PACKAGE_NAME: String = "com.instagram.android"
        private const val TIKTOK_PACKAGE_NAME: String = "com.ss.android.ugc.trill"
        private const val SNAPCHAT_PACKAGE_NAME: String = "com.snapchat.android"
        private const val LINKEDIN_PACKAGE_NAME: String = "com.linkedin.android"

        private const val EVENT_TYPE_WINDOW_STATE: Int = AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED
        private const val EVENT_TYPE_WINDOW_AND_CONTENT: Int = AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED or AccessibilityEvent.TYPE_WINDOW_CONTENT_CHANGED

        private val platformBlockedStates = HashMap<String, Boolean>()
        private var isServiceStopped: Boolean = false;

        // Static method to update the blocked state
        fun updatePlatformBlockedState(platform: String, isBlocked: Boolean) {
            platformBlockedStates[platform] = isBlocked
            Log.d(TAG, "Updated $platform block state to: $isBlocked")
        }
        // get the platform blocked state. This method added to avoid unnecessary errors.
        fun getPlatformBlockedState(platform: String): Boolean {
            return platformBlockedStates[platform] ?: false // Return false by default if not found
        }

        fun updateServiceStoppedState(isStopped: Boolean){
            isServiceStopped = isStopped;
        }
    }

    private val packages = arrayOf(
        YOUTUBE_PACKAGE_NAME,
        INSTAGRAM_PACKAGE_NAME,
        TIKTOK_PACKAGE_NAME,
        SNAPCHAT_PACKAGE_NAME,
        LINKEDIN_PACKAGE_NAME,
    )

    private val packageEventTypeMap = hashMapOf(
        YOUTUBE_PACKAGE_NAME to EVENT_TYPE_WINDOW_STATE,
        INSTAGRAM_PACKAGE_NAME to EVENT_TYPE_WINDOW_AND_CONTENT,
        LINKEDIN_PACKAGE_NAME to EVENT_TYPE_WINDOW_AND_CONTENT,
        TIKTOK_PACKAGE_NAME to EVENT_TYPE_WINDOW_AND_CONTENT,
        SNAPCHAT_PACKAGE_NAME to EVENT_TYPE_WINDOW_AND_CONTENT,
    )

    private var currentEventTypeFlag: Int = EVENT_TYPE_WINDOW_STATE


    override fun onServiceConnected() {
        super.onServiceConnected()
        Log.d("MyAccessibilityService", "Service connected")
        youtubeShortsDetector = YouTubeShortsDetector()
        instagramReelsDetector = InstagramReelsDetector()
        snapchatSpotlightDetector = SnapchatSpotlightDetector()
        snapchatStoriesDetector = SnapchatStoriesDetector()
        tiktokVideoDetector = TiktokVideoDetector()
        linkedinClipsDetector = LinkedinClipsDetector()

        updateServiceInfo(EVENT_TYPE_WINDOW_STATE);
    }

    private fun updateServiceInfo(eventTypes: Int) {
        val info = AccessibilityServiceInfo().apply {
            this.eventTypes = eventTypes
            feedbackType = AccessibilityServiceInfo.FEEDBACK_GENERIC
            notificationTimeout = 100
            packageNames = packages
            flags = AccessibilityServiceInfo.FLAG_INCLUDE_NOT_IMPORTANT_VIEWS or
                    AccessibilityServiceInfo.FLAG_REPORT_VIEW_IDS
        }
        serviceInfo = info
        Log.d(TAG, "Updated serviceInfo.") // Debugging
    }

    override fun onAccessibilityEvent(event: AccessibilityEvent) {
        if(isServiceStopped){
            return;
        }
        val packageName = event.getPackageName();
        if (packageName == null) {
            Log.w("MyAccessibilityService", "Package name is null!");
            return; // Exit if package name is unavailable
        }
        Log.d("MyAccessibilityService", "Event Package Name: ${packageName}");

        when (event.eventType) {
            AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED -> {
                handleWindowStateChanged(event)
            }
        }
        val rootNode: AccessibilityNodeInfo? = rootInActiveWindow

        if (rootNode == null) {
            Log.w("MyAccessibilityService", "Root node is null!")
            return
        }

        when (event?.packageName) {
            YOUTUBE_PACKAGE_NAME -> {
                var _youtubeShortsBlocker: String = "youtubeShortsBlockerNotifier"
                if (getPlatformBlockedState(_youtubeShortsBlocker) && 
                    youtubeShortsDetector.isPlatformDetected(rootNode)) {
                    performGlobalAction(GLOBAL_ACTION_BACK)
                }
            }
            INSTAGRAM_PACKAGE_NAME -> {
                var _instagramReelsBlocker: String = "instagramReelsBlockerNotifier"
                if (getPlatformBlockedState(_instagramReelsBlocker) && 
                    instagramReelsDetector.isPlatformDetected(rootNode)) {
                    performGlobalAction(GLOBAL_ACTION_BACK)
                }
            }
            SNAPCHAT_PACKAGE_NAME -> {
                var _snapchatSpotlightBlocker: String = "snapchatSpotlightBlockerNotifier"
                var _snapchatStoriesBlocker: String = "snapchatStoriesBlockerNotifier"
                if (getPlatformBlockedState(_snapchatSpotlightBlocker) &&
                    snapchatSpotlightDetector.isPlatformDetected(rootNode)) {
                    performGlobalAction(GLOBAL_ACTION_BACK)
                }else if(getPlatformBlockedState(_snapchatStoriesBlocker) &&
                    snapchatStoriesDetector.isPlatformDetected(rootNode)){
                    performGlobalAction(GLOBAL_ACTION_BACK)
                }
            }
            TIKTOK_PACKAGE_NAME -> {
                var _tiktokVideosBlocker: String = "tiktokVideosBlockerNotifier"
                if (getPlatformBlockedState(_tiktokVideosBlocker) &&
                    tiktokVideoDetector.isPlatformDetected(rootNode)) {
                    // We are not performing GLOBAL_ACTION_BACK in this because if we do so the app will be closed which leads to bad user experience. We are clicking on the Friends tab rather going back.
                    // The logic of this is implemented in the TiktokVideoDetector.kt file.
                    // performGlobalAction(GLOBAL_ACTION_BACK)
                }
            }
            LINKEDIN_PACKAGE_NAME -> {
                var _linkedinVideosBlocker: String = "linkedinVideosBlockerNotifier"
                if (getPlatformBlockedState(_linkedinVideosBlocker) &&
                    linkedinClipsDetector.isPlatformDetected(rootNode)) {
                    performGlobalAction(GLOBAL_ACTION_BACK)
                }
            }
        }

        rootNode.recycle()
    }

    private fun handleWindowStateChanged(event: AccessibilityEvent) {
        val packageName = event.packageName?.toString() ?: return
        val desiredEventTypeFlag = packageEventTypeMap[packageName] ?: EVENT_TYPE_WINDOW_STATE

        if (desiredEventTypeFlag != currentEventTypeFlag) {
            currentEventTypeFlag = desiredEventTypeFlag
            updateServiceInfo(currentEventTypeFlag)
        }
    }

    override fun onInterrupt() {
        Log.d("MyAccessibilityService", "Service interrupted")
        //Handle interruption (e.g., another accessibility service is enabled)
    }

    override fun onDestroy() {
        super.onDestroy()
        Log.d("MyAccessibilityService", "Service destroyed")
    }
}