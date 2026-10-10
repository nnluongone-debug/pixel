import 'package:flutter/material.dart';

import '../../core/l10n/l10n.dart';
import '../../core/theme/app_theme.dart';
import '../habit_editor/editor_parts.dart';
import 'account_parts.dart';

/// Step 1 of sign-in: email input and the guest-data explanation.
class LoginEmailStep extends StatelessWidget {
  const LoginEmailStep({
    super.key,
    required this.controller,
    required this.errorText,
    required this.busy,
    required this.secondsLeft,
    required this.onSubmit,
  });

  final TextEditingController controller;
  final String? errorText;
  final bool busy;

  /// Remaining wait before another code may be requested; 0 when free.
  final int secondsLeft;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        EditorSectionHeader(tag: '01', title: l10n.accountEmailLabel),
        const SizedBox(height: 10),
        AccountTerminalField(
          controller: controller,
          hint: 'you@example.com',
          errorText: errorText,
          enabled: !busy,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.send,
          autofillHints: const [AutofillHints.email],
          onSubmitted: (_) => onSubmit(),
        ),
        const SizedBox(height: 16),
        AccountButton(
          label: secondsLeft > 0
              ? l10n.accountResendIn(secondsLeft)
              : l10n.accountSendCode,
          busy: busy,
          onPressed: secondsLeft > 0 ? null : onSubmit,
        ),
        const SizedBox(height: 16),
        EditorPanel(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.link, size: 18, color: AppColors.cyan),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  l10n.accountGuestLinkNote,
                  style: AppTextStyles.bodySm,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
