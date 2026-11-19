import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sankalp/views/accessibility_service_manager.dart';
import 'package:sankalp/views/widgets/logo.dart';

/// Shown until the accessibility service is switched on. The app checks again
/// every time the user comes back, so this page disappears by itself.
class SetupPage extends StatelessWidget {
  const SetupPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final manager = context.read<AccessibilityServiceManager>();
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 40, 20, 24),
          children: [
            const Center(child: SankalpLogo(size: 72)),
            const SizedBox(height: 24),
            Text('Set up Sankalp',
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineMedium
                    ?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text(
              'Sankalp uses Accessibility to spot short-video feeds and take '
              'you back out. It doesn\'t collect or send any of your data.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 32),
            _Step(
              number: 1,
              title: 'Allow restricted settings',
              body: 'Android 13 and newer only. In App info, tap the three-dot '
                  'menu (top right), then Allow restricted settings. Android '
                  'asks for this because Sankalp isn\'t from the Play Store.',
              action: OutlinedButton.icon(
                onPressed: manager.openAppInfo,
                icon: const Icon(Icons.open_in_new, size: 18),
                label: const Text('Open app info'),
              ),
            ),
            const SizedBox(height: 12),
            _Step(
              number: 2,
              title: 'Turn on Sankalp',
              body: 'In Accessibility, open Downloaded apps (or Installed '
                  'services), tap Sankalp, and switch it on.',
              action: FilledButton.icon(
                style: FilledButton.styleFrom(
                    minimumSize: const Size(0, 44)),
                onPressed: manager.openAccessibilitySettings,
                icon: const Icon(Icons.accessibility_new),
                label: const Text('Open Accessibility'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Step extends StatelessWidget {
  const _Step({
    required this.number,
    required this.title,
    required this.body,
    required this.action,
  });
  final int number;
  final String title;
  final String body;
  final Widget action;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: scheme.primaryContainer,
              foregroundColor: scheme.onPrimaryContainer,
              child: Text('$number',
                  style: const TextStyle(fontWeight: FontWeight.w700)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(body,
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(color: scheme.onSurfaceVariant)),
                  const SizedBox(height: 12),
                  action,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
