package com.example.sankalp.app_activity_detector

import android.view.accessibility.AccessibilityNodeInfo
import android.view.accessibility.AccessibilityNodeInfo.ACTION_CLICK

class TiktokVideoDetector : PlatformDetector {
  companion object {
    private const val REEL_FRAGMENT_ROOT_ID = "com.ss.android.ugc.trill:id/pum";
    private const val FRIENDS_BUTTON_ROOT_ID = "com.ss.android.ugc.trill:id/jnk";
  }

  override fun isPlatformDetected(rootNode: AccessibilityNodeInfo): Boolean {
    // Checking if the Video is running on the screen or not
    val reelRoot = findNodeById(rootNode, REEL_FRAGMENT_ROOT_ID)
    if (reelRoot == null){
      return false;
    }

    // If the video is running on the screen press on the friends button to block the video.
    val friendsButton = findNodeById(rootNode, FRIENDS_BUTTON_ROOT_ID)
    if(friendsButton == null){
      return false;
    }
    friendsButton.performAction(ACTION_CLICK)

    return true;
  }



  private fun findNodeById(rootNode: AccessibilityNodeInfo, viewId: String): AccessibilityNodeInfo? {
    val nodes = rootNode.findAccessibilityNodeInfosByViewId(viewId)
    if (nodes.isNotEmpty()) {
      return nodes[0];
    }

    return null;
  }
}