import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

/// Small glowing dot. With [ping] a ring expands from it and fades out,
/// like the live-status dot in the design; otherwise it just breathes.
class PulseDot extends StatefulWidget {
  const PulseDot({
    super.key,
    this.color = AppColors.primary,
    this.size = 8,
    this.ping = false,
  });

  final Color color;
  final double size;
  final bool ping;

  @override
  State<PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<PulseDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.size;
    final color = widget.color;
    return SizedBox(
      width: size,
      height: size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final t = _controller.value;
          return Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              if (widget.ping)
                Opacity(
                  opacity: 0.75 * (1 - t),
                  child: Transform.scale(
                    scale: 1 + 1.2 * t,
                    child: _dot(size, color, glow: false),
                  ),
                ),
              Opacity(
                opacity: widget.ping ? 1 : 0.55 + 0.45 * (1 - t),
                child: _dot(size, color, glow: !widget.ping),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _dot(double size, Color color, {required bool glow}) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      color: color,
      shape: BoxShape.circle,
      boxShadow: glow ? AppGlow.soft(color) : null,
    ),
  );
}
