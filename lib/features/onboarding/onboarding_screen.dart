import 'package:flutter/material.dart';

import '../../core/l10n/l10n.dart';
import '../../core/theme/app_theme.dart';
import 'onboarding_brick_art.dart';
import 'onboarding_page.dart';
import 'onboarding_reminder_action.dart';

/// First-run intro: four swipeable pages, Skip, page dots, Next/Start.
/// [onDone] fires on Skip or Start.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key, required this.onDone});

  final VoidCallback onDone;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  static const _pageCount = 4;
  final _controller = PageController();
  int _page = 0;

  bool get _isLast => _page == _pageCount - 1;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _next() {
    if (_isLast) return widget.onDone();
    _controller.nextPage(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  }

  List<Widget> _pages(AppLocalizations l10n) => [
    OnboardingPage(
      art: const OnboardingBrickArt(
        icon: Icons.grid_view_rounded,
        color: AppColors.mint,
        filledRows: 0,
        extra: 2,
      ),
      title: l10n.onboardingWelcomeTitle,
      body: l10n.onboardingWelcomeBody,
    ),
    OnboardingPage(
      art: const OnboardingBrickArt(
        icon: Icons.add_box_outlined,
        color: AppColors.cyan,
        filledRows: 2,
        extra: 5,
      ),
      title: l10n.onboardingMatrixTitle,
      body: l10n.onboardingMatrixBody,
    ),
    OnboardingPage(
      art: const OnboardingBrickArt(
        icon: Icons.emoji_events_outlined,
        color: AppColors.amber,
        filledRows: 3,
      ),
      title: l10n.onboardingRewardsTitle,
      body: l10n.onboardingRewardsBody,
    ),
    OnboardingPage(
      art: const OnboardingBrickArt(
        icon: Icons.notifications_none_rounded,
        color: AppColors.lavender,
        filledRows: 1,
        extra: 1,
      ),
      title: l10n.onboardingRemindersTitle,
      body: l10n.onboardingRemindersBody,
      action: const OnboardingReminderAction(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: Visibility.maintain(
                visible: !_isLast,
                child: TextButton(
                  onPressed: widget.onDone,
                  child: Text(l10n.onboardingSkip),
                ),
              ),
            ),
            Expanded(
              child: PageView(
                controller: _controller,
                onPageChanged: (i) => setState(() => _page = i),
                children: _pages(l10n),
              ),
            ),
            _Dots(count: _pageCount, active: _page),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: _next,
                  child: Text(
                    _isLast ? l10n.onboardingStart : l10n.onboardingNext,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Dots extends StatelessWidget {
  const _Dots({required this.count, required this.active});

  final int count;
  final int active;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < count; i++)
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: i == active ? 22 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: i == active ? AppColors.primary : AppColors.cellEmpty,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
      ],
    );
  }
}
