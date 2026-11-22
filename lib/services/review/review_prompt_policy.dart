/// When it is polite to show the store's in-app review sheet.
///
/// Asked only right after a happy moment the player just earned (badge,
/// theme), never on first days, at most [maxPrompts] times in total and no
/// more than once per [cooldown]. Google/Apple add their own quotas on top,
/// so the sheet may still not appear.
class ReviewPromptPolicy {
  const ReviewPromptPolicy({
    this.minAge = const Duration(days: 3),
    this.cooldown = const Duration(days: 60),
    this.maxPrompts = 3,
  });

  /// Time since the first launch before the first ask.
  final Duration minAge;

  /// Gap between two asks.
  final Duration cooldown;

  /// Lifetime cap of asks.
  final int maxPrompts;

  bool shouldAsk({
    required DateTime now,
    required DateTime firstSeen,
    required DateTime? lastAsked,
    required int askedCount,
  }) {
    if (askedCount >= maxPrompts) return false;
    if (now.difference(firstSeen) < minAge) return false;
    if (lastAsked != null && now.difference(lastAsked) < cooldown) {
      return false;
    }
    return true;
  }
}
