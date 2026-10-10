import 'check_in.dart';
import 'habit.dart';
import 'user_stats.dart';

/// Outcome of changing a habit's progress, so the UI can play the right
/// feedback (block drop, XP pop, level-up banner).
class ProgressUpdate {
  const ProgressUpdate({
    required this.habit,
    required this.stats,
    required this.previousLevel,
    this.placedCheckIn,
    this.removedCheckIn = false,
  });

  final Habit habit;
  final UserStats stats;
  final int previousLevel;

  /// Block placed by this update (target just reached), if any.
  final CheckIn? placedCheckIn;

  /// True when progress dropped below target and today's block was removed.
  final bool removedCheckIn;

  int get xpGained => placedCheckIn?.xpEarned ?? 0;
  bool get leveledUp => stats.currentLevel > previousLevel;
}
