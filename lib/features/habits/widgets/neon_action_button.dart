import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_theme.dart';

/// Square neon action button: outlined when idle, filled when [active],
/// neutral grey when [muted] (not started). Every tap gives a light haptic,
/// a click and a squash-and-bounce.
class NeonActionButton extends StatefulWidget {
  const NeonActionButton({
    super.key,
    required this.color,
    required this.onTap,
    required this.child,
    this.onLongPress,
    this.active = false,
    this.muted = false,
  });

  final Color color;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final bool active;
  final bool muted;
  final Widget child;

  @override
  State<NeonActionButton> createState() => _NeonActionButtonState();
}

class _NeonActionButtonState extends State<NeonActionButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _bounce = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 380),
  );
  late final Animation<double> _scale = TweenSequence([
    TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.84), weight: 25),
    TweenSequenceItem(tween: Tween(begin: 0.84, end: 1.1), weight: 35),
    TweenSequenceItem(tween: Tween(begin: 1.1, end: 1.0), weight: 40),
  ]).animate(CurvedAnimation(parent: _bounce, curve: Curves.easeOut));

  void _press(VoidCallback action) {
    HapticFeedback.lightImpact();
    SystemSound.play(SystemSoundType.click);
    _bounce.forward(from: 0);
    action();
  }

  @override
  void dispose() {
    _bounce.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color;
    final active = widget.active;
    final foreground = active
        ? AppColors.textOnNeon
        : widget.muted
        ? AppColors.textSecondary
        : color;
    return ScaleTransition(
      scale: _scale,
      child: GestureDetector(
        onTap: () => _press(widget.onTap),
        onLongPress: widget.onLongPress == null
            ? null
            : () => _press(widget.onLongPress!),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          width: 40,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: active ? color : AppColors.surfaceHigh,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: active
                  ? color
                  : widget.muted
                  ? AppColors.outlineVariant.withValues(alpha: 0.6)
                  : color.withValues(alpha: 0.45),
            ),
            boxShadow: active
                ? AppGlow.strong(color)
                : widget.muted
                ? null
                : AppGlow.soft(color),
          ),
          child: IconTheme(
            data: IconThemeData(color: foreground, size: 22),
            child: DefaultTextStyle(
              style: AppTextStyles.labelLg.copyWith(
                color: foreground,
                fontWeight: FontWeight.w700,
              ),
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}
