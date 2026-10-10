import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_theme.dart';
import '../habit_editor/editor_parts.dart';

/// Full-width action button with an in-flight spinner. A null [onPressed] or
/// [busy] disables it.
class AccountButton extends StatelessWidget {
  const AccountButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.busy = false,
    this.danger = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool busy;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final onTap = busy ? null : onPressed;
    final child = busy
        ? SizedBox.square(
            dimension: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: danger ? AppColors.error : AppColors.textOnNeon,
            ),
          )
        : Text(label, overflow: TextOverflow.ellipsis);
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: danger
          ? OutlinedButton(
              onPressed: onTap,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: const BorderSide(color: AppColors.error),
                textStyle: AppTextStyles.labelLg.copyWith(
                  fontWeight: FontWeight.w700,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: child,
            )
          : FilledButton(onPressed: onTap, child: child),
    );
  }
}

/// Terminal-style input: `>` prompt inside an inset panel, optional error.
class AccountTerminalField extends StatelessWidget {
  const AccountTerminalField({
    super.key,
    required this.controller,
    required this.hint,
    this.errorText,
    this.keyboardType,
    this.maxLength,
    this.maxLines = 1,
    this.inputFormatters = const [],
    this.autofillHints,
    this.textInputAction,
    this.onChanged,
    this.onSubmitted,
    this.enabled = true,
  });

  final TextEditingController controller;
  final String hint;
  final String? errorText;
  final TextInputType? keyboardType;
  final int? maxLength;
  final int maxLines;
  final List<TextInputFormatter> inputFormatters;
  final Iterable<String>? autofillHints;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final hasError = errorText != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        EditorPanel(
          accent: hasError ? AppColors.error : null,
          padding: const EdgeInsets.fromLTRB(12, 4, 12, 4),
          child: Row(
            crossAxisAlignment: maxLines > 1
                ? CrossAxisAlignment.start
                : CrossAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.only(top: maxLines > 1 ? 14 : 0),
                child: Text(
                  '>',
                  style: AppTextStyles.labelLg.copyWith(color: AppColors.mint),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: controller,
                  enabled: enabled,
                  keyboardType: keyboardType,
                  minLines: maxLines > 1 ? 2 : 1,
                  maxLines: maxLines,
                  textInputAction: textInputAction,
                  autofillHints: autofillHints,
                  onChanged: onChanged,
                  onSubmitted: onSubmitted,
                  cursorColor: AppColors.mint,
                  inputFormatters: [
                    if (maxLength != null)
                      LengthLimitingTextInputFormatter(maxLength),
                    ...inputFormatters,
                  ],
                  style: AppTextStyles.bodyLg,
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: AppTextStyles.bodyLg.copyWith(
                      color: AppColors.textMuted,
                    ),
                    filled: false,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (hasError) AccountErrorText(errorText!),
      ],
    );
  }
}

/// Red one-line message under a field or form.
class AccountErrorText extends StatelessWidget {
  const AccountErrorText(this.message, {super.key});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Semantics(
        liveRegion: true,
        child: Text(
          message,
          style: AppTextStyles.labelMd.copyWith(color: AppColors.error),
        ),
      ),
    );
  }
}

/// Small underlined text action (resend, change email).
class AccountTextLink extends StatelessWidget {
  const AccountTextLink({super.key, required this.label, this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: AppColors.cyan,
        disabledForegroundColor: AppColors.textMuted,
        minimumSize: const Size(0, 44),
        textStyle: AppTextStyles.labelMd.copyWith(
          decoration: enabled ? TextDecoration.underline : null,
        ),
      ),
      child: Text(label),
    );
  }
}
