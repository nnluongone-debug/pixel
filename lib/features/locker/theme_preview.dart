import 'dart:math';

import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../domain/cosmetics/theme_catalog.dart';
import '../matrix/skins/brick_skin.dart';

/// Square grid of bricks painted with the skin of [id]. [hero] draws the big
/// 5x5 pattern with the center star tile and animates animated skins (unless
/// reduce-motion is on); otherwise a static 3x3 thumbnail.
class ThemePreview extends StatefulWidget {
  const ThemePreview({super.key, required this.id, this.size = 64})
    : hero = false;

  const ThemePreview.hero({super.key, required this.id, this.size = 220})
    : hero = true;

  final ThemeId id;
  final double size;
  final bool hero;

  @override
  State<ThemePreview> createState() => _ThemePreviewState();
}

class _ThemePreviewState extends State<ThemePreview>
    with SingleTickerProviderStateMixin {
  static const _cycleSeconds = 60;
  late final AnimationController _clock = AnimationController(
    vsync: this,
    duration: const Duration(seconds: _cycleSeconds),
  );

  BrickSkin get _skin => BrickSkin.of(widget.id);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncClock();
  }

  @override
  void didUpdateWidget(ThemePreview old) {
    super.didUpdateWidget(old);
    _syncClock();
  }

  void _syncClock() {
    final reduceMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    final animate = widget.hero && _skin.animated && !reduceMotion;
    if (animate && !_clock.isAnimating) {
      _clock.repeat();
    } else if (!animate && _clock.isAnimating) {
      _clock.stop();
    }
  }

  @override
  void dispose() {
    _clock.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => RepaintBoundary(
    child: SizedBox.square(
      dimension: widget.size,
      child: CustomPaint(
        painter: _GridPainter(skin: _skin, hero: widget.hero, clock: _clock),
      ),
    ),
  );
}

/// Hero pattern: m mint, c cyan, a amber, x empty slot, S star tile.
const _heroPattern = ['mcxam', 'cmamc', 'acSca', 'mamcm', 'xmcmx'];

Color? _heroColor(String ch) => switch (ch) {
  'm' || 'S' => AppColors.mint,
  'c' => AppColors.cyan,
  'a' => AppColors.amber,
  _ => null,
};

class _GridPainter extends CustomPainter {
  _GridPainter({required this.skin, required this.hero, required this.clock})
    : super(repaint: clock);

  final BrickSkin skin;
  final bool hero;
  final Animation<double> clock;

  @override
  void paint(Canvas canvas, Size size) {
    final panel = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(hero ? 14 : 6),
    );
    canvas.drawRRect(panel, Paint()..color = skin.panelColor);
    canvas.drawRRect(
      panel,
      Paint()
        ..style = PaintingStyle.stroke
        ..color = skin.panelBorderColor,
    );
    final n = hero ? 5 : 3;
    final pad = hero ? 14.0 : 5.0;
    final gap = hero ? 6.0 : 2.0;
    final cell = (size.width - pad * 2 - gap * (n - 1)) / n;
    final bricks = <Rect>[];
    final colors = <Color>[];
    Rect? star;
    for (var r = 0; r < n; r++) {
      for (var c = 0; c < n; c++) {
        final rect = Rect.fromLTWH(
          pad + c * (cell + gap),
          pad + r * (cell + gap),
          cell,
          cell,
        );
        final ch = hero ? _heroPattern[r][c] : '';
        final color = hero
            ? _heroColor(ch)
            : AppColors.habitPalette[(r * 3 + c) % 5];
        if (color == null) {
          skin.paintSlot(canvas, rect);
          continue;
        }
        skin.paintBrick(canvas, rect, color);
        bricks.add(rect);
        colors.add(color);
        if (ch == 'S') star = rect;
      }
    }
    if (star != null) _paintStar(canvas, star);
    final t = hero && skin.animated ? clock.value * 60 : 0.0;
    skin.paintOverlay(canvas, size, bricks, colors, t);
  }

  void _paintStar(Canvas canvas, Rect rect) {
    final center = rect.center;
    final outer = rect.width * 0.28;
    final inner = outer * 0.45;
    final path = Path();
    for (var i = 0; i < 10; i++) {
      final radius = i.isEven ? outer : inner;
      final angle = -pi / 2 + i * pi / 5;
      final p = center + Offset(cos(angle), sin(angle)) * radius;
      i == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
    }
    canvas.drawPath(
      path..close(),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..strokeJoin = StrokeJoin.round
        ..color = AppColors.textOnNeon,
    );
  }

  @override
  bool shouldRepaint(_GridPainter old) => old.skin != skin || old.hero != hero;
}
