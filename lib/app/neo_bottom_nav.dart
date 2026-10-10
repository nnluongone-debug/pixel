import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/theme/app_theme.dart';

/// One tab in the floating pill bar.
class NeoNavItem {
  const NeoNavItem(this.icon, this.label);

  final IconData icon;
  final String label;
}

/// Floating pill tab bar with a raised mint "+" in the middle, per the
/// Neo-Matrix design. [items] are split evenly around the center button.
class NeoBottomNav extends StatelessWidget {
  const NeoBottomNav({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
    required this.onCreate,
  });

  final List<NeoNavItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    final half = items.length ~/ 2;
    Widget tab(int i) => Expanded(
      child: _NavTab(
        item: items[i],
        active: i == currentIndex,
        onTap: () {
          HapticFeedback.selectionClick();
          onTap(i);
        },
      ),
    );

    return SafeArea(
      top: false,
      minimum: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: SizedBox(
        height: 84,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.bottomCenter,
          children: [
            Container(
              height: 68,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(9999),
                border: Border.all(color: const Color(0x1FFFFFFF)),
                boxShadow: const [
                  BoxShadow(color: Color(0xB3000000), blurRadius: 24),
                ],
              ),
              child: Row(
                children: [
                  for (var i = 0; i < half; i++) tab(i),
                  const SizedBox(width: 72),
                  for (var i = half; i < items.length; i++) tab(i),
                ],
              ),
            ),
            Positioned(
              top: 0,
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.mediumImpact();
                  onCreate();
                },
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppColors.mint,
                    shape: BoxShape.circle,
                    boxShadow: AppGlow.strong(AppColors.mint),
                  ),
                  child: const Icon(
                    Icons.add,
                    size: 34,
                    color: AppColors.textOnNeon,
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

class _NavTab extends StatelessWidget {
  const _NavTab({
    required this.item,
    required this.active,
    required this.onTap,
  });

  final NeoNavItem item;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = active ? AppColors.mint : AppColors.textSecondary;
    return InkResponse(
      onTap: onTap,
      radius: 32,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(item.icon, color: color, size: 24),
          const SizedBox(height: 3),
          // Fixed line box: Vietnamese diacritics and fallback fonts must not
          // grow the label and push the bar out of the pill.
          Text(
            item.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            strutStyle: const StrutStyle(
              fontSize: 9,
              height: 1.4,
              forceStrutHeight: true,
            ),
            style: AppTextStyles.labelSm.copyWith(
              color: color,
              fontWeight: active ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
          const SizedBox(height: 3),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: active ? 16 : 0,
            height: 2,
            decoration: BoxDecoration(
              color: AppColors.mint,
              borderRadius: BorderRadius.circular(1),
              boxShadow: active ? AppGlow.soft(AppColors.mint) : null,
            ),
          ),
        ],
      ),
    );
  }
}
