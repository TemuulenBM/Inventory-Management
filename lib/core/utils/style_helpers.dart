import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:retail_control_platform/core/constants/app_colors.dart';
import 'package:retail_control_platform/core/constants/app_radius.dart';
import 'package:retail_control_platform/core/constants/app_spacing.dart';

/// Tailwind-inspired utility helpers for styling
/// Glassmorphism, shadows, gradients, extensions

// ===== SHADOW HELPERS =====

class AppShadows {
  AppShadows._();

  /// Soft shadow (дизайн: 0 4px 20px -2px rgba(194,117,91,0.1))
  static BoxShadow soft = BoxShadow(
    color: AppColors.primary.withValues(alpha: 0.1),
    offset: const Offset(0, 4),
    blurRadius: 20,
    spreadRadius: -2,
  );

  /// Glass shadow (дизайн: 0 8px 32px 0 rgba(31,38,135,0.05))
  static BoxShadow glass = BoxShadow(
    color: const Color(0xFF1F2687).withValues(alpha: 0.05),
    offset: const Offset(0, 8),
    blurRadius: 32,
    spreadRadius: 0,
  );

  /// Glow shadow (floating effect)
  static BoxShadow glow = BoxShadow(
    color: AppColors.primary.withValues(alpha: 0.25),
    offset: const Offset(0, 0),
    blurRadius: 25,
    spreadRadius: -5,
  );

  /// Elevated shadow (card hover state)
  static BoxShadow elevated = BoxShadow(
    color: AppColors.shadowLight,
    offset: const Offset(0, 8),
    blurRadius: 30,
    spreadRadius: -4,
  );

  /// Strong shadow (modals, dialogs)
  static BoxShadow strong = BoxShadow(
    color: AppColors.black.withValues(alpha: 0.15),
    offset: const Offset(0, 12),
    blurRadius: 40,
    spreadRadius: -8,
  );
}

// ===== GRADIENT HELPERS =====

class AppGradients {
  AppGradients._();

  /// Warm glow gradient (primary to transparent)
  static LinearGradient warmGlow = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      AppColors.primary,
      AppColors.primaryLight,
      AppColors.primary.withValues(alpha: 0.5),
      Colors.transparent,
    ],
    stops: const [0.0, 0.3, 0.7, 1.0],
  );

  /// Teal gradient (secondary theme)
  static LinearGradient tealFlow = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      AppColors.secondary,
      AppColors.secondaryLight,
    ],
  );

  /// Background gradient (subtle)
  static LinearGradient backgroundSubtle = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      AppColors.backgroundLight,
      AppColors.surfaceVariantLight,
    ],
  );

  /// Dark background gradient
  static LinearGradient backgroundDark = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      AppColors.backgroundDark,
      AppColors.surfaceVariantDark,
    ],
  );

  /// Shimmer gradient (loading effect)
  static LinearGradient shimmer = LinearGradient(
    begin: Alignment(-1.0, 0.0),
    end: Alignment(1.0, 0.0),
    colors: [
      AppColors.gray200,
      AppColors.gray100,
      AppColors.gray200,
    ],
    stops: const [0.0, 0.5, 1.0],
  );
}

// ===== GLASSMORPHISM HELPER =====

/// Glassmorphism decoration үүсгэх
/// Дизайн: backdrop-filter blur(12px), rgba(255,255,255,0.7), white border
BoxDecoration glassDecoration({
  double blur = 12.0,
  Color? backgroundColor,
  Color? borderColor,
  double borderWidth = 1.0,
  BorderRadius? borderRadius,
  List<BoxShadow>? shadows,
}) {
  return BoxDecoration(
    color: backgroundColor ?? AppColors.glassWhite,
    borderRadius: borderRadius ?? AppRadius.radiusLG,
    border: Border.all(
      color: borderColor ?? AppColors.glassBorder,
      width: borderWidth,
    ),
    boxShadow: shadows ?? [AppShadows.glass],
  );
}

/// Dark mode glassmorphism
BoxDecoration glassDecorationDark({
  double blur = 12.0,
  Color? backgroundColor,
  Color? borderColor,
  double borderWidth = 1.0,
  BorderRadius? borderRadius,
}) {
  return BoxDecoration(
    color: backgroundColor ?? AppColors.glassDark,
    borderRadius: borderRadius ?? AppRadius.radiusLG,
    border: Border.all(
      color: borderColor ?? AppColors.gray700,
      width: borderWidth,
    ),
    boxShadow: [
      BoxShadow(
        color: AppColors.black.withValues(alpha: 0.3),
        offset: const Offset(0, 8),
        blurRadius: 32,
      ),
    ],
  );
}

