import 'package:flutter/foundation.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../usage/usage_analytics.dart';
import 'review_prompt_policy.dart';

/// Shows the native review sheet when [ReviewPromptPolicy] allows it and
/// keeps the bookkeeping (first launch, last ask, ask count) in prefs.
class ReviewPrompter {
  ReviewPrompter({
    required this._prefs,
    required this._analytics,
    InAppReview? review,
    this.policy = const ReviewPromptPolicy(),
    DateTime Function()? clock,
  }) : _review = review ?? InAppReview.instance,
       _clock = clock ?? DateTime.now;

  static const firstSeenKey = 'review_first_seen_ms';
  static const lastAskedKey = 'review_last_asked_ms';
  static const askedCountKey = 'review_asked_count';

  final SharedPreferences _prefs;
  final UsageAnalytics _analytics;
  final InAppReview _review;
  final ReviewPromptPolicy policy;
  final DateTime Function() _clock;

  /// Records the first launch once; later calls keep the original date.
  Future<void> markFirstSeen() async {
    if (_prefs.containsKey(firstSeenKey)) return;
    await _prefs.setInt(firstSeenKey, _clock().millisecondsSinceEpoch);
  }

  /// Asks for a review if allowed. [trigger] is a short tag for analytics,
  /// e.g. `badge` or `theme`. Returns whether the sheet was requested.
  Future<bool> maybeAsk({required String trigger}) async {
    final now = _clock();
    final firstSeenMs = _prefs.getInt(firstSeenKey);
    if (firstSeenMs == null) {
      await markFirstSeen();
      return false;
    }
    final lastAskedMs = _prefs.getInt(lastAskedKey);
    final count = _prefs.getInt(askedCountKey) ?? 0;
    final allowed = policy.shouldAsk(
      now: now,
      firstSeen: DateTime.fromMillisecondsSinceEpoch(firstSeenMs),
      lastAsked: lastAskedMs == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(lastAskedMs),
      askedCount: count,
    );
    if (!allowed) return false;
    try {
      if (!await _review.isAvailable()) return false;
      // Count the ask before showing it: the API never says whether the
      // sheet appeared, and a crash must not lead to re-asking at once.
      await _prefs.setInt(lastAskedKey, now.millisecondsSinceEpoch);
      await _prefs.setInt(askedCountKey, count + 1);
      await _review.requestReview();
      await _analytics.reviewRequested(trigger);
      return true;
    } catch (e) {
      debugPrint('In-app review failed: $e');
      return false;
    }
  }
}
