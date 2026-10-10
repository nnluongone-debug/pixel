import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/account_providers.dart';

/// The signed-in account's uid and verified email. Widgets read this instead
/// of the Firebase `User` so tests can override it without Firebase.
class AccountIdentity {
  const AccountIdentity({required this.uid, required this.email});

  final String uid;
  final String email;

  @override
  bool operator ==(Object other) =>
      other is AccountIdentity && other.uid == uid && other.email == email;

  @override
  int get hashCode => Object.hash(uid, email);
}

/// Null in guest mode, or while the account has no verified email.
final accountIdentityProvider = Provider<AccountIdentity?>((ref) {
  final user = ref.watch(authUserProvider).value;
  final email = user?.email;
  if (user == null || email == null) return null;
  return AccountIdentity(uid: user.uid, email: email);
});
