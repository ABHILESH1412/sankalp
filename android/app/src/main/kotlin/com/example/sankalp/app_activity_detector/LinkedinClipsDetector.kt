package com.example.sankalp.app_activity_detector

import android.view.accessibility.AccessibilityNodeInfo
import android.view.accessibility.AccessibilityNodeInfo.ACTION_CLICK

class LinkedinClipsDetector : PlatformDetector {
  companion object {
    private const val REEL_FRAGMENT_ROOT_ID = "com.linkedin.android:id/media_viewer_social_actions_vertical_presenter";
    private const val HOME_PAGE_REEL_MUTE_BUTTON_ID = "com.linkedin.android:id/sound_button";
  }

  override fun isPlatformDetected(rootNode: AccessibilityNodeInfo): Boolean {
    // Checking if the video is playing on the home feed of the linkedin, if yes then we make sure that it is muted
    val muteButton = findNodeById(rootNode, HOME_PAGE_REEL_MUTE_BUTTON_ID);
    if(muteButton != null && muteButton.isChecked == true){
      muteButton.performAction(AccessibilityNodeInfo.ACTION_CLICK)
    }

    // Checking if the user is on the dedicated video page
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