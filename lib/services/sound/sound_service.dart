import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

import 'sound_slot.dart';

/// A preloaded, replayable voice for one slot.
abstract interface class SoundVoice {
  Future<void> start(double volume);
  Future<void> dispose();
}

/// Creates the [SoundVoice] for one asset (path relative to `assets/`).
typedef SoundVoiceFactory =
    Future<SoundVoice> Function(String assetPath, int maxPlayers);

class _PoolVoice implements SoundVoice {
  _PoolVoice(this._pool);

  final AudioPool _pool;

  @override
  Future<void> start(double volume) => _pool.start(volume: volume);

  @override
  Future<void> dispose() => _pool.dispose();
}

Future<SoundVoice> _createPoolVoice(String assetPath, int maxPlayers) async =>
    _PoolVoice(
      // Fully pre-created so overlapping plays never build a player on the fly.
      await AudioPool.createFromAsset(
        path: assetPath,
        maxPlayers: maxPlayers,
        minPlayers: maxPlayers,
      ),
    );

/// Ambient audio session: respects the iOS silent switch, mixes with the
/// user's music and never takes Android audio focus.
Future<void> _configureAudioSession() => AudioPlayer.global.setAudioContext(
  AudioContext(
    iOS: AudioContextIOS(category: AVAudioSessionCategory.ambient),
    android: const AudioContextAndroid(
      usageType: AndroidUsageType.game,
      contentType: AndroidContentType.sonification,
      audioFocus: AndroidAudioFocus.none,
    ),
  ),
);

/// Low-latency sound effects for the equipped pack. Nothing here throws into
/// the UI: load and playback failures are logged and the sound is skipped.
class SoundService {
  SoundService({
    SoundVoiceFactory? voiceFactory,
    Future<void> Function()? configureSession,
    DateTime Function()? now,
  }) : _voiceFactory = voiceFactory ?? _createPoolVoice,
       _configureSession = configureSession ?? _configureAudioSession,
       _now = now ?? DateTime.now;

  final SoundVoiceFactory _voiceFactory;
  final Future<void> Function() _configureSession;
  final DateTime Function() _now;

  final Map<SoundSlot, SoundVoice> _voices = {};
  final Map<SoundSlot, DateTime> _lastPlayed = {};
  bool _sessionReady = false;
  bool _disposed = false;
  int _loadGeneration = 0;
  Completer<void>? _previewCancel;
  String? _packId;

  bool enabled = true;
  double _volume = 1.0;

  String? get packId => _packId;
  double get volume => _volume;
  set volume(double value) => _volume = value.clamp(0.0, 1.0);

  /// Preloads every slot of [packId], replacing the previous pack. A newer
  /// call supersedes one still in flight.
  Future<void> loadPack(String packId) async {
    final generation = ++_loadGeneration;
    _packId = packId;
    await _releaseVoices();
    if (!_sessionReady) {
      try {
        await _configureSession();
        _sessionReady = true;
      } catch (e) {
        debugPrint('Sound: audio session setup failed: $e');
      }
    }
    final loaded = <SoundSlot, SoundVoice>{};
    await Future.wait([
      for (final slot in SoundSlot.values)
        () async {
          try {
            loaded[slot] = await _voiceFactory(
              slot.assetPath(packId),
              slot.maxPlayers,
            );
          } catch (e) {
            debugPrint('Sound: ${slot.name} failed: $e');
          }
        }(),
    ]);
    if (_disposed || generation != _loadGeneration) {
      await Future.wait(loaded.values.map(_safeDispose));
      return;
    }
    _voices.addAll(loaded);
  }

  /// Plays [slot] unless muted, not loaded yet or fired too soon after the
  /// previous play of the same slot.
  void play(SoundSlot slot) {
    if (!enabled || _volume <= 0) return;
    final voice = _voices[slot];
    if (voice == null) return;
    final now = _now();
    final last = _lastPlayed[slot];
    if (last != null && now.difference(last) < slot.minGap) return;
    _lastPlayed[slot] = now;
    unawaited(
      voice
          .start(_volume)
          .catchError((Object e) => debugPrint('Sound: ${slot.name}: $e')),
    );
  }

  /// Plays [slots] of [packId] one after another with [gap] between starts,
  /// using temporary voices so the equipped pack is untouched, then keeps the
  /// voices alive for [tail] so the last sound rings out. Honors mute and
  /// volume; ignores the per-slot rate limit. A new preview cancels the one
  /// in progress. Never throws.
  Future<void> preview(
    String packId,
    List<SoundSlot> slots, {
    Duration gap = const Duration(milliseconds: 600),
    Duration tail = const Duration(milliseconds: 1300),
  }) async {
    _previewCancel?.complete();
    if (!enabled || _volume <= 0 || _disposed) return;
    final cancel = _previewCancel = Completer<void>();
    // Resolves false when this preview was superseded.
    Future<bool> wait(Duration d) async {
      await Future.any([Future<void>.delayed(d), cancel.future]);
      return !cancel.isCompleted;
    }

    final temp = <SoundVoice>[];
    try {
      for (final slot in slots) {
        if (cancel.isCompleted) break;
        try {
          final voice = await _voiceFactory(
            slot.assetPath(packId),
            slot.maxPlayers,
          );
          temp.add(voice);
          if (cancel.isCompleted) break;
          await voice.start(_volume);
        } catch (e) {
          debugPrint('Sound: preview ${slot.name} failed: $e');
        }
        if (!await wait(slot == slots.last ? tail : gap)) break;
      }
    } finally {
      if (identical(_previewCancel, cancel)) _previewCancel = null;
      await Future.wait(temp.map(_safeDispose));
    }
  }

  Future<void> dispose() async {
    _disposed = true;
    _previewCancel?.complete();
    await _releaseVoices();
  }

  Future<void> _releaseVoices() async {
    final old = _voices.values.toList();
    _voices.clear();
    await Future.wait(old.map(_safeDispose));
  }

  Future<void> _safeDispose(SoundVoice voice) async {
    try {
      await voice.dispose();
    } catch (e) {
      debugPrint('Sound: dispose failed: $e');
    }
  }
}
