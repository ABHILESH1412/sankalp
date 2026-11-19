package com.example.sankalp.app_activity_detector

import android.view.accessibility.AccessibilityNodeInfo

/** Shared helpers for walking another app's accessibility node tree safely. */
internal object NodeUtils {
  private const val MAX_DEPTH = 40

  fun findNodeById(rootNode: AccessibilityNodeInfo, viewId: String): AccessibilityNodeInfo? =
    rootNode.findAccessibilityNodeInfosByViewId(viewId)?.firstOrNull()

  /** Finds a node inside the view with [viewId] whose content description matches. */
  fun findNodeByIdAndContentDescription(
    rootNode: AccessibilityNodeInfo,
    viewId: String,
    contentDescription: String
  ): AccessibilityNodeInfo? {
    val parentNode = findNodeById(rootNode, viewId) ?: return null
    return searchByContentDescription(parentNode, contentDescription, 0)
  }

  private fun searchByContentDescription(
    node: AccessibilityNodeInfo,
    contentDescription: String,
    depth: Int
  ): AccessibilityNodeInfo? {
    if (node.contentDescription?.toString()?.equals(contentDescription, ignoreCase = true) == true) {
      return node
    }
    if (depth >= MAX_DEPTH) return null
    for (i in 0 until node.childCount) {
      val child = node.getChild(i) ?: continue
      searchByContentDescription(child, contentDescription, depth + 1)?.let { return it }
    }
    return null
  }

  /**
   * Clicks the parent of [node] (the mute toggle's clickable container). The parent
   * can be null while the other app is re-laying out its views; this used to crash.
   */
  fun clickParent(node: AccessibilityNodeInfo) {
    (node.parent ?: node).performAction(AccessibilityNodeInfo.ACTION_CLICK)
  }
}
