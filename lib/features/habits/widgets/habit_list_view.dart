import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/theme/app_theme.dart';
import '../../../providers/habit_providers.dart';
import 'habit_card.dart';

/// "ACTIVE HABITS" section. Lays cards out in a plain column so it can sit
/// inside the home screen's scroll view without nested scrolling.
class HabitListView extends ConsumerWidget {
  const HabitListView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habits = ref.watch(habitsControllerProvider);

    // Keep the current cards while a mutation reloads the list, so the page
    // doesn't jump and each card keeps its animation state.
    return habits.when(
      skipLoadingOnReload: true,
      data: (habits) {
        final now = DateTime.now();
        // Habits due today first; List.sort is not stable, so partition.
        final list = [
          ...habits.where((h) => h.isDueOn(now)),
          ...habits.where((h) => !h.isDueOn(now)),
        ];
        final inProgress = list
            .where((h) => h.isDueOn(now) && !h.isCompleted)
            .length;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    context.l10n.gridHabitsTitle,
                    style: AppTextStyles.headlineSm.copyWith(
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                Text(
                  context.l10n.gridHabitsInProgress(inProgress),
                  style: AppTextStyles.labelSm.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (list.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Text(
                  context.l10n.gridHabitsEmpty,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodySm,
                ),
              ),
            for (final habit in list) ...[
              // Keyed by id so each card keeps its animation state when the
              // list refreshes after a mutation.
              HabitCard(key: ValueKey(habit.id), habit: habit),
              const SizedBox(height: 6),
            ],
          ],
        );
      },
      loading: () => const Padding(
        padding: EdgeInsets.all(24),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Text(
        context.l10n.gridHabitsLoadError('$e'),
        style: AppTextStyles.bodySm.copyWith(color: AppColors.error),
      ),
    );
  }
}
