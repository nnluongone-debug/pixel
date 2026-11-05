import 'package:flutter/material.dart';

import '../l10n/l10n.dart';
import '../theme/app_theme.dart';

/// Red dot marking unseen unlocks.
class NewDot extends StatelessWidget {
  const NewDot({super.key, this.size = 9});

  final double size;

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      color: AppColors.deleteRed,
      shape: BoxShape.circle,
      border: Border.all(color: AppColors.surface, width: 1.5),
      boxShadow: AppGlow.soft(AppColors.deleteRed),
    ),
  );
}

/// "NEW" tag on a badge or theme the player hasn't looked at yet.
class NewChip extends StatelessWidget {
  const NewChip({super.key});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    decoration: BoxDecoration(
      color: AppColors.deleteRed,
      borderRadius: BorderRadius.circular(6),
      boxShadow: AppGlow.soft(AppColors.deleteRed),
    ),
    child: Text(
      context.l10n.commonNew,
      style: AppTextStyles.labelSm.copyWith(
        color: Colors.white,
        fontWeight: FontWeight.w800,
      ),
    ),
  );
}
