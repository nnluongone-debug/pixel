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
import '../../../providers/sound_providers.dart';
import '../../../services/sound/sound_slot.dart';
import '../focus_timer_controller.dart';
import '../habit_display_format.dart';
import '../../habit_detail/habit_detail_screen.dart';
import 'habit_card_parts.dart';
import 'habit_action_button.dart';

/// One active habit; tapping the card opens its detail page, the button runs
/// [HabitActionButton]. Hitting the daily target — from a tap or the running
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
    // Warm the sound engine so the first tap and level-up are not silent.
    SoundFx.warmUp(context);
    _events = ref
        .read(progressEventsProvider)
        .stream
        .where((u) => u.habit.id == habit.id && u.placedCheckIn != null)
        .listen(_onTargetReached);
  }

  void _onTargetReached(ProgressUpdate update) {
    if (!mounted) return;
    HapticFeedback.heavyImpact();
    SoundFx.play(context, SoundSlot.complete);
    setState(() => _lastXp = update.xpGained);
    _celebrate.forward(from: 0);
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

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => HabitDetailScreen.open(Navigator.of(context), habit.id),
      child: AnimatedBuilder(
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
            HabitActionButton(habit: habit),
          ],
        ),
      ),
    );
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
