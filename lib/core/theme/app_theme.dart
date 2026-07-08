import 'package:flutter/material.dart';
import 'package:flutter_template/core/theme/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';

abstract final class AppTheme {
  static ThemeData light() {
    const scheme = ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.brandPrimary,
      onPrimary: Colors.white,
      primaryContainer: Color(0xFFFFE8D3),
      onPrimaryContainer: AppColors.textPrimary,
      secondary: AppColors.brandSecondary,
      onSecondary: Colors.white,
      secondaryContainer: Color(0xFFF7E8E5),
      onSecondaryContainer: AppColors.textPrimary,
      tertiary: AppColors.brandTertiary,
      onTertiary: AppColors.textPrimary,
      tertiaryContainer: Color(0xFFFFF4D6),
      onTertiaryContainer: AppColors.textPrimary,
      error: AppColors.danger,
      onError: Colors.white,
      surface: AppColors.cream,
      onSurface: AppColors.textPrimary,
      onSurfaceVariant: AppColors.textSecondary,
      outline: AppColors.outlineMuted,
      outlineVariant: Color(0xFFF0E6DA),
      shadow: Color(0x408B1A2E),
      scrim: Colors.black54,
      inverseSurface: AppColors.maroon,
      onInverseSurface: AppColors.cream,
      inversePrimary: AppColors.goldGlow,
      surfaceTint: AppColors.brandPrimary,
    );
    return _base(scheme, outline: AppColors.outlineMuted);
  }

  static ThemeData dark() {
    const scheme = ColorScheme(
      brightness: Brightness.dark,
      primary: AppColors.brandPrimary,
      onPrimary: Colors.white,
      primaryContainer: Color(0xFF6B1424),
      onPrimaryContainer: AppColors.goldGlow,
      secondary: AppColors.brandSecondary,
      onSecondary: Colors.white,
      secondaryContainer: Color(0xFF4A121F),
      onSecondaryContainer: AppColors.goldGlow,
      tertiary: AppColors.brandTertiary,
      onTertiary: AppColors.maroon,
      tertiaryContainer: Color(0xFF5C4A18),
      onTertiaryContainer: AppColors.goldGlow,
      error: AppColors.danger,
      onError: Colors.white,
      surface: AppColors.darkBackground,
      onSurface: AppColors.darkTextPrimary,
      onSurfaceVariant: Color(0xFFD4C4B8),
      outline: AppColors.outlineMutedDark,
      outlineVariant: Color(0xFF3D2228),
      shadow: Colors.black54,
      scrim: Colors.black87,
      inverseSurface: AppColors.ivory,
      onInverseSurface: AppColors.maroon,
      inversePrimary: AppColors.brandPrimary,
      surfaceTint: AppColors.brandPrimary,
    );
    return _base(scheme, outline: AppColors.outlineMutedDark);
  }

  static ThemeData _base(ColorScheme scheme, {required Color outline}) {
    final radius = BorderRadius.circular(16);
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.ivory,
      appBarTheme: AppBarTheme(
        centerTitle: false,
        backgroundColor: AppColors.cream,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 1,
        surfaceTintColor: Colors.transparent,
        shadowColor: AppColors.brandSecondary.withValues(alpha: 0.08),
      ),
      cardTheme: CardThemeData(
        color: AppColors.cream,
        elevation: 0.5,
        shadowColor: AppColors.brandSecondary.withValues(alpha: 0.14),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: radius,
          side: BorderSide(color: AppColors.brandTertiary.withValues(alpha: 0.22)),
        ),
        margin: EdgeInsets.zero,
      ),
      dividerColor: AppColors.brandTertiary.withValues(alpha: 0.25),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.cream,
        border: OutlineInputBorder(borderRadius: radius),
        enabledBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(color: outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(color: scheme.primary, width: 1.4),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          shape: RoundedRectangleBorder(borderRadius: radius),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: scheme.primary,
          side: BorderSide(color: scheme.primary.withValues(alpha: 0.65)),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          shape: RoundedRectangleBorder(borderRadius: radius),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        elevation: 0,
        backgroundColor: AppColors.cream,
        indicatorColor: AppColors.brandTertiary.withValues(alpha: 0.28),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => TextStyle(
            color: states.contains(WidgetState.selected) ? scheme.primary : scheme.onSurfaceVariant,
            fontWeight: states.contains(WidgetState.selected) ? FontWeight.w700 : FontWeight.w600,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected) ? scheme.primary : scheme.onSurfaceVariant,
          ),
        ),
      ),
    );

    // SRS NFR: Bangla-first UI readability (fallbacks still apply per platform).
    return base.copyWith(
      textTheme: GoogleFonts.notoSansBengaliTextTheme(base.textTheme),
      primaryTextTheme: GoogleFonts.notoSansBengaliTextTheme(base.primaryTextTheme),
    );
  }
}
