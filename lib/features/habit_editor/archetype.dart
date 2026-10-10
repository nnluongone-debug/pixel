import '../../core/l10n/l10n.dart';
import '../../domain/progression/xp_rules.dart';

/// Flavor class derived from the chosen icon, shown in the identity card.
class Archetype {
  const Archetype(this.name, this.flavor);

  final String name;
  final String flavor;

  /// The only mechanic that differs per habit: the streak bonus. Read from
  /// [XpRules] so the copy can never drift from the real numbers.
  static String mechanics(AppLocalizations l10n) =>
      l10n.editorStreakBonus(XpRules.streakBonusPerDay, XpRules.maxStreakBonus);

  static Archetype of(
    String iconName,
    AppLocalizations l10n,
  ) => switch (iconName) {
    'book' => Archetype(l10n.editorArchScholar, l10n.editorArchScholarFlavor),
    'fitness' => Archetype(
      l10n.editorArchWarrior,
      l10n.editorArchWarriorFlavor,
    ),
    'water_drop' => Archetype(l10n.editorArchHydro, l10n.editorArchHydroFlavor),
    'zen' => Archetype(l10n.editorArchMonk, l10n.editorArchMonkFlavor),
    'terminal' => Archetype(l10n.editorArchHacker, l10n.editorArchHackerFlavor),
    _ => Archetype(l10n.editorArchStriker, l10n.editorArchStrikerFlavor),
  };
}
