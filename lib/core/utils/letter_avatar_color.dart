import 'dart:ui';

import '../theme/app_theme.dart';
import 'search_text_normalizer.dart';

/// Stable avatar color per letter, picked from the habit palette.
/// Accented letters share their base letter's color (`Đ` = `D`).
abstract final class LetterAvatarColor {
  static Color of(String text) {
    final folded = SearchTextNormalizer.normalize(text);
    if (folded.isEmpty) return AppColors.mint;
    final palette = AppColors.habitPalette;
    return palette[folded.runes.first % palette.length];
  }
}
