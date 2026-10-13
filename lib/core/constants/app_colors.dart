// Path: core/constants/app_colors.dart
import "package:flutter/material.dart";

/// Central color palette for the gallery app.
/// Kept dependency-free so [AppTheme] and widgets can use it anywhere.
class AppColors {
  AppColors._();

  // Brand
  static const Color primary = Color(0xFF4CAF50);
  static const Color primaryGreen = Color(0xFF43A047);
  static const Color forestGreen = Color(0xFF2E7D32);
  static const Color secondaryBlue = Color(0xFF2196F3);
  static const Color gold = Color(0xFFFFB300);

  // Status
  static const Color success = Color(0xFF43A047);
  static const Color error = Color(0xFFE53935);
  static const Color info = Color(0xFF1E88E5);
  static const Color warning = Color(0xFFFB8C00);

  // Light scheme
  static const Color lightBackground = Color(0xFFF7F8F7);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightTextPrimary = Color(0xFF1A1C1A);
  static const Color lightTextSecondary = Color(0xFF6B726B);
  static const Color lightDivider = Color(0xFFE3E6E3);
  static const Color lightShadow = Color(0x1A000000);
  static const Color lightDisabled = Color(0xFFBDBDBD);
  static const Color lightAltRow = Color(0xFFF0F2F0);
  static const Color greyMuted = Color(0xFFE0E0E0);

  // Dark scheme
  static const Color darkBackground = Color(0xFF121412);
  static const Color darkSurface = Color(0xFF1C211C);
  static const Color darkTextPrimary = Color(0xFFF1F3F1);
  static const Color darkTextSecondary = Color(0xFFA9B3A9);
  static const Color darkDivider = Color(0xFF2E352E);
  static const Color darkShadow = Color(0x66000000);
  static const Color darkAltRow = Color(0xFF222722);
}

/// Opacity helper kept here so widgets don't need extension imports.
extension ColorOpacity on Color {
  Color adjustOpacity(double opacity) => withValues(alpha: opacity);
}
