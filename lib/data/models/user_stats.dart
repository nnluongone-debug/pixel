class UserStats {
  const UserStats({
    required this.currentLevel,
    required this.currentXp,
    required this.targetXp,
    required this.streakDays,
  });

  static const initial = UserStats(
    currentLevel: 1,
    currentXp: 0,
    targetXp: 100,
    streakDays: 0,
  );

  final int currentLevel;

  /// XP gained inside the current level, from 0 to [targetXp] (exclusive).
  final int currentXp;

  /// XP needed to go from [currentLevel] to the next level.
  final int targetXp;
  final int streakDays;

  double get levelProgress =>
      targetXp <= 0 ? 0 : (currentXp / targetXp).clamp(0.0, 1.0);

  Map<String, Object?> toMap() => {
    'current_level': currentLevel,
    'current_xp': currentXp,
    'target_xp': targetXp,
    'streak_days': streakDays,
  };

  factory UserStats.fromMap(Map<String, Object?> map) => UserStats(
    currentLevel: map['current_level']! as int,
    currentXp: map['current_xp']! as int,
    targetXp: map['target_xp']! as int,
    streakDays: map['streak_days']! as int,
  );
}
