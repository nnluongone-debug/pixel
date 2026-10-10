/// One block on the pixel matrix: a habit that hit its target on [date].
class CheckIn {
  const CheckIn({
    required this.id,
    required this.habitId,
    required this.date,
    required this.xpEarned,
    required this.gridX,
    required this.gridY,
  });

  final String id;
  final String habitId;

  /// `YYYY-MM-DD`, local calendar.
  final String date;
  final int xpEarned;

  /// Matrix column: days since 1970-01-01 of [date]. The UI maps it to a
  /// visible column relative to today.
  final int gridX;

  /// Matrix row counted from the base (0 = bottom). Blocks fall down when a
  /// lower block on the same day is removed.
  final int gridY;

  Map<String, Object?> toMap() => {
    'id': id,
    'habit_id': habitId,
    'date': date,
    'xp_earned': xpEarned,
    'grid_x': gridX,
    'grid_y': gridY,
  };

  factory CheckIn.fromMap(Map<String, Object?> map) => CheckIn(
    id: map['id']! as String,
    habitId: map['habit_id']! as String,
    date: map['date']! as String,
    xpEarned: map['xp_earned']! as int,
    gridX: map['grid_x']! as int,
    gridY: map['grid_y']! as int,
  );
}
