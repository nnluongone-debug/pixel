import 'package:flutter/material.dart';

import '../../core/l10n/l10n.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/habit_icons.dart';

/// Icon matrix: one row while collapsed (always including the selected
/// icon) plus a toggle tile that expands to every icon.
class IconPickerGrid extends StatefulWidget {
  const IconPickerGrid({
    super.key,
    required this.selected,
    required this.color,
    required this.onChanged,
  });

  final String selected;
  final Color color;
  final ValueChanged<String> onChanged;

  @override
  State<IconPickerGrid> createState() => _IconPickerGridState();
}

class _IconPickerGridState extends State<IconPickerGrid> {
  /// Tiles shrink to this at most so the row fits one more; then they
  /// stretch to fill the width exactly.
  static const double _minTile = 44;
  static const double _gap = 8;
  bool _expanded = false;

  /// Icons shown in a collapsed row of [slots] icon tiles.
  List<String> _collapsed(int slots) {
    final names = HabitIcons.all.keys.take(slots).toList();
    if (!names.contains(widget.selected) &&
        HabitIcons.all.containsKey(widget.selected) &&
        names.isNotEmpty) {
      names[names.length - 1] = widget.selected;
    }
    return names;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final perRow = ((width + _gap) / (_minTile + _gap)).floor().clamp(
          2,
          99,
        );
        final tile = (width - _gap * (perRow - 1)) / perRow;
        final fitsOneRow = HabitIcons.all.length <= perRow;
        final names = _expanded || fitsOneRow
            ? HabitIcons.all.keys.toList()
            : _collapsed(perRow - 1);
        return AnimatedSize(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          alignment: Alignment.topCenter,
          child: Wrap(
            spacing: _gap,
            runSpacing: _gap,
            children: [
              for (final name in names)
                _IconTile(
                  size: tile,
                  icon: HabitIcons.of(name),
                  label: name,
                  color: widget.color,
                  selected: name == widget.selected,
                  onTap: () => widget.onChanged(name),
                ),
              if (!fitsOneRow)
                _ToggleTile(
                  size: tile,
                  expanded: _expanded,
                  tooltip: _expanded
                      ? l10n.editorIconsLess
                      : l10n.editorIconsMore,
                  onTap: () => setState(() => _expanded = !_expanded),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _ToggleTile extends StatelessWidget {
  const _ToggleTile({
    required this.size,
    required this.expanded,
    required this.tooltip,
    required this.onTap,
  });

  final double size;
  final bool expanded;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Semantics(
        button: true,
        label: tooltip,
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: AppColors.surfaceRaised,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.borderActive),
            ),
            child: Icon(
              expanded ? Icons.expand_less : Icons.more_horiz,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

class _IconTile extends StatelessWidget {
  const _IconTile({
    required this.size,
    required this.icon,
    required this.label,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final double size;
  final IconData icon;
  final String label;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: selected
                ? color.withValues(alpha: 0.12)
                : AppColors.surfaceRaised,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? color : AppColors.borderSubtle,
              width: selected ? 2 : 1,
            ),
            boxShadow: selected ? AppGlow.soft(color) : null,
          ),
          child: Icon(icon, color: selected ? color : AppColors.textSecondary),
        ),
      ),
    );
  }
}
