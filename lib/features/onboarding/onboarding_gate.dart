import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/onboarding_providers.dart';
import 'onboarding_screen.dart';

/// Shows the first-run intro until it is finished, then [child].
class OnboardingGate extends ConsumerWidget {
  const OnboardingGate({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (ref.watch(onboardingDoneProvider)) return child;
    return OnboardingScreen(
      onDone: () => ref.read(onboardingDoneProvider.notifier).complete(),
    );
  }
}
