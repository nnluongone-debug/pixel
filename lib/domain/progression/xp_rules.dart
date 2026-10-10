import '../../data/models/user_stats.dart';

/// XP and level formulas. Levels are always derived from the lifetime XP
/// total, so undoing a check-in can never leave stats inconsistent.
abstract final class XpRules {
  /// XP for placing one block on the matrix.
  static const int baseXpPerCheckIn = 25;

  /// Bonus per consecutive prior day of the same habit.
  static const int streakBonusPerDay = 5;
  static const int maxStreakBonus = 50;

  /// Line-clear bonus per fully filled matrix row at check-in time.
  static const int rowBonusPerRow = 5;
  static const int maxRowBonus = 50;

  static const int firstLevelTargetXp = 100;
  static const int targetXpGrowthPerLevel = 50;

  /// XP awarded for a check-in, given how many consecutive due days the
  /// habit was already completed right before this one, and how many matrix
  /// rows were fully cleared when it landed.
  static int xpForCheckIn({
    required int priorStreakDays,
    int completedRows = 0,
  }) {
    final streakBonus = (priorStreakDays * streakBonusPerDay).clamp(
      0,
      maxStreakBonus,
    );
    return baseXpPerCheckIn + streakBonus + rowBonus(completedRows);
  }

  /// Bonus per tile for [completedRows] cleared rows ("+N XP MULTIPLIER").
  static int rowBonus(int completedRows) =>
      (completedRows * rowBonusPerRow).clamp(0, maxRowBonus);

  /// XP needed to go from [level] to [level] + 1.
  static int targetXpForLevel(int level) =>
      firstLevelTargetXp + (level - 1) * targetXpGrowthPerLevel;

  /// Converts lifetime XP into level + XP inside that level.
  static UserStats statsFromTotalXp(int totalXp, {required int streakDays}) {
    var level = 1;
    var remaining = totalXp < 0 ? 0 : totalXp;
    while (remaining >= targetXpForLevel(level)) {
      remaining -= targetXpForLevel(level);
      level++;
    }
    return UserStats(
      currentLevel: level,
      currentXp: remaining,
      targetXp: targetXpForLevel(level),
      streakDays: streakDays,
    );
  }
}
