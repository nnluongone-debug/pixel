import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pixel_quest/domain/analytics/pixel_badge.dart';
import 'package:pixel_quest/features/stats/badge_unlock_listener.dart';
import 'package:pixel_quest/features/stats/widgets/badge_sprites.dart';
import 'package:pixel_quest/providers/analytics_providers.dart';
import 'package:pixel_quest/providers/locale_providers.dart';
import 'package:pixel_quest/providers/new_unlocks_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../support/local_progress.dart';
import '../../support/localized_test_app.dart';

/// Badge list the test can change, standing in for a new unlock.
final _badges = NotifierProvider<_Badges, List<BadgeStatus>>(_Badges.new);

class _Badges extends Notifier<List<BadgeStatus>> {
  @override
  List<BadgeStatus> build() => [
    _status(BadgeCatalog.firstBlock, unlocked: true),
  ];

  void unlock(BadgeDefinition d) =>
      state = [...state, _status(d, unlocked: true)];
}

BadgeStatus _status(BadgeDefinition d, {required bool unlocked}) => BadgeStatus(
  definition: d,
  unlockedDay: unlocked ? 20000 : null,
  progressKind: BadgeProgressKind.blocks,
  progress: 1,
  goal: 1,
);

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  test('every badge sprite is a 12x12 grid of known pixels', () {
    for (final glyph in BadgeGlyph.values) {
      final sprite = BadgeSprites.of(glyph);
      expect(sprite, hasLength(BadgeSprites.size), reason: '$glyph rows');
      for (final row in sprite) {
        expect(row.length, BadgeSprites.size, reason: '$glyph: "$row"');
        expect(RegExp(r'^[.+#o]+$').hasMatch(row), isTrue, reason: '$glyph');
      }
    }
  });

  test('catalog runs from common to legendary', () {
    final tiers = [for (final b in BadgeCatalog.all) b.tier.index];
    expect(tiers, [...tiers]..sort());
    expect(BadgeCatalog.all.last.tier, BadgeTier.legendary);
  });

  testWidgets('first run records existing badges silently, then a new '
      'unlock celebrates once', (tester) async {
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (_) async => null,
    );
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        badgesProvider.overrideWith((ref) => ref.watch(_badges)),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: localizedTestApp(
          home: const BadgeUnlockListener(child: Scaffold()),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();
    expect(find.text('NEW BADGE!'), findsNothing);
    expect(prefs.getStringList(BadgeUnlockListener.seenKey), ['firstBlock']);

    // An unlock that arrives without a local action (sync, reinstall,
    // demo) is recorded silently.
    container.read(_badges.notifier).unlock(BadgeCatalog.warrior);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('NEW BADGE!'), findsNothing);
    expect(
      prefs.getStringList(BadgeUnlockListener.seenKey),
      containsAll(['firstBlock', 'warrior']),
    );
    // ...but still marked NEW and announced with a toast.
    expect(container.read(newUnlocksProvider)[UnlockKind.badge], {'warrior'});
    expect(find.textContaining('1 new badge'), findsNothing);
    expect(find.textContaining('New badge unlocked!'), findsOneWidget);

    emitLocalProgress(container);
    await tester.pump();
    container.read(_badges.notifier).unlock(BadgeCatalog.legend);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('NEW BADGE!'), findsOneWidget);
    expect(find.text('LEGENDARY'), findsOneWidget);
    expect(container.read(newUnlocksProvider)[UnlockKind.badge], {
      'warrior',
      'legend',
    });

    await tester.tap(find.text('AWESOME'));
    await tester.pumpAndSettle();
    expect(find.text('NEW BADGE!'), findsNothing);

    // Same badges again: no second celebration.
    container.read(_badges.notifier).unlock(BadgeCatalog.legend);
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('NEW BADGE!'), findsNothing);

    await container
        .read(newUnlocksProvider.notifier)
        .acknowledge(UnlockKind.badge);
    expect(container.read(newUnlocksProvider)[UnlockKind.badge], isEmpty);
    expect(prefs.getStringList(UnlockKind.badge.prefsKey), isEmpty);
  });
}
