import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pixel_quest/data/models/habit.dart';
import 'package:pixel_quest/data/models/progress_update.dart';
import 'package:pixel_quest/data/models/user_stats.dart';
import 'package:pixel_quest/providers/habit_providers.dart';

/// Simulates the player logging progress on this device, which is what
/// allows unlock popups (sync/demo unlocks stay silent).
void emitLocalProgress(ProviderContainer container) {
  container
      .read(progressEventsProvider)
      .add(
        ProgressUpdate(
          habit: Habit(
            id: 'local',
            name: 'Local',
            type: HabitType.checklist,
            target: 1,
            currentProgress: 1,
            colorHex: '#2DE38E',
            iconName: 'target',
            createdAt: DateTime(2026),
          ),
          stats: UserStats.initial,
          previousLevel: 1,
        ),
      );
}
