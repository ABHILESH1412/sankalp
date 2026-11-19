import 'package:flutter/foundation.dart';
import 'package:sankalp/views/shared_preference_helper.dart';

/// A short-video feed the user can block. [key] is the preference the native
/// accessibility service reads (MyAccessibilityService.kt), so never rename it.
class Feed {
  const Feed(this.title, this.app, this.key, this.icon);
  final String title;
  final String app;
  final String key;
  final String icon;
}

const feeds = <Feed>[
  Feed('YouTube Shorts', 'YouTube', 'youtubeShortsBlockerNotifier',
      'assets/images/youtube_shorts.png'),
  Feed('Instagram Reels', 'Instagram', 'instagramReelsBlockerNotifier',
      'assets/images/instagram_reels.png'),
  Feed('Snapchat Spotlight', 'Snapchat', 'snapchatSpotlightBlockerNotifier',
      'assets/images/snapchat.png'),
  Feed('Snapchat Stories', 'Snapchat', 'snapchatStoriesBlockerNotifier',
      'assets/images/snapchat.png'),
  Feed('TikTok', 'TikTok', 'tiktokVideosBlockerNotifier',
      'assets/images/tiktok.png'),
  Feed('LinkedIn videos', 'LinkedIn', 'linkedinVideosBlockerNotifier',
      'assets/images/linkedin.png'),
  Feed('X videos', 'X (Twitter)', 'xVideosBlockerNotifier',
      'assets/images/x.png'),
];

/// Keys of the feeds that are currently blocked.
final ValueNotifier<Set<String>> blockedFeedsNotifier = ValueNotifier({
  for (final feed in feeds)
    if (SharedPrefsHelper().getBool(feed.key) ?? false) feed.key,
});

Future<void> setFeedBlocked(String key, bool blocked) async {
  final next = {...blockedFeedsNotifier.value};
  blocked ? next.add(key) : next.remove(key);
  blockedFeedsNotifier.value = next;
  await SharedPrefsHelper().setBool(key, blocked);
}
