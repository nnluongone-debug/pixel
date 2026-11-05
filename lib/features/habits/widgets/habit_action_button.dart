import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/habit.dart';
import '../../../providers/habit_providers.dart';
import '../../../services/sound/sound_slot.dart';
import '../focus_timer_controller.dart';
import 'neon_action_button.dart';

/// The habit's main action, shared by the home card and the detail page:
/// counter `+1` (long-press undoes one), checklist `✓` toggle, timer
/// `▶`/`❚❚` focus session.
class HabitActionButton extends ConsumerWidget {
  const HabitActionButton({super.key, required this.habit, this.size = 40});

  final Habit habit;
  final double size;

  Future<void> _run(
    BuildContext context,
    Future<Object?> Function() action,
  ) async {
    try {
      await action();
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.gridUpdateFailed(habit.name, '$e')),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final running = ref.watch(
      focusTimerProvider.select((s) => s?.habitId == habit.id),
    );
    final habits = ref.read(habitsControllerProvider.notifier);
    final timer = ref.read(focusTimerProvider.notifier);
    return NeonActionButton(
      size: size,
      color: AppColors.fromHex(habit.colorHex),
      active: habit.isCompleted || running,
      muted: habit.type == HabitType.checklist && !habit.isCompleted,
      sound: switch (habit.type) {
        HabitType.counter => SoundSlot.increment,
        HabitType.checklist => SoundSlot.tap,
        HabitType.timer => running ? SoundSlot.focusStop : SoundSlot.focusStart,
      },
      onTap: () => _run(context, switch (habit.type) {
        HabitType.counter => () => habits.increment(habit.id),
        HabitType.checklist => () => habits.setCompleted(
          habit.id,
          completed: !habit.isCompleted,
        ),
        HabitType.timer => running ? timer.stop : () => timer.start(habit.id),
      }),
      onLongPress: habit.type == HabitType.counter
          ? () => _run(context, () => habits.increment(habit.id, amount: -1))
          : null,
      child: switch (habit.type) {
        HabitType.counter => const Text('+1'),
        HabitType.checklist => Icon(
          habit.isCompleted ? Icons.check_rounded : Icons.circle_outlined,
        ),
        HabitType.timer => Icon(
          running ? Icons.pause_rounded : Icons.play_arrow_rounded,
        ),
      },
    );
  }
}
