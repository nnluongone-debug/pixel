import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';

/// "■ GRID VIEW" title with a pulsing mint pixel and the profile button.
class NeoTopBar extends StatefulWidget implements PreferredSizeWidget {
  const NeoTopBar({super.key, required this.title, this.onProfileTap});

  final String title;
  final VoidCallback? onProfileTap;

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  State<NeoTopBar> createState() => _NeoTopBarState();
}

class _NeoTopBarState extends State<NeoTopBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xE611131A),
        border: Border(bottom: BorderSide(color: Color(0x4D3C4A3F))),
      ),
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: 64,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                FadeTransition(
                  opacity: Tween(begin: 0.45, end: 1.0).animate(_pulse),
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(2),
                      boxShadow: AppGlow.strong(AppColors.mint),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    widget.title.toUpperCase(),
                    style: AppTextStyles.headlineLg.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: widget.onProfileTap,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.mint.withValues(alpha: 0.15),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.4),
                      ),
                      boxShadow: AppGlow.soft(AppColors.mint),
                    ),
                    child: const Icon(
                      Icons.person_outline,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
