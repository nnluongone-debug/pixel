import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/l10n/l10n.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/sync_providers.dart';
import '../habit_editor/editor_parts.dart';
import 'account_parts.dart';

/// Sync phase, last sync time, pending changes and a SYNC NOW button.
class ProfileSyncCard extends ConsumerWidget {
  const ProfileSyncCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final status = ref.watch(syncStatusProvider);
    final (label, color) = switch (status.phase) {
      SyncPhase.idle => (l10n.accountSyncIdle, AppColors.mint),
      SyncPhase.syncing => (l10n.accountSyncSyncing, AppColors.cyan),
      SyncPhase.offline => (l10n.accountSyncOffline, AppColors.amber),
      SyncPhase.error => (l10n.accountSyncError, AppColors.error),
      SyncPhase.disabled => (l10n.accountSyncDisabled, AppColors.textMuted),
    };
    final last = status.lastSyncedAt;
    final lastText = last == null
        ? l10n.accountSyncNever
        : l10n.accountSyncLast(
            DateFormat.MMMd(context.localeTag).add_Hm().format(last),
          );
    final canSync =
        status.phase != SyncPhase.syncing && status.phase != SyncPhase.disabled;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        EditorSectionHeader(
          tag: '07',
          title: l10n.accountSyncTitle,
          trailing: label,
          trailingColor: color,
        ),
        const SizedBox(height: 10),
        EditorPanel(
          accent: color,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(lastText, style: AppTextStyles.labelMd),
              if (status.pendingCount > 0) ...[
                const SizedBox(height: 4),
                Text(
                  l10n.accountSyncPending(status.pendingCount),
                  style: AppTextStyles.labelMd.copyWith(color: AppColors.amber),
                ),
              ],
              const SizedBox(height: 12),
              AccountButton(
                label: l10n.accountSyncNow,
                busy: status.phase == SyncPhase.syncing,
                onPressed: canSync ? () => _sync(context, ref) : null,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _sync(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    final failed = context.l10n.accountActionFailed;
    try {
      await ref.read(syncStatusProvider.notifier).syncNow();
    } catch (_) {
      messenger.showSnackBar(SnackBar(content: Text(failed)));
    }
  }
}
