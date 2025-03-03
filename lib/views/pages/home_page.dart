import 'package:sankalp/views/widgets/doom_scroll_toggle_widget.dart';
import 'package:flutter/material.dart';
import 'package:sankalp/data/notifiers.dart';
import 'package:sankalp/views/shared_preference_helper.dart';
import 'package:sankalp/views/widgets/global_start_stop_button_widget.dart';
import 'package:url_launcher/url_launcher.dart';

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
    ["X (Twitter) Videos", "xVideosBlockerNotifier", "assets/images/x.png"],
  ];
  final githubUrl = "https://github.com/ABHILESH1412/sankalp";

  Future<void> _launchGitHub() async {
    final Uri url = Uri.parse(githubUrl);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $githubUrl';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Sankalp',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
        ),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // leading: const Icon(Icons.light),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: InkWell(
              onTap: _launchGitHub,
              child: Image.asset(
                'assets/images/github.png', // Replace with your GitHub logo image
                width: 30, // Adjust size
                height: 30,
              ),
            ),
          ),
          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text(
                          "Close",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 20),
                        ),
                      ),
                    ],
                    title: const Text(
                      "Usage Notes",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
                    ),
                    contentPadding: const EdgeInsets.all(25),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("1) This app will not automatically start on restart of the phone.", style: TextStyle(fontSize: 18),),
                        SizedBox(height: 10,),
                        Text("2) The app automatically detects videos playing on the home feed of X (twitter), Linkedin, Instagram and mutes them for a seamless, distraction-free experience.", style: TextStyle(fontSize: 18),),
                      ],
                    )),
              );
            },
            icon: Icon(Icons.info),
          ),
          ValueListenableBuilder(
            valueListenable: darkModeNotifier,
            builder: (context, darkMode, child) {
              return IconButton(
                onPressed: () {
                  SharedPrefsHelper()
                      .setBool('darkModeNotifier', !darkModeNotifier.value);
                  darkModeNotifier.value = !darkModeNotifier.value;
                },
                icon: darkMode ? Icon(Icons.light_mode) : Icon(Icons.dark_mode),
              );
            },
          ),
        ],
        toolbarHeight: 70,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: _widgetInfo.length + 1,
                itemBuilder: (context, index) {
                  if (index == _widgetInfo.length) {
                    return SizedBox(
                      height: 120,
                    );
                  }
                  return DoomScrollToggleWidget(
                    title: _widgetInfo[index][0],
                    spKey: _widgetInfo[index][1],
                    iconPath: _widgetInfo[index][2],
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: GlobalStartStopButtonWidget(),
    );
  }
}
