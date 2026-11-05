import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/sync/sync_service.dart';
import 'account_providers.dart';
import 'habit_providers.dart';
import 'new_unlocks_provider.dart';
import 'locale_providers.dart';
import 'repository_providers.dart';

enum SyncPhase {
  /// Guest mode or Firebase unavailable: nothing to sync.
  disabled,
  idle,
  syncing,
  offline,
  error,
}

class SyncStatus {
  const SyncStatus({
    required this.phase,
    this.lastSyncedAt,
    this.pendingCount = 0,
  });

  static const disabled = SyncStatus(phase: SyncPhase.disabled);

  final SyncPhase phase;
  final DateTime? lastSyncedAt;

  /// Local changes not yet uploaded.
  final int pendingCount;

  SyncStatus copyWith({
    SyncPhase? phase,
    DateTime? lastSyncedAt,
    int? pendingCount,
  }) => SyncStatus(
    phase: phase ?? this.phase,
    lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
    pendingCount: pendingCount ?? this.pendingCount,
  );
}

final firestoreProvider = Provider<FirebaseFirestore>(
  (ref) => FirebaseFirestore.instance,
);

final syncStatusProvider = NotifierProvider<SyncController, SyncStatus>(
  SyncController.new,
);

/// Cloud sync of the local SQLite data for the signed-in account. Syncs when
/// an account signs in, shortly after local changes, and on app resume.
/// Sync failures never throw: they show up as [SyncPhase.offline] or
/// [SyncPhase.error] and are retried on the next trigger.
class SyncController extends Notifier<SyncStatus> {
  static const _debounce = Duration(seconds: 2);
  static const _signOutPushTimeout = Duration(seconds: 5);

  SyncService? _service;
  Timer? _timer;
  Future<void>? _running;
  bool _rerun = false;
  bool _attached = false;

  /// Set while [signOutAndWipe] runs: no new sync may start.
  bool _closing = false;

  @override
  SyncStatus build() {
    _timer?.cancel();
    _attached = false;
    _closing = false;
    final user = ref.watch(authUserProvider).value;
    if (!ref.watch(firebaseAvailableProvider) || user == null) {
      _service = null;
      return SyncStatus.disabled;
    }
    final service = _service = SyncService(
      firestore: ref.watch(firestoreProvider),
      db: ref.watch(databaseProvider),
      prefs: ref.watch(sharedPreferencesProvider),
      uid: user.uid,
    );

    final events = ref
        .watch(progressEventsProvider)
        .stream
        .listen((_) => _onLocalChange(service));
    final lifecycle = AppLifecycleListener(onResume: syncNow);
    ref.listen(habitsControllerProvider, (_, next) {
      if (next.hasValue) _onLocalChange(service);
    });
    ref.onDispose(() {
      _timer?.cancel();
      events.cancel();
      lifecycle.dispose();
    });

    Future.microtask(syncNow);
    return const SyncStatus(phase: SyncPhase.idle);
  }

  /// Uploads pending changes and downloads remote ones now.
  Future<void> syncNow() => _sync();

  /// Uploads what it can, then signs out and clears this device back to an
  /// empty guest state. Returns 0 on success.
  ///
  /// If changes are still unsynced after the upload attempt (offline,
  /// rejected) and [discardPending] is false, nothing is signed out or
  /// wiped and the number of unsynced changes is returned: the UI should ask
  /// the user to confirm losing them and call again with
  /// `discardPending: true`. If signing out fails the local data is kept and
  /// the error propagates.
  Future<int> signOutAndWipe({bool discardPending = false}) async {
    final service = _service;
    final auth = ref.read(authServiceProvider);
    final habits = ref.read(habitsControllerProvider.notifier);
    _closing = true;
    _timer?.cancel();
    _service = null;
    try {
      while (_running != null) {
        await _running;
      }
      var pushFailed = false;
      var pending = 0;
      if (service != null) {
        try {
          await service.push().timeout(_signOutPushTimeout);
        } on Object {
          // Best effort: sign-out must still work offline.
          pushFailed = true;
        }
        pending = await _safePending(service);
        if (pending > 0 && !discardPending) {
          _service = service;
          _closing = false;
          state = state.copyWith(
            phase: pushFailed ? SyncPhase.offline : SyncPhase.idle,
            pendingCount: pending,
          );
          return pending;
        }
      }
      await auth.signOut();
      await service?.wipeLocal();
      ref.invalidate(newUnlocksProvider);
      habits.refreshAll();
      return 0;
    } on Object {
      _service ??= service;
      _closing = false;
      rethrow;
    }
  }

  /// Deletes the account with all its cloud data, then clears this device
  /// back to an empty guest state. Pending uploads are dropped: they would
  /// only be deleted again.
  Future<void> deleteAccountAndWipe() async {
    final service = _service;
    final auth = ref.read(authServiceProvider);
    final habits = ref.read(habitsControllerProvider.notifier);
    _closing = true;
    _timer?.cancel();
    _service = null;
    try {
      while (_running != null) {
        await _running;
      }
      await auth.deleteAccount();
      await service?.wipeLocal();
      ref.invalidate(newUnlocksProvider);
      habits.refreshAll();
    } on Object {
      _service ??= service;
      _closing = false;
      rethrow;
    }
  }

  Future<void> _onLocalChange(SyncService service) async {
    if (_closing || !ref.mounted || !identical(service, _service)) return;
    _timer?.cancel();
    _timer = Timer(_debounce, () => _sync(onlyIfPending: true));
    final pending = await service.pendingCount();
    if (ref.mounted && identical(service, _service)) {
      state = state.copyWith(pendingCount: pending);
    }
  }

  Future<void> _sync({bool onlyIfPending = false}) {
    final running = _running;
    if (running != null) {
      _rerun = true;
      return running;
    }
    final service = _service;
    if (_closing || service == null) return Future.value();
    return _running = _run(service, onlyIfPending).whenComplete(() {
      _running = null;
      if (_rerun && ref.mounted) {
        _rerun = false;
        unawaited(_sync());
      }
    });
  }

  Future<void> _run(SyncService service, bool onlyIfPending) async {
    bool current() => ref.mounted && identical(service, _service);
    try {
      if (onlyIfPending && await service.pendingCount() == 0) return;
      if (!current()) return;
      state = state.copyWith(phase: SyncPhase.syncing);
      final changed = await _exchange(service);
      if (!current()) return;
      if (changed) ref.read(habitsControllerProvider.notifier).refreshAll();
      state = SyncStatus(
        phase: SyncPhase.idle,
        lastSyncedAt: DateTime.now(),
        pendingCount: await service.pendingCount(),
      );
    } on Object catch (e) {
      if (!current()) return;
      final offline =
          e is TimeoutException ||
          (e is FirebaseException &&
              (e.code == 'unavailable' || e.code == 'deadline-exceeded'));
      state = state.copyWith(
        phase: offline ? SyncPhase.offline : SyncPhase.error,
        pendingCount: await _safePending(service),
      );
    }
  }

  /// The first run links the account; later ones are a plain push + pull.
  Future<bool> _exchange(SyncService service) async {
    if (!_attached) {
      final changed = await service.attach();
      _attached = true;
      return changed;
    }
    await service.push();
    return service.pull();
  }

  Future<int> _safePending(SyncService service) async {
    try {
      return await service.pendingCount();
    } on Object {
      return state.pendingCount;
    }
  }
}
