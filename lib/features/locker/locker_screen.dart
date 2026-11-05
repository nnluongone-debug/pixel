import 'package:flutter/material.dart';

import '../../core/l10n/l10n.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/cosmetics/theme_catalog.dart';
import 'locker_hero_card.dart';
import 'theme_row.dart';

/// BRICK THEMES / VAULT: the active theme and the six-tier collection.
class LockerScreen extends StatelessWidget {
  const LockerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: [
            Row(
              children: [
                IconButton(
                  tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                  onPressed: () => Navigator.of(context).maybePop(),
                  icon: const Icon(Icons.arrow_back),
                ),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    l10n.lockerTitle,
                    style: AppTextStyles.headlineSm,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceRaised,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    l10n.lockerVaultTag,
                    style: AppTextStyles.labelSm.copyWith(
                      color: AppColors.cyan,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const LockerHeroCard(),
            const SizedBox(height: 24),
            Text(
              l10n.lockerCollection(ThemeCatalog.all.length),
              style: AppTextStyles.labelMd,
            ),
            const SizedBox(height: 10),
            for (final theme in ThemeCatalog.all) ...[
              ThemeRow(key: ValueKey(theme.id), theme: theme),
              const SizedBox(height: 10),
            ],
          ],
        ),
      ),
    );
  }
}
