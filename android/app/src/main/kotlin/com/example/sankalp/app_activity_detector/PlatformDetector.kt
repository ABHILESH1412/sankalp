package com.example.sankalp.app_activity_detector

import android.view.accessibility.AccessibilityNodeInfo

interface PlatformDetector {
  fun isPlatformDetected(rootNode: AccessibilityNodeInfo): Boolean
}