import 'package:flutter/material.dart';
import 'package:sankalp/data/stats.dart';
import 'package:sankalp/theme.dart';
import 'package:sankalp/views/pages/settings_page.dart';
import 'package:sankalp/views/widgets/break_button.dart';
import 'package:sankalp/views/widgets/feed_list.dart';
import 'package:sankalp/views/widgets/logo.dart';
import 'package:sankalp/views/widgets/status_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    refreshStats();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // Blocks are counted natively while the user is in other apps.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) refreshStats();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: refreshStats,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            children: [
              Row(
                children: [
                  const SankalpLogo(size: 30),
                  const SizedBox(width: 10),
                  Text('Sankalp',
                      style: theme.textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w700)),
                  const Spacer(),
                  IconButton(
                    tooltip: 'Settings',
                    icon: const Icon(Icons.settings_outlined),
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const SettingsPage()),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const StatusCard(),
              const SectionLabel('Feeds to block'),
              const FeedList(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
          child: const BreakButton(),
        ),
      ),
    );
  }
}
