import 'package:timezone/timezone.dart' as tz;

/// Legacy / alternate IANA ids that platforms still report but newer
/// tz databases rename. Lookups try the id as given first.
const Map<String, String> legacyTimeZoneAliases = {
  'Asia/Saigon': 'Asia/Ho_Chi_Minh',
  'Asia/Calcutta': 'Asia/Kolkata',
  'Asia/Katmandu': 'Asia/Kathmandu',
  'Asia/Rangoon': 'Asia/Yangon',
  'Asia/Dacca': 'Asia/Dhaka',
  'Europe/Kiev': 'Europe/Kyiv',
  'America/Buenos_Aires': 'America/Argentina/Buenos_Aires',
  'Pacific/Samoa': 'Pacific/Pago_Pago',
  'Atlantic/Faeroe': 'Atlantic/Faroe',
};

/// Resolves the device zone to a tz [tz.Location]: the reported [id], then
/// its legacy alias, then any zone whose UTC offset at [now] matches the
/// device's (so prompts fire at the right wall-clock time even for an
/// unknown id), and finally UTC.
tz.Location resolveLocalLocation(String? id, {required DateTime now}) {
  for (final candidate in [id, legacyTimeZoneAliases[id]]) {
    if (candidate == null) continue;
    try {
      return tz.getLocation(candidate);
    } on tz.LocationNotFoundException {
      continue;
    }
  }
  final offset = now.timeZoneOffset;
  final instant = now.millisecondsSinceEpoch;
  final names = tz.timeZoneDatabase.locations.keys.toList()..sort();
  for (final name in names) {
    final location = tz.timeZoneDatabase.locations[name]!;
    if (location.timeZone(instant).offset == offset) return location;
  }
  return tz.UTC;
}
