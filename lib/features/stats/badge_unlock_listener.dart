import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/analytics/pixel_badge.dart';
import '../../providers/analytics_providers.dart';
import '../../providers/locale_providers.dart';
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
    _showing = true;
    try {
      for (final badge in fresh) {
        seen.add(badge.id.name);
        await prefs.setStringList(BadgeUnlockListener.seenKey, seen.toList());
        if (!mounted) return;
        await BadgeUnlockDialog.show(context, badge);
      }
    } finally {
      _showing = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(badgesProvider, (_, next) => _check(next));
    return widget.child;
  }
}
