import 'package:flutter/material.dart';

import '../../core/l10n/l10n.dart';
import '../../core/theme/app_theme.dart';
import 'editor_parts.dart';

/// Section 02: color swatches.
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
                    right: swatch == AppColors.habitPalette.last ? 0 : 6,
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
          height: 44,
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
