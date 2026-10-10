import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_quest/data/models/user_profile.dart';
import 'package:pixel_quest/data/repositories/profile_repository.dart';
import 'package:pixel_quest/domain/analytics/pixel_badge.dart';
import 'package:pixel_quest/features/account/account_identity.dart';
import 'package:pixel_quest/providers/account_providers.dart';
import 'package:pixel_quest/providers/analytics_providers.dart';
import 'package:pixel_quest/providers/locale_providers.dart';
import 'package:pixel_quest/providers/sync_providers.dart';
import 'package:pixel_quest/services/auth/auth_service.dart';

import '../../support/localized_test_app.dart';

const testIdentity = AccountIdentity(uid: 'u1', email: 'ada@example.com');

/// Auth service that records calls and fails on demand; no Firebase.
class FakeAuthService extends AuthService {
  Duration resendDelay = const Duration(seconds: 30);
  AuthException? requestError;
  AuthException? verifyError;
  final requests = <({String email, String lang})>[];
  final verifications = <({String email, String code})>[];

  @override
  Future<Duration> requestCode(String email, {required String lang}) async {
    requests.add((email: email, lang: lang));
    if (requestError != null) throw requestError!;
    return resendDelay;
  }

  @override
  Future<void> verifyCode(String email, String code) async {
    verifications.add((email: email, code: code));
    if (verifyError != null) throw verifyError!;
  }
}

class FakeProfileRepository extends ProfileRepository {
  final saved = <({String uid, UserProfile profile})>[];

  /// Completer the write waits on; null completes immediately. A never-
  /// completed one models Firestore offline (no server ack).
  Future<void>? pending;

  @override
  Future<void> save(String uid, UserProfile profile) {
    saved.add((uid: uid, profile: profile));
    return pending ?? Future.value();
  }
}

class FakeSyncController extends SyncController {
  FakeSyncController(this.initial);

  final SyncStatus initial;
  int syncCalls = 0;

  /// Results of successive `signOutAndWipe` calls (unsent change counts).
  List<int> signOutResults = [0];
  final signOutDiscards = <bool>[];

  @override
  SyncStatus build() => initial;

  @override
  Future<void> syncNow() async => syncCalls++;

  @override
  Future<int> signOutAndWipe({bool discardPending = false}) async {
    signOutDiscards.add(discardPending);
    return signOutResults.removeAt(0);
  }
}

BadgeStatus badge(BadgeDefinition definition, {int? unlockedDay}) =>
    BadgeStatus(
      definition: definition,
      unlockedDay: unlockedDay,
      progressKind: BadgeProgressKind.blocks,
      progress: 0,
      goal: 1,
    );

/// Pumps [home] at 360x640 with account providers faked.
Future<void> pumpAccount(
  WidgetTester tester,
  Widget home, {
  bool firebase = true,
  AccountIdentity? identity = testIdentity,
  UserProfile? profile,
  FakeAuthService? auth,
  FakeProfileRepository? repo,
  FakeSyncController? sync,
  List<BadgeStatus>? badges = const [],
  Locale locale = const Locale('en'),
}) async {
  tester.view.physicalSize = const Size(360, 640);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final user = profile ?? UserProfile(email: testIdentity.email);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        firebaseAvailableProvider.overrideWithValue(firebase),
        authServiceProvider.overrideWithValue(auth ?? FakeAuthService()),
        accountIdentityProvider.overrideWithValue(identity),
        profileProvider.overrideWith((ref) => Stream.value(user)),
        profileRepositoryProvider.overrideWithValue(
          repo ?? FakeProfileRepository(),
        ),
        syncStatusProvider.overrideWith(
          () => sync ?? FakeSyncController(SyncStatus.disabled),
        ),
        badgesProvider.overrideWithValue(badges),
        effectiveLocaleProvider.overrideWithValue(locale),
      ],
      child: localizedTestApp(home: home, locale: locale),
    ),
  );
  await tester.pump();
}
