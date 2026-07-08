import 'package:flutter/material.dart';

/// Puja Bandhu palette — SRS §19 (saffron, maroon, marigold gold, warm ivory).
abstract final class AppColors {
  // Primary palette (SRS §19.2)
  static const Color brandPrimary = Color(0xFFD9740A); // Deep Saffron
  static const Color brandSecondary = Color(0xFF7A1F2B); // Maroon
  static const Color brandTertiary = Color(0xFFF4B731); // Marigold Gold

  // Warm accent
  static const Color warmOrange = Color(0xFFE08A2E);

  // Semantic (SRS §19.3)
  static const Color success = Color(0xFF3B7A4A);
  static const Color warning = Color(0xFFE0A526);
  static const Color danger = Color(0xFFC0392B);
  static const Color info = Color(0xFF2E6F95);

  // Surfaces
  static const Color ivory = Color(0xFFFBF6EE); // Warm Ivory background
  static const Color cream = Color(0xFFFFFFFF); // Pure White cards
  static const Color maroon = Color(0xFF7A1F2B);
  static const Color goldGlow = Color(0xFFFFF4D6);
  static const Color goldAccent = brandTertiary;

  // Text
  static const Color textPrimary = Color(0xFF2B2420); // Charcoal
  static const Color textSecondary = Color(0xFF7A6F63); // Warm Gray

  // Neutrals
  static const Color outlineMuted = Color(0xFFE8E0D4);
  static const Color outlineMutedDark = Color(0xFF4A3A32);

  // Dark mode (SRS §19.4)
  static const Color darkBackground = Color(0xFF1C1714);
  static const Color darkSurface = Color(0xFF2A231E);
  static const Color darkTextPrimary = Color(0xFFF2EAE0);

  /// Hero / marketing gradients (countdown, splash, feature icons).
  static const List<Color> brandGradient = [brandSecondary, brandPrimary, warmOrange];
  static const List<Color> festiveSurfaceGradient = [ivory, cream];
  static const List<Color> countdownGradient = [brandSecondary, brandPrimary, warmOrange];
}
