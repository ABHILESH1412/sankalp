package com.example.sankalp.app_activity_detector

import android.view.accessibility.AccessibilityNodeInfo

class SnapchatStoriesDetector : PlatformDetector {
  companion object {
    private const val REEL_FRAGMENT_ROOT_ID = "com.snapchat.android:id/df_large_story";
  }

  override fun isPlatformDetected(rootNode: AccessibilityNodeInfo): Boolean {
    val reelRoot = NodeUtils.findNodeById(rootNode, REEL_FRAGMENT_ROOT_ID)
    if (reelRoot != null) {
      return true;
    }

    return false;
  }
}