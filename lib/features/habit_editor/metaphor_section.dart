import 'package:flutter/material.dart';

import '../../core/l10n/l10n.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/progression/xp_rules.dart';
import 'editor_parts.dart';

/// Section 02: color swatches and the T-block preview.
class MetaphorSection extends StatelessWidget {
  const MetaphorSection({
    super.key,
    required this.color,
    required this.onColorChanged,
  });

  final Color color;
  final ValueChanged<Color> onColorChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        EditorSectionHeader(
          tag: context.l10n.editorMetaphorTag,
          title: context.l10n.editorColorTitle,
        ),
        const SizedBox(height: 8),
        Text(context.l10n.editorColorHint, style: AppTextStyles.bodySm),
        const SizedBox(height: 10),
        Row(
          children: [
            for (final swatch in AppColors.habitPalette)
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: swatch == AppColors.habitPalette.last ? 0 : 8,
                  ),
                  child: _Swatch(
                    color: swatch,
                    selected: swatch.toARGB32() == color.toARGB32(),
                    onTap: () => onColorChanged(swatch),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        _TBlockCard(color: color),
      ],
    );
  }
}

class _Swatch extends StatelessWidget {
  const _Swatch({
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: context.l10n.editorColorSemantics(AppColors.toHex(color)),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 52,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
            border: selected ? Border.all(color: Colors.white, width: 2) : null,
            boxShadow: selected ? AppGlow.strong(color) : null,
          ),
          child: selected
              ? const Icon(Icons.check, color: AppColors.textOnNeon)
              : null,
        ),
      ),
    );
  }
}

class _TBlockCard extends StatelessWidget {
  const _TBlockCard({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return EditorPanel(
      child: Row(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.surfaceLowest,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderSubtle),
            ),
            child: CustomPaint(painter: TBlockPainter(color)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.editorTBlock,
                  style: AppTextStyles.headlineSm,
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    _Pill(context.l10n.editorActive, color: color),
                    _Pill(
                      context.l10n.editorXpPerTile(XpRules.baseXpPerCheckIn),
                      color: AppColors.cyan,
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(context.l10n.editorField, style: AppTextStyles.labelSm),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill(this.text, {required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.7)),
      ),
      child: Text(text, style: AppTextStyles.labelSm.copyWith(color: color)),
    );
  }
}

/// Draws a glowing T-tetromino (one brick on top, three below) in [color].
class TBlockPainter extends CustomPainter {
  const TBlockPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final brick = size.shortestSide / 4;
    final origin = Offset(
      (size.width - brick * 3) / 2,
      (size.height - brick * 2) / 2,
    );
    const cells = [(1, 0), (0, 1), (1, 1), (2, 1)];
    final glow = Paint()
      ..color = color.withValues(alpha: 0.5)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    final fill = Paint()..color = color;
    for (final (col, row) in cells) {
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(
          origin.dx + col * brick + 1,
          origin.dy + row * brick + 1,
          brick - 2,
          brick - 2,
        ),
        const Radius.circular(3),
      );
      canvas.drawRRect(rect, glow);
      canvas.drawRRect(rect, fill);
    }
  }

  @override
  bool shouldRepaint(TBlockPainter oldDelegate) => oldDelegate.color != color;
}
