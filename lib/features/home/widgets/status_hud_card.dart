import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/l10n/l10n_labels.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/user_stats.dart';
import '../../../providers/habit_providers.dart';
import 'pulse_dot.dart';

/// Top HUD: year + today's date on the left, streak / level / XP pills on
/// the right.
class StatusHudCard extends ConsumerWidget {
  const StatusHudCard({super.key, this.today});

  /// Overrides "now" (tests, previews). Defaults to the device clock.
  final DateTime? today;

  /// "TUE, OCT 24" in English, "T3, 24 THG 10" in Vietnamese (day first).
  static String dateLabel(DateTime d, AppLocalizations l10n) {
    final tag = l10n.localeName;
    if (!tag.startsWith('vi')) {
      return DateFormat('EEE, MMM d', tag).format(d).toUpperCase();
    }
    // Vietnamese: day before month, weekday from the shared ARB labels
    // (intl would give "Th 7").
    return '${l10n.weekdayShort(d.weekday)}, ${DateFormat('d MMM', tag).format(d)}'
        .toUpperCase();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Keep showing the last stats while a refresh is in flight.
    final stats = ref.watch(userStatsProvider).value ?? UserStats.initial;
    final now = today ?? DateTime.now();
    final freezes = ref.watch(streakFreezeProvider).value?.held ?? 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.5),
        ),
        boxShadow: const [BoxShadow(color: Color(0x80000000), blurRadius: 20)],
      ),
      child: Row(
        children: [
          Expanded(
            child: FittedBox(
              alignment: Alignment.centerLeft,
              fit: BoxFit.scaleDown,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.gridHudYear(now.year),
                    style: AppTextStyles.labelSm.copyWith(
                      color: AppColors.textSecondary,
                      letterSpacing: 1.5,
                    ),
                  ),
                  Text(
                    dateLabel(now, context.l10n),
                    style: AppTextStyles.headlineSm.copyWith(
                      fontSize: 16,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            flex: 3,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _Pill(
                    color: AppColors.primary,
                    glow: AppColors.mint,
                    leading: const PulseDot(ping: true),
                    text: context.l10n.gridHudStreak(stats.streakDays),
                    trailing: Icons.bolt_rounded,
                  ),
                  if (freezes > 0) ...[
                    const SizedBox(width: 4),
                    Tooltip(
                      message: context.l10n.streakFreezeTooltip,
                      child: _Pill(
                        color: AppColors.cyan,
                        text: context.l10n.gridHudFreezes(freezes),
                        trailing: Icons.ac_unit,
                        trailingColor: AppColors.cyan,
                      ),
                    ),
                  ],
                  const SizedBox(width: 4),
                  _Pill(
                    color: AppColors.cyan,
                    text: context.l10n.gridHudLevel(stats.currentLevel),
                  ),
                  const SizedBox(width: 4),
                  _Pill(
                    color: AppColors.amber,
                    text: context.l10n.gridHudXp(stats.currentXp),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({
    required this.color,
    required this.text,
    this.glow,
    this.leading,
    this.trailing,
    this.trailingColor = AppColors.amber,
  });

  final Color color;
  final Color? glow;
  final String text;
  final Widget? leading;
  final IconData? trailing;
  final Color trailingColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: leading == null ? 8 : 10,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceHigh,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.4)),
        boxShadow: AppGlow.soft(glow ?? color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (leading != null) ...[leading!, const SizedBox(width: 6)],
          Text(
            text,
            style: AppTextStyles.labelSm.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: 4),
            Icon(trailing, size: 13, color: trailingColor),
          ],
        ],
      ),
    );
  }
}
