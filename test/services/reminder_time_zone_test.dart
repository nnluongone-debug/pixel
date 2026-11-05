import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_quest/services/reminder_time_zone.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

void main() {
  setUpAll(tz_data.initializeTimeZones);

  final now = DateTime.utc(2026, 10, 10, 12);

  test('known id is returned as is', () {
    expect(
      resolveLocalLocation('Asia/Ho_Chi_Minh', now: now).name,
      'Asia/Ho_Chi_Minh',
    );
  });

  test('every alias maps to a zone present in the database', () {
    for (final target in legacyTimeZoneAliases.values) {
      expect(() => tz.getLocation(target), returnsNormally, reason: target);
    }
  });

  test('legacy ids resolve to the same UTC offset as their target', () {
    for (final entry in legacyTimeZoneAliases.entries) {
      final legacy = resolveLocalLocation(entry.key, now: now);
      final target = tz.getLocation(entry.value);
      final instant = now.millisecondsSinceEpoch;
      expect(
        legacy.timeZone(instant).offset,
        target.timeZone(instant).offset,
        reason: entry.key,
      );
    }
  });

  test('unknown id falls back to a zone with the device offset', () {
    final loc = resolveLocalLocation('Mars/Olympus', now: now);
    expect(loc.timeZone(now.millisecondsSinceEpoch).offset, now.timeZoneOffset);
  });

  test('null id still resolves', () {
    expect(resolveLocalLocation(null, now: now), isA<tz.Location>());
  });
}
