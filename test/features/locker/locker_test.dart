import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pixel_quest/data/models/user_stats.dart';
import 'package:pixel_quest/domain/cosmetics/theme_catalog.dart';
import 'package:pixel_quest/domain/progression/xp_rules.dart';
import 'package:pixel_quest/features/locker/cosmetic_unlock_listener.dart';
import 'package:pixel_quest/features/locker/locker_screen.dart';
import 'package:pixel_quest/providers/cosmetics_providers.dart';
import 'package:pixel_quest/providers/habit_providers.dart';
import 'package:pixel_quest/providers/locale_providers.dart';
import 'package:pixel_quest/providers/sound_providers.dart';
import 'package:pixel_quest/services/sound/sound_service.dart';
import 'package:pixel_quest/services/sound/sound_slot.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../support/local_progress.dart';
import '../../support/localized_test_app.dart';

class _Player extends Notifier<({int level, int streak})> {
  _Player(this.initial);
  final ({int level, int streak}) initial;

  @override
  ({int level, int streak}) build() => initial;

  void set({int? level, int? streak}) =>
      state = (level: level ?? state.level, streak: streak ?? state.streak);
}

class _FakeSound extends SoundService {
  final previews = <(String, List<SoundSlot>)>[];

  @override
  Future<void> preview(
    String packId,
    List<SoundSlot> slots, {
    Duration gap = const Duration(milliseconds: 600),
    Duration tail = const Duration(milliseconds: 1300),
  }) async => previews.add((packId, slots));
}

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  late NotifierProvider<_Player, ({int level, int streak})> playerProvider;
  late _FakeSound sound;
  late ProviderContainer container;

  Future<void> pump(
    WidgetTester tester,
    Widget home, {
    int level = 1,
    int streak = 0,
    Locale locale = const Locale('en'),
  }) async {
    SharedPreferences.setMockInitialValues({});
    final sp = await SharedPreferences.getInstance();
    playerProvider = NotifierProvider(
      () => _Player((level: level, streak: streak)),
    );
    sound = _FakeSound();
    container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sp),
        soundServiceProvider.overrideWithValue(sound),
        userStatsProvider.overrideWith((ref) {
          final l = ref.watch(playerProvider).level;
          return UserStats(
            currentLevel: l,
            currentXp: 0,
            targetXp: XpRules.targetXpForLevel(l),
            streakDays: 0,
          );
        }),
        bestStreakProvider.overrideWith(
          (ref) async => ref.watch(playerProvider).streak,
        ),
      ],
    );
    addTearDown(container.dispose);
    // Tall enough that every row is built.
    tester.view.physicalSize = const Size(360, 2600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: localizedTestApp(home: home, locale: locale),
      ),
    );
    await container.read(userStatsProvider.future);
    await container.read(bestStreakProvider.future);
    await tester.pump();
  }

  testWidgets('shows the active hero and each tier condition', (tester) async {
    await pump(tester, const LockerScreen(), streak: 34);
    expect(find.text('ACTIVE SKIN'), findsOneWidget);
    expect(find.text('Arcade Neon Glow'), findsNWidgets(2)); // hero + row
    expect(find.text('ACTIVE'), findsOneWidget);
    expect(find.text('THEME COLLECTION (6 TIERS)'), findsOneWidget);
    expect(find.text('EQUIP'), findsOneWidget); // Game Boy only
    expect(find.text('LVL 6'), findsOneWidget);
    expect(find.text('34/45 D'), findsOneWidget);
    expect(find.text('75%'), findsOneWidget);
    expect(find.text('Requires 45-Day Streak'), findsOneWidget);
    expect(find.text('LVL 35'), findsOneWidget);
    expect(find.text('Requires Hero LVL 35 or 90-Day Streak'), findsOneWidget);
    expect(find.text('LVL 50'), findsOneWidget);
    expect(find.text('Requires Hero LVL 50 or 180-Day Streak'), findsOneWidget);
    expect(find.text('TIER 6 • COSMIC'), findsOneWidget);
    expect(find.text('PRO'), findsNothing);
  });

  testWidgets('equips an unlocked theme and plays its sound', (tester) async {
    await pump(tester, const LockerScreen(), level: 6);
    expect(find.text('TIER 3 • EPIC • UNLOCKED'), findsOneWidget);
    expect(find.text('EQUIP'), findsNWidgets(2));
    await tester.tap(find.text('EQUIP').last);
    await tester.pump();
    await tester.pump();
    expect(container.read(equippedThemeProvider), ThemeId.cyberpunk);
    expect(container.read(equippedSoundProvider), SoundPackId.laserDrop);
    expect(sound.previews.last.$1, 'laserDrop');
    expect(sound.previews.last.$2, [SoundSlot.complete]);
    expect(find.text('Cyber Glitch & CRT'), findsNWidgets(2)); // hero + row
  });

  testWidgets('tapping a sound line previews that pack', (tester) async {
    await pump(tester, const LockerScreen());
    await tester.tap(find.text('4-Bit Chiptune Bleep'));
    await tester.pump();
    expect(sound.previews.last.$1, 'chiptune');
    expect(sound.previews.last.$2, [SoundSlot.complete, SoundSlot.levelUp]);
  });

  testWidgets('celebrates a new unlock once; first run is silent', (
    tester,
  ) async {
    await pump(
      tester,
      const CosmeticUnlockListener(child: Scaffold(body: Text('app'))),
      level: 3,
    );
    await tester.pump();
    expect(find.text('NEW THEME!'), findsNothing);
    expect(
      container.read(sharedPreferencesProvider).getStringList('seen_cosmetics'),
      isEmpty,
    );

    emitLocalProgress(container);
    await tester.pump();
    container.read(playerProvider.notifier).set(level: 6);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('NEW THEME!'), findsOneWidget);
    expect(find.text('Cyber Glitch & CRT'), findsOneWidget);

    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.widgetWithText(TextButton, 'LATER'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('NEW THEME!'), findsNothing);

    // Re-evaluating with the same progress does not celebrate again.
    container.invalidate(userStatsProvider);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('NEW THEME!'), findsNothing);
  });

  testWidgets('renders in Vietnamese', (tester) async {
    await pump(tester, const LockerScreen(), locale: const Locale('vi'));
    expect(find.text('BỘ GẠCH'), findsOneWidget);
    expect(find.text('KHO'), findsOneWidget);
    expect(find.text('GIAO DIỆN ĐANG DÙNG'), findsOneWidget);
    expect(find.text('CẤP 2 • HIẾM'), findsWidgets);
    expect(find.text('CẤP 6 • VŨ TRỤ'), findsOneWidget);
    expect(find.text('Cần chuỗi 45 ngày'), findsOneWidget);
    expect(find.text('LV 35'), findsOneWidget);
  });
}
