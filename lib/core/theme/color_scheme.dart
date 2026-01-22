import 'package:flutter/material.dart';
import 'package:retail_control_platform/core/constants/app_colors.dart';

/// Material 3 ColorScheme-үүд (light ба dark mode)
/// Дизайн системийн өнгөөр дүүргэсэн
class AppColorSchemes {
  AppColorSchemes._();

  /// Light mode color scheme
  static final ColorScheme lightColorScheme = ColorScheme.light(
    // Primary colors (Terracotta/Rust)
    primary: AppColors.primary, // #c2755b
    onPrimary: AppColors.white,
    primaryContainer: AppColors.primaryLight,
    onPrimaryContainer: AppColors.primaryDark,

    // Secondary colors (Teal)
    secondary: AppColors.secondary, // #00878F
    onSecondary: AppColors.white,
    secondaryContainer: AppColors.secondaryLight,
    onSecondaryContainer: AppColors.secondaryDark,

    // Tertiary (Success green as tertiary)
    tertiary: AppColors.successGreen,
    onTertiary: AppColors.white,
    tertiaryContainer: AppColors.successBackground,
    onTertiaryContainer: AppColors.successGreen,

    // Error colors
    error: AppColors.danger,
    onError: AppColors.white,
    errorContainer: AppColors.errorBackground,
    onErrorContainer: AppColors.dangerRed,

    // Background & Surface
    background: AppColors.backgroundLight, // #fbfaf9
    onBackground: AppColors.textMainLight, // #181311
    surface: AppColors.surfaceLight, // #ffffff
    onSurface: AppColors.textMainLight,
    surfaceVariant: AppColors.surfaceVariantLight,
    onSurfaceVariant: AppColors.textSecondaryLight,

    // Outline
    outline: AppColors.gray300,
    outlineVariant: AppColors.gray200,

    // Shadow & Scrim
    shadow: AppColors.shadowLight,
    scrim: AppColors.overlayDark,

    // Inverse colors
    inverseSurface: AppColors.surfaceDark,
    onInverseSurface: AppColors.textMainDark,
    inversePrimary: AppColors.primaryLight,
  );

  /// Dark mode color scheme
  static final ColorScheme darkColorScheme = ColorScheme.dark(
    // Primary colors (lighter tint for dark mode)
    primary: AppColors.primaryLight, // Lighter tint for dark mode
    onPrimary: AppColors.textMainLight,
    primaryContainer: AppColors.primaryDark,
    onPrimaryContainer: AppColors.primaryLight,

    // Secondary colors
    secondary: AppColors.secondary,
    onSecondary: AppColors.textMainLight,
    secondaryContainer: AppColors.secondaryDark,
    onSecondaryContainer: AppColors.secondaryLight,

    // Tertiary
    tertiary: AppColors.successGreen,
    onTertiary: AppColors.textMainLight,
    tertiaryContainer: AppColors.successGreen,
    onTertiaryContainer: AppColors.successBackground,

    // Error colors
    error: AppColors.error,
    onError: AppColors.textMainLight,
    errorContainer: AppColors.dangerRed,
    onErrorContainer: AppColors.errorBackground,

    // Background & Surface
    background: AppColors.backgroundDark, // #1d2025
    onBackground: AppColors.textMainDark, // #ffffff
    surface: AppColors.surfaceDark, // #2a2d33
    onSurface: AppColors.textMainDark,
    surfaceVariant: AppColors.surfaceVariantDark,
    onSurfaceVariant: AppColors.textSecondaryDark,

    // Outline
    outline: AppColors.gray700,
    outlineVariant: AppColors.gray800,

    // Shadow & Scrim
    shadow: AppColors.black,
    scrim: AppColors.overlayDark,

    // Inverse colors
    inverseSurface: AppColors.surfaceLight,
    onInverseSurface: AppColors.textMainLight,
    inversePrimary: AppColors.primary,
  );
}
