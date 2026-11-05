import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/l10n.dart';
import '../../providers/account_providers.dart';
import 'account_frame.dart';
import 'account_identity.dart';
import 'account_parts.dart';
import '../locker/locker_entry_card.dart';
import 'profile_badges_section.dart';
import 'profile_form.dart';
import 'profile_delete_account_button.dart';
import 'profile_sign_out_button.dart';
import 'profile_sync_card.dart';

/// The signed-in account: editable profile, badges, sync and sign-out.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final identity = ref.watch(accountIdentityProvider);
    final profile = ref.watch(profileProvider);
    final Widget body;
    if (identity == null) {
      body = const _Loading();
    } else if (profile.value case final value?) {
      body = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ProfileForm(
            key: ValueKey(identity.uid),
            identity: identity,
            initial: value,
          ),
          const SizedBox(height: 28),
          const LockerEntryCard(),
          const SizedBox(height: 28),
          const ProfileBadgesSection(),
          const SizedBox(height: 28),
          const ProfileSyncCard(),
          const SizedBox(height: 28),
          const ProfileSignOutButton(),
          const SizedBox(height: 12),
          const ProfileDeleteAccountButton(),
        ],
      );
    } else if (profile.hasError) {
      body = AccountErrorText(l10n.accountActionFailed);
    } else {
      body = const _Loading();
    }
    return AccountFrame(
      tag: l10n.accountProfileTag,
      title: l10n.accountProfileTitle,
      child: body,
    );
  }
}

class _Loading extends StatelessWidget {
  const _Loading();

  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.symmetric(vertical: 48),
    child: Center(child: CircularProgressIndicator()),
  );
}
