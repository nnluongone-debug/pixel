import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/l10n.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/sync_providers.dart';
import '../../services/auth/auth_service.dart';

/// Low-emphasis DELETE ACCOUNT link (required by store policies). Deletes
/// the account and all cloud data after an explicit confirmation.
class ProfileDeleteAccountButton extends ConsumerStatefulWidget {
  const ProfileDeleteAccountButton({super.key});

  @override
  ConsumerState<ProfileDeleteAccountButton> createState() =>
      _DeleteAccountState();
}

class _DeleteAccountState extends ConsumerState<ProfileDeleteAccountButton> {
  bool _busy = false;

  Future<bool> _confirm() async {
    final l10n = context.l10n;
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(l10n.accountDeleteTitle, style: AppTextStyles.labelLg),
        content: Text(l10n.accountDeleteBody, style: AppTextStyles.bodyMd),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.accountCancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.deleteRed),
            child: Text(l10n.accountDeleteConfirm),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  Future<void> _delete() async {
    if (_busy) return;
    final l10n = context.l10n;
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final sync = ref.read(syncStatusProvider.notifier);
    if (!await _confirm() || !mounted) return;
    setState(() => _busy = true);
    try {
      await sync.deleteAccountAndWipe();
      navigator.popUntil((route) => route.isFirst);
    } on AuthException catch (e) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            e.failure == AuthFailure.network
                ? l10n.accountDeleteOffline
                : l10n.accountActionFailed,
          ),
        ),
      );
    } catch (_) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.accountActionFailed)));
    }
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) => Center(
    child: _busy
        ? const Padding(
            padding: EdgeInsets.all(12),
            child: SizedBox.square(
              dimension: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.deleteRed,
              ),
            ),
          )
        : TextButton(
            onPressed: _delete,
            style: TextButton.styleFrom(foregroundColor: AppColors.textMuted),
            child: Text(context.l10n.accountDelete),
          ),
  );
}
