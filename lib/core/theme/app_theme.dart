import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Neo-Matrix color tokens (Stitch design system).
abstract final class AppColors {
  // Obsidian surface scale.
  static const Color background = Color(0xFF0B0C10);
  static const Color surfaceLowest = Color(0xFF0C0E15);
  static const Color surface = Color(0xFF16181F);
  static const Color surfaceLow = Color(0xFF191B22);
  static const Color surfaceRaised = Color(0xFF1E222D);
  static const Color surfaceHigh = Color(0xFF282A31);
  static const Color inputInset = Color(0xFF111318);

  /// Empty matrix cell / unfilled progress segment.
  static const Color cellEmpty = Color(0xFF252936);

  /// Pixel matrix slots that have no brick yet.
  static const Color matrixSlotFill = Color(0x66282A31);
  static const Color matrixSlotBorder = Color(0x333C4A3F);

  static const Color outlineVariant = Color(0xFF3C4A3F);
  static const Color borderSubtle = Color(0x14FFFFFF); // 8% white
  static const Color borderActive = Color(0x29FFFFFF); // 16% white

  static const Color textPrimary = Color(0xFFE2E2EC);
  static const Color textSecondary = Color(0xFFBACBBC);
  static const Color textMuted = Color(0xFF859588);
  static const Color textOnNeon = Color(0xFF0B0C10);

  // Neon accents. Mint is the brand / primary action color.
  static const Color primary = Color(0xFF65FFAB);
  static const Color mint = Color(0xFF2DE38E); // Workout, core momentum
  static const Color cyan = Color(0xFF00D2FF); // Hydration, deep work
  static const Color amber = Color(0xFFF9CA24); // Streaks, reading
  static const Color lavender = Color(0xFFA29BFE); // Focus, intellect
  static const Color rose = Color(0xFFFF7675); // Strength, creativity
  static const Color orange = Color(0xFFFF9F43); // Energy, cooking
  static const Color pink = Color(0xFFFF4D94); // Love, relationships

  static const Color error = Color(0xFFFFB4AB);
  static const Color deleteRed = Color(0xFFFF3B30); // iOS destructive red

  /// Colors a user can pick for a habit, in display order.
  static const List<Color> habitPalette = [
    mint,
    cyan,
    amber,
    lavender,
    rose,
    orange,
    pink,
  ];

  /// Parses `#RRGGBB` or `#AARRGGBB`; falls back to [mint] on bad input.
  static Color fromHex(String hex) {
    final cleaned = hex.replaceFirst('#', '');
    if (cleaned.length != 6 && cleaned.length != 8) return mint;
    final value = int.tryParse(
      cleaned.length == 6 ? 'FF$cleaned' : cleaned,
      radix: 16,
    );
    return value == null ? mint : Color(value);
  }

  /// Formats a color as `#RRGGBB` for storage in `habits.color_hex`.
  static String toHex(Color color) {
    final rgb = color.toARGB32() & 0xFFFFFF;
    return '#${rgb.toRadixString(16).padLeft(6, '0').toUpperCase()}';
  }
}

/// Neon glow shadows. Use only on active elements (filled cells, completed
/// checkers, active badges) — never on neutral cards.
abstract final class AppGlow {
  static List<BoxShadow> soft(Color color) => [
    BoxShadow(color: color.withValues(alpha: 0.25), blurRadius: 8),
  ];

  static List<BoxShadow> strong(Color color) => [
    BoxShadow(color: color.withValues(alpha: 0.45), blurRadius: 12),
    BoxShadow(
      color: color.withValues(alpha: 0.20),
      blurRadius: 24,
      spreadRadius: 2,
    ),
  ];

  /// Tight glow for small matrix cells so neighbours don't bleed together.
  static List<BoxShadow> cell(Color color) => [
    BoxShadow(color: color.withValues(alpha: 0.35), blurRadius: 6),
  ];

  /// Card with a 1px border, optionally glowing in an accent color.
  static BoxDecoration card({Color? glowColor, double radius = 16}) {
    return BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: glowColor?.withValues(alpha: 0.6) ?? AppColors.borderSubtle,
      ),
      boxShadow: glowColor == null ? null : soft(glowColor),
    );
  }
}

