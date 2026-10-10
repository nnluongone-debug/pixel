import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'account_identity.dart';
import 'login_screen.dart';
import 'profile_screen.dart';

/// Entry point of the account UI, wired to the top bar person button.
abstract final class AccountEntry {
  /// Opens the profile when signed in, otherwise the login flow.
  static Future<void> open(BuildContext context, WidgetRef ref) {
    final signedIn = ref.read(accountIdentityProvider) != null;
    return Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => signedIn ? const ProfileScreen() : const LoginScreen(),
      ),
    );
  }
}
