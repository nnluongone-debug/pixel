/// Every event that can make a sound. The slot name is also the WAV file name
/// inside each pack folder (`assets/sounds/<packId>/<slot>.wav`).
enum SoundSlot {
  tap(minGap: Duration(milliseconds: 40), maxPlayers: 3),
  increment(minGap: Duration(milliseconds: 40), maxPlayers: 3),
  undo(minGap: Duration(milliseconds: 60)),
  complete,
  // Demo seeding drops ~150 bricks at once; cap it at about 8 per second.
  brickLand(minGap: Duration(milliseconds: 125), maxPlayers: 4),
  rowClear(minGap: Duration(milliseconds: 150)),
  levelUp,
  badgeUnlock,
  focusStart,
  focusStop;

  const SoundSlot({
    this.minGap = const Duration(milliseconds: 80),
    this.maxPlayers = 2,
  });

  /// Shortest allowed time between two plays; faster requests are dropped.
  final Duration minGap;

  /// Overlapping voices kept alive for this slot.
  final int maxPlayers;

  /// Asset path relative to the `assets/` folder, as `AssetSource` expects.
  String assetPath(String packId) => 'sounds/$packId/$name.wav';
}
