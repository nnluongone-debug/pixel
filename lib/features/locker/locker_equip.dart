import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/cosmetics/theme_catalog.dart';
import '../../providers/cosmetics_providers.dart';
import '../../providers/sound_providers.dart';
import '../../services/sound/sound_slot.dart';

/// Equip and preview flows shared by the vault and the unlock popup.
abstract final class LockerEquip {
  /// Equips theme [id] (skin + its sound pack) with a haptic tick and a
  /// preview of the new pack's `complete` sound.
  static Future<void> equip(WidgetRef ref, ThemeId id) async {
    final ok = await ref.read(cosmeticSelectionProvider.notifier).equip(id);
    if (!ok) return;
    HapticFeedback.selectionClick();
    previewSound(ref, ThemeCatalog.of(id).sound, const [SoundSlot.complete]);
  }

  /// Plays slots of any pack, equipped or not. Never throws into the UI.
  static void previewSound(
    WidgetRef ref,
    SoundPackId pack,
    List<SoundSlot> slots,
  ) {
    try {
      ref.read(soundServiceProvider).preview(pack.name, slots);
    } catch (e) {
      debugPrint('Locker: sound preview failed: $e');
    }
  }
}
