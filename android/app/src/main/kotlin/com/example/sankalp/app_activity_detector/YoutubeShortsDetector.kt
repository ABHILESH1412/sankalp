package com.example.sankalp.app_activity_detector

import android.view.accessibility.AccessibilityNodeInfo

class YouTubeShortsDetector : PlatformDetector {
  companion object {
    private const val REEL_FRAGMENT_ROOT_ID = "com.google.android.youtube:id/reel_watch_fragment_root";
  }

  override fun isPlatformDetected(rootNode: AccessibilityNodeInfo): Boolean {
    val reelRoot = NodeUtils.findNodeById(rootNode, REEL_FRAGMENT_ROOT_ID)
    if (reelRoot != null) {
      return true;
    }

    return false;
  }
}