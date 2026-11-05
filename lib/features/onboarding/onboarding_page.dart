import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// One intro page: illustration, title, body and an optional [action].
class OnboardingPage extends StatelessWidget {
  const OnboardingPage({
    super.key,
    required this.art,
    required this.title,
    required this.body,
    this.action,
  });

  final Widget art;
  final String title;
  final String body;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        children: [
          const SizedBox(height: 24),
          art,
          const SizedBox(height: 36),
          Text(
            title,
            style: AppTextStyles.headlineLg,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            body,
            style: AppTextStyles.bodyLg.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          if (action != null) ...[const SizedBox(height: 24), action!],
        ],
      ),
    );
  }
}
