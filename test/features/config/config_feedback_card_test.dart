import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pixel_quest/features/config/config_feedback_card.dart';
import 'package:pixel_quest/providers/app_info_providers.dart';
import 'package:pixel_quest/providers/locale_providers.dart';
import 'package:pixel_quest/providers/onboarding_providers.dart';
import 'package:pixel_quest/services/feedback_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../support/localized_test_app.dart';

class _FakeFeedback extends FeedbackService {
  _FakeFeedback(this.result);
  final bool result;
  final opened = <Uri>[];

  @override
  Future<bool> open(Uri uri) async {
    opened.add(uri);
    return result;
  }
}

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  Future<(SharedPreferences, _FakeFeedback)> pumpCard(
    WidgetTester tester, {
    bool opens = true,
  }) async {
    SharedPreferences.setMockInitialValues({onboardingDoneKey: true});
    final prefs = await SharedPreferences.getInstance();
    final feedback = _FakeFeedback(opens);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          feedbackServiceProvider.overrideWithValue(feedback),
          appInfoProvider.overrideWith(
            (ref) async => PackageInfo(
              appName: 'PixelHabit',
              packageName: 'test',
              version: '1.0.1',
              buildNumber: '2',
            ),
          ),
        ],
        child: localizedTestApp(
          home: const Scaffold(
            body: SingleChildScrollView(child: ConfigFeedbackCard()),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return (prefs, feedback);
  }

  testWidgets('shows the version and opens a pre-filled email', (tester) async {
    final (_, feedback) = await pumpCard(tester);
    expect(find.text('Version 1.0.1 (2)'), findsOneWidget);

    await tester.tap(find.text('SEND FEEDBACK'));
    await tester.pumpAndSettle();
    expect(feedback.opened, hasLength(1));
    final params = Uri.splitQueryString(feedback.opened.single.query);
    expect(params['subject'], '[PixelHabit 1.0.1] Feedback');
    expect(params['body'], contains('App: 1.0.1 (2)'));
    expect(find.byType(SnackBar), findsNothing);
  });

  testWidgets('no mail app shows the address with a copy action', (
    tester,
  ) async {
    await pumpCard(tester, opens: false);
    await tester.tap(find.text('SEND FEEDBACK'));
    await tester.pumpAndSettle();
    expect(find.textContaining(FeedbackService.supportEmail), findsOneWidget);
    expect(find.text('COPY'), findsOneWidget);
  });

  testWidgets('Replay intro clears the onboarding flag', (tester) async {
    final (prefs, _) = await pumpCard(tester);
    await tester.tap(find.text('REPLAY INTRO'));
    await tester.pumpAndSettle();
    expect(prefs.getBool(onboardingDoneKey), isFalse);
  });
}
