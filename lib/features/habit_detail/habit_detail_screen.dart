import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/l10n.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/habit_icons.dart';
import '../../data/models/habit.dart';
import '../../providers/habit_providers.dart';
import '../habits/focus_timer_controller.dart';
import '../habits/habit_display_format.dart';
import '../habits/widgets/habit_action_button.dart';
import '../habits/widgets/habit_card_parts.dart';
import 'habit_recent_days_strip.dart';

/// One habit up close: icon, name, today's progress and its action button.
/// Opened from a home card or a tapped reminder.
class HabitDetailScreen extends ConsumerWidget {
  const HabitDetailScreen({super.key, required this.habitId});

  final String habitId;

  static const routeName = 'habit-detail';

  static Future<void> open(NavigatorState navigator, String habitId) =>
      navigator.push(
        MaterialPageRoute<void>(
          settings: RouteSettings(name: routeName, arguments: habitId),
          builder: (_) => HabitDetailScreen(habitId: habitId),
        ),
      );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habits = ref.watch(habitsControllerProvider);
    final habit = habits.value?.where((h) => h.id == habitId).firstOrNull;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          tooltip: MaterialLocalizations.of(context).backButtonTooltip,
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: SafeArea(
        child: switch ((habit, habits.isLoading && !habits.hasValue)) {
          (_, true) => const Center(child: CircularProgressIndicator()),
          (final Habit h, _) => _DetailBody(habit: h),
          _ => Center(
            child: Text(
              context.l10n.detailNotFound,
              style: AppTextStyles.bodyMd,
            ),
          ),
        },
      ),
    );
  }
}

class _DetailBody extends ConsumerWidget {
  const _DetailBody({required this.habit});

  final Habit habit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final color = AppColors.fromHex(habit.colorHex);
    final streak = habit.type == HabitType.checklist
        ? ref.watch(habitStreakProvider(habit.id)).value ?? 0
        : 0;
    final focus = ref.watch(
      focusTimerProvider.select((s) => s?.habitId == habit.id ? s : null),
    );
    final ratio = habit.completionRatio;
    final status = habit.isDueOn(DateTime.now())
        ? HabitDisplay.badge(
            l10n,
            habit,
            streak: streak,
            focusElapsed: focus?.elapsed,
          )
        : l10n.gridHabitRestDay;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
      child: Column(
        children: [
          const Spacer(),
          HabitIconBox(
            icon: HabitIcons.of(habit.iconName),
            color: color,
            size: 96,
          ),
          const SizedBox(height: 20),
          Text(
            habit.name,
            textAlign: TextAlign.center,
            style: AppTextStyles.headlineLg,
          ),
          const SizedBox(height: 28),
          Row(
            children: [
              Expanded(
                child: Text(
                  status,
                  style: AppTextStyles.labelMd.copyWith(color: color),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                '${(ratio * 100).floor()}%',
                style: AppTextStyles.labelMd.copyWith(color: color),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: TweenAnimationBuilder<double>(
              tween: Tween(end: ratio),
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOutCubic,
              builder: (_, value, _) => LinearProgressIndicator(
                value: value,
                minHeight: 14,
                backgroundColor: AppColors.cellEmpty,
                color: color,
              ),
            ),
          ),
          const SizedBox(height: 24),
          HabitRecentDaysStrip(habit: habit),
          const Spacer(),
          HabitActionButton(habit: habit, size: 96),
          const Spacer(),
        ],
      ),
    );
  }
}
