import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// Square pixel-framed tile showing the player's initials.
class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({super.key, required this.name, required this.email});

  final String name;
  final String email;

  /// Up to two initials from [name], else the first letter of [email].
  static String initials(String name, String email) {
    final words = name.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty);
    final letters = words
        .take(2)
        .map((w) => String.fromCharCode(w.runes.first));
    final text = letters.join();
    if (text.isNotEmpty) return text.toUpperCase();
    return email.isEmpty ? '?' : email[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    const size = 72.0;
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.mint.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.mint, width: 2),
        boxShadow: AppGlow.strong(AppColors.mint),
      ),
      child: Text(
        initials(name, email),
        style: AppTextStyles.headlineLg.copyWith(color: AppColors.primary),
      ),
    );
  }
}
