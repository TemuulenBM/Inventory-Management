import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:retail_control_platform/core/constants/app_colors.dart';
import 'package:retail_control_platform/core/constants/app_radius.dart';
import 'package:retail_control_platform/core/constants/app_spacing.dart';
import 'package:retail_control_platform/core/utils/style_helpers.dart';

/// Glassmorphism panel (дизайн файлуудаас)
/// Backdrop blur + semi-transparent background + border
class GlassPanel extends StatelessWidget {
  final Widget child;
  final double blur;
  final Color? backgroundColor;
  final Color? borderColor;
  final double borderWidth;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final List<BoxShadow>? shadows;

  const GlassPanel({
    super.key,
    required this.child,
    this.blur = 12.0,
    this.backgroundColor,
    this.borderColor,
    this.borderWidth = 1.0,
    this.borderRadius,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.shadows,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final defaultBgColor = isDark
        ? AppColors.glassDark
        : AppColors.glassWhite;
    final defaultBorderColor = isDark
        ? AppColors.gray700
        : AppColors.glassBorder;

    return Container(
      width: width,
      height: height,
      margin: margin,
      child: ClipRRect(
        borderRadius: borderRadius ?? AppRadius.radiusLG,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding ?? AppSpacing.paddingMD,
            decoration: BoxDecoration(
              color: backgroundColor ?? defaultBgColor,
              borderRadius: borderRadius ?? AppRadius.radiusLG,
              border: Border.all(
                color: borderColor ?? defaultBorderColor,
                width: borderWidth,
              ),
              boxShadow: shadows ?? [AppShadows.glass],
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Compact glass panel (less padding)
class GlassPanelCompact extends StatelessWidget {
  final Widget child;
  final double blur;

  const GlassPanelCompact({
    super.key,
    required this.child,
    this.blur = 12.0,
  });

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      blur: blur,
      padding: AppSpacing.paddingSM,
      child: child,
    );
  }
}

/// Glass card with tap functionality
class GlassCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double blur;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;

  const GlassCard({
    super.key,
    required this.child,
    this.onTap,
    this.blur = 12.0,
    this.padding,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final panel = GlassPanel(
      blur: blur,
      padding: padding ?? AppSpacing.paddingMD,
      borderRadius: borderRadius,
      child: child,
    );

    if (onTap == null) {
      return panel;
    }

    return InkWell(
      onTap: onTap,
      borderRadius: borderRadius ?? AppRadius.radiusLG,
      child: panel,
    );
  }
}
