import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/l10n.dart';
import '../../providers/account_providers.dart';
import '../../providers/locale_providers.dart';
import '../../services/auth/auth_service.dart';
import 'account_frame.dart';
import 'auth_error_text.dart';
import 'cloud_unavailable_card.dart';
import 'code_boxes.dart';
import 'login_code_step.dart';
import 'login_email_step.dart';
import 'profile_screen.dart';
import 'resend_timer.dart';

/// Passwordless email-code sign-in. Replaces itself with [ProfileScreen]
/// once the code is verified.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _email = TextEditingController();
  final _code = TextEditingController();
  final _codeFocus = FocusNode();
  final _resend = ResendTimer();

  bool _codeStep = false;
  bool _busy = false;
  AuthException? _error;

  @override
  void dispose() {
    _email.dispose();
    _code.dispose();
    _codeFocus.dispose();
    _resend.dispose();
    super.dispose();
  }

  Future<void> _requestCode() async {
    if (_busy) return;
    final email = _email.text;
    if (!AuthService.isValidEmail(email)) {
      setState(() => _error = const AuthException(AuthFailure.invalidEmail));
      return;
    }
    final lang = ref.read(effectiveLocaleProvider).languageCode;
    setState(() {
      _busy = true;
      _error = null;
    });
    AuthException? failure;
    try {
      final delay = await ref
          .read(authServiceProvider)
          .requestCode(email, lang: lang);
      _resend.start(delay);
    } on AuthException catch (e) {
      failure = e;
      final wait = e.retryAfter;
      if (wait != null) _resend.start(wait);
    } catch (_) {
      failure = const AuthException(AuthFailure.unknown);
    }
    if (!mounted) return;
    setState(() {
      _busy = false;
      _error = failure;
      if (failure == null) {
        _codeStep = true;
        _code.clear();
      }
    });
  }

  Future<void> _verify() async {
    final code = _code.text;
    if (_busy || code.length != CodeBoxes.length) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    AuthException? failure;
    try {
      await ref.read(authServiceProvider).verifyCode(_email.text, code);
    } on AuthException catch (e) {
      failure = e;
    } catch (_) {
      failure = const AuthException(AuthFailure.unknown);
    }
    if (!mounted) return;
    if (failure == null) {
      await Navigator.of(context).pushReplacement<void, void>(
        MaterialPageRoute(builder: (_) => const ProfileScreen()),
      );
      return;
    }
    setState(() {
      _busy = false;
      _error = failure;
      if (failure!.failure == AuthFailure.invalidCode) _code.clear();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _codeFocus.requestFocus();
    });
  }

  Future<void> _paste() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final digits = (data?.text ?? '').replaceAll(RegExp(r'\D'), '');
    if (!mounted || digits.isEmpty) return;
    final text = digits.length > CodeBoxes.length
        ? digits.substring(0, CodeBoxes.length)
        : digits;
    _code.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
    _onCodeChanged(text);
  }

  void _onCodeChanged(String code) {
    if (_error != null) setState(() => _error = null);
    if (code.length == CodeBoxes.length) _verify();
  }

  void _changeEmail() => setState(() {
    _codeStep = false;
    _error = null;
    _code.clear();
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final available = ref.watch(firebaseAvailableProvider);
    final error = _error;
    final message = error == null ? null : authErrorMessage(l10n, error);
    return AccountFrame(
      tag: l10n.accountLoginTag,
      title: l10n.accountLoginTitle,
      child: !available
          ? const CloudUnavailableCard()
          : ValueListenableBuilder<int>(
              valueListenable: _resend,
              builder: (context, seconds, _) => _codeStep
                  ? LoginCodeStep(
                      email: AuthService.normalizeEmail(_email.text),
                      controller: _code,
                      focusNode: _codeFocus,
                      errorText: message,
                      busy: _busy,
                      secondsLeft: seconds,
                      onCodeChanged: _onCodeChanged,
                      onPaste: _paste,
                      onVerify: _verify,
                      onResend: _requestCode,
                      onChangeEmail: _changeEmail,
                    )
                  : LoginEmailStep(
                      controller: _email,
                      errorText: message,
                      busy: _busy,
                      secondsLeft: seconds,
                      onSubmit: _requestCode,
                    ),
            ),
    );
  }
}
