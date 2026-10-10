import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/l10n/l10n.dart';
import '../features/account/account_entry.dart';
import '../features/config/config_screen.dart';
import '../features/habit_editor/habit_editor_sheet.dart';
import '../features/home/home_screen.dart';
import '../features/stats/badge_unlock_listener.dart';
import '../features/stats/stats_screen.dart';
import '../features/tasks/tasks_screen.dart';
import '../providers/home_widget_providers.dart';
import '../providers/reminder_providers.dart';
import '../providers/sync_providers.dart';
import 'neo_bottom_nav.dart';
import 'neo_top_bar.dart';

/// Root layout: top bar, the four tabs, and the floating pill nav whose
/// center "+" opens the New Habit sheet.
class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  int _index = 0;

  /// (nav item, top bar title) per tab, in display order.
  List<(NeoNavItem, String)> _tabs(AppLocalizations l10n) => [
    (NeoNavItem(Icons.grid_view_rounded, l10n.navMatrix), l10n.titleGridView),
    (NeoNavItem(Icons.layers_outlined, l10n.navTasks), l10n.titleTasks),
    (NeoNavItem(Icons.equalizer_rounded, l10n.navStats), l10n.titleStats),
    (NeoNavItem(Icons.settings_outlined, l10n.navConfig), l10n.titleConfig),
  ];

  @override
  Widget build(BuildContext context) {
    // Keeps home screen widgets in sync and handles their tap deep links.
    ref.watch(homeWidgetSyncProvider);
    // Reschedules daily prompts whenever habits change.
    ref.watch(reminderSyncProvider);
    // Cloud sync for the signed-in account (no-op for guests).
    ref.watch(syncStatusProvider);
    final tabs = _tabs(context.l10n);
    return BadgeUnlockListener(
      child: Scaffold(
        extendBody: true,
        appBar: NeoTopBar(
          title: tabs[_index].$2,
          // Guest → login; signed in → profile.
          onProfileTap: () => AccountEntry.open(context, ref),
        ),
        // IndexedStack keeps each tab's scroll position and animations alive.
        body: IndexedStack(
          index: _index,
          children: const [
            HomeScreen(),
            TasksScreen(),
            StatsScreen(),
            ConfigScreen(),
          ],
        ),
        bottomNavigationBar: NeoBottomNav(
          items: [for (final t in tabs) t.$1],
          currentIndex: _index,
          onTap: (i) => setState(() => _index = i),
          onCreate: () => HabitEditorSheet.show(context),
        ),
      ),
    );
  }
}
