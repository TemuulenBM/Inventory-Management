import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:retail_control_platform/core/theme/color_scheme.dart';
import 'package:retail_control_platform/core/theme/component_themes.dart';
import 'package:retail_control_platform/core/theme/text_theme.dart';

/// App-ийн үндсэн theme system
/// Light ба Dark mode дэмждэг Material 3 theme
class AppTheme {
  AppTheme._();

  /// Light mode theme
  static ThemeData light = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,

    // Color scheme
    colorScheme: AppColorSchemes.lightColorScheme,

    // Typography
    textTheme: AppTextTheme.lightTextTheme,

    // Component themes
    elevatedButtonTheme: AppComponentThemes.elevatedButtonTheme,
    outlinedButtonTheme: AppComponentThemes.outlinedButtonTheme,
    textButtonTheme: AppComponentThemes.textButtonTheme,
    iconButtonTheme: AppComponentThemes.iconButtonTheme,
    floatingActionButtonTheme: AppComponentThemes.floatingActionButtonTheme,
    cardTheme: AppComponentThemes.cardTheme,
    inputDecorationTheme: AppComponentThemes.inputDecorationTheme,
    appBarTheme: AppComponentThemes.appBarTheme,
    bottomNavigationBarTheme: AppComponentThemes.bottomNavigationBarTheme,
    chipTheme: AppComponentThemes.chipTheme,
    dialogTheme: AppComponentThemes.dialogTheme,
    bottomSheetTheme: AppComponentThemes.bottomSheetTheme,
    snackBarTheme: AppComponentThemes.snackBarTheme,
    dividerTheme: AppComponentThemes.dividerTheme,
    checkboxTheme: AppComponentThemes.checkboxTheme,
    radioTheme: AppComponentThemes.radioTheme,
    switchTheme: AppComponentThemes.switchTheme,
    progressIndicatorTheme: AppComponentThemes.progressIndicatorTheme,

    // Visual density
    visualDensity: VisualDensity.adaptivePlatformDensity,

    // Platform-specific behavior
    platform: TargetPlatform.android,

    // Splash color
    splashColor: AppColorSchemes.lightColorScheme.primary.withValues(alpha: 0.1),
    highlightColor: AppColorSchemes.lightColorScheme.primary.withValues(alpha: 0.05),

    // Font family fallback
    fontFamily: 'Noto Sans',
  );

  /// Dark mode theme
  static ThemeData dark = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,

    // Color scheme
    colorScheme: AppColorSchemes.darkColorScheme,

    // Typography
    textTheme: AppTextTheme.darkTextTheme,

    // Component themes (same as light mode, will adapt via ColorScheme)
    elevatedButtonTheme: AppComponentThemes.elevatedButtonTheme,
    outlinedButtonTheme: AppComponentThemes.outlinedButtonTheme,
    textButtonTheme: AppComponentThemes.textButtonTheme,
    iconButtonTheme: AppComponentThemes.iconButtonTheme,
    floatingActionButtonTheme: AppComponentThemes.floatingActionButtonTheme,
    cardTheme: AppComponentThemes.cardTheme.copyWith(
      color: AppColorSchemes.darkColorScheme.surface,
    ),
    inputDecorationTheme: AppComponentThemes.inputDecorationTheme.copyWith(
      fillColor: AppColorSchemes.darkColorScheme.surfaceVariant,
    ),
    appBarTheme: AppComponentThemes.appBarTheme.copyWith(
      backgroundColor: AppColorSchemes.darkColorScheme.surface,
      foregroundColor: AppColorSchemes.darkColorScheme.onSurface,
      titleTextStyle: AppTextTheme.darkTextTheme.titleLarge,
      iconTheme: IconThemeData(
        color: AppColorSchemes.darkColorScheme.onSurface,
      ),
    ),
    bottomNavigationBarTheme:
        AppComponentThemes.bottomNavigationBarTheme.copyWith(
      backgroundColor: AppColorSchemes.darkColorScheme.surface,
    ),
    chipTheme: AppComponentThemes.chipTheme.copyWith(
      backgroundColor: AppColorSchemes.darkColorScheme.surfaceVariant,
    ),
    dialogTheme: AppComponentThemes.dialogTheme.copyWith(
      backgroundColor: AppColorSchemes.darkColorScheme.surface,
    ),
    bottomSheetTheme: AppComponentThemes.bottomSheetTheme.copyWith(
      backgroundColor: AppColorSchemes.darkColorScheme.surface,
    ),
    snackBarTheme: AppComponentThemes.snackBarTheme,
    dividerTheme: AppComponentThemes.dividerTheme.copyWith(
      color: AppColorSchemes.darkColorScheme.outlineVariant,
    ),
    checkboxTheme: AppComponentThemes.checkboxTheme,
    radioTheme: AppComponentThemes.radioTheme,
    switchTheme: AppComponentThemes.switchTheme,
    progressIndicatorTheme: AppComponentThemes.progressIndicatorTheme,

    // Visual density
    visualDensity: VisualDensity.adaptivePlatformDensity,

    // Platform-specific behavior
    platform: TargetPlatform.android,

    // Splash color
    splashColor: AppColorSchemes.darkColorScheme.primary.withValues(alpha: 0.1),
    highlightColor: AppColorSchemes.darkColorScheme.primary.withValues(alpha: 0.05),

    // Font family fallback
    fontFamily: 'Noto Sans',
  );

  /// System UI overlay style for light theme
  static SystemUiOverlayStyle lightSystemUiOverlayStyle =
      const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.light,
    systemNavigationBarColor: Colors.white,
    systemNavigationBarIconBrightness: Brightness.dark,
  );

  /// System UI overlay style for dark theme
  static SystemUiOverlayStyle darkSystemUiOverlayStyle =
      const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
    systemNavigationBarColor: Color(0xFF1D2025),
    systemNavigationBarIconBrightness: Brightness.light,
  );
}
