import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Why an email-code sign-in step failed; the UI maps each to a message.
enum AuthFailure {
  invalidEmail,

  /// A code was requested too recently or too often; see [AuthException.retryAfter].
  tooManyRequests,
  invalidCode,

  /// No pending code, or it expired: request a new one.
  expiredCode,
  tooManyAttempts,
  network,

  /// The sign-in backend isn't reachable or not deployed yet.
  unavailable,
  unknown,
}

class AuthException implements Exception {
  const AuthException(this.failure, {this.retryAfter, this.attemptsLeft});

  final AuthFailure failure;
  final Duration? retryAfter;
  final int? attemptsLeft;

  @override
  String toString() => 'AuthException($failure)';
}

/// Passwordless sign-in: the backend emails a 6-digit code, then trades a
/// correct code for a Firebase custom token.
class AuthService {
  /// Firebase singletons are resolved lazily, so a subclass (tests) can be
  /// built without an initialized Firebase app.
  AuthService({FirebaseAuth? auth, FirebaseFunctions? functions})
    : _authOverride = auth,
      _functionsOverride = functions;

  /// Must match the region the Cloud Functions are deployed to.
  static const functionsRegion = 'asia-southeast1';
  static final _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  final FirebaseAuth? _authOverride;
  final FirebaseFunctions? _functionsOverride;

  FirebaseAuth get _auth => _authOverride ?? FirebaseAuth.instance;
  FirebaseFunctions get _functions =>
      _functionsOverride ??
      FirebaseFunctions.instanceFor(region: functionsRegion);

  Stream<User?> authStateChanges() => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  static String normalizeEmail(String email) => email.trim().toLowerCase();
  static bool isValidEmail(String email) =>
      _emailPattern.hasMatch(normalizeEmail(email));

  /// Emails a code to [email]; [lang] picks the email language.
  /// Returns how long to wait before the code can be re-sent.
  Future<Duration> requestCode(String email, {required String lang}) async {
    final normalized = normalizeEmail(email);
    if (!isValidEmail(normalized)) {
      throw const AuthException(AuthFailure.invalidEmail);
    }
    final data = await _call('requestLoginCode', {
      'email': normalized,
      'lang': lang,
    });
    return Duration(
      seconds: (data['resendAfterSeconds'] as num?)?.toInt() ?? 60,
    );
  }

  /// Verifies [code] and signs in. The account is created on first use.
  Future<void> verifyCode(String email, String code) async {
    final data = await _call('verifyLoginCode', {
      'email': normalizeEmail(email),
      'code': code.trim(),
    });
    final token = data['token'];
    if (token is! String) throw const AuthException(AuthFailure.unknown);
    try {
      await _auth.signInWithCustomToken(token);
    } on FirebaseAuthException catch (e) {
      throw AuthException(
        e.code == 'network-request-failed'
            ? AuthFailure.network
            : AuthFailure.unknown,
      );
    }
  }

  Future<void> signOut() => _auth.signOut();

  /// Deletes the account and all cloud data server-side, then signs out.
  Future<void> deleteAccount() async {
    await _call('deleteAccount', const {});
    await _auth.signOut();
  }

  Future<Map<String, Object?>> _call(
    String name,
    Map<String, Object?> payload,
  ) async {
    try {
      final result = await _functions.httpsCallable(name).call(payload);
      return Map<String, Object?>.from(result.data as Map);
    } on FirebaseFunctionsException catch (e) {
      throw _mapError(e);
    }
  }

  static AuthException _mapError(FirebaseFunctionsException e) {
    final details = e.details is Map ? e.details as Map : const {};
    int? intOf(String key) => (details[key] as num?)?.toInt();
    return switch (e.code) {
      'invalid-argument' => AuthException(
        details['field'] == 'code'
            ? AuthFailure.invalidCode
            : AuthFailure.invalidEmail,
      ),
      'resource-exhausted' => AuthException(
        details['reason'] == 'attempts'
            ? AuthFailure.tooManyAttempts
            : AuthFailure.tooManyRequests,
        retryAfter: intOf('retryAfterSeconds') == null
            ? null
            : Duration(seconds: intOf('retryAfterSeconds')!),
      ),
      'permission-denied' => AuthException(
        AuthFailure.invalidCode,
        attemptsLeft: intOf('attemptsLeft'),
      ),
      // Only a tagged not-found means "no active code"; an untagged one is
      // the callable itself missing (backend not deployed).
      'not-found' => AuthException(
        details['reason'] == 'expired'
            ? AuthFailure.expiredCode
            : AuthFailure.unavailable,
      ),
      'unavailable' ||
      'deadline-exceeded' => const AuthException(AuthFailure.network),
      'internal' ||
      'unimplemented' => const AuthException(AuthFailure.unavailable),
      _ => const AuthException(AuthFailure.unknown),
    };
  }
}
