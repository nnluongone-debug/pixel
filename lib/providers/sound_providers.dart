import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/sound/sound_service.dart';
import '../services/sound/sound_slot.dart';
import 'cosmetics_providers.dart';
import 'habit_providers.dart';

/// Delay before the level-up jingle so it follows, not masks, the completion
/// sound that fires on the same progress event.
const _levelUpDelay = Duration(milliseconds: 350);

/// The sound engine, kept in sync with the equipped pack, the mute switch and
/// the volume. Also plays the level-up jingle for any progress event, so it is
/// heard once no matter which screen caused it; read or watch this provider
/// once at app start so the listener is active.
final soundServiceProvider = Provider<SoundService>((ref) {
  final service = SoundService();
  Timer? levelUpTimer;
  ref.onDispose(() {
    levelUpTimer?.cancel();
    service.dispose();
  });

  ref.listen(equippedSoundProvider, (_, pack) {
    service.loadPack(pack.name);
  }, fireImmediately: true);
  ref.listen(cosmeticSelectionProvider, (_, selection) {
    service
      ..enabled = selection.soundEnabled
      ..volume = selection.volume;
  }, fireImmediately: true);

  final sub = ref.read(progressEventsProvider).stream.listen((update) {
    if (!update.leveledUp) return;
    levelUpTimer?.cancel();
    levelUpTimer = Timer(_levelUpDelay, () => service.play(SoundSlot.levelUp));
  });
  ref.onDispose(sub.cancel);
  return service;
});

/// Fire-and-forget sound playback for widgets; never throws into the UI.
abstract final class SoundFx {
  static void play(BuildContext context, SoundSlot slot) =>
      _service(context)?.play(slot);

  /// Instantiates the engine early so the first sound is not lost.
  static void warmUp(BuildContext context) => _service(context);

  static SoundService? _service(BuildContext context) {
    try {
      return ProviderScope.containerOf(
        context,
        listen: false,
      ).read(soundServiceProvider);
    } catch (e) {
      debugPrint('Sound: engine unavailable: $e');
      return null;
    }
  }
}
