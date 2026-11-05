import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_quest/services/feedback_service.dart';

void main() {
  test('mail link carries subject, hint and diagnostics', () {
    final uri = FeedbackService.buildMailUri(
      subject: 'Góp ý',
      hint: 'Describe it here:',
      version: '1.0.1',
      build: '2',
      locale: 'vi',
      os: 'android 14',
    );

    expect(uri.scheme, 'mailto');
    expect(uri.path, FeedbackService.supportEmail);
    // Spaces must be %20, never '+', or mail apps show literal pluses.
    expect(uri.query, isNot(contains('+')));
    final params = Uri.splitQueryString(uri.query);
    expect(params['subject'], '[PixelHabit 1.0.1] Góp ý');
    final body = params['body']!;
    expect(body, startsWith('Describe it here:'));
    expect(body, contains('App: 1.0.1 (2)'));
    expect(body, contains('OS: android 14'));
    expect(body, contains('Locale: vi'));
  });
}
