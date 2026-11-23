import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/l10n.dart';
import '../../domain/cosmetics/theme_catalog.dart';
import '../../providers/celebration_providers.dart';
import '../../providers/cosmetics_providers.dart';
import '../../providers/growth_providers.dart';
import '../../providers/locale_providers.dart';
import '../../providers/new_unlocks_provider.dart';
import 'cosmetic_unlock_dialog.dart';
import 'locker_equip.dart';

/// Pops "NEW THEME!" once per item when a level-up
/// unlocks it. Seen ids are stored; the first evaluation records what is
/// already unlocked silently, and default items never celebrate.
class CosmeticUnlockListener extends ConsumerStatefulWidget {
  const CosmeticUnlockListener({super.key, required this.child});

  static const seenKey = 'seen_cosmetics';

  final Widget child;

  @override
  ConsumerState<CosmeticUnlockListener> createState() => _ListenerState();
}

class _ListenerState extends ConsumerState<CosmeticUnlockListener> {
  bool _showing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _check());
  }

  Future<void> _check() async {
    if (_showing || !mounted) return;
    // Until stats load everything but defaults looks locked: wait.
    if (ref.read(playerProgressProvider) == null) return;
    final prefs = ref.read(sharedPreferencesProvider);
    final unlocked = ref.read(unlockedThemesProvider);
    final items = [
      for (final item in ThemeCatalog.all)
        if (!item.unlock.isFree && unlocked.contains(item.id)) item,
    ];
    final stored = prefs.getStringList(CosmeticUnlockListener.seenKey);
    if (stored == null) {
      await prefs.setStringList(CosmeticUnlockListener.seenKey, [
        for (final i in items) i.id.name,
      ]);
      return;
    }
    final seen = stored.toSet();
    final fresh = items.where((i) => !seen.contains(i.id.name)).toList();
    if (fresh.isEmpty) return;
    // Claimed before any await, so an overlapping check can't celebrate
    // the same unlock twice.
    _showing = true;
    try {
      await ref.read(newUnlocksProvider.notifier).add(UnlockKind.theme, [
        for (final i in fresh) i.id.name,
      ]);
      if (!ref.read(lastLocalProgressProvider.notifier).isRecent) {
        // Arrived by sync / reinstall / demo, not earned just now: no popups,
        // only the NEW markers and a short toast.
        await prefs.setStringList(CosmeticUnlockListener.seenKey, [
          ...seen,
          for (final i in fresh) i.id.name,
        ]);
        if (mounted) {
          ScaffoldMessenger.maybeOf(context)?.showSnackBar(
            SnackBar(
              content: Text(context.l10n.unlockToastThemes(fresh.length)),
            ),
          );
        }
        return;
      }
      final queue = ref.read(celebrationQueueProvider);
      final analytics = ref.read(usageAnalyticsProvider);
      final reviews = ref.read(reviewPrompterProvider);
      for (final item in fresh) {
        seen.add(item.id.name);
        await prefs.setStringList(
          CosmeticUnlockListener.seenKey,
          seen.toList(),
        );
        unawaited(analytics.themeUnlocked(item.id.name));
        if (!mounted) return;
        final equip = await queue.run(
          () => CosmeticUnlockDialog.show(context, item),
        );
        if (!mounted) return;
        if (equip && mounted) await LockerEquip.equip(ref, item.id);
      }
      // A freshly earned theme is a happy moment: a good time to ask.
      await queue.run(() => reviews.maybeAsk(trigger: 'theme'));
    } finally {
      _showing = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(lastLocalProgressProvider); // start tracking from app start
    ref.listen(unlockedThemesProvider, (_, _) => _check());
    ref.listen(playerProgressProvider, (_, _) => _check());
    return widget.child;
  }
}
