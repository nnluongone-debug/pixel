import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

/// One card of the 2x2 grid: label, big value, caption and an optional
/// widget in the top-right or beside the value.
class StatTile extends StatelessWidget {
  const StatTile({
    super.key,
    required this.label,
    required this.value,
    required this.caption,
    required this.accent,
    this.unit,
    this.topRight,
    this.valueTrailing,
  });

  final String label;
  final String value;
  final String? unit;
  final String caption;
  final Color accent;
  final Widget? topRight;
  final Widget? valueTrailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: AppGlow.card(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.labelSm,
                ),
              ),
              if (topRight != null)
                Flexible(
                  child: FittedBox(fit: BoxFit.scaleDown, child: topRight),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(value, style: AppTextStyles.stat(accent)),
                ),
              ),
              if (unit != null) ...[
                const SizedBox(width: 6),
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text(
                    unit!,
                    style: AppTextStyles.labelMd.copyWith(color: accent),
                  ),
                ),
              ],
              if (valueTrailing != null) ...[const Spacer(), valueTrailing!],
            ],
          ),
          const SizedBox(height: 6),
          Text(
            caption,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.labelMd.copyWith(color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}

/// Small bordered chip, e.g. a rate delta or "88% EFFICIENCY".
class StatChip extends StatelessWidget {
  const StatChip(this.text, {super.key, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(text, style: AppTextStyles.labelSm.copyWith(color: color)),
    );
  }
}
