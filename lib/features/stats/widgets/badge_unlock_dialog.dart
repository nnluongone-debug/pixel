import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/analytics/pixel_badge.dart';
import '../stats_formatters.dart';
import 'badge_style.dart';
import 'badge_tier_style.dart';
import 'pixel_badge_art.dart';

/// "NEW BADGE!" celebration. Rarer tiers throw more sparks.
abstract final class BadgeUnlockDialog {
  static Future<void> show(BuildContext context, BadgeDefinition badge) {
    HapticFeedback.heavyImpact();
    return showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: context.l10n.statsBadgeNewDismiss,
      barrierColor: const Color(0xD9000000),
      transitionDuration: const Duration(milliseconds: 420),
      pageBuilder: (_, _, _) => _Body(badge: badge),
      transitionBuilder: (_, anim, _, child) => FadeTransition(
        opacity: anim,
        child: ScaleTransition(
          scale: CurvedAnimation(parent: anim, curve: Curves.elasticOut),
          child: child,
        ),
      ),
    );
  }
}

class _Body extends StatefulWidget {
  const _Body({required this.badge});

  final BadgeDefinition badge;

  @override
  State<_Body> createState() => _BodyState();
}

class _BodyState extends State<_Body> with SingleTickerProviderStateMixin {
  late final AnimationController _burst = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..forward();

  @override
  void dispose() {
    _burst.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final badge = widget.badge;
    final tier = BadgeTierStyle.of(badge.tier);
    final color = BadgeStyle.color(badge.glyph);

    return Center(
      child: Material(
        type: MaterialType.transparency,
        child: Container(
          width: 300,
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
          decoration: AppGlow.card(glowColor: tier.labelColor, radius: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.statsBadgeNewTitle,
                style: AppTextStyles.headlineSm.copyWith(
                  color: tier.labelColor,
                  shadows: [Shadow(color: tier.labelColor, blurRadius: 14)],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                l10n.badgeTier(badge.tier),
                style: AppTextStyles.labelMd.copyWith(color: tier.labelColor),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: 200,
                height: 160,
                child: CustomPaint(
                  painter: _BurstPainter(
                    progress: _burst,
                    count: tier.burstParticles,
                    colors: tier.rainbow
                        ? const [
                            AppColors.amber,
                            AppColors.rose,
                            AppColors.lavender,
                            AppColors.cyan,
                            AppColors.mint,
                          ]
                        : [color, Colors.white],
                  ),
                  child: Center(
                    child: PixelBadgeArt(
                      definition: badge,
                      unlocked: true,
                      size: 120,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.badgeName(badge.id),
                textAlign: TextAlign.center,
                style: AppTextStyles.headlineSm,
              ),
              const SizedBox(height: 6),
              Text(
                l10n.badgeDescription(badge.id),
                textAlign: TextAlign.center,
                style: AppTextStyles.bodySm,
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(l10n.statsBadgeNewDismiss),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// One-shot radial burst of square pixel sparks around the badge.
class _BurstPainter extends CustomPainter {
  _BurstPainter({
    required this.progress,
    required this.count,
    required this.colors,
  }) : super(repaint: progress);

  final Animation<double> progress;
  final int count;
  final List<Color> colors;

  @override
  void paint(Canvas canvas, Size size) {
    final t = Curves.easeOutCubic.transform(progress.value);
    if (progress.value >= 1) return;
    final center = size.center(Offset.zero);
    final random = Random(count);
    final paint = Paint();
    for (var i = 0; i < count; i++) {
      final angle = random.nextDouble() * 2 * pi;
      final reach = 50 + random.nextDouble() * 70;
      final side = 2.0 + random.nextDouble() * 4;
      final p = center + Offset(cos(angle), sin(angle)) * reach * t;
      paint.color = colors[i % colors.length].withValues(alpha: 1 - t);
      canvas.drawRect(
        Rect.fromCenter(center: p, width: side, height: side),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_BurstPainter old) =>
      old.count != count || old.colors != colors;
}
