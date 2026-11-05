import '../progression/xp_rules.dart';

/// Brick themes, in collection order. Also the values stored in prefs and
/// Firestore (`users/{uid}.cosmetics.skin`).
enum ThemeId {
  gameBoy,
  neonGlow,
  cyberpunk,
  gemstone,
  pureGold,
  nebula;

  static ThemeId? fromName(String? name) {
    for (final id in values) {
      if (id.name == name) return id;
    }
    return null;
  }
}

/// Sound pack bundled with each theme; the name is its asset folder under
/// `assets/sounds/`.
enum SoundPackId {
  chiptune,
  synthPop,
  laserDrop,
  crystalChime,
  coinCascade,
  cosmicWarp,
}

/// Six rarity tiers, shown as "TIER n • NAME".
enum ThemeTier {
  common,
  rare,
  epic,
  legendary,
  mythic,
  cosmic;

  int get number => index + 1;
}

/// What the player has achieved, for unlock checks.
typedef ThemeProgress = ({int level, int totalXp, int bestStreak});

/// Any one satisfied condition unlocks the theme; none at all means free.
class ThemeUnlock {
  const ThemeUnlock({this.level, this.streakDays, this.proOnly = false});

  static const free = ThemeUnlock();

  /// Player level that unlocks it.
  final int? level;

  /// Best-ever daily streak (days) that unlocks it.
  final int? streakDays;

  /// Only a Pro purchase unlocks it.
  final bool proOnly;

  bool get isFree => level == null && streakDays == null && !proOnly;

  bool isMet(ThemeProgress p, {required bool hasPro}) {
    if (isFree) return true;
    if (proOnly) return hasPro;
    return (level != null && p.level >= level!) ||
        (streakDays != null && p.bestStreak >= streakDays!);
  }

  /// Progress toward the closest condition, 0..1 (1 when unlocked).
  double ratio(ThemeProgress p, {required bool hasPro}) {
    if (isMet(p, hasPro: hasPro)) return 1;
    if (proOnly) return 0;
    var best = 0.0;
    if (level != null) {
      final needed = XpRules.totalXpForLevel(level!);
      if (needed > 0) best = p.totalXp / needed;
    }
    if (streakDays != null) {
      final r = p.bestStreak / streakDays!;
      if (r > best) best = r;
    }
    return best.clamp(0.0, 1.0);
  }
}

class BrickTheme {
  const BrickTheme(this.id, this.tier, this.sound, this.unlock);

  final ThemeId id;
  final ThemeTier tier;
  final SoundPackId sound;
  final ThemeUnlock unlock;

  bool isUnlocked(ThemeProgress p, {bool hasPro = false}) =>
      unlock.isMet(p, hasPro: hasPro);
}

abstract final class ThemeCatalog {
  static const gameBoy = BrickTheme(
    ThemeId.gameBoy,
    ThemeTier.common,
    SoundPackId.chiptune,
    ThemeUnlock.free,
  );
  static const neonGlow = BrickTheme(
    ThemeId.neonGlow,
    ThemeTier.rare,
    SoundPackId.synthPop,
    ThemeUnlock.free,
  );
  static const cyberpunk = BrickTheme(
    ThemeId.cyberpunk,
    ThemeTier.epic,
    SoundPackId.laserDrop,
    ThemeUnlock(level: 6),
  );
  static const gemstone = BrickTheme(
    ThemeId.gemstone,
    ThemeTier.legendary,
    SoundPackId.crystalChime,
    ThemeUnlock(streakDays: 45),
  );
  static const pureGold = BrickTheme(
    ThemeId.pureGold,
    ThemeTier.mythic,
    SoundPackId.coinCascade,
    ThemeUnlock(level: 35, streakDays: 90),
  );
  static const nebula = BrickTheme(
    ThemeId.nebula,
    ThemeTier.cosmic,
    SoundPackId.cosmicWarp,
    ThemeUnlock(level: 50, streakDays: 180),
  );

  /// Collection order, tier 1 → 6.
  static const all = [gameBoy, neonGlow, cyberpunk, gemstone, pureGold, nebula];

  /// The look every player starts with.
  static const defaultTheme = neonGlow;

  static BrickTheme of(ThemeId id) => all.firstWhere((t) => t.id == id);
}
