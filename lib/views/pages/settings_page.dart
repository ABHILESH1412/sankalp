import 'package:flutter/material.dart';
import 'package:sankalp/data/notifiers.dart';
import 'package:sankalp/theme.dart';
import 'package:sankalp/views/widgets/update_settings_tiles.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  static const _githubUrl = 'https://github.com/ABHILESH1412/sankalp';
  static const _issuesUrl =
      'https://docs.google.com/forms/d/e/1FAIpQLScvWRgABpLPKN50RcnjE78CuPq66ML7XKiLMzHjm2EgvGv_2Q/viewform?usp=dialog';
  static const _featureUrl =
      'https://docs.google.com/forms/d/e/1FAIpQLSdOcPQ9CQfu9INH4e8gYyoupSTb3AvA3p6f4wTKIlMjQmA0Bg/viewform?usp=dialog';

  Future<void> _openUrl(BuildContext context, String url) async {
    final messenger = ScaffoldMessenger.of(context);
    bool opened;
    try {
      opened =
          await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } catch (_) {
      opened = false;
    }
    if (!opened) {
      messenger.showSnackBar(
          const SnackBar(content: Text("Couldn't open the link")));
    }
  }

  void _showHowItWorks(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.info_outline),
        title: const Text('How it works'),
        content: const Text(
          'Sankalp uses Android Accessibility to notice when a short-video '
          'feed opens and takes you back out of it.\n\n'
          'Videos playing in the home feeds of Instagram, LinkedIn and X are '
          'muted automatically.\n\n'
          'Need a few minutes? Take a break from the home screen.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
        children: [
          const SectionLabel('Appearance'),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: ValueListenableBuilder<ThemeMode>(
                valueListenable: themeModeNotifier,
                builder: (context, mode, _) => SegmentedButton<ThemeMode>(
                  showSelectedIcon: false,
                  segments: const [
                    ButtonSegment(
                        value: ThemeMode.system,
                        icon: Icon(Icons.brightness_auto_outlined),
                        label: Text('System')),
                    ButtonSegment(
                        value: ThemeMode.light,
                        icon: Icon(Icons.light_mode_outlined),
                        label: Text('Light')),
                    ButtonSegment(
                        value: ThemeMode.dark,
                        icon: Icon(Icons.dark_mode_outlined),
                        label: Text('Dark')),
                  ],
                  selected: {mode},
                  onSelectionChanged: (s) => setThemeMode(s.first),
                ),
              ),
            ),
          ),
          const SectionLabel('Updates'),
          const Card(child: UpdateSettingsTiles()),
          const SectionLabel('About'),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: const Text('How it works'),
                  onTap: () => _showHowItWorks(context),
                ),
                const Divider(indent: 56),
                ListTile(
                  leading: const Icon(Icons.code),
                  title: const Text('Source code'),
                  subtitle: const Text('GitHub'),
                  trailing: const Icon(Icons.open_in_new, size: 18),
                  onTap: () => _openUrl(context, _githubUrl),
                ),
              ],
            ),
          ),
          const SectionLabel('Feedback'),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.bug_report_outlined),
                  title: const Text('Report an issue'),
                  trailing: const Icon(Icons.open_in_new, size: 18),
                  onTap: () => _openUrl(context, _issuesUrl),
                ),
                const Divider(indent: 56),
                ListTile(
                  leading: const Icon(Icons.lightbulb_outline),
                  title: const Text('Request a feature'),
                  trailing: const Icon(Icons.open_in_new, size: 18),
                  onTap: () => _openUrl(context, _featureUrl),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
