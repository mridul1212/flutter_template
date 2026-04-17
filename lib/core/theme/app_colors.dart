import 'package:flutter/material.dart';

/// Central palette and semantic colors. Prefer referencing these instead of inline hex/random [Colors.*].
abstract final class AppColors {
  // Brand
  static const Color brandPrimary = Color(0xFF2563EB);
  static const Color brandSecondary = Color(0xFF7C3AED);
  static const Color brandTertiary = Color(0xFF0EA5E9);

  // Semantic (light surfaces)
  static const Color success = Color(0xFF16A34A);
  static const Color warning = Color(0xFFF59E0B);
  static const Color danger = Color(0xFFDC2626);

  // Neutrals (for borders / subtle fills when not using ColorScheme)
  static const Color outlineMuted = Color(0xFFE5E7EB);
  static const Color outlineMutedDark = Color(0xFF374151);

  /// Optional extra brand accents for marketing / illustrations.
  static const List<Color> brandGradient = [brandPrimary, brandTertiary];
}
