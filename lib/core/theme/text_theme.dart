import 'package:flutter/material.dart';
import 'package:retail_control_platform/core/constants/app_colors.dart';

/// Custom TextTheme
/// - Display/Headings: Epilogue (weights 400-900)
/// - Body/Labels: Noto Sans (weights 400-700)
class AppTextTheme {
  AppTextTheme._();

  /// Light mode text theme
  static TextTheme lightTextTheme = TextTheme(
    // Display styles (Epilogue - large headings)
    displayLarge: TextStyle(
      fontFamily: 'Epilogue',
      fontSize: 57,
      fontWeight: FontWeight.w800,
      letterSpacing: -0.5,
      color: AppColors.textMainLight,
      height: 1.12,
    ),
    displayMedium: TextStyle(
      fontFamily: 'Epilogue',
      fontSize: 45,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.25,
      color: AppColors.textMainLight,
      height: 1.16,
    ),
    displaySmall: TextStyle(
      fontFamily: 'Epilogue',
      fontSize: 36,
      fontWeight: FontWeight.w700,
      letterSpacing: 0,
      color: AppColors.textMainLight,
      height: 1.22,
    ),

    // Headline styles (Epilogue - section headings)
    headlineLarge: TextStyle(
      fontFamily: 'Epilogue',
      fontSize: 32,
      fontWeight: FontWeight.w600,
      letterSpacing: 0,
      color: AppColors.textMainLight,
      height: 1.25,
    ),
    headlineMedium: TextStyle(
      fontFamily: 'Epilogue',
      fontSize: 28,
      fontWeight: FontWeight.w600,
      letterSpacing: 0,
      color: AppColors.textMainLight,
      height: 1.29,
    ),
    headlineSmall: TextStyle(
      fontFamily: 'Epilogue',
      fontSize: 24,
      fontWeight: FontWeight.w600,
      letterSpacing: 0,
      color: AppColors.textMainLight,
      height: 1.33,
    ),

    // Title styles (Epilogue - card titles, dialog titles)
    titleLarge: TextStyle(
      fontFamily: 'Epilogue',
      fontSize: 22,
      fontWeight: FontWeight.w500,
      letterSpacing: 0,
      color: AppColors.textMainLight,
      height: 1.27,
    ),
    titleMedium: TextStyle(
      fontFamily: 'Epilogue',
      fontSize: 16,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.15,
      color: AppColors.textMainLight,
      height: 1.50,
    ),
    titleSmall: TextStyle(
      fontFamily: 'Epilogue',
      fontSize: 14,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.1,
      color: AppColors.textMainLight,
      height: 1.43,
    ),

    // Body styles (Noto Sans - main content)
    bodyLarge: TextStyle(
      fontFamily: 'Noto Sans',
      fontSize: 16,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.5,
      color: AppColors.textMainLight,
      height: 1.50,
    ),
    bodyMedium: TextStyle(
      fontFamily: 'Noto Sans',
      fontSize: 14,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.25,
      color: AppColors.textMainLight,
      height: 1.43,
    ),
    bodySmall: TextStyle(
      fontFamily: 'Noto Sans',
      fontSize: 12,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.4,
      color: AppColors.textSecondaryLight,
      height: 1.33,
    ),

    // Label styles (Noto Sans - buttons, chips)
    labelLarge: TextStyle(
      fontFamily: 'Noto Sans',
      fontSize: 14,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.1,
      color: AppColors.textMainLight,
      height: 1.43,
    ),
    labelMedium: TextStyle(
      fontFamily: 'Noto Sans',
      fontSize: 12,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.5,
      color: AppColors.textMainLight,
      height: 1.33,
    ),
    labelSmall: TextStyle(
      fontFamily: 'Noto Sans',
      fontSize: 11,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.5,
      color: AppColors.textSecondaryLight,
      height: 1.45,
    ),
  );

  /// Dark mode text theme
  static TextTheme darkTextTheme = TextTheme(
    // Display styles
    displayLarge: TextStyle(
      fontFamily: 'Epilogue',
      fontSize: 57,
      fontWeight: FontWeight.w800,
      letterSpacing: -0.5,
      color: AppColors.textMainDark,
      height: 1.12,
    ),
    displayMedium: TextStyle(
      fontFamily: 'Epilogue',
      fontSize: 45,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.25,
      color: AppColors.textMainDark,
      height: 1.16,
    ),
    displaySmall: TextStyle(
      fontFamily: 'Epilogue',
      fontSize: 36,
      fontWeight: FontWeight.w700,
      letterSpacing: 0,
      color: AppColors.textMainDark,
      height: 1.22,
    ),

    // Headline styles
    headlineLarge: TextStyle(
      fontFamily: 'Epilogue',
      fontSize: 32,
      fontWeight: FontWeight.w600,
      letterSpacing: 0,
      color: AppColors.textMainDark,
      height: 1.25,
    ),
    headlineMedium: TextStyle(
      fontFamily: 'Epilogue',
      fontSize: 28,
      fontWeight: FontWeight.w600,
      letterSpacing: 0,
      color: AppColors.textMainDark,
      height: 1.29,
    ),
    headlineSmall: TextStyle(
      fontFamily: 'Epilogue',
      fontSize: 24,
      fontWeight: FontWeight.w600,
      letterSpacing: 0,
      color: AppColors.textMainDark,
      height: 1.33,
    ),

    // Title styles
    titleLarge: TextStyle(
      fontFamily: 'Epilogue',
      fontSize: 22,
      fontWeight: FontWeight.w500,
      letterSpacing: 0,
      color: AppColors.textMainDark,
      height: 1.27,
    ),
    titleMedium: TextStyle(
      fontFamily: 'Epilogue',
      fontSize: 16,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.15,
      color: AppColors.textMainDark,
      height: 1.50,
    ),
    titleSmall: TextStyle(
      fontFamily: 'Epilogue',
      fontSize: 14,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.1,
      color: AppColors.textMainDark,
      height: 1.43,
    ),

    // Body styles
    bodyLarge: TextStyle(
      fontFamily: 'Noto Sans',
      fontSize: 16,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.5,
      color: AppColors.textMainDark,
      height: 1.50,
    ),
    bodyMedium: TextStyle(
      fontFamily: 'Noto Sans',
      fontSize: 14,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.25,
      color: AppColors.textMainDark,
      height: 1.43,
    ),
    bodySmall: TextStyle(
      fontFamily: 'Noto Sans',
      fontSize: 12,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.4,
      color: AppColors.textSecondaryDark,
      height: 1.33,
    ),

    // Label styles
    labelLarge: TextStyle(
      fontFamily: 'Noto Sans',
      fontSize: 14,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.1,
      color: AppColors.textMainDark,
      height: 1.43,
    ),
    labelMedium: TextStyle(
      fontFamily: 'Noto Sans',
      fontSize: 12,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.5,
      color: AppColors.textMainDark,
      height: 1.33,
    ),
    labelSmall: TextStyle(
      fontFamily: 'Noto Sans',
      fontSize: 11,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.5,
      color: AppColors.textSecondaryDark,
      height: 1.45,
    ),
  );
}
