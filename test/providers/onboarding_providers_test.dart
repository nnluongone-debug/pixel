import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_quest/data/database/app_database.dart';
import 'package:pixel_quest/data/models/habit.dart';
import 'package:pixel_quest/providers/locale_providers.dart';
import 'package:pixel_quest/providers/onboarding_providers.dart';
import 'package:pixel_quest/providers/repository_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();

  late Database db;
  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    db = await AppDatabase.open(
      factory: databaseFactoryFfiNoIsolate,
      path: inMemoryDatabasePath,
    );
  });

  tearDown(() => db.close());

  ProviderContainer container() => ProviderContainer(
    overrides: [
      databaseProvider.overrideWithValue(db),
      sharedPreferencesProvider.overrideWithValue(prefs),
    ],
  );

  test('complete and reset persist the flag', () async {
    final c = container();
    addTearDown(c.dispose);
    expect(c.read(onboardingDoneProvider), isFalse);

    await c.read(onboardingDoneProvider.notifier).complete();
    expect(c.read(onboardingDoneProvider), isTrue);
    expect(prefs.getBool(onboardingDoneKey), isTrue);

    await c.read(onboardingDoneProvider.notifier).reset();
    expect(c.read(onboardingDoneProvider), isFalse);
    expect(prefs.getBool(onboardingDoneKey), isFalse);
  });

  test('fresh install keeps the intro', () async {
    await markExistingUsersOnboarded(prefs, db);
    expect(prefs.containsKey(onboardingDoneKey), isFalse);
  });

  test('users with habits skip the intro after updating', () async {
    final c = container();
    addTearDown(c.dispose);
    await c
        .read(habitRepositoryProvider)
        .createHabit(
          name: 'Read',
          type: HabitType.checklist,
          target: 1,
          colorHex: '#F9CA24',
          iconName: 'book',
        );

    await markExistingUsersOnboarded(prefs, db);
    expect(prefs.getBool(onboardingDoneKey), isTrue);
  });

  test('an explicit replay choice is never overwritten', () async {
    await prefs.setBool(onboardingDoneKey, false);
    final c = container();
    addTearDown(c.dispose);
    await c
        .read(habitRepositoryProvider)
        .createHabit(
          name: 'Run',
          type: HabitType.checklist,
          target: 1,
          colorHex: '#2DE38E',
          iconName: 'run',
        );

    await markExistingUsersOnboarded(prefs, db);
    expect(prefs.getBool(onboardingDoneKey), isFalse);
  });
}
