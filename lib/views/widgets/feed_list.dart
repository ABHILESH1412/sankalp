import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sankalp/data/feeds.dart';

/// One card listing every feed with an on/off switch.
class FeedList extends StatelessWidget {
  const FeedList({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Set<String>>(
      valueListenable: blockedFeedsNotifier,
      builder: (context, blocked, _) => Card(
        child: Column(
          children: [
            for (var i = 0; i < feeds.length; i++) ...[
              if (i > 0) const Divider(indent: 72),
              _FeedTile(feed: feeds[i], blocked: blocked.contains(feeds[i].key)),
            ],
          ],
        ),
      ),
    );
  }
}

class _FeedTile extends StatelessWidget {
  const _FeedTile({required this.feed, required this.blocked});
  final Feed feed;
  final bool blocked;

  void _toggle(bool value) {
    HapticFeedback.selectionClick();
    setFeedBlocked(feed.key, value);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return ListTile(
      onTap: () => _toggle(!blocked),
      leading: Container(
        width: 40,
        height: 40,
        padding: const EdgeInsets.all(7),
        decoration: BoxDecoration(
          // Light tile so dark glyphs (X, TikTok) stay visible in dark mode.
          color: const Color(0xFFF4F4F4),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: scheme.outlineVariant, width: 0.5),
        ),
        child: Image.asset(feed.icon, fit: BoxFit.contain),
      ),
      title: Text(feed.title,
          style: theme.textTheme.titleMedium
              ?.copyWith(fontWeight: FontWeight.w500)),
      subtitle: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        layoutBuilder: (current, previous) => Stack(
          alignment: Alignment.centerLeft,
          children: [...previous, if (current != null) current],
        ),
        child: Text(
          blocked ? 'Blocked' : 'Allowed',
          key: ValueKey(blocked),
          style: theme.textTheme.bodySmall?.copyWith(
            color: blocked ? scheme.primary : scheme.onSurfaceVariant,
          ),
        ),
      ),
      trailing: Switch(
        value: blocked,
        onChanged: _toggle,
        thumbIcon: WidgetStateProperty.resolveWith(
          (states) => Icon(
            states.contains(WidgetState.selected) ? Icons.check : Icons.close,
          ),
        ),
      ),
    );
  }
}
