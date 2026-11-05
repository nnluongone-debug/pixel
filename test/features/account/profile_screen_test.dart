import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pixel_quest/data/models/user_profile.dart';
import 'package:pixel_quest/domain/analytics/pixel_badge.dart';
import 'package:pixel_quest/features/account/profile_screen.dart';
import 'package:pixel_quest/providers/sync_providers.dart';

import 'account_test_support.dart';

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  Future<void> scrollTo(WidgetTester tester, Finder finder) async {
    await tester.scrollUntilVisible(
      finder,
      200,
      scrollable: find.byType(Scrollable).first,
    );
  }

  testWidgets('email is read-only and marked verified', (tester) async {
    await pumpAccount(tester, const ProfileScreen());
    expect(find.text('ada@example.com'), findsOneWidget);
    expect(find.byIcon(Icons.lock_outline), findsOneWidget);
    expect(find.text('VERIFIED'), findsOneWidget);
    // Editable fields only: name, birth year, address.
    expect(find.byType(TextField), findsNWidgets(3));
  });

  testWidgets('invalid birth year blocks the save', (tester) async {
    final repo = FakeProfileRepository();
    await pumpAccount(tester, const ProfileScreen(), repo: repo);
    await tester.enterText(find.byType(TextField).at(1), '1800');
    await scrollTo(tester, find.text('SAVE PROFILE'));
    await tester.tap(find.text('SAVE PROFILE'));
    await tester.pump();
    expect(find.textContaining('Enter a year between 1900'), findsOneWidget);
    expect(repo.saved, isEmpty);
  });

  testWidgets('saves trimmed-by-repository values for the signed-in uid', (
    tester,
  ) async {
    final repo = FakeProfileRepository();
    await pumpAccount(tester, const ProfileScreen(), repo: repo);
    await tester.enterText(find.byType(TextField).at(0), 'Ada Lovelace');
    await tester.enterText(find.byType(TextField).at(1), '1990');
    await tester.enterText(find.byType(TextField).at(2), '1 Main St');
    await tester.ensureVisible(find.text('FEMALE'));
    await tester.tap(find.text('FEMALE'));
    await scrollTo(tester, find.text('SAVE PROFILE'));
    await tester.tap(find.text('SAVE PROFILE'));
    await tester.pump();
    await tester.pump();

    final saved = repo.saved.single;
    expect(saved.uid, 'u1');
    expect(saved.profile.email, 'ada@example.com');
    expect(saved.profile.name, 'Ada Lovelace');
    expect(saved.profile.birthYear, 1990);
    expect(saved.profile.gender, Gender.female);
    expect(saved.profile.address, '1 Main St');
    expect(
      find.textContaining('will sync when you are online'),
      findsOneWidget,
    );
  });

  testWidgets('lists only unlocked badges with count', (tester) async {
    await pumpAccount(
      tester,
      const ProfileScreen(),
      badges: [
        badge(BadgeCatalog.firstBlock, unlockedDay: 20000),
        badge(BadgeCatalog.brickLayer),
      ],
    );
    await scrollTo(tester, find.text('1/2'));
    expect(find.text('1/2'), findsOneWidget);
    expect(find.text('FIRST BLOCK'), findsOneWidget);
    expect(find.text('BRICK LAYER'), findsNothing);
    expect(find.textContaining('UNLOCKED OCT'), findsOneWidget);
  });

  testWidgets('shows an empty state when no badge is unlocked', (tester) async {
    await pumpAccount(
      tester,
      const ProfileScreen(),
      badges: [badge(BadgeCatalog.firstBlock)],
    );
    await scrollTo(tester, find.textContaining('No badges unlocked'));
    expect(find.text('0/1'), findsOneWidget);
  });

  testWidgets('sync card shows status and triggers SYNC NOW', (tester) async {
    final sync = FakeSyncController(
      SyncStatus(
        phase: SyncPhase.idle,
        lastSyncedAt: DateTime(2026, 10, 7, 9, 41),
        pendingCount: 2,
      ),
    );
    await pumpAccount(tester, const ProfileScreen(), sync: sync);
    await scrollTo(tester, find.text('SYNC NOW'));
    expect(find.text('SYNCED'), findsOneWidget);
    expect(find.textContaining('09:41'), findsOneWidget);
    expect(find.text('2 CHANGES PENDING'), findsOneWidget);
    await tester.tap(find.text('SYNC NOW'));
    await tester.pump();
    expect(sync.syncCalls, 1);
  });

  testWidgets('sign out asks for confirmation before wiping', (tester) async {
    final sync = FakeSyncController(SyncStatus.disabled);
    await pumpAccount(tester, const ProfileScreen(), sync: sync);
    await scrollTo(tester, find.text('SIGN OUT'));
    await tester.tap(find.text('SIGN OUT'));
    await tester.pumpAndSettle();
    expect(find.text('SIGN OUT?'), findsOneWidget);

    await tester.tap(find.text('CANCEL'));
    await tester.pumpAndSettle();
    expect(sync.signOutDiscards, isEmpty);

    await tester.tap(find.text('SIGN OUT'));
    await tester.pumpAndSettle();
    await tester.tap(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.text('SIGN OUT'),
      ),
    );
    await tester.pumpAndSettle();
    expect(sync.signOutDiscards, [false]);
  });

  testWidgets('unsent changes offer keeping the session or discarding', (
    tester,
  ) async {
    final sync = FakeSyncController(SyncStatus.disabled)
      ..signOutResults = [3, 3, 0];
    await pumpAccount(tester, const ProfileScreen(), sync: sync);
    Future<void> signOut() async {
      await scrollTo(tester, find.text('SIGN OUT'));
      await tester.tap(find.text('SIGN OUT'));
      await tester.pumpAndSettle();
      await tester.tap(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.text('SIGN OUT'),
        ),
      );
      // The busy spinner animates forever, so settle is not possible here.
      await tester.pump(const Duration(milliseconds: 400));
    }

    await signOut();
    expect(find.textContaining('3 changes haven'), findsOneWidget);
    await tester.tap(find.text('STAY SIGNED IN'));
    await tester.pumpAndSettle();
    expect(sync.signOutDiscards, [false]);

    await signOut();
    await tester.tap(find.text('SIGN OUT ANYWAY'));
    await tester.pumpAndSettle();
    expect(sync.signOutDiscards, [false, false, true]);
  });

  testWidgets('save does not wait for a server ack while offline', (
    tester,
  ) async {
    final repo = FakeProfileRepository()..pending = Completer<void>().future;
    await pumpAccount(tester, const ProfileScreen(), repo: repo);
    await scrollTo(tester, find.text('SAVE PROFILE'));
    await tester.tap(find.text('SAVE PROFILE'));
    await tester.pump();
    await tester.pump();
    expect(repo.saved, hasLength(1));
    expect(
      find.textContaining('will sync when you are online'),
      findsOneWidget,
    );
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('a write that fails later shows an error', (tester) async {
    final failing = Completer<void>();
    final repo = FakeProfileRepository()..pending = failing.future;
    await pumpAccount(tester, const ProfileScreen(), repo: repo);
    await scrollTo(tester, find.text('SAVE PROFILE'));
    await tester.tap(find.text('SAVE PROFILE'));
    await tester.pump();
    failing.completeError(StateError('denied'));
    await tester.pump();
    await tester.pump();
    expect(
      find.text('Something went wrong. Please try again.'),
      findsOneWidget,
    );
  });

  testWidgets('renders in Vietnamese', (tester) async {
    await pumpAccount(
      tester,
      const ProfileScreen(),
      locale: const Locale('vi'),
      badges: [badge(BadgeCatalog.firstBlock, unlockedDay: 20000)],
    );
    expect(find.text('ĐÃ XÁC MINH'), findsOneWidget);
    expect(find.text('TÊN HIỂN THỊ'), findsOneWidget);
    await scrollTo(tester, find.text('LƯU HỒ SƠ'));
    expect(find.text('LƯU HỒ SƠ'), findsOneWidget);
  });
}
