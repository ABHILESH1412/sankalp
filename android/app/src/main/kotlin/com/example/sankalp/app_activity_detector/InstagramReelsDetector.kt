package com.example.sankalp.app_activity_detector

import android.view.accessibility.AccessibilityNodeInfo
import android.util.Log

class InstagramReelsDetector : PlatformDetector {
  companion object {
    private const val REEL_FRAGMENT_ROOT_ID = "com.instagram.android:id/clips_viewer_view_pager";
    private const val HOME_PAGE_VIDEO_CONTAINER = "com.instagram.android:id/video_container";
  }

  override fun isPlatformDetected(rootNode: AccessibilityNodeInfo): Boolean {
    // Checking if the the home feed have have any video or not, if there is a video then we make sure that it is muted.
    val isUnMute = findNodeByIdAndContentDescription(rootNode, HOME_PAGE_VIDEO_CONTAINER, "turn sound off");
    if(isUnMute != null){
      isUnMute.parent.performAction(AccessibilityNodeInfo.ACTION_CLICK)
    }

    // Checking if the user is on the reel page.
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

  private fun findNodeByIdAndContentDescription(
    rootNode: AccessibilityNodeInfo,
    viewId: String,
    contentDescription: String
  ): AccessibilityNodeInfo? {
    val parentNode = findNodeById(rootNode, viewId) ?: return null
    Log.w("instagramdetector: ", "video container found.");

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
        child.recycle() // Recycle the child after searching it
      }
      return null
    }


    val result =  searchInChildren(parentNode)
      parentNode.recycle() //recycle parent node here is important
    return result
  }
}