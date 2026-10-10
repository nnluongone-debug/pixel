import 'package:intl/intl.dart';

import '../../core/l10n/l10n_labels.dart';
import '../../data/models/habit.dart';
import '../../domain/analytics/analytics_range.dart';
import '../../domain/analytics/habit_consistency.dart';
import '../../domain/analytics/pixel_badge.dart';
import '../../l10n/app_localizations.dart';

/// Display strings for the analytics screen. Domain code is language
/// neutral; everything user-visible is mapped to localized text here.
extension StatsL10n on AppLocalizations {
  String rangeChip(AnalyticsRange range) => switch (range) {
    AnalyticsRange.week => statsRangeWeek,
    AnalyticsRange.month => statsRangeMonth,
    AnalyticsRange.year => statsRangeYear,
    AnalyticsRange.allTime => statsRangeAll,
  };

  String rangeCaption(AnalyticsRange range) => switch (range) {
    AnalyticsRange.week => statsCaptionWeek,
    AnalyticsRange.month => statsCaptionMonth,
    AnalyticsRange.year => statsCaptionYear,
    AnalyticsRange.allTime => statsCaptionAll,
  };

  String rangeWindow(AnalyticsRange range) => switch (range) {
    AnalyticsRange.week => statsWindowWeek,
    AnalyticsRange.month => statsWindowMonth,
    AnalyticsRange.year => statsWindowYear,
    AnalyticsRange.allTime => statsWindowAll,
  };

  /// `OCT 2026` / `THÁNG 10 2026`.
  String monthYear(DateTime date, String localeTag) => statsMonthYear(
    DateFormat.MMM(localeTag).format(date).toUpperCase(),
    date.month,
    date.year,
  );

  /// `SYNCED: TODAY 09:41`; [loadedAt] is the moment the data was read.
  String syncLine(DateTime loadedAt) => statsSyncLine(
    '${loadedAt.hour.toString().padLeft(2, '0')}:'
    '${loadedAt.minute.toString().padLeft(2, '0')}',
  );

  /// Signed percentage points, e.g. `+4.2 PTS`.
  String delta(double points) => statsDeltaPoints(
    '${points >= 0 ? '+' : '-'}${points.abs().toStringAsFixed(1)}',
  );

  String badgeTier(BadgeTier tier) => switch (tier) {
    BadgeTier.common => statsTierCommon,
    BadgeTier.rare => statsTierRare,
    BadgeTier.epic => statsTierEpic,
    BadgeTier.legendary => statsTierLegendary,
  };

  String badgeName(BadgeId id) => switch (id) {
    BadgeId.firstBlock => statsBadgeFirstBlockName,
    BadgeId.brickLayer => statsBadgeBrickLayerName,
    BadgeId.brickMaster => statsBadgeBrickMasterName,
    BadgeId.warrior => statsBadgeWarriorName,
    BadgeId.lineClearer => statsBadgeLineClearerName,
    BadgeId.legend => statsBadgeLegendName,
    BadgeId.perfectDay => statsBadgePerfectDayName,
    BadgeId.perfectWeek => statsBadgePerfectWeekName,
    BadgeId.level5 => statsBadgeLevel5Name,
    BadgeId.level10 => statsBadgeLevel10Name,
  };

  String badgeDescription(BadgeId id) => switch (id) {
    BadgeId.firstBlock => statsBadgeFirstBlockDesc,
    BadgeId.brickLayer => statsBadgeBrickLayerDesc,
    BadgeId.brickMaster => statsBadgeBrickMasterDesc,
    BadgeId.warrior => statsBadgeWarriorDesc,
    BadgeId.lineClearer => statsBadgeLineClearerDesc,
    BadgeId.legend => statsBadgeLegendDesc,
    BadgeId.perfectDay => statsBadgePerfectDayDesc,
    BadgeId.perfectWeek => statsBadgePerfectWeekDesc,
    BadgeId.level5 => statsBadgeLevel5Desc,
    BadgeId.level10 => statsBadgeLevel10Desc,
  };

  /// Where the user stands on a badge, e.g. `BEST 5 / 7 DAYS`.
  String badgeProgress(BadgeStatus s) => switch (s.progressKind) {
    BadgeProgressKind.blocks => statsProgressBlocks(s.progress, s.goal),
    BadgeProgressKind.streakDays => statsProgressStreak(s.progress, s.goal),
    BadgeProgressKind.perfectRun => statsProgressPerfectRun(s.progress, s.goal),
    BadgeProgressKind.bestDay => statsProgressBestDay(s.progress, s.goal),
    BadgeProgressKind.noHabits => statsProgressNoHabits,
    BadgeProgressKind.level => statsProgressLevel(s.progress, s.goal),
  };

  /// Right-hand figure of a breakdown row. Only days that met the target are
  /// stored, so totals are lower bounds ("≥") rather than exact amounts.
  String habitStat(HabitConsistency c) {
    final total = c.minimumTotal;
    switch (c.habit.type) {
      case HabitType.checklist:
        return statsStatDone(c.metDays);
      case HabitType.timer:
        final h = total ~/ 60;
        final m = total % 60;
        return statsStatLogged(
          h > 0 ? statsDurationHM(h, m) : statsDurationM(m),
        );
      case HabitType.counter:
        final unit = c.habit.unit.trim().isEmpty
            ? ''
            : ' ${unitLabel(c.habit.unit.trim())}';
        return '≥ $total$unit';
    }
  }
}

/// Date and number formatting for the analytics screen.
abstract final class StatsFormat {
  /// `OCT 7` / `7 THG 10`.
  static String monthDay(DateTime date, String localeTag) =>
      DateFormat.MMMd(localeTag).format(date).toUpperCase();

  static String percent(int? value) => value == null ? '--' : '$value%';
}