/// Glass container widget (backdropFilter-тэй)
class GlassContainer extends StatelessWidget {
  final Widget child;
  final double blur;
  final Color? backgroundColor;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;
  final double? width;
  final double? height;

  const GlassContainer({
    super.key,
    required this.child,
    this.blur = 12.0,
    this.backgroundColor,
    this.borderRadius,
    this.padding,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius ?? AppRadius.radiusLG,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          width: width,
          height: height,
          padding: padding ?? AppSpacing.paddingMD,
          decoration: glassDecoration(
            blur: blur,
            backgroundColor: backgroundColor,
            borderRadius: borderRadius,
          ),
          child: child,
        ),
      ),
    );
  }
}

// ===== BUILDCONTEXT EXTENSIONS =====

extension BuildContextExtensions on BuildContext {
  /// Theme shortcuts
  ThemeData get theme => Theme.of(this);
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  TextTheme get textTheme => Theme.of(this).textTheme;

  /// MediaQuery shortcuts
  Size get screenSize => MediaQuery.of(this).size;
  double get screenWidth => MediaQuery.of(this).size.width;
  double get screenHeight => MediaQuery.of(this).size.height;
  EdgeInsets get viewPadding => MediaQuery.of(this).viewPadding;
  EdgeInsets get viewInsets => MediaQuery.of(this).viewInsets;
  double get devicePixelRatio => MediaQuery.of(this).devicePixelRatio;

  /// Brightness
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;
  bool get isLightMode => Theme.of(this).brightness == Brightness.light;

  /// Navigation shortcuts
  void pop<T>([T? result]) => Navigator.of(this).pop(result);
  Future<T?> push<T>(Widget page) => Navigator.of(this).push<T>(
        MaterialPageRoute(builder: (_) => page),
      );

  /// Spacing helpers
  SizedBox get verticalSpaceXS => AppSpacing.verticalXS;
  SizedBox get verticalSpaceSM => AppSpacing.verticalSM;
  SizedBox get verticalSpaceMD => AppSpacing.verticalMD;
  SizedBox get verticalSpaceLG => AppSpacing.verticalLG;
  SizedBox get verticalSpaceXL => AppSpacing.verticalXL;

  SizedBox get horizontalSpaceXS => AppSpacing.horizontalXS;
  SizedBox get horizontalSpaceSM => AppSpacing.horizontalSM;
  SizedBox get horizontalSpaceMD => AppSpacing.horizontalMD;
  SizedBox get horizontalSpaceLG => AppSpacing.horizontalLG;
  SizedBox get horizontalSpaceXL => AppSpacing.horizontalXL;

  /// SnackBar helper
  void showSnackBar(
    String message, {
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
  }) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: duration,
        action: action,
      ),
    );
  }

  /// Dialog helper
  Future<T?> showConfirmDialog<T>({
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
  }) {
    return showDialog<T>(
      context: this,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(cancelText),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(confirmText),
          ),
        ],
      ),
    );
  }
}

// ===== UTILITY FUNCTIONS =====

/// Padding utility (Tailwind-style)
EdgeInsets px(double value) => EdgeInsets.all(value);
EdgeInsets py(double value) => EdgeInsets.symmetric(vertical: value);
EdgeInsets pxh(double value) => EdgeInsets.symmetric(horizontal: value);
EdgeInsets pt(double value) => EdgeInsets.only(top: value);
EdgeInsets pb(double value) => EdgeInsets.only(bottom: value);
EdgeInsets pl(double value) => EdgeInsets.only(left: value);
EdgeInsets pr(double value) => EdgeInsets.only(right: value);

/// Border radius utility
BorderRadius rounded(double value) => BorderRadius.circular(value);
BorderRadius roundedTop(double value) => AppRadius.topRadius(value);
BorderRadius roundedBottom(double value) => AppRadius.bottomRadius(value);

/// Shadow utility
List<BoxShadow> shadow([BoxShadow? customShadow]) => [
      customShadow ?? AppShadows.soft,
    ];
