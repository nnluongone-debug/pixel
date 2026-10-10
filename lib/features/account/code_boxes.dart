import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_theme.dart';

/// Six pixel boxes driven by one hidden [TextField], so the numeric
/// keyboard, one-time-code autofill and paste all work on a single field.
class CodeBoxes extends StatelessWidget {
  const CodeBoxes({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    this.enabled = true,
    this.hasError = false,
  });

  static const length = 6;

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final bool enabled;
  final bool hasError;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => focusNode.requestFocus(),
      child: Stack(
        children: [
          ListenableBuilder(
            listenable: Listenable.merge([controller, focusNode]),
            builder: (context, _) {
              final text = controller.text;
              final active = focusNode.hasFocus
                  ? text.length.clamp(0, length - 1)
                  : -1;
              return Row(
                children: [
                  for (var i = 0; i < length; i++) ...[
                    if (i > 0) const SizedBox(width: 8),
                    Expanded(
                      child: _Box(
                        char: i < text.length ? text[i] : '',
                        active: i == active,
                        hasError: hasError,
                      ),
                    ),
                  ],
                ],
              );
            },
          ),
          Positioned.fill(
            child: Opacity(
              opacity: 0,
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                enabled: enabled,
                autofocus: true,
                keyboardType: TextInputType.number,
                autofillHints: const [AutofillHints.oneTimeCode],
                enableInteractiveSelection: false,
                showCursor: false,
                inputFormatters: [_DigitsFormatter()],
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Keeps digits only and cuts pasted text (e.g. "123 456") to six.
class _DigitsFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final text = digits.length > CodeBoxes.length
        ? digits.substring(0, CodeBoxes.length)
        : digits;
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}

class _Box extends StatelessWidget {
  const _Box({
    required this.char,
    required this.active,
    required this.hasError,
  });

  final String char;
  final bool active;
  final bool hasError;

  @override
  Widget build(BuildContext context) {
    final color = hasError
        ? AppColors.error
        : active
        ? AppColors.mint
        : char.isNotEmpty
        ? AppColors.mint.withValues(alpha: 0.5)
        : AppColors.borderActive;
    return Container(
      height: 56,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.inputInset,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color, width: active ? 2 : 1),
        boxShadow: active ? AppGlow.soft(AppColors.mint) : null,
      ),
      child: Text(
        char,
        style: AppTextStyles.headlineSm.copyWith(color: AppColors.primary),
      ),
    );
  }
}
