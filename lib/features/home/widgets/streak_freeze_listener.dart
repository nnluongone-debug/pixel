import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/l10n/l10n_labels.dart';
import '../../../core/utils/date_key_utils.dart';
import '../../../providers/habit_providers.dart';
import '../../../providers/locale_providers.dart';

/// Shows "Streak freeze used on {weekday}. Streak saved!" once when a freeze
/// covered a recent day. Only freezes from the last two days count, so an
/// old one is not announced after a long absence, and the newest announced
/// day is stored so each freeze toasts once.
class StreakFreezeListener extends ConsumerWidget {
  const StreakFreezeListener({super.key, required this.child});

  static const seenKey = 'streak_freeze_seen_day';

  /// How many days back a frozen day is still worth announcing.
  static const _recentDays = 2;

  final Widget child;

  void _announce(BuildContext context, WidgetRef ref, Set<int> frozenDays) {
    if (frozenDays.isEmpty) return;
    final newest = frozenDays.reduce((a, b) => a > b ? a : b);
    final today = DateKeys.epochDay(DateTime.now());
    final prefs = ref.read(sharedPreferencesProvider);
    if (newest < today - _recentDays ||
        newest <= (prefs.getInt(seenKey) ?? -1)) {
      return;
    }
    // Stored first so a rebuild or a second listener can't repeat the toast.
    prefs.setInt(seenKey, newest).catchError((Object _) => false);
    final date = DateTime.fromMillisecondsSinceEpoch(
      newest * Duration.millisecondsPerDay,
      isUtc: true,
    );
    final l10n = context.l10n;
    ScaffoldMessenger.maybeOf(context)?.showSnackBar(
      SnackBar(
        content: Text(l10n.streakFreezeUsed(l10n.weekdayShort(date.weekday))),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(streakFreezeProvider, (_, next) {
      final state = next.value;
      if (state != null && state.streak > 0) {
        _announce(context, ref, state.frozenDays);
      }
    });
    return child;
  }
}
