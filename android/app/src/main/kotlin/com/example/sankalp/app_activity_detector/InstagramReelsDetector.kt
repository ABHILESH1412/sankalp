package com.example.sankalp.app_activity_detector

import android.view.accessibility.AccessibilityNodeInfo

class InstagramReelsDetector : PlatformDetector {
  companion object {
    private const val REEL_FRAGMENT_ROOT_ID = "com.instagram.android:id/clips_viewer_view_pager";
    private const val HOME_PAGE_VIDEO_CONTAINER = "com.instagram.android:id/video_container";
  }

  override fun isPlatformDetected(rootNode: AccessibilityNodeInfo): Boolean {
    // Checking if the the home feed have have any video or not, if there is a video then we make sure that it is muted.
    val isUnMute = NodeUtils.findNodeByIdAndContentDescription(rootNode, HOME_PAGE_VIDEO_CONTAINER, "turn sound off");
    if(isUnMute != null){
      NodeUtils.clickParent(isUnMute)
    }

    // Checking if the user is on the reel page.
    val reelRoot = NodeUtils.findNodeById(rootNode, REEL_FRAGMENT_ROOT_ID)
    if (reelRoot != null) {
      return true;
    }

    return false;
  }
}