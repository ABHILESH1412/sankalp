import 'package:sankalp/views/widgets/doom_scroll_toggle_widget.dart';
import 'package:flutter/material.dart';
import 'package:sankalp/data/notifiers.dart';
import 'package:sankalp/views/shared_preference_helper.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});
  final List<List<String>> _widgetInfo = [
    [
      "Youtube Shorts",
      "youtubeShortsBlockerNotifier",
      "assets/images/youtube_shorts.png"
    ],
    [
      "Instagram Reels",
      "instagramReelsBlockerNotifier",
      "assets/images/instagram_reels.png"
    ],
    [
      "Snapchat Spotlight",
      "snapchatSpotlightBlockerNotifier",
      "assets/images/snapchat.png"
    ],
    [
      "Snapchat Stories",
      "snapchatStoriesBlockerNotifier",
      "assets/images/snapchat.png"
    ],
    ["TikTok", "tiktokVideosBlockerNotifier", "assets/images/tiktok.png"],
    [
      "Linkedin Videos",
      "linkedinVideosBlockerNotifier",
      "assets/images/linkedin.png"
    ],
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Main Content',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          leading: const Icon(Icons.light),
          actions: [
            ValueListenableBuilder(
              valueListenable: darkModeNotifier,
              builder: (context, darkMode, child) {
                return IconButton(
                  onPressed: () {
                    SharedPrefsHelper()
                        .setBool('darkModeNotifier', !darkModeNotifier.value);
                    darkModeNotifier.value = !darkModeNotifier.value;
                  },
                  icon:
                      darkMode ? Icon(Icons.light_mode) : Icon(Icons.dark_mode),
                );
              },
            )
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: _widgetInfo.length,
                itemBuilder: (context, index) {
                  return DoomScrollToggleWidget(
                    title: _widgetInfo[index][0],
                    spKey: _widgetInfo[index][1],
                    iconPath: _widgetInfo[index][2],
                  );
                },
              ),
            ),
          ],
        ));
  }
}
