import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_quest/services/review/review_prompt_policy.dart';

void main() {
  const policy = ReviewPromptPolicy();
  final firstSeen = DateTime(2026, 11, 1);

  bool ask(DateTime now, {DateTime? lastAsked, int count = 0}) =>
      policy.shouldAsk(
        now: now,
        firstSeen: firstSeen,
        lastAsked: lastAsked,
        askedCount: count,
      );

  test('waits until the app is a few days old', () {
    expect(ask(DateTime(2026, 11, 2)), isFalse);
    expect(ask(DateTime(2026, 11, 4)), isTrue);
  });

  test('respects the cooldown between asks', () {
    final last = DateTime(2026, 11, 10);
    expect(ask(DateTime(2026, 12, 1), lastAsked: last, count: 1), isFalse);
    expect(ask(DateTime(2027, 1, 10), lastAsked: last, count: 1), isTrue);
  });

  test('stops after the lifetime cap', () {
    expect(ask(DateTime(2028, 1, 1), count: 3), isFalse);
  });
}
