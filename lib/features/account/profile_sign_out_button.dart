import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/l10n.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/sync_providers.dart';
import 'account_parts.dart';

/// SIGN OUT with confirmation. Uploads first; if some changes could not be
/// uploaded the user may keep the session or sign out and lose them.
class ProfileSignOutButton extends ConsumerStatefulWidget {
  const ProfileSignOutButton({super.key});

  @override
  ConsumerState<ProfileSignOutButton> createState() => _SignOutState();
}

class _SignOutState extends ConsumerState<ProfileSignOutButton> {
  bool _busy = false;

  Future<bool> _confirm({
    required String body,
    required String cancel,
    required String accept,
    String? title,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(
          title ?? context.l10n.accountSignOutTitle,
          style: AppTextStyles.labelLg,
        ),
        content: Text(body, style: AppTextStyles.bodyMd),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: Text(accept),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  Future<void> _signOut() async {
    if (_busy) return;
    final l10n = context.l10n;
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final sync = ref.read(syncStatusProvider.notifier);
    if (!await _confirm(
      body: l10n.accountSignOutBody,
      cancel: l10n.accountCancel,
      accept: l10n.accountSignOut,
    )) {
      return;
    }
    if (!mounted) return;
    setState(() => _busy = true);
    try {
      var unsent = await sync.signOutAndWipe();
      if (unsent > 0) {
        if (!mounted) return;
        final discard = await _confirm(
          body: l10n.accountSignOutPendingBody(unsent),
          cancel: l10n.accountKeepSignedIn,
          accept: l10n.accountSignOutAnyway,
        );
        unsent = discard ? await sync.signOutAndWipe(discardPending: true) : -1;
      }
      if (unsent == 0) navigator.popUntil((route) => route.isFirst);
    } catch (_) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.accountActionFailed)));
    }
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) => AccountButton(
    label: context.l10n.accountSignOut,
    danger: true,
    busy: _busy,
    onPressed: _signOut,
  );
}
