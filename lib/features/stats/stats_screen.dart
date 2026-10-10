import '../../core/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../providers/analytics_providers.dart';
import 'widgets/activity_matrix_card.dart';
import 'widgets/badges_section.dart';
import 'widgets/habit_breakdown_section.dart';
import 'widgets/stat_tiles.dart';
import 'widgets/stats_header.dart';

/// Habit analytics tab. The shell provides the top bar and the floating
/// nav, so the list leaves room at the bottom for it.
class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(analyticsDataProvider);
    final value = data.value;

    if (value == null) {
      if (data.hasError) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(context.l10n.statsLoadError, style: AppTextStyles.bodyMd),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () => ref.invalidate(analyticsDataProvider),
                child: Text(context.l10n.commonRetry),
              ),
            ],
          ),
        );
      }
      return const Center(
        child: CircularProgressIndicator(color: AppColors.mint),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
      children: [
        StatsHeader(loadedAt: value.loadedAt),
        const SizedBox(height: 16),
        const StatTiles(),
        const SizedBox(height: 16),
        const ActivityMatrixCard(),
        const SizedBox(height: 24),
        const HabitBreakdownSection(),
        const SizedBox(height: 12),
        const BadgesSection(),
      ],
    );
  }
}
