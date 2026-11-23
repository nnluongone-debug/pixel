import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:pixel_quest/services/review/review_prompter.dart';
import 'package:pixel_quest/services/usage/usage_analytics.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeReview implements InAppReview {
  _FakeReview({this.available = true});

  final bool available;
  int requests = 0;

  @override
  Future<bool> isAvailable() async => available;

  @override
  Future<void> requestReview() async => requests++;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late SharedPreferences prefs;
  var now = DateTime(2026, 11, 1);

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    now = DateTime(2026, 11, 1);
  });

  ReviewPrompter prompter(_FakeReview review) => ReviewPrompter(
    prefs: prefs,
    analytics: const UsageAnalytics(),
    review: review,
    clock: () => now,
  );

  test('never asks on the first days, then asks once', () async {
    final review = _FakeReview();
    final p = prompter(review);
    await p.markFirstSeen();

    expect(await p.maybeAsk(trigger: 'badge'), isFalse);
    now = now.add(const Duration(days: 5));
    expect(await p.maybeAsk(trigger: 'badge'), isTrue);
    // Cooldown blocks an immediate second ask.
    expect(await p.maybeAsk(trigger: 'theme'), isFalse);
    expect(review.requests, 1);
    expect(prefs.getInt(ReviewPrompter.askedCountKey), 1);
  });

  test('markFirstSeen keeps the original date', () async {
    final p = prompter(_FakeReview());
    await p.markFirstSeen();
    final first = prefs.getInt(ReviewPrompter.firstSeenKey);
    now = now.add(const Duration(days: 9));
    await p.markFirstSeen();
    expect(prefs.getInt(ReviewPrompter.firstSeenKey), first);
  });

  test('does not count an ask when the sheet is unavailable', () async {
    final review = _FakeReview(available: false);
    final p = prompter(review);
    await p.markFirstSeen();
    now = now.add(const Duration(days: 5));

    expect(await p.maybeAsk(trigger: 'badge'), isFalse);
    expect(review.requests, 0);
    expect(prefs.getInt(ReviewPrompter.askedCountKey), isNull);
  });
}
