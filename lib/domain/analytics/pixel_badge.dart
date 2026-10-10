/// Artwork key; the UI maps each value to an icon.
enum BadgeGlyph {
  block,
  stack,
  tower,
  shield,
  line,
  crown,
  sun,
  calendar,
  star,
  bolt,
}

/// Stable badge identity; the UI maps each value to localized text.
enum BadgeId {
  firstBlock,
  brickLayer,
  brickMaster,
  warrior,
  lineClearer,
  legend,
  perfectDay,
  perfectWeek,
  level5,
  level10,
}

/// What a locked badge's progress figures measure.
enum BadgeProgressKind {
  /// [BadgeStatus.progress] of [BadgeStatus.goal] blocks placed.
  blocks,

  /// Longest streak so far, in days.
  streakDays,

  /// Longest run of perfect days.
  perfectRun,

  /// Best day so far: `progress` habits done of `goal` due.
  bestDay,

  /// No habit has been due yet; progress and goal are 0.
  noHabits,

  /// Current level of the goal level.
  level,
}

/// Rarity, from easiest to hardest. Each tier looks richer than the last.
enum BadgeTier { common, rare, epic, legendary }

/// A badge the history can unlock. Badges award no XP.
class BadgeDefinition {
  const BadgeDefinition(this.id, this.glyph, this.tier);

  final BadgeId id;
  final BadgeGlyph glyph;
  final BadgeTier tier;
}

/// A badge evaluated against the stored history.
class BadgeStatus {
  const BadgeStatus({
    required this.definition,
    required this.unlockedDay,
    required this.progressKind,
    required this.progress,
    required this.goal,
  });

  final BadgeDefinition definition;

  /// Epoch day the condition first became true; null while locked.
  final int? unlockedDay;
  final BadgeProgressKind progressKind;
  final int progress;
  final int goal;

  bool get isUnlocked => unlockedDay != null;
}

/// Every badge, in display order.
abstract final class BadgeCatalog {
  static const firstBlock = BadgeDefinition(
    BadgeId.firstBlock,
    BadgeGlyph.block,
    BadgeTier.common,
  );
  static const brickLayer = BadgeDefinition(
    BadgeId.brickLayer,
    BadgeGlyph.stack,
    BadgeTier.rare,
  );
  static const brickMaster = BadgeDefinition(
    BadgeId.brickMaster,
    BadgeGlyph.tower,
    BadgeTier.epic,
  );
  static const warrior = BadgeDefinition(
    BadgeId.warrior,
    BadgeGlyph.shield,
    BadgeTier.rare,
  );
  static const lineClearer = BadgeDefinition(
    BadgeId.lineClearer,
    BadgeGlyph.line,
    BadgeTier.epic,
  );
  static const legend = BadgeDefinition(
    BadgeId.legend,
    BadgeGlyph.crown,
    BadgeTier.legendary,
  );
  static const perfectDay = BadgeDefinition(
    BadgeId.perfectDay,
    BadgeGlyph.sun,
    BadgeTier.common,
  );
  static const perfectWeek = BadgeDefinition(
    BadgeId.perfectWeek,
    BadgeGlyph.calendar,
    BadgeTier.epic,
  );
  static const level5 = BadgeDefinition(
    BadgeId.level5,
    BadgeGlyph.star,
    BadgeTier.rare,
  );
  static const level10 = BadgeDefinition(
    BadgeId.level10,
    BadgeGlyph.bolt,
    BadgeTier.legendary,
  );

  /// Display order: easiest to hardest, so the carousel reads as a ladder.
  static const all = [
    firstBlock,
    perfectDay,
    brickLayer,
    warrior,
    level5,
    lineClearer,
    perfectWeek,
    brickMaster,
    legend,
    level10,
  ];
}
