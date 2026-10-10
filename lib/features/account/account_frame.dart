import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// Page scaffold shared by login and profile: back button, terminal tag,
/// title and a scrolling body.
class AccountFrame extends StatelessWidget {
  const AccountFrame({
    super.key,
    required this.tag,
    required this.title,
    required this.child,
  });

  final String tag;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          tag,
          style: AppTextStyles.labelLg.copyWith(color: AppColors.cyan),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '■ $title',
                style: AppTextStyles.headlineLg.copyWith(
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 20),
              child,
            ],
          ),
        ),
      ),
    );
  }
}
