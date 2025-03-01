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
    val isUnMute = findNodeByIdAndContentDescription(rootNode, HOME_PAGE_VIDEO_MUTE_BUTTON_ID, CONT_DESC);
    if(isUnMute != null){
      isUnMute.parent.performAction(AccessibilityNodeInfo.ACTION_CLICK)
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

  private fun findNodeByIdAndContentDescription(
    rootNode: AccessibilityNodeInfo,
    viewId: String,
    contentDescription: String
  ): AccessibilityNodeInfo? {
    val parentNode = findNodeById(rootNode, viewId) ?: return null

    fun searchInChildren(node: AccessibilityNodeInfo): AccessibilityNodeInfo? {
      if (node.contentDescription?.toString()?.equals(contentDescription, ignoreCase = true) == true) {
        return node
      }

      for (i in 0 until node.childCount) {
        val child = node.getChild(i) ?: continue
        val foundNode = searchInChildren(child)
        if (foundNode != null) {
          // node.recycle() Don't recycle parent here
          return foundNode
        }
      }
      return null
    }


    val result =  searchInChildren(parentNode)
    return result
  }
}