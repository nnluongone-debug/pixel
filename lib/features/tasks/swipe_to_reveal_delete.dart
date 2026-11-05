import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_theme.dart';

/// iOS-style row: swipe left to reveal a red delete button, swipe far to
/// delete straight away. Tapping the row while open closes it.
class SwipeToRevealDelete extends StatefulWidget {
  const SwipeToRevealDelete({
    super.key,
    required this.child,
    required this.label,
    required this.onDelete,
    this.borderRadius = 18,
  });

  final Widget child;
  final String label;

  /// May show a confirmation; the row slides back closed afterwards.
  final Future<void> Function() onDelete;
  final double borderRadius;

  @override
  State<SwipeToRevealDelete> createState() => _SwipeToRevealDeleteState();
}

class _SwipeToRevealDeleteState extends State<SwipeToRevealDelete>
    with SingleTickerProviderStateMixin {
  static const double _actionWidth = 88;

  /// Fraction of the row width the content has slid left.
  late final AnimationController _slide = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 220),
  );
  double _width = 1;
  bool _pastFullSwipe = false;
  bool _busy = false;

  double get _openValue => (_actionWidth / _width).clamp(0, 1);
  bool get _isOpen => _slide.value > 0;

  @override
  void dispose() {
    _slide.dispose();
    super.dispose();
  }

  void _animateTo(double value) =>
      _slide.animateTo(value, curve: Curves.easeOutCubic);

  void _onDragUpdate(DragUpdateDetails d) {
    _slide.value = (_slide.value - d.primaryDelta! / _width).clamp(0, 1);
    final past = _slide.value > 0.6;
    if (past != _pastFullSwipe) {
      _pastFullSwipe = past;
      HapticFeedback.selectionClick();
    }
  }

  void _onDragEnd(DragEndDetails d) {
    final velocity = d.primaryVelocity ?? 0;
    if (_pastFullSwipe) {
      _pastFullSwipe = false;
      _delete(fromFullSwipe: true);
    } else if (velocity < -400 ||
        (velocity <= 400 && _slide.value > _openValue / 2)) {
      _animateTo(_openValue);
    } else {
      _animateTo(0);
    }
  }

  Future<void> _delete({bool fromFullSwipe = false}) async {
    if (_busy) return;
    _busy = true;
    try {
      // Not awaited: a cancelled animation must not drop the delete.
      if (fromFullSwipe) _slide.animateTo(1, curve: Curves.easeOut);
      await widget.onDelete();
    } finally {
      _busy = false;
      if (mounted) _animateTo(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        _width = constraints.maxWidth;
        return Semantics(
          customSemanticsActions: {
            CustomSemanticsAction(label: widget.label): _delete,
          },
          child: GestureDetector(
            onHorizontalDragUpdate: _onDragUpdate,
            onHorizontalDragEnd: _onDragEnd,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              child: AnimatedBuilder(
                animation: _slide,
                child: widget.child,
                builder: (context, child) {
                  final offset = _slide.value * _width;
                  return Stack(
                    children: [
                      Positioned.fill(
                        child: _DeleteBackdrop(
                          width: offset,
                          label: widget.label,
                          onTap: _delete,
                        ),
                      ),
                      Transform.translate(
                        offset: Offset(-offset, 0),
                        // Same tree open or closed, so the child keeps state.
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: _isOpen ? () => _animateTo(0) : null,
                          child: AbsorbPointer(
                            absorbing: _isOpen,
                            child: child,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}

class _DeleteBackdrop extends StatelessWidget {
  const _DeleteBackdrop({
    required this.width,
    required this.label,
    required this.onTap,
  });

  final double width;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: SizedBox(
        width: width,
        child: Material(
          color: AppColors.deleteRed,
          child: InkWell(
            onTap: onTap,
            child: OverflowBox(
              maxWidth: double.infinity,
              alignment: Alignment.centerLeft,
              // Stays pinned to the row's trailing edge, like iOS.
              child: SizedBox(
                width: _SwipeToRevealDeleteState._actionWidth,
                child: Semantics(
                  button: true,
                  label: label,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.delete_outline, color: Colors.white),
                      const SizedBox(height: 2),
                      Text(
                        label,
                        style: AppTextStyles.labelSm.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
