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
  final issuesUrl =
      "https://docs.google.com/forms/d/e/1FAIpQLScvWRgABpLPKN50RcnjE78CuPq66ML7XKiLMzHjm2EgvGv_2Q/viewform?usp=dialog";
  final featureUrl =
      "https://docs.google.com/forms/d/e/1FAIpQLSdOcPQ9CQfu9INH4e8gYyoupSTb3AvA3p6f4wTKIlMjQmA0Bg/viewform?usp=dialog";

  Future<void> _launchGitHub() async {
    final Uri url = Uri.parse(githubUrl);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $githubUrl';
    }
  }

  Future<void> _reportAnIssue() async {
    final Uri url = Uri.parse(issuesUrl);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $issuesUrl';
    }
  }

  Future<void> _requestAFeature() async {
    final Uri url = Uri.parse(featureUrl);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $featureUrl';
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
        // toolbarHeight: 70,
      ),
      endDrawer: Drawer(
        child: ListView(
          children: [
            ListTile(
              title: const Text(
                textAlign: TextAlign.center,
                "Settings",
                style:
                    const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),
            ),
            Divider(
              thickness: 2,
            ),
            // Dark Mode and Light Mode
            ValueListenableBuilder(
              valueListenable: darkModeNotifier,
              builder: (context, darkMode, child) {
                return ListTile(
                  leading: darkMode
                      ? const Icon(Icons.dark_mode)
                      : const Icon(Icons.light_mode),
                  title: Text(
                    darkMode ? "Dark Mode" : "Light Mode",
                    style: const TextStyle(fontSize: 18),
                  ),
                  onTap: () {
                    SharedPrefsHelper()
                        .setBool('darkModeNotifier', !darkModeNotifier.value);
                    darkModeNotifier.value = !darkModeNotifier.value;
                  },
                  trailing: Switch(
                      value: darkMode,
                      onChanged: (value) {
                        SharedPrefsHelper().setBool(
                            'darkModeNotifier', !darkModeNotifier.value);
                        darkModeNotifier.value = !darkModeNotifier.value;
                      }),
                );
              },
            ),
            // App Info
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text(
                "App Info",
                style: TextStyle(fontSize: 18),
              ),
              onTap: () {
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
                        Text(
                          "The app automatically detects videos playing on the home feed of X (twitter), Linkedin, Instagram and mutes them for a seamless, distraction-free experience.",
                          style: TextStyle(fontSize: 18),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            // Report an Issue
            ListTile(
              leading: const Icon(Icons.bug_report_outlined),
              title: const Text(
                "Report an Issue",
                style: TextStyle(fontSize: 18),
              ),
              onTap: _reportAnIssue,
            ),
            // Request a Feature
            ListTile(
              leading: const Icon(Icons.star),
              title: const Text(
                "Request a Feature",
                style: TextStyle(fontSize: 18),
              ),
              onTap: _requestAFeature,
            ),
            // Github
            ListTile(
              leading: Image.asset(
                'assets/images/github.png', // Replace with your GitHub logo image
                width: 25, // Adjust size
                height: 25,
              ),
              title: Text(
                "Github",
                style: const TextStyle(fontSize: 18),
              ),
              onTap: _launchGitHub,
            ),
          ],
        ),
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