/// Typography: Space Grotesk for headlines, Plus Jakarta Sans for body,
/// JetBrains Mono for data, labels and counters.
abstract final class AppTextStyles {
  /// Emoji in user text (e.g. habit names) fall back to the system
  /// color-emoji font, since the brand fonts have no emoji glyphs.
  static const List<String> _emojiFallback = [
    'Apple Color Emoji',
    'Noto Color Emoji',
  ];

  static TextStyle _e(TextStyle style) =>
      style.copyWith(fontFamilyFallback: _emojiFallback);

  static TextStyle get headlineXl => _e(
    GoogleFonts.spaceGrotesk(
      fontSize: 32,
      fontWeight: FontWeight.w700,
      height: 38 / 32,
      letterSpacing: -0.64,
      color: AppColors.textPrimary,
    ),
  );

  static TextStyle get headlineLg => _e(
    GoogleFonts.spaceGrotesk(
      fontSize: 28,
      fontWeight: FontWeight.w600,
      height: 36 / 28,
      letterSpacing: -0.56,
      color: AppColors.textPrimary,
    ),
  );

  static TextStyle get headlineSm => _e(
    GoogleFonts.spaceGrotesk(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      height: 28 / 20,
      letterSpacing: -0.2,
      color: AppColors.textPrimary,
    ),
  );

  static TextStyle get bodyLg => _e(
    GoogleFonts.plusJakartaSans(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      height: 24 / 16,
      color: AppColors.textPrimary,
    ),
  );

  static TextStyle get bodyMd => _e(
    GoogleFonts.plusJakartaSans(
      fontSize: 14,
      height: 20 / 14,
      color: AppColors.textPrimary,
    ),
  );

  static TextStyle get bodySm => _e(
    GoogleFonts.plusJakartaSans(
      fontSize: 12,
      height: 18 / 12,
      color: AppColors.textSecondary,
    ),
  );

  static TextStyle get labelLg => _e(
    GoogleFonts.jetBrainsMono(
      fontSize: 13,
      fontWeight: FontWeight.w500,
      height: 16 / 13,
      letterSpacing: 0.26,
      color: AppColors.textPrimary,
    ),
  );

  static TextStyle get labelMd => _e(
    GoogleFonts.jetBrainsMono(
      fontSize: 11,
      fontWeight: FontWeight.w500,
      height: 14 / 11,
      letterSpacing: 0.44,
      color: AppColors.textSecondary,
    ),
  );

  static TextStyle get labelSm => _e(
    GoogleFonts.jetBrainsMono(
      fontSize: 9,
      fontWeight: FontWeight.w600,
      height: 12 / 9,
      letterSpacing: 0.54,
      color: AppColors.textSecondary,
    ),
  );

  /// Big numeric stat (streak days, level) tinted in a neon color.
  static TextStyle stat(Color color) => _e(
    GoogleFonts.spaceGrotesk(
      fontSize: 32,
      fontWeight: FontWeight.w700,
      color: color,
      shadows: [Shadow(color: color.withValues(alpha: 0.5), blurRadius: 12)],
    ),
  );
}

abstract final class AppTheme {
  static ThemeData get dark {
    const scheme = ColorScheme.dark(
      primary: AppColors.mint,
      onPrimary: AppColors.textOnNeon,
      secondary: AppColors.cyan,
      onSecondary: AppColors.textOnNeon,
      tertiary: AppColors.amber,
      surface: AppColors.surface,
      onSurface: AppColors.textPrimary,
      error: AppColors.error,
      outline: AppColors.borderActive,
      outlineVariant: AppColors.borderSubtle,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.background,
      textTheme: TextTheme(
        displaySmall: AppTextStyles.headlineXl,
        headlineMedium: AppTextStyles.headlineLg,
        titleLarge: AppTextStyles.headlineSm,
        bodyLarge: AppTextStyles.bodyLg,
        bodyMedium: AppTextStyles.bodyMd,
        bodySmall: AppTextStyles.bodySm,
        labelLarge: AppTextStyles.labelLg,
        labelMedium: AppTextStyles.labelMd,
        labelSmall: AppTextStyles.labelSm,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: AppTextStyles.headlineSm.copyWith(
          color: AppColors.mint,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.borderSubtle),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.mint,
          foregroundColor: AppColors.textOnNeon,
          textStyle: AppTextStyles.labelLg.copyWith(
            fontWeight: FontWeight.w700,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.inputInset,
        labelStyle: AppTextStyles.labelMd,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.borderSubtle),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.mint),
        ),
      ),
      dividerColor: AppColors.borderSubtle,
    );
  }
}
