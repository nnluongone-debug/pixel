import 'package:flutter/material.dart';

import '../../core/l10n/l10n.dart';
import '../../core/theme/app_theme.dart';
import '../habit_editor/editor_parts.dart';
import 'account_parts.dart';
import 'code_boxes.dart';

/// Step 2 of sign-in: six-digit code, verify, resend and change email.
class LoginCodeStep extends StatelessWidget {
  const LoginCodeStep({
    super.key,
    required this.email,
    required this.controller,
    required this.focusNode,
    required this.errorText,
    required this.busy,
    required this.secondsLeft,
    required this.onCodeChanged,
    required this.onPaste,
    required this.onVerify,
    required this.onResend,
    required this.onChangeEmail,
  });

  final String email;
  final TextEditingController controller;
  final FocusNode focusNode;
  final String? errorText;
  final bool busy;
  final int secondsLeft;
  final ValueChanged<String> onCodeChanged;
  final VoidCallback onPaste;
  final VoidCallback onVerify;
  final VoidCallback onResend;
  final VoidCallback onChangeEmail;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        EditorSectionHeader(tag: '02', title: l10n.accountCodeLabel),
        const SizedBox(height: 10),
        Text(l10n.accountCodeSent(email), style: AppTextStyles.bodySm),
        const SizedBox(height: 14),
        CodeBoxes(
          controller: controller,
          focusNode: focusNode,
          enabled: !busy,
          hasError: errorText != null,
          onChanged: onCodeChanged,
        ),
        if (errorText != null) AccountErrorText(errorText!),
        Align(
          alignment: Alignment.centerRight,
          child: AccountTextLink(
            label: l10n.accountPaste,
            onPressed: busy ? null : onPaste,
          ),
        ),
        const SizedBox(height: 8),
        AccountButton(
          label: l10n.accountVerify,
          busy: busy,
          onPressed: onVerify,
        ),
        const SizedBox(height: 8),
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            AccountTextLink(
              label: secondsLeft > 0
                  ? l10n.accountResendIn(secondsLeft)
                  : l10n.accountResend,
              onPressed: secondsLeft > 0 || busy ? null : onResend,
            ),
            AccountTextLink(
              label: l10n.accountChangeEmail,
              onPressed: busy ? null : onChangeEmail,
            ),
          ],
        ),
      ],
    );
  }
}
