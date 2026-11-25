import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/l10n/l10n.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/date_key_utils.dart';
import '../../data/models/habit.dart';
import '../../data/repositories/habit_backfill_repository.dart';
import '../../providers/habit_providers.dart';
import '../../providers/repository_providers.dart';

/// Seven chips (oldest left, yesterday right) to log a habit for days the
/// user forgot. Tap marks a day done, tap again unmarks it.
class HabitRecentDaysStrip extends ConsumerStatefulWidget {
  const HabitRecentDaysStrip({super.key, required this.habit});

  final Habit habit;

  @override
  ConsumerState<HabitRecentDaysStrip> createState() => _StripState();
}

class _StripState extends ConsumerState<HabitRecentDaysStrip> {
  Habit get habit => widget.habit;

  /// Day keys whose toggle is in flight; their chips ignore taps.
  final Set<String> _busy = {};

  Future<bool> _confirmUnmark() async {
    final l10n = context.l10n;
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(l10n.detailUnmarkBonusTitle, style: AppTextStyles.labelLg),
        content: Text(l10n.detailUnmarkBonusBody, style: AppTextStyles.bodyMd),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.commonCancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: Text(l10n.detailUnmarkBonusConfirm),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  Future<void> _toggle(String key, bool done) async {
    if (!_busy.add(key)) return;
    setState(() {});
    final messenger = ScaffoldMessenger.of(context);
    final failed = context.l10n.detailBackfillFailed;
    try {
      if (done &&
          await ref
              .read(habitBackfillRepositoryProvider)
              .hasBonusXp(habit.id, key) &&
          !(mounted && await _confirmUnmark())) {
        return;
      }
      HapticFeedback.lightImpact();
      await ref
          .read(habitsControllerProvider.notifier)
          .setPastDay(habit.id, key, done: !done);
    } catch (_) {
      messenger.showSnackBar(SnackBar(content: Text(failed)));
    } finally {
      _busy.remove(key);
      if (mounted) setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final color = AppColors.fromHex(habit.colorHex);
    final today = ref.watch(currentDayProvider);
    final doneKeys = ref.watch(habitRecentDaysProvider(habit.id)).value ?? {};
    final locale = Localizations.localeOf(context).toString();
    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            l10n.detailRecentDaysTitle,
            style: AppTextStyles.labelMd.copyWith(color: color),
          ),
        ),
        const SizedBox(height: 2),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(l10n.detailRecentDaysHint, style: AppTextStyles.bodySm),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            for (final key in HabitBackfillRepository.windowKeys(today))
              _DayChip(
                date: DateKeys.toDate(key),
                weekday: DateFormat.E(locale).format(DateKeys.toDate(key)),
                color: color,
                done: doneKeys.contains(key),
                due: habit.isDueOn(DateKeys.toDate(key)),
                enabled:
                    !_busy.contains(key) &&
                    HabitBackfillRepository.isEditable(habit, key, today),
                onTap: () => _toggle(key, doneKeys.contains(key)),
              ),
          ],
        ),
      ],
    );
  }
}

class _DayChip extends StatelessWidget {
  const _DayChip({
    required this.date,
    required this.weekday,
    required this.color,
    required this.done,
    required this.due,
    required this.enabled,
    required this.onTap,
  });

  final DateTime date;
  final String weekday;
  final Color color;
  final bool done;
  final bool due;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fg = done ? AppColors.background : color;
    return Flexible(
      child: Opacity(
        opacity: enabled ? (due || done ? 1 : 0.55) : 0.25,
        child: Semantics(
          button: true,
          enabled: enabled,
          selected: done,
          label: '$weekday ${date.day}',
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: enabled ? onTap : null,
            child: Container(
              constraints: const BoxConstraints(minWidth: 36, maxWidth: 44),
              height: 56,
              padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 6),
              decoration: BoxDecoration(
                color: done ? color : Colors.transparent,
                border: Border.all(color: color, width: 2),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FittedBox(
                    child: Text(
                      weekday,
                      style: AppTextStyles.labelSm.copyWith(color: fg),
                    ),
                  ),
                  Text(
                    '${date.day}',
                    style: AppTextStyles.labelMd.copyWith(color: fg),
                  ),
                  if (!due)
                    Container(width: 4, height: 4, color: fg)
                  else
                    const SizedBox(height: 4),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
