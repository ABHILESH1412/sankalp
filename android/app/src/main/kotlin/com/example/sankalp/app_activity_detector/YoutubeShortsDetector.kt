package com.example.sankalp.app_activity_detector

import android.view.accessibility.AccessibilityNodeInfo

class YouTubeShortsDetector : PlatformDetector {
  companion object {
    private const val REEL_FRAGMENT_ROOT_ID = "com.google.android.youtube:id/reel_watch_fragment_root";
  }

  override fun isPlatformDetected(rootNode: AccessibilityNodeInfo): Boolean {
    val reelRoot = findNodeById(rootNode, REEL_FRAGMENT_ROOT_ID)
    if (reelRoot != null) {
      return true;
    }

    return false;
  }



  private fun findNodeById(rootNode: AccessibilityNodeInfo, viewId: String): AccessibilityNodeInfo? {
    val nodes = rootNode.findAccessibilityNodeInfosByViewId(viewId)
    if (nodes.isNotEmpty()) {
      return nodes[0];
    }

    return null;
  }
}