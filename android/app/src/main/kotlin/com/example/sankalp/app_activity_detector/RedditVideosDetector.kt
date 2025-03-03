package com.example.sankalp.app_activity_detector

import android.view.accessibility.AccessibilityNodeInfo
import android.util.Log

class RedditVideosDetector : PlatformDetector {

    companion object {
        private const val VIDEO_VIEW_ID = "com.reddit.frontpage:id/reddit_video_view"
        private const val POST_UNIT_ID = "com.reddit.frontpage:id/post_unit"
        private const val FEED_LAZY_COLUMN_ID = "com.reddit.frontpage:id/feed_lazy_column"
    }
    override fun isPlatformDetected(rootNode: AccessibilityNodeInfo): Boolean {
        val videoView = findNodeByIdRecursive(rootNode, VIDEO_VIEW_ID)
          Log.d("RedditVideosDetector", "videoView: $videoView")

        if (videoView == null) {
            return false // No video view found.
        }

        // Check if video is inside a post_unit on the homepage.
        if (isNodeWithinPostUnit(videoView)) {
              Log.d("RedditVideosDetector", "Video found within post_unit.  Homepage, not full-screen.")
            return false
        }
        Log.d("RedditVideosDetector", "Full-screen video detected.")

        return true // It's a full-screen video.
    }
    private fun isNodeWithinPostUnit(node: AccessibilityNodeInfo): Boolean {
      var currentNode: AccessibilityNodeInfo? = node
      while (currentNode != null) {
          if (currentNode.viewIdResourceName == POST_UNIT_ID) {
              //Check if post unit is inside feed_lazy_column.
              var postUnitNode: AccessibilityNodeInfo? = currentNode;
              while(postUnitNode != null){
                if(postUnitNode.viewIdResourceName == FEED_LAZY_COLUMN_ID){
                  return true; // Found post_unit inside feed_lazy_column.
                }
                postUnitNode = postUnitNode.parent;
              }
          }
          currentNode = currentNode.parent
      }
      return false
    }

    private fun findNodeByIdRecursive(rootNode: AccessibilityNodeInfo?, viewId: String): AccessibilityNodeInfo? {
        rootNode ?: return null // Kotlin's safe call and elvis operator

        if (rootNode.viewIdResourceName == viewId) {
            return rootNode
        }

        for (i in 0 until rootNode.childCount) {
            val child = rootNode.getChild(i)
            val foundNode = findNodeByIdRecursive(child, viewId)
            if (foundNode != null) {
                return foundNode
            }
        }

        return null
    }
}