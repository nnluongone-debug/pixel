import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_quest/data/database/app_database.dart';
import 'package:pixel_quest/data/models/habit.dart';
import 'package:pixel_quest/providers/account_providers.dart';
import 'package:pixel_quest/providers/habit_providers.dart';
import 'package:pixel_quest/providers/locale_providers.dart';
import 'package:pixel_quest/providers/repository_providers.dart';
import 'package:pixel_quest/providers/sync_providers.dart';
import 'package:pixel_quest/services/auth/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class _FakeUser implements User {
  @override
  String get uid => 'user-1';

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeAuth extends AuthService {
  int signOuts = 0;

  @override
  Future<void> signOut() async => signOuts++;
}

/// Every upload fails as if the network were down.
class _OfflineFirestore extends FakeFirebaseFirestore {
  @override
  WriteBatch batch() =>
      throw FirebaseException(plugin: 'cloud_firestore', code: 'unavailable');
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();

  late Database db;
  late _FakeAuth auth;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    db = await AppDatabase.open(
      factory: databaseFactoryFfiNoIsolate,
      path: inMemoryDatabasePath,
    );
    auth = _FakeAuth();
  });

  tearDown(() => db.close());

  Future<ProviderContainer> start(FirebaseFirestore firestore) async {
    final container = ProviderContainer(
      overrides: [
        firebaseAvailableProvider.overrideWithValue(true),
        authUserProvider.overrideWith((ref) => Stream.value(_FakeUser())),
        authServiceProvider.overrideWithValue(auth),
        firestoreProvider.overrideWithValue(firestore),
        databaseProvider.overrideWithValue(db),
        sharedPreferencesProvider.overrideWithValue(
          await SharedPreferences.getInstance(),
        ),
      ],
    );
    addTearDown(container.dispose);
    container.listen(authUserProvider, (_, _) {});
    await pumpEventQueue();
    container.listen(syncStatusProvider, (_, _) {});
    container.listen(habitsControllerProvider, (_, _) {});
    return container;
  }

  Future<void> addHabit(ProviderContainer c) => c
      .read(habitsControllerProvider.notifier)
      .create(
        name: 'Water',
        type: HabitType.checklist,
        target: 1,
        colorHex: '#00E5FF',
        iconName: 'water_drop',
      );

  test('signOutAndWipe uploads, signs out and wipes', () async {
    final container = await start(FakeFirebaseFirestore());
    await addHabit(container);

    final pending = await container
        .read(syncStatusProvider.notifier)
        .signOutAndWipe();

    expect(pending, 0);
    expect(auth.signOuts, 1);
    expect(await db.query('habits'), isEmpty);
  });

  test('signOutAndWipe refuses while changes are unsynced', () async {
    final container = await start(_OfflineFirestore());
    await addHabit(container);
    final sync = container.read(syncStatusProvider.notifier);

    expect(await sync.signOutAndWipe(), 1);
    expect(auth.signOuts, 0);
    expect(await db.query('habits'), hasLength(1));
    expect(container.read(syncStatusProvider).pendingCount, 1);

    // The controller still works after a refused sign-out.
    await sync.syncNow();
    expect(container.read(syncStatusProvider).phase, SyncPhase.offline);

    expect(await sync.signOutAndWipe(discardPending: true), 0);
    expect(auth.signOuts, 1);
    expect(await db.query('habits'), isEmpty);
  });

  test('signOutAndWipe waits for a sync in flight, then wipes', () async {
    final container = await start(FakeFirebaseFirestore());
    await addHabit(container);
    final sync = container.read(syncStatusProvider.notifier);

    final running = sync.syncNow();
    final result = await sync.signOutAndWipe(discardPending: true);
    await running;

    expect(result, 0);
    expect(await db.query('habits'), isEmpty);
    expect(await db.query('sync_outbox'), isEmpty);
    expect(auth.signOuts, 1);
  });
}
