import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pixel_quest/features/account/login_screen.dart';
import 'package:pixel_quest/features/account/profile_screen.dart';
import 'package:pixel_quest/services/auth/auth_service.dart';

import 'account_test_support.dart';

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  Future<void> sendCode(
    WidgetTester tester, [
    String email = 'Ada@Example.com',
  ]) async {
    await tester.enterText(find.byType(TextField), email);
    await tester.tap(find.text('SEND CODE'));
    await tester.pump();
    await tester.pump();
  }

  testWidgets('shows cloud-unavailable state without the form', (tester) async {
    await pumpAccount(tester, const LoginScreen(), firebase: false);
    expect(find.text('CLOUD UNAVAILABLE'), findsOneWidget);
    expect(find.byType(TextField), findsNothing);
    expect(find.text('SEND CODE'), findsNothing);
  });

  testWidgets('rejects an invalid email without calling the service', (
    tester,
  ) async {
    final auth = FakeAuthService();
    await pumpAccount(tester, const LoginScreen(), auth: auth);
    expect(find.textContaining('linked to your account'), findsOneWidget);
    await sendCode(tester, 'not-an-email');
    expect(find.text('Enter a valid email address.'), findsOneWidget);
    expect(auth.requests, isEmpty);
  });

  testWidgets('request moves to the code step with a live countdown', (
    tester,
  ) async {
    final auth = FakeAuthService()..resendDelay = const Duration(seconds: 3);
    await pumpAccount(tester, const LoginScreen(), auth: auth);
    await sendCode(tester);

    expect(auth.requests.single, (email: 'Ada@Example.com', lang: 'en'));
    expect(find.text('VERIFY'), findsOneWidget);
    expect(find.textContaining('ada@example.com'), findsOneWidget);
    expect(find.text('RESEND IN 3S'), findsOneWidget);
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('RESEND IN 2S'), findsOneWidget);
    await tester.pump(const Duration(seconds: 2));
    expect(find.text('RESEND CODE'), findsOneWidget);

    await tester.tap(find.text('CHANGE EMAIL'));
    await tester.pump();
    expect(find.text('SEND CODE'), findsOneWidget);
  });

  testWidgets('rate limit keeps the email step and disables sending', (
    tester,
  ) async {
    final auth = FakeAuthService()
      ..requestError = const AuthException(
        AuthFailure.tooManyRequests,
        retryAfter: Duration(seconds: 20),
      );
    await pumpAccount(tester, const LoginScreen(), auth: auth);
    await sendCode(tester);
    expect(find.textContaining('Too many requests'), findsOneWidget);
    expect(find.text('RESEND IN 20S'), findsOneWidget);
    await tester.pump(const Duration(seconds: 20));
  });

  testWidgets('wrong code shows attempts left and clears the boxes', (
    tester,
  ) async {
    final auth = FakeAuthService()
      ..verifyError = const AuthException(
        AuthFailure.invalidCode,
        attemptsLeft: 2,
      );
    await pumpAccount(tester, const LoginScreen(), auth: auth);
    await sendCode(tester);
    await tester.enterText(find.byType(TextField), '123456');
    await tester.pump();
    await tester.pump();

    expect(auth.verifications.single, (
      email: 'Ada@Example.com',
      code: '123456',
    ));
    expect(find.text('Wrong code. 2 attempts left.'), findsOneWidget);
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      '',
    );
    await tester.pump(const Duration(seconds: 30));
  });

  testWidgets('code field keeps six digits only', (tester) async {
    await pumpAccount(tester, const LoginScreen());
    await sendCode(tester);
    await tester.enterText(find.byType(TextField), '12 34a56789');
    await tester.pump();
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      '123456',
    );
    await tester.pump(const Duration(seconds: 30));
  });

  testWidgets('successful verification replaces login with the profile', (
    tester,
  ) async {
    final auth = FakeAuthService();
    await pumpAccount(tester, const LoginScreen(), auth: auth);
    await sendCode(tester);
    await tester.enterText(find.byType(TextField), '654321');
    await tester.pump();
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.byType(ProfileScreen), findsOneWidget);
    expect(find.byType(LoginScreen), findsNothing);
    await tester.pump(const Duration(seconds: 30));
  });

  testWidgets('renders in Vietnamese and sends the vi language', (
    tester,
  ) async {
    final auth = FakeAuthService();
    await pumpAccount(
      tester,
      const LoginScreen(),
      auth: auth,
      locale: const Locale('vi'),
    );
    expect(find.text('ĐĂNG NHẬP'), findsNothing);
    expect(find.textContaining('ĐĂNG NHẬP'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'a@b.co');
    await tester.tap(find.text('GỬI MÃ'));
    await tester.pump();
    await tester.pump();
    expect(auth.requests.single.lang, 'vi');
    expect(find.text('XÁC THỰC'), findsOneWidget);
    await tester.pump(const Duration(seconds: 30));
  });
}
