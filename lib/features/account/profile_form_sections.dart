import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/l10n/l10n.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/user_profile.dart';
import '../habit_editor/editor_parts.dart';
import 'account_parts.dart';

String _genderLabel(AppLocalizations l10n, Gender g) => switch (g) {
  Gender.male => l10n.accountGenderMale,
  Gender.female => l10n.accountGenderFemale,
  Gender.other => l10n.accountGenderOther,
  Gender.unspecified => l10n.accountGenderUnspecified,
};

/// A labelled profile field: section header above, [child] below.
class ProfileSection extends StatelessWidget {
  const ProfileSection({
    super.key,
    required this.tag,
    required this.title,
    required this.child,
    this.trailing,
  });

  final String tag;
  final String title;
  final String? trailing;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          EditorSectionHeader(tag: tag, title: title, trailing: trailing),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

/// Birth year as a four-digit numeric field.
class BirthYearField extends StatelessWidget {
  const BirthYearField({
    super.key,
    required this.controller,
    required this.errorText,
  });

  final TextEditingController controller;
  final String? errorText;

  @override
  Widget build(BuildContext context) => AccountTerminalField(
    controller: controller,
    hint: context.l10n.accountBirthYearHint,
    errorText: errorText,
    maxLength: 4,
    keyboardType: TextInputType.number,
    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
  );
}

/// Segmented gender chooser.
class GenderChips extends StatelessWidget {
  const GenderChips({super.key, required this.value, required this.onChanged});

  final Gender value;
  final ValueChanged<Gender> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final g in Gender.values)
          EditorChip(
            label: _genderLabel(l10n, g),
            selected: g == value,
            onTap: () => onChanged(g),
          ),
      ],
    );
  }
}

/// Read-only email with a lock and a VERIFIED chip.
class VerifiedEmailField extends StatelessWidget {
  const VerifiedEmailField({super.key, required this.email});

  final String email;

  @override
  Widget build(BuildContext context) {
    return EditorPanel(
      child: Row(
        children: [
          const Icon(Icons.lock_outline, size: 18, color: AppColors.textMuted),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              email,
              style: AppTextStyles.bodyLg.copyWith(
                color: AppColors.textSecondary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.mint.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: AppColors.mint),
            ),
            child: Text(
              context.l10n.accountVerified,
              style: AppTextStyles.labelSm.copyWith(color: AppColors.mint),
            ),
          ),
        ],
      ),
    );
  }
}
