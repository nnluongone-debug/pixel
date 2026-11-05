import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/l10n.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/new_unlock_marks.dart';
import '../../domain/cosmetics/theme_catalog.dart';
import '../../providers/cosmetics_providers.dart';
import '../../providers/new_unlocks_provider.dart';
import 'locker_screen.dart';

/// Tappable "ARCADE LOCKER" row used on Profile and Config.
class LockerEntryCard extends ConsumerWidget {
  const LockerEntryCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final unlocked = ref.watch(unlockedThemesProvider).length;
    final hasNew = ref.watch(
      newUnlocksProvider.select((s) => s[UnlockKind.theme]!.isNotEmpty),
    );
    return Semantics(
      button: true,
      label: l10n.lockerTitle,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          final unlocks = ref.read(newUnlocksProvider.notifier);
          // Coming back from the locker means its NEW themes were seen.
          Navigator.of(context)
              .push<void>(
                MaterialPageRoute(builder: (_) => const LockerScreen()),
              )
              .then((_) => unlocks.acknowledge(UnlockKind.theme));
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: AppGlow.card(glowColor: AppColors.lavender),
          child: Row(
            children: [
              const Icon(Icons.inventory_2_outlined, color: AppColors.lavender),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.lockerTitle,
                      style: AppTextStyles.headlineSm,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      l10n.lockerEntrySubtitle(
                        unlocked,
                        ThemeCatalog.all.length,
                      ),
                      style: AppTextStyles.labelSm,
                    ),
                  ],
                ),
              ),
              if (hasNew) ...[const NewChip(), const SizedBox(width: 4)],
              const Icon(Icons.chevron_right, color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}
