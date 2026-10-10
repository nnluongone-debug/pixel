import '../../core/l10n/l10n.dart';
import '../../services/auth/auth_service.dart';

/// Localized message for a failed sign-in step.
String authErrorMessage(AppLocalizations l10n, AuthException e) =>
    switch (e.failure) {
      AuthFailure.invalidEmail => l10n.accountErrInvalidEmail,
      AuthFailure.tooManyRequests => l10n.accountErrTooManyRequests,
      AuthFailure.invalidCode =>
        e.attemptsLeft == null
            ? l10n.accountErrInvalidCode
            : l10n.accountErrInvalidCodeLeft(e.attemptsLeft!),
      AuthFailure.expiredCode => l10n.accountErrExpiredCode,
      AuthFailure.tooManyAttempts => l10n.accountErrTooManyAttempts,
      AuthFailure.network => l10n.accountErrNetwork,
      AuthFailure.unavailable => l10n.accountErrUnavailable,
      AuthFailure.unknown => l10n.accountErrUnknown,
    };
