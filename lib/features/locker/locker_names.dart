import 'package:flutter/material.dart';

import '../../core/l10n/l10n.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/cosmetics/theme_catalog.dart';

/// Localized names of brick themes, tiers and their sound packs.
extension LockerL10n on AppLocalizations {
  String themeName(ThemeId id) => switch (id) {
    ThemeId.gameBoy => lockerThemeGameBoy,
    ThemeId.neonGlow => lockerThemeNeonGlow,
    ThemeId.cyberpunk => lockerThemeCyberpunk,
    ThemeId.gemstone => lockerThemeGemstone,
    ThemeId.pureGold => lockerThemePureGold,
    ThemeId.nebula => lockerThemeNebula,
  };

  String soundPackName(SoundPackId id) => switch (id) {
    SoundPackId.chiptune => soundPackChiptune,
    SoundPackId.synthPop => soundPackSynthPop,
    SoundPackId.laserDrop => soundPackLaserDrop,
    SoundPackId.crystalChime => soundPackCrystalChime,
    SoundPackId.coinCascade => soundPackCoinCascade,
    SoundPackId.cosmicWarp => soundPackCosmicWarp,
  };

  String rarityName(ThemeTier tier) => switch (tier) {
    ThemeTier.common => lockerRarityCommon,
    ThemeTier.rare => lockerRarityRare,
    ThemeTier.epic => lockerRarityEpic,
    ThemeTier.legendary => lockerRarityLegendary,
    ThemeTier.mythic => lockerRarityMythic,
    ThemeTier.cosmic => lockerRarityCosmic,
  };

  /// `TIER 2 • RARE`.
  String tierLine(ThemeTier tier) =>
      lockerTierLine(tier.number, rarityName(tier));
}

/// Accent color per rarity tier.
extension ThemeTierColor on ThemeTier {
  Color get color => switch (this) {
    ThemeTier.common => const Color(0xFF9BB09E),
    ThemeTier.rare => AppColors.mint,
    ThemeTier.epic => AppColors.lavender,
    ThemeTier.legendary => AppColors.amber,
    ThemeTier.mythic => const Color(0xFFFF9F43),
    ThemeTier.cosmic => const Color(0xFFB388FF),
  };
}
