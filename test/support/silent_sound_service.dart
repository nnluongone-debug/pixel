import 'package:pixel_quest/providers/sound_providers.dart';
import 'package:pixel_quest/services/sound/sound_service.dart';

class _SilentVoice implements SoundVoice {
  @override
  Future<void> start(double volume) async {}

  @override
  Future<void> dispose() async {}
}

/// Provider override that swaps the audio plugin for silent voices, so widget
/// tests can trigger sounds without platform channels.
final silentSoundOverride = soundServiceProvider.overrideWith(
  (ref) => SoundService(
    voiceFactory: (_, _) async => _SilentVoice(),
    configureSession: () async {},
  ),
);
