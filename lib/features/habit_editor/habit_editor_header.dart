import 'package:flutter/material.dart';

import '../../core/l10n/l10n.dart';
import '../../core/theme/app_theme.dart';

/// Drag handle, "MOD_INIT.EXE" tag, title and close button of the sheet.
class HabitEditorHeader extends StatelessWidget {
  const HabitEditorHeader({super.key, required this.isEditing});

  final bool isEditing;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 8),
        Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: AppColors.surfaceHigh,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 8, 4),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: AppColors.mint.withValues(alpha: 0.6),
                  ),
                ),
                child: Text(
                  'MOD_INIT.EXE',
                  style: AppTextStyles.labelSm.copyWith(color: AppColors.mint),
                ),
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: AppColors.mint,
                        shape: BoxShape.circle,
                        boxShadow: AppGlow.soft(AppColors.mint),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        isEditing
                            ? context.l10n.editorEditHabit
                            : context.l10n.editorNewHabit,
                        style: AppTextStyles.headlineSm,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: context.l10n.editorClose,
                onPressed: () => Navigator.of(context).maybePop(),
                icon: const Icon(Icons.close),
                color: AppColors.textPrimary,
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.surfaceRaised,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
