import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/repositories/cosmetics_repository.dart';
import '../domain/cosmetics/theme_catalog.dart';
import '../domain/progression/xp_rules.dart';
import 'account_providers.dart';
import 'habit_providers.dart';
import 'locale_providers.dart';
import 'repository_providers.dart';
import 'sync_providers.dart';

final cosmeticsRepositoryProvider = Provider<CosmeticsRepository>(
  (ref) => CosmeticsRepository(
    ref.watch(sharedPreferencesProvider),
    firestore: ref.watch(firebaseAvailableProvider)
        ? ref.watch(firestoreProvider)
        : null,
  ),
);

/// Best-ever global streak (days with nothing due don't break it).
/// Refreshes after every mutation via the habit list.
final bestStreakProvider = FutureProvider<int>((ref) async {
  await ref.watch(habitsControllerProvider.future);
  return ref.watch(userStatsRepositoryProvider).getBestStreak();
});

/// Level, lifetime XP and best streak; null until loaded, so callers can
/// avoid flashing locked fallbacks at startup.
final playerProgressProvider = Provider<ThemeProgress?>((ref) {
  final stats = ref.watch(userStatsProvider).value;
  final best = ref.watch(bestStreakProvider).value;
  if (stats == null || best == null) return null;
  return (
    level: stats.currentLevel,
    totalXp: XpRules.totalXpForLevel(stats.currentLevel) + stats.currentXp,
    bestStreak: best,
  );
});

/// Pro entitlement. Always false until purchases ship (plan phase 6).
final hasProProvider = Provider<bool>((ref) => false);

/// Themes the player can equip right now.
final unlockedThemesProvider = Provider<Set<ThemeId>>((ref) {
  final progress = ref.watch(playerProgressProvider);
  final hasPro = ref.watch(hasProProvider);
  return {
    for (final theme in ThemeCatalog.all)
      if (progress == null
          ? theme.unlock.isFree
          : theme.isUnlocked(progress, hasPro: hasPro))
        theme.id,
  };
});

final cosmeticSelectionProvider =
    NotifierProvider<CosmeticSelectionController, CosmeticSelection>(
      CosmeticSelectionController.new,
    );

/// The stored theme plus sound settings. Equipping is persisted locally and
/// mirrored to the signed-in account; on sign-in the newer copy wins.
class CosmeticSelectionController extends Notifier<CosmeticSelection> {
  @override
  CosmeticSelection build() {
    final repo = ref.watch(cosmeticsRepositoryProvider);
    ref.listen(authUserProvider, (_, next) {
      final user = next.value;
      if (user != null) _reconcile(user.uid, user.email);
    }, fireImmediately: true);
    return repo.load();
  }

  /// Equips [id] (skin + its sound pack) if unlocked; false when locked.
  Future<bool> equip(ThemeId id) async {
    // read, not watch: equipping must not make this notifier rebuild on
    // every later progress change.
    final progress = ref.read(playerProgressProvider);
    final theme = ThemeCatalog.of(id);
    if (progress != null &&
        !theme.isUnlocked(progress, hasPro: ref.read(hasProProvider))) {
      return false;
    }
    state = state.copyWith(
      theme: id,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );
    await ref.read(cosmeticsRepositoryProvider).save(state);
    _push();
    return true;
  }

  Future<void> setSoundEnabled(bool enabled) =>
      _saveSettings(state.copyWith(soundEnabled: enabled));

  /// Pass `persist: false` while a slider is dragging and persist on release.
  Future<void> setVolume(double volume, {bool persist = true}) {
    final next = state.copyWith(volume: volume.clamp(0.0, 1.0));
    if (!persist) {
      state = next;
      return Future.value();
    }
    return _saveSettings(next);
  }

  Future<void> _saveSettings(CosmeticSelection next) async {
    state = next;
    await ref.read(cosmeticsRepositoryProvider).saveSettings(next);
  }

  void _push() {
    final user = ref.read(authUserProvider).value;
    final email = user?.email;
    if (user == null || email == null) return;
    ref
        .read(cosmeticsRepositoryProvider)
        .pushRemote(user.uid, email, state)
        .catchError((Object e) => debugPrint('Cosmetics push failed: $e'));
  }

  Future<void> _reconcile(String uid, String? email) async {
    try {
      final repo = ref.read(cosmeticsRepositoryProvider);
      final remote = await repo.fetchRemote(uid);
      if (!ref.mounted) return;
      if (remote != null && remote.updatedAt > state.updatedAt) {
        state = state.copyWith(
          theme: remote.theme,
          updatedAt: remote.updatedAt,
        );
        await repo.save(state);
      } else if (state.updatedAt > (remote?.updatedAt ?? -1) && email != null) {
        await repo.pushRemote(uid, email, state);
      }
    } catch (e) {
      debugPrint('Cosmetics reconcile failed: $e');
    }
  }
}

/// Theme to draw with: the choice, or the default if it is no longer
/// unlocked. The stored choice is kept for later. While progress loads the
/// stored choice is trusted, so the look doesn't flash at startup.
final equippedThemeProvider = Provider<ThemeId>((ref) {
  final chosen = ref.watch(cosmeticSelectionProvider).theme;
  final progress = ref.watch(playerProgressProvider);
  if (progress == null) return chosen;
  final ok = ThemeCatalog.of(
    chosen,
  ).isUnlocked(progress, hasPro: ref.watch(hasProProvider));
  return ok ? chosen : ThemeCatalog.defaultTheme.id;
});

/// Sound pack of the equipped theme.
final equippedSoundProvider = Provider<SoundPackId>(
  (ref) => ThemeCatalog.of(ref.watch(equippedThemeProvider)).sound,
);
