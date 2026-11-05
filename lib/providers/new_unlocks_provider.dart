import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'locale_providers.dart';

/// What kind of reward an unlock is.
enum UnlockKind {
  badge('new_badges'),
  theme('new_cosmetics');

  const UnlockKind(this.prefsKey);
  final String prefsKey;
}

/// Unlocked badges / themes the player hasn't looked at yet. Drives the
/// "NEW" dots on the nav bar and the NEW chips on cards, so an unlock is
/// noticed even when it arrived without a popup (sync, reinstall, demo).
final newUnlocksProvider =
    NotifierProvider<NewUnlocks, Map<UnlockKind, Set<String>>>(NewUnlocks.new);

class NewUnlocks extends Notifier<Map<UnlockKind, Set<String>>> {
  @override
  Map<UnlockKind, Set<String>> build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    return {
      for (final kind in UnlockKind.values)
        kind: (prefs.getStringList(kind.prefsKey) ?? const []).toSet(),
    };
  }

  bool has(UnlockKind kind) => state[kind]!.isNotEmpty;

  Future<void> add(UnlockKind kind, Iterable<String> ids) =>
      _save(kind, {...state[kind]!, ...ids});

  /// Clears [kind] once the player has seen the screen listing it.
  Future<void> acknowledge(UnlockKind kind) async {
    if (state[kind]!.isEmpty) return;
    await _save(kind, const {});
  }

  Future<void> _save(UnlockKind kind, Set<String> ids) async {
    state = {...state, kind: ids};
    await ref
        .read(sharedPreferencesProvider)
        .setStringList(kind.prefsKey, ids.toList());
  }
}
