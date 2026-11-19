import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sankalp/data/break_controller.dart';
import 'package:sankalp/data/feeds.dart';
import 'package:sankalp/data/notifiers.dart';
import 'package:sankalp/data/stats.dart';

/// Hero card at the top of the home screen: protection status, break
/// countdown, and today's stats.
class StatusCard extends StatefulWidget {
  const StatusCard({super.key});

  @override
  State<StatusCard> createState() => _StatusCardState();
}

class _StatusCardState extends State<StatusCard> {
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    breakEndNotifier.addListener(_onChanged);
    blockedFeedsNotifier.addListener(_onChanged);
    statsNotifier.addListener(_onChanged);
    _syncTicker();
  }

  @override
  void dispose() {
    breakEndNotifier.removeListener(_onChanged);
    blockedFeedsNotifier.removeListener(_onChanged);
    statsNotifier.removeListener(_onChanged);
    _ticker?.cancel();
    super.dispose();
  }

  void _onChanged() {
    _syncTicker();
    if (mounted) setState(() {});
  }

  void _syncTicker() {
    final onBreak = breakEndNotifier.value != null;
    if (onBreak && _ticker == null) {
      _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
    } else if (!onBreak) {
      _ticker?.cancel();
      _ticker = null;
    }
  }

  void _tick() {
    final end = breakEndNotifier.value;
    if (end != null && !end.isAfter(DateTime.now())) {
      // Break over; the native blocker checks the stored end time itself.
      breakEndNotifier.value = null;
      return;
    }
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final breakEnd = breakEndNotifier.value;
    final blocked = blockedFeedsNotifier.value.length;
    final stats = statsNotifier.value;

    final Color bg;
    final Color fg;
    final IconData icon;
    final String title;
    final String subtitle;
    if (breakEnd != null) {
      bg = scheme.tertiaryContainer;
      fg = scheme.onTertiaryContainer;
      icon = Icons.coffee_outlined;
      title = 'On a break';
      subtitle =
          'Blocking resumes at ${DateFormat.jm().format(breakEnd)}';
    } else if (blocked == 0) {
      bg = scheme.surfaceContainerHighest;
      fg = scheme.onSurface;
      icon = Icons.shield_outlined;
      title = 'Nothing blocked yet';
      subtitle = 'Turn on a feed below to start';
    } else {
      bg = scheme.primaryContainer;
      fg = scheme.onPrimaryContainer;
      icon = Icons.verified_user_outlined;
      title = 'Protection on';
      subtitle = 'Blocking $blocked of ${feeds.length} feeds';
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(28),
      ),
      child: DefaultTextStyle.merge(
        style: TextStyle(color: fg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: fg.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: fg),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: theme.textTheme.titleLarge?.copyWith(
                              color: fg, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 2),
                      Text(subtitle,
                          style: theme.textTheme.bodyMedium
                              ?.copyWith(color: fg.withValues(alpha: 0.8))),
                    ],
                  ),
                ),
              ],
            ),
            if (breakEnd != null) ...[
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    formatCountdown(breakEnd.difference(DateTime.now())),
                    style: theme.textTheme.displaySmall?.copyWith(
                      color: fg,
                      fontWeight: FontWeight.w600,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: BreakController.end,
                    style: TextButton.styleFrom(foregroundColor: fg),
                    child: const Text('End break'),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _Stat(
                    value: NumberFormat.decimalPattern()
                        .format(stats.blockedToday),
                    label: 'blocked today',
                    color: fg,
                  ),
                ),
                Container(
                    width: 1, height: 36, color: fg.withValues(alpha: 0.2)),
                const SizedBox(width: 16),
                Expanded(
                  child: _Stat(
                    value: stats.breakFreeDays == 1
                        ? '1 day'
                        : '${stats.breakFreeDays} days',
                    label: 'without a break',
                    color: fg,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label, required this.color});
  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value,
            style: theme.textTheme.headlineSmall
                ?.copyWith(color: color, fontWeight: FontWeight.w700)),
        Text(label,
            style: theme.textTheme.bodySmall
                ?.copyWith(color: color.withValues(alpha: 0.8))),
      ],
    );
  }
}

/// "04:09", or "1:02:03" for breaks longer than an hour.
String formatCountdown(Duration remaining) {
  if (remaining.isNegative) remaining = Duration.zero;
  String two(int n) => n.toString().padLeft(2, '0');
  final h = remaining.inHours;
  final m = remaining.inMinutes % 60;
  final s = remaining.inSeconds % 60;
  return h > 0 ? '$h:${two(m)}:${two(s)}' : '${two(m)}:${two(s)}';
}
