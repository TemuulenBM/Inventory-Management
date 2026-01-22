import 'package:flutter/material.dart';
import 'package:retail_control_platform/core/constants/app_colors.dart';
import 'package:retail_control_platform/core/constants/app_radius.dart';
import 'package:retail_control_platform/core/constants/app_spacing.dart';

/// Material 3 component themes (Button, Card, Input, AppBar, гэх мэт)
class AppComponentThemes {
  AppComponentThemes._();

  // ===== BUTTON THEMES =====

  /// ElevatedButton theme (Primary button - terracotta color)
  static ElevatedButtonThemeData elevatedButtonTheme = ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.white,
      disabledBackgroundColor: AppColors.gray300,
      disabledForegroundColor: AppColors.gray500,
      elevation: 2,
      shadowColor: AppColors.shadowMedium,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.buttonRadius, // 16px
      ),
      padding: AppSpacing.buttonPadding, // h:24, v:16
      minimumSize: const Size(88, 48),
      textStyle: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
      ),
    ),
  );

  /// OutlinedButton theme (Secondary button)
  static OutlinedButtonThemeData outlinedButtonTheme = OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: AppColors.primary,
      disabledForegroundColor: AppColors.gray400,
      side: const BorderSide(color: AppColors.primary, width: 1.5),
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.buttonRadius,
      ),
      padding: AppSpacing.buttonPadding,
      minimumSize: const Size(88, 48),
      textStyle: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
      ),
    ),
  );

  /// TextButton theme
  static TextButtonThemeData textButtonTheme = TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: AppColors.primary,
      disabledForegroundColor: AppColors.gray400,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.radiusMD,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      textStyle: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
      ),
    ),
  );

  /// IconButton theme
  static IconButtonThemeData iconButtonTheme = IconButtonThemeData(
    style: IconButton.styleFrom(
      foregroundColor: AppColors.textMainLight,
      iconSize: AppSpacing.iconSizeMedium, // 24px
      minimumSize: const Size(40, 40),
      padding: const EdgeInsets.all(8),
    ),
  );

  /// FloatingActionButton theme
  static FloatingActionButtonThemeData floatingActionButtonTheme =
      FloatingActionButtonThemeData(
    backgroundColor: AppColors.secondary, // Teal
    foregroundColor: AppColors.white,
    elevation: 4,
    shape: RoundedRectangleBorder(
      borderRadius: AppRadius.radiusLG,
    ),
    iconSize: 24,
  );

  // ===== CARD THEME =====

  static CardTheme cardTheme = CardTheme(
    color: AppColors.surfaceLight,
    shadowColor: AppColors.shadowLight,
    surfaceTintColor: Colors.transparent,
    elevation: 1,
    shape: RoundedRectangleBorder(
      borderRadius: AppRadius.cardRadius, // 16px
    ),
    margin: const EdgeInsets.symmetric(
      horizontal: AppSpacing.md,
      vertical: AppSpacing.sm,
    ),
    clipBehavior: Clip.antiAlias,
  );

  // ===== INPUT DECORATION THEME =====

  static InputDecorationTheme inputDecorationTheme = InputDecorationTheme(
    filled: true,
    fillColor: AppColors.surfaceLight,
    contentPadding: AppSpacing.inputPadding, // h:16, v:16
    border: OutlineInputBorder(
      borderRadius: AppRadius.inputRadius, // 12px
      borderSide: const BorderSide(color: AppColors.gray300, width: 1),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: AppRadius.inputRadius,
      borderSide: const BorderSide(color: AppColors.gray300, width: 1),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: AppRadius.inputRadius,
      borderSide: const BorderSide(color: AppColors.primary, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: AppRadius.inputRadius,
      borderSide: const BorderSide(color: AppColors.danger, width: 1),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: AppRadius.inputRadius,
      borderSide: const BorderSide(color: AppColors.danger, width: 2),
    ),
    disabledBorder: OutlineInputBorder(
      borderRadius: AppRadius.inputRadius,
      borderSide: const BorderSide(color: AppColors.gray200, width: 1),
    ),
    labelStyle: const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: AppColors.textSecondaryLight,
    ),
    hintStyle: const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: AppColors.gray400,
    ),
    errorStyle: const TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: AppColors.danger,
    ),
    prefixIconColor: AppColors.textSecondaryLight,
    suffixIconColor: AppColors.textSecondaryLight,
  );

  // ===== APP BAR THEME =====

  static AppBarTheme appBarTheme = AppBarTheme(
    backgroundColor: AppColors.surfaceLight,
    foregroundColor: AppColors.textMainLight,
    elevation: 0,
    centerTitle: false,
    titleTextStyle: const TextStyle(
      fontFamily: 'Epilogue',
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: AppColors.textMainLight,
      letterSpacing: 0,
    ),
    iconTheme: const IconThemeData(
      color: AppColors.textMainLight,
      size: 24,
    ),
    actionsIconTheme: const IconThemeData(
      color: AppColors.textMainLight,
      size: 24,
    ),
    toolbarHeight: AppSpacing.appBarHeight, // 56px
  );

  // ===== BOTTOM NAVIGATION BAR THEME =====

  static BottomNavigationBarThemeData bottomNavigationBarTheme =
      BottomNavigationBarThemeData(
    backgroundColor: AppColors.surfaceLight,
    selectedItemColor: AppColors.primary,
    unselectedItemColor: AppColors.gray500,
    selectedLabelStyle: const TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w600,
    ),
    unselectedLabelStyle: const TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w400,
    ),
    type: BottomNavigationBarType.fixed,
    elevation: 8,
  );

  // ===== CHIP THEME =====

  static ChipThemeData chipTheme = ChipThemeData(
    backgroundColor: AppColors.gray100,
    disabledColor: AppColors.gray200,
    selectedColor: AppColors.primary,
    secondarySelectedColor: AppColors.secondary,
    labelPadding: const EdgeInsets.symmetric(horizontal: 12),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    shape: RoundedRectangleBorder(
      borderRadius: AppRadius.chipRadius, // Pill shape
    ),
    labelStyle: const TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: AppColors.textMainLight,
    ),
    secondaryLabelStyle: const TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: AppColors.white,
    ),
    brightness: Brightness.light,
  );

  // ===== DIALOG THEME =====

  static DialogTheme dialogTheme = DialogTheme(
    backgroundColor: AppColors.surfaceLight,
    elevation: 8,
    shape: RoundedRectangleBorder(
      borderRadius: AppRadius.modalRadius, // 24px
    ),
    titleTextStyle: const TextStyle(
      fontFamily: 'Epilogue',
      fontSize: 24,
      fontWeight: FontWeight.w600,
      color: AppColors.textMainLight,
    ),
    contentTextStyle: const TextStyle(
      fontFamily: 'Noto Sans',
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: AppColors.textMainLight,
      height: 1.5,
    ),
  );

  // ===== BOTTOM SHEET THEME =====

  static BottomSheetThemeData bottomSheetTheme = BottomSheetThemeData(
    backgroundColor: AppColors.surfaceLight,
    elevation: 8,
    shape: RoundedRectangleBorder(
      borderRadius: AppRadius.bottomSheetRadius, // Top rounded only
    ),
    clipBehavior: Clip.antiAlias,
  );

  // ===== SNACKBAR THEME =====

  static SnackBarThemeData snackBarTheme = SnackBarThemeData(
    backgroundColor: AppColors.surfaceDark,
    contentTextStyle: const TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: AppColors.textMainDark,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: AppRadius.radiusMD,
    ),
    behavior: SnackBarBehavior.floating,
    elevation: 6,
  );

  // ===== DIVIDER THEME =====

  static DividerThemeData dividerTheme = const DividerThemeData(
    color: AppColors.gray200,
    thickness: 1,
    space: 1,
  );

  // ===== CHECKBOX THEME =====

  static CheckboxThemeData checkboxTheme = CheckboxThemeData(
    fillColor: MaterialStateProperty.resolveWith((states) {
      if (states.contains(MaterialState.selected)) {
        return AppColors.primary;
      }
      return AppColors.transparent;
    }),
    checkColor: MaterialStateProperty.all(AppColors.white),
    shape: RoundedRectangleBorder(
      borderRadius: AppRadius.radiusXS, // 4px
    ),
  );

  // ===== RADIO THEME =====

  static RadioThemeData radioTheme = RadioThemeData(
    fillColor: MaterialStateProperty.resolveWith((states) {
      if (states.contains(MaterialState.selected)) {
        return AppColors.primary;
      }
      return AppColors.gray400;
    }),
  );

  // ===== SWITCH THEME =====

  static SwitchThemeData switchTheme = SwitchThemeData(
    thumbColor: MaterialStateProperty.resolveWith((states) {
      if (states.contains(MaterialState.selected)) {
        return AppColors.primary;
      }
      return AppColors.gray400;
    }),
    trackColor: MaterialStateProperty.resolveWith((states) {
      if (states.contains(MaterialState.selected)) {
        return AppColors.primaryLight;
      }
      return AppColors.gray200;
    }),
  );

  // ===== PROGRESS INDICATOR THEME =====

  static ProgressIndicatorThemeData progressIndicatorTheme =
      const ProgressIndicatorThemeData(
    color: AppColors.primary,
    linearTrackColor: AppColors.gray200,
    circularTrackColor: AppColors.gray200,
  );
}
