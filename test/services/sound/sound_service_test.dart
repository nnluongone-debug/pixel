import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_quest/domain/cosmetics/theme_catalog.dart';
import 'package:pixel_quest/services/sound/sound_service.dart';
import 'package:pixel_quest/services/sound/sound_slot.dart';

class _FakeVoice implements SoundVoice {
  _FakeVoice(this.path, this.log);

  final String path;
  final List<String> log;
  bool disposed = false;

  @override
  Future<void> start(double volume) async => log.add('$path@$volume');

  @override
  Future<void> dispose() async => disposed = true;
}

void main() {
  late List<String> played;
  late List<_FakeVoice> created;
  late DateTime clock;
  late SoundService service;

  setUp(() {
    played = [];
    created = [];
    clock = DateTime(2026, 1, 1);
    service = SoundService(
      voiceFactory: (path, _) async {
        final voice = _FakeVoice(path, played);
        created.add(voice);
        return voice;
      },
      configureSession: () async {},
      now: () => clock,
    );
  });

  test('slot maps to pack asset path', () {
    expect(
      SoundSlot.badgeUnlock.assetPath('synthPop'),
      'sounds/synthPop/badgeUnlock.wav',
    );
  });

  test('plays only after the pack is loaded', () async {
    service.play(SoundSlot.tap);
    expect(played, isEmpty);
    await service.loadPack('chiptune');
    service.play(SoundSlot.tap);
    expect(played, ['sounds/chiptune/tap.wav@1.0']);
  });

  test('respects enabled flag and clamped volume', () async {
    await service.loadPack('chiptune');
    service.enabled = false;
    service.play(SoundSlot.complete);
    expect(played, isEmpty);
    service
      ..enabled = true
      ..volume = 7;
    expect(service.volume, 1.0);
    service.volume = 0.4;
    service.play(SoundSlot.complete);
    expect(played, ['sounds/chiptune/complete.wav@0.4']);
    service.volume = 0;
    clock = clock.add(const Duration(seconds: 1));
    service.play(SoundSlot.complete);
    expect(played, hasLength(1));
  });

  test('rate limits brickLand bursts to about 8 per second', () async {
    await service.loadPack('chiptune');
    for (var i = 0; i < 150; i++) {
      service.play(SoundSlot.brickLand);
      clock = clock.add(const Duration(milliseconds: 2));
    }
    // 150 requests over 300 ms with a 125 ms gap: at most 3 get through.
    expect(played.length, inInclusiveRange(1, 3));
    clock = clock.add(const Duration(milliseconds: 125));
    service.play(SoundSlot.brickLand);
    expect(played.length, inInclusiveRange(2, 4));
  });

  test('other slots are limited independently', () async {
    await service.loadPack('chiptune');
    service
      ..play(SoundSlot.tap)
      ..play(SoundSlot.complete)
      ..play(SoundSlot.tap);
    expect(played, hasLength(2));
  });

  test('switching packs disposes the old voices and loads the new', () async {
    await service.loadPack('chiptune');
    final first = List.of(created);
    expect(first, hasLength(SoundSlot.values.length));
    await service.loadPack('synthPop');
    expect(first.every((v) => v.disposed), isTrue);
    expect(service.packId, 'synthPop');
    service.play(SoundSlot.levelUp);
    expect(played, ['sounds/synthPop/levelUp.wav@1.0']);
  });

  test('a failing slot is skipped without throwing', () async {
    service = SoundService(
      voiceFactory: (path, _) async {
        if (path.endsWith('tap.wav')) throw StateError('missing asset');
        return _FakeVoice(path, played);
      },
      configureSession: () async {},
      now: () => clock,
    );
    await service.loadPack('chiptune');
    service
      ..play(SoundSlot.tap)
      ..play(SoundSlot.undo);
    expect(played, ['sounds/chiptune/undo.wav@1.0']);
  });

  test('a failing audio session does not block loading', () async {
    service = SoundService(
      voiceFactory: (path, _) async => _FakeVoice(path, played),
      configureSession: () async => throw StateError('no platform'),
      now: () => clock,
    );
    await service.loadPack('chiptune');
    service.play(SoundSlot.tap);
    expect(played, hasLength(1));
  });

  test(
    'preview plays another pack in order and disposes temp voices',
    () async {
      await service.loadPack('chiptune');
      final before = created.length;
      await service.preview('synthPop', [
        SoundSlot.complete,
        SoundSlot.levelUp,
      ], gap: const Duration(milliseconds: 1));
      expect(played, [
        'sounds/synthPop/complete.wav@1.0',
        'sounds/synthPop/levelUp.wav@1.0',
      ]);
      expect(created.skip(before).every((v) => v.disposed), isTrue);
      expect(created.take(before).any((v) => v.disposed), isFalse);
      expect(service.packId, 'chiptune');
    },
  );

  test('preview keeps the last voice alive for the tail', () async {
    final done = service.preview('synthPop', [
      SoundSlot.levelUp,
    ], tail: const Duration(milliseconds: 80));
    await Future<void>.delayed(const Duration(milliseconds: 30));
    expect(created.single.disposed, isFalse);
    await done;
    expect(created.single.disposed, isTrue);
  });

  test('a new preview cancels the previous one', () async {
    final first = service.preview('synthPop', [
      SoundSlot.complete,
      SoundSlot.levelUp,
    ], gap: const Duration(seconds: 5));
    await Future<void>.delayed(const Duration(milliseconds: 10));
    final firstVoices = List.of(created);
    final second = service.preview('chiptune', [
      SoundSlot.tap,
    ], tail: const Duration(milliseconds: 10));
    await first; // returns promptly instead of waiting 5 s
    expect(firstVoices.single.disposed, isTrue);
    expect(played.where((p) => p.contains('levelUp')), isEmpty);
    await second;
    expect(created.every((v) => v.disposed), isTrue);
  });

  test('preview honors mute', () async {
    service.enabled = false;
    await service.preview('synthPop', [SoundSlot.complete]);
    expect(played, isEmpty);
  });

  test('every pack ships every slot file', () {
    for (final pack in SoundPackId.values) {
      for (final slot in SoundSlot.values) {
        final file = File('assets/${slot.assetPath(pack.name)}');
        expect(file.existsSync(), isTrue, reason: file.path);
        expect(file.lengthSync(), greaterThan(1000), reason: file.path);
      }
    }
  });
}
