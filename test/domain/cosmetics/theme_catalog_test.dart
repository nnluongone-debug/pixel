import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_quest/domain/cosmetics/theme_catalog.dart';
import 'package:pixel_quest/domain/progression/xp_rules.dart';

ThemeProgress at({int level = 1, int bestStreak = 0, int? totalXp}) => (
  level: level,
  totalXp: totalXp ?? XpRules.totalXpForLevel(level),
  bestStreak: bestStreak,
);

Set<ThemeId> unlocked(ThemeProgress p, {bool pro = false}) => {
  for (final t in ThemeCatalog.all)
    if (t.isUnlocked(p, hasPro: pro)) t.id,
};

void main() {
  test('six themes, tiers 1..6 in order, each with its own sound pack', () {
    expect(ThemeCatalog.all.map((t) => t.tier.number), [1, 2, 3, 4, 5, 6]);
    expect(
      ThemeCatalog.all.map((t) => t.sound).toSet(),
      hasLength(ThemeCatalog.all.length),
    );
    expect(ThemeCatalog.defaultTheme.id, ThemeId.neonGlow);
  });

  test('unlock rules follow the brick themes design', () {
    expect(unlocked(at()), {ThemeId.gameBoy, ThemeId.neonGlow});
    expect(unlocked(at(level: 6)), contains(ThemeId.cyberpunk));
    expect(unlocked(at(level: 99)), isNot(contains(ThemeId.gemstone)));
    expect(unlocked(at(bestStreak: 45)), contains(ThemeId.gemstone));
    expect(unlocked(at(level: 35)), contains(ThemeId.pureGold));
    expect(unlocked(at(bestStreak: 90)), contains(ThemeId.pureGold));
    expect(
      unlocked(at(level: 34, bestStreak: 89)),
      isNot(contains(ThemeId.pureGold)),
    );
    expect(unlocked(at(level: 50)), contains(ThemeId.nebula));
    expect(unlocked(at(bestStreak: 180)), contains(ThemeId.nebula));
    expect(
      unlocked(at(level: 49, bestStreak: 179)),
      isNot(contains(ThemeId.nebula)),
    );
  });

  test('progress ratio takes the closest condition', () {
    final gem = ThemeCatalog.gemstone.unlock;
    expect(
      gem.ratio(at(bestStreak: 34), hasPro: false),
      closeTo(34 / 45, 1e-9),
    );
    final gold = ThemeCatalog.pureGold.unlock;
    final half = XpRules.totalXpForLevel(35) ~/ 2;
    expect(
      gold.ratio(at(totalXp: half, bestStreak: 9), hasPro: false),
      closeTo(0.5, 0.01),
    );
    expect(gold.ratio(at(bestStreak: 81), hasPro: false), closeTo(0.9, 1e-9));
    expect(
      ThemeCatalog.nebula.unlock.ratio(at(bestStreak: 90), hasPro: false),
      closeTo(0.5, 1e-9),
    );
    expect(ThemeCatalog.gameBoy.unlock.ratio(at(), hasPro: false), 1);
  });
}
