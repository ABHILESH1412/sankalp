package com.example.sankalp.app_activity_detector

import android.view.accessibility.AccessibilityNodeInfo
import android.view.accessibility.AccessibilityNodeInfo.ACTION_CLICK
import android.util.Log

class XVideosDetector : PlatformDetector {
  companion object {
    private const val REEL_FRAGMENT_ROOT_ID = "com.twitter.android:id/seekbar";
    private const val HOME_PAGE_VIDEO_MUTE_BUTTON_ID = "com.twitter.android:id/audio_toggle_icon";
    private const val CONT_DESC = "Mute audio";
  }

  override fun isPlatformDetected(rootNode: AccessibilityNodeInfo): Boolean {
    // Checking if the video is playing on the home feed of the linkedin, if yes then we make sure that it is muted
    val isUnMute = NodeUtils.findNodeByIdAndContentDescription(rootNode, HOME_PAGE_VIDEO_MUTE_BUTTON_ID, CONT_DESC);
    if(isUnMute != null){
      NodeUtils.clickParent(isUnMute)
    }

    // Checking if the user is on the dedicated video page
    val reelRoot = NodeUtils.findNodeById(rootNode, REEL_FRAGMENT_ROOT_ID)
    if (reelRoot != null) {
      return true;
    }

    return false;
  }
}