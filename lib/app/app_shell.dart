import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/l10n/l10n.dart';
import '../features/account/account_entry.dart';
import '../features/account/account_identity.dart';
import '../features/account/profile_avatar.dart';
import '../features/config/config_screen.dart';
import '../features/habit_detail/habit_detail_screen.dart';
import '../features/habit_editor/habit_editor_sheet.dart';
import '../features/locker/cosmetic_unlock_listener.dart';
import '../features/home/home_screen.dart';
import '../features/home/widgets/streak_freeze_listener.dart';
import '../features/stats/badge_unlock_listener.dart';
import '../features/stats/stats_screen.dart';
import '../features/tasks/tasks_screen.dart';
import '../providers/account_providers.dart';
import '../providers/home_widget_providers.dart';
import '../providers/new_unlocks_provider.dart';
import '../providers/reminder_providers.dart';
import '../providers/sound_providers.dart';
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
  StreamSubscription<String>? _reminderTaps;

  @override
  void initState() {
    super.initState();
    final reminders = ref.read(reminderServiceProvider);
    _reminderTaps = reminders.tappedHabitIds.listen(_openHabit);
    reminders.launchHabitId().then((id) {
      if (id != null) _openHabit(id);
    });
  }

  @override
  void dispose() {
    _reminderTaps?.cancel();
    super.dispose();
  }

  /// A tapped reminder lands on its habit's detail page, above the home tab.
  void _openHabit(String habitId) {
    if (!mounted) return;
    final navigator = Navigator.of(context);
    navigator.popUntil((route) => route.isFirst);
    _selectTab(0);
    HabitDetailScreen.open(navigator, habitId);
  }

  /// (nav item, top bar title) per tab, in display order.
  List<(NeoNavItem, String)> _tabs(
    AppLocalizations l10n,
    Map<UnlockKind, Set<String>> fresh,
  ) => [
    (NeoNavItem(Icons.grid_view_rounded, l10n.navMatrix), l10n.titleGridView),
    (NeoNavItem(Icons.layers_outlined, l10n.navTasks), l10n.titleTasks),
    (
      NeoNavItem(
        Icons.equalizer_rounded,
        l10n.navStats,
        dot: fresh[UnlockKind.badge]!.isNotEmpty,
      ),
      l10n.titleStats,
    ),
    (
      NeoNavItem(
        Icons.settings_outlined,
        l10n.navConfig,
        dot: fresh[UnlockKind.theme]!.isNotEmpty,
      ),
      l10n.titleConfig,
    ),
  ];

  static const _statsTab = 2;

  void _selectTab(int i) {
    // Leaving Stats means its NEW badges have been seen.
    if (_index == _statsTab && i != _statsTab) {
      ref.read(newUnlocksProvider.notifier).acknowledge(UnlockKind.badge);
    }
    setState(() => _index = i);
  }

  @override
  Widget build(BuildContext context) {
    // Keeps home screen widgets in sync and handles their tap deep links.
    ref.watch(homeWidgetSyncProvider);
    // Reschedules daily prompts whenever habits change.
    ref.watch(reminderSyncProvider);
    // Cloud sync for the signed-in account (no-op for guests).
    ref.watch(syncStatusProvider);
    // Arcade sound engine (also plays the level-up jingle).
    ref.watch(soundServiceProvider);
    final tabs = _tabs(context.l10n, ref.watch(newUnlocksProvider));
    final identity = ref.watch(accountIdentityProvider);
    final profileName = ref.watch(profileProvider).value?.name ?? '';
    final initial = identity == null
        ? null
        : ProfileAvatar.initials(profileName, identity.email).characters.first;
    return StreakFreezeListener(
      child: BadgeUnlockListener(
        child: CosmeticUnlockListener(
          child: Scaffold(
            extendBody: true,
            appBar: NeoTopBar(
              title: tabs[_index].$2,
              initial: initial,
              // Guest → login; signed in → profile.
              onProfileTap: () => AccountEntry.open(context, ref),
            ),
            // IndexedStack keeps each tab's scroll position and animations alive.
            body: IndexedStack(
              index: _index,
              // IndexedStack keeps hidden tabs animating; TickerMode pauses them.
              children: [
                for (final (i, tab) in const [
                  HomeScreen(),
                  TasksScreen(),
                  StatsScreen(),
                  ConfigScreen(),
                ].indexed)
                  TickerMode(enabled: i == _index, child: tab),
              ],
            ),
            bottomNavigationBar: NeoBottomNav(
              items: [for (final t in tabs) t.$1],
              currentIndex: _index,
              onTap: _selectTab,
              onCreate: () => HabitEditorSheet.show(context),
            ),
          ),
        ),
      ),
    );
  }
}
