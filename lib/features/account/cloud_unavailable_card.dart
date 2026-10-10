import 'package:flutter/material.dart';

import '../../core/l10n/l10n.dart';
import '../../core/theme/app_theme.dart';
import '../habit_editor/editor_parts.dart';

/// Shown instead of the sign-in form when Firebase did not initialize.
class CloudUnavailableCard extends StatelessWidget {
  const CloudUnavailableCard({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return EditorPanel(
      accent: AppColors.amber,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.cloud_off, size: 20, color: AppColors.amber),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.accountUnavailableTitle,
                  style: AppTextStyles.labelLg.copyWith(color: AppColors.amber),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(l10n.accountUnavailableBody, style: AppTextStyles.bodyMd),
        ],
      ),
    );
  }
}
