package com.example.sankalp.app_activity_detector

import android.view.accessibility.AccessibilityNodeInfo

class InstagramReelsDetector : PlatformDetector {
  companion object {
    private const val REEL_FRAGMENT_ROOT_ID = "com.instagram.android:id/clips_viewer_view_pager";
  }

  override fun isPlatformDetected(rootNode: AccessibilityNodeInfo): Boolean {
    val reelRoot = findNodeById(rootNode, REEL_FRAGMENT_ROOT_ID)
    if (reelRoot != null) {
      reelRoot.recycle();
      return true;
    }

    return false;
  }



  private fun findNodeById(rootNode: AccessibilityNodeInfo, viewId: String): AccessibilityNodeInfo? {
    val nodes = rootNode.findAccessibilityNodeInfosByViewId(viewId)
    if (nodes.isNotEmpty()) {
      val node = nodes[0];
      nodes.forEach { if (it != node) it.recycle(); } //recycle other nodes.
      return node;
    }

    return null;
  }
}