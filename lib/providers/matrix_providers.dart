import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/app_theme.dart';
import '../features/matrix/models/check_in_block.dart';
import '../features/matrix/widgets/matrix_layout.dart';
import 'habit_providers.dart';
import 'repository_providers.dart';

/// Bricks for the rolling 10-day pixel matrix, colored by their habit.
/// Rebuilds whenever habits change (every mutation refreshes the habit list).
final matrixBlocksProvider = FutureProvider<List<CheckInBlock>>((ref) async {
  final habits = await ref.watch(habitsControllerProvider.future);
  final calendar = MatrixCalendar(today: DateTime.now());
  final checkIns = await ref
      .watch(checkInRepositoryProvider)
      .getBetween(calendar.firstKey, calendar.lastKey);

  final colors = {for (final h in habits) h.id: AppColors.fromHex(h.colorHex)};
  return [
    for (final c in checkIns)
      if (colors[c.habitId] case final color?)
        CheckInBlock.fromCheckIn(c, color),
  ];
});
