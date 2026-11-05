import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// "01 // IDENTITY  HABIT TITLE ........ MAX 32 CHR" row above each section.
class EditorSectionHeader extends StatelessWidget {
  const EditorSectionHeader({
    super.key,
    required this.tag,
    required this.title,
    this.trailing,
    this.trailingColor = AppColors.textMuted,
  });

  final String tag;
  final String title;
  final String? trailing;
  final Color trailingColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
          decoration: BoxDecoration(
            color: AppColors.surfaceRaised,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: AppColors.cyan.withValues(alpha: 0.5)),
          ),
          child: Text(
            tag,
            style: AppTextStyles.labelSm.copyWith(color: AppColors.cyan),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: AppTextStyles.labelMd,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (trailing != null)
          Text(
            trailing!,
            style: AppTextStyles.labelSm.copyWith(color: trailingColor),
          ),
      ],
    );
  }
}

/// Rounded inset panel used by every section body.
class EditorPanel extends StatelessWidget {
  const EditorPanel({
    super.key,
    required this.child,
    this.accent,
    this.padding = const EdgeInsets.all(12),
  });

  final Widget child;
  final Color? accent;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.inputInset,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: accent?.withValues(alpha: 0.5) ?? AppColors.borderSubtle,
        ),
      ),
      child: child,
    );
  }
}

/// Small pill chip; the selected one glows in [color].
class EditorChip extends StatelessWidget {
  const EditorChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.color = AppColors.mint,
    this.horizontalPadding = 14,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color color;
  final double horizontalPadding;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          constraints: const BoxConstraints(minHeight: 36),
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? color.withValues(alpha: 0.12) : null,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: selected ? color : AppColors.borderActive,
            ),
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              style: AppTextStyles.labelMd.copyWith(
                color: selected ? color : AppColors.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Square +/- button of the quota stepper.
class StepperButton extends StatelessWidget {
  const StepperButton({
    super.key,
    required this.icon,
    required this.onPressed,
    required this.tooltip,
    this.color = AppColors.mint,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final String tooltip;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onPressed,
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.surfaceLowest,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: enabled ? color : AppColors.borderSubtle),
          ),
          child: Icon(
            icon,
            size: 20,
            color: enabled ? color : AppColors.textMuted,
          ),
        ),
      ),
    );
  }
}

/// Two-or-more option segmented control in the editor's neon style.
class EditorSegmented<T> extends StatelessWidget {
  const EditorSegmented({
    super.key,
    required this.options,
    required this.selected,
    required this.onChanged,
    this.color = AppColors.mint,
  });

  final Map<T, String> options;
  final T selected;
  final ValueChanged<T> onChanged;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AppColors.surfaceLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Row(
        children: [
          for (final entry in options.entries)
            Expanded(
              child: Semantics(
                button: true,
                selected: entry.key == selected,
                child: GestureDetector(
                  onTap: () => onChanged(entry.key),
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    height: 34,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: entry.key == selected
                          ? color.withValues(alpha: 0.14)
                          : null,
                      borderRadius: BorderRadius.circular(10),
                      border: entry.key == selected
                          ? Border.all(color: color.withValues(alpha: 0.6))
                          : null,
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        entry.value,
                        style: AppTextStyles.labelMd.copyWith(
                          color: entry.key == selected
                              ? color
                              : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
