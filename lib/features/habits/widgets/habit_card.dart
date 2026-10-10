import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/habit_icons.dart';
import '../../../data/models/habit.dart';
import '../../../data/models/progress_update.dart';
import '../../../providers/habit_providers.dart';
import '../focus_timer_controller.dart';
import '../habit_display_format.dart';
import 'habit_card_parts.dart';
import 'neon_action_button.dart';

/// One active habit. The action depends on the type:
/// counter `+1` (long-press undoes one), checklist `✓` toggle, timer `▶`/`❚❚`
/// focus session. Hitting the daily target — from a tap or the running
/// timer — fires a heavy haptic, a card jolt with glow flash and a floating
/// "+XP"; the repository awards the XP and the matrix drops the brick.
class HabitCard extends ConsumerStatefulWidget {
  const HabitCard({super.key, required this.habit});

  final Habit habit;

  @override
  ConsumerState<HabitCard> createState() => _HabitCardState();
}

class _HabitCardState extends ConsumerState<HabitCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _celebrate = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );
  StreamSubscription<ProgressUpdate>? _events;
  int _lastXp = 0;

  Habit get habit => widget.habit;

  @override
  void initState() {
    super.initState();
    _events = ref
        .read(progressEventsProvider)
        .stream
        .where((u) => u.habit.id == habit.id && u.placedCheckIn != null)
        .listen(_onTargetReached);
  }

  void _onTargetReached(ProgressUpdate update) {
    if (!mounted) return;
    HapticFeedback.heavyImpact();
    setState(() => _lastXp = update.xpGained);
    _celebrate.forward(from: 0);
  }

  Future<void> _run(Future<Object?> Function() action) async {
    try {
      await action();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.gridUpdateFailed(habit.name, '$e')),
        ),
      );
    }
  }

  void _onAction({required bool focusRunning}) {
    final habits = ref.read(habitsControllerProvider.notifier);
    final timer = ref.read(focusTimerProvider.notifier);
    _run(switch (habit.type) {
      HabitType.counter => () => habits.increment(habit.id),
      HabitType.checklist => () => habits.setCompleted(
        habit.id,
        completed: !habit.isCompleted,
      ),
      HabitType.timer =>
        focusRunning ? timer.stop : () => timer.start(habit.id),
    });
  }

  void _onUndo() {
    _run(
      () => ref
          .read(habitsControllerProvider.notifier)
          .increment(habit.id, amount: -1),
    );
  }

  @override
  void dispose() {
    _events?.cancel();
    _celebrate.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = AppColors.fromHex(habit.colorHex);
    final isRestDay = !habit.isDueOn(DateTime.now());
    final streak = habit.type == HabitType.checklist
        ? ref.watch(habitStreakProvider(habit.id)).value ?? 0
        : 0;
    final focus = ref.watch(
      focusTimerProvider.select((s) => s?.habitId == habit.id ? s : null),
    );

    return AnimatedBuilder(
      animation: _celebrate,
      builder: (context, child) {
        final t = _celebrate.value;
        final flash = _celebrate.isAnimating ? 1 - t : 0.0;
        final jolt = -7 * sin(pi * t * 3) * (1 - t);
        return Transform.translate(
          offset: Offset(0, _celebrate.isAnimating ? jolt : 0),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLow,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: Color.lerp(
                      habit.isCompleted
                          ? color.withValues(alpha: 0.35)
                          : AppColors.outlineVariant.withValues(alpha: 0.4),
                      color,
                      flash,
                    )!,
                  ),
                  boxShadow: flash > 0
                      ? [
                          BoxShadow(
                            color: color.withValues(alpha: 0.45 * flash),
                            blurRadius: 24,
                          ),
                        ]
                      : null,
                ),
                child: child,
              ),
              if (_celebrate.isAnimating) _xpFloat(t),
            ],
          ),
        );
      },
      child: Row(
        children: [
          HabitIconBox(icon: HabitIcons.of(habit.iconName), color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      habit.name,
                      style: AppTextStyles.headlineSm.copyWith(fontSize: 16),
                    ),
                    HabitBadge(
                      text: isRestDay
                          ? context.l10n.gridHabitRestDay
                          : HabitDisplay.badge(
                              context.l10n,
                              habit,
                              streak: streak,
                              focusElapsed: focus?.elapsed,
                            ),
                      color: color,
                      muted: isRestDay,
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                MiniPixelBar(
                  segments: HabitDisplay.segmentCount(habit),
                  filled: HabitDisplay.filledSegments(habit, streak: streak),
                  color: color,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          NeonActionButton(
            color: color,
            active: habit.isCompleted || focus != null,
            muted: habit.type == HabitType.checklist && !habit.isCompleted,
            onTap: () => _onAction(focusRunning: focus != null),
            onLongPress: habit.type == HabitType.counter ? _onUndo : null,
            child: _actionContent(focusRunning: focus != null),
          ),
        ],
      ),
    );
  }

  Widget _actionContent({required bool focusRunning}) {
    return switch (habit.type) {
      HabitType.counter => const Text('+1'),
      HabitType.checklist => Icon(
        habit.isCompleted ? Icons.check_rounded : Icons.circle_outlined,
      ),
      HabitType.timer => Icon(
        focusRunning ? Icons.pause_rounded : Icons.play_arrow_rounded,
      ),
    };
  }

  /// "+25 XP" rising and fading above the action button.
  Widget _xpFloat(double t) {
    return Positioned(
      right: 8,
      top: -6 - 28 * Curves.easeOut.transform(t),
      child: Opacity(
        opacity: (1 - t).clamp(0.0, 1.0),
        child: XpFloatLabel(xp: _lastXp),
      ),
    );
  }
}
