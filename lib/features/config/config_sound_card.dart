import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../locker/locker_names.dart';
import '../../core/l10n/l10n.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/cosmetics_providers.dart';
import '../../providers/sound_providers.dart';
import '../../services/sound/sound_slot.dart';

/// Sound settings: master switch, volume, the equipped pack and a preview.
class ConfigSoundCard extends ConsumerStatefulWidget {
  const ConfigSoundCard({super.key});

  @override
  ConsumerState<ConfigSoundCard> createState() => _ConfigSoundCardState();
}

class _ConfigSoundCardState extends ConsumerState<ConfigSoundCard> {
  Timer? _previewTimer;

  /// Plays the completion sound, then the level-up jingle.
  void _preview() {
    final sound = ref.read(soundServiceProvider);
    sound.play(SoundSlot.complete);
    _previewTimer?.cancel();
    _previewTimer = Timer(
      const Duration(milliseconds: 450),
      () => sound.play(SoundSlot.levelUp),
    );
  }

  @override
  void dispose() {
    _previewTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final selection = ref.watch(cosmeticSelectionProvider);
    final controller = ref.read(cosmeticSelectionProvider.notifier);
    final pack = ref.watch(equippedSoundProvider);
    final enabled = selection.soundEnabled;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: AppGlow.card(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                enabled ? Icons.volume_up_outlined : Icons.volume_off_outlined,
                color: AppColors.cyan,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  l10n.soundCardTitle,
                  style: AppTextStyles.headlineSm,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Switch(value: enabled, onChanged: controller.setSoundEnabled),
            ],
          ),
          Text(
            l10n.soundPackLabel(l10n.soundPackName(pack)),
            style: AppTextStyles.labelSm,
          ),
          Row(
            children: [
              Text(l10n.soundVolume, style: AppTextStyles.labelMd),
              Expanded(
                child: Slider(
                  value: selection.volume,
                  onChanged: enabled
                      ? (v) => controller.setVolume(v, persist: false)
                      : null,
                  onChangeEnd: enabled ? controller.setVolume : null,
                ),
              ),
            ],
          ),
          OutlinedButton(
            onPressed: enabled ? _preview : null,
            child: Text(l10n.soundPreview),
          ),
        ],
      ),
    );
  }
}
