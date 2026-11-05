import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/l10n.dart';
import '../../domain/analytics/pixel_badge.dart';
import '../../providers/analytics_providers.dart';
import '../../providers/celebration_providers.dart';
import '../../providers/locale_providers.dart';
import '../../providers/new_unlocks_provider.dart';
import 'widgets/badge_unlock_dialog.dart';

/// Pops a "NEW BADGE!" dialog the first time each badge unlocks, from any
/// tab. Seen badge ids are stored, so a badge celebrates only once; the very
/// first evaluation records what is already unlocked without popping, so
/// existing users aren't flooded after an update.
class BadgeUnlockListener extends ConsumerStatefulWidget {
  const BadgeUnlockListener({super.key, required this.child});

  static const seenKey = 'seen_badges';

  final Widget child;

  @override
  ConsumerState<BadgeUnlockListener> createState() =>
      _BadgeUnlockListenerState();
}

class _BadgeUnlockListenerState extends ConsumerState<BadgeUnlockListener> {
  bool _showing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _check(ref.read(badgesProvider)),
    );
  }

  Future<void> _check(List<BadgeStatus>? badges) async {
    if (badges == null || _showing || !mounted) return;
    final prefs = ref.read(sharedPreferencesProvider);
    final unlocked = [
      for (final b in badges)
        if (b.isUnlocked) b.definition,
    ];
    final stored = prefs.getStringList(BadgeUnlockListener.seenKey);
    if (stored == null) {
      await prefs.setStringList(BadgeUnlockListener.seenKey, [
        for (final d in unlocked) d.id.name,
      ]);
      return;
    }

    final seen = stored.toSet();
    final fresh = unlocked.where((d) => !seen.contains(d.id.name)).toList();
    if (fresh.isEmpty) return;
    // Claimed before any await, so an overlapping check can't celebrate
    // the same unlock twice.
    _showing = true;
    try {
      await ref.read(newUnlocksProvider.notifier).add(UnlockKind.badge, [
        for (final d in fresh) d.id.name,
      ]);
      if (!ref.read(lastLocalProgressProvider.notifier).isRecent) {
        // Arrived by sync / reinstall / demo, not earned just now: no popups,
        // only the NEW markers and a short toast.
        await prefs.setStringList(BadgeUnlockListener.seenKey, [
          ...seen,
          for (final d in fresh) d.id.name,
        ]);
        if (mounted) {
          ScaffoldMessenger.maybeOf(context)?.showSnackBar(
            SnackBar(
              content: Text(context.l10n.unlockToastBadges(fresh.length)),
            ),
          );
        }
        return;
      }
      final queue = ref.read(celebrationQueueProvider);
      for (final badge in fresh) {
        seen.add(badge.id.name);
        await prefs.setStringList(BadgeUnlockListener.seenKey, seen.toList());
        if (!mounted) return;
        await queue.run(() => BadgeUnlockDialog.show(context, badge));
      }
    } finally {
      _showing = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(lastLocalProgressProvider); // start tracking from app start
    ref.listen(badgesProvider, (_, next) => _check(next));
    return widget.child;
  }
}
