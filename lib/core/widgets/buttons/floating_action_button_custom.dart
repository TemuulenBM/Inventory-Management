import 'package:flutter/material.dart';
import 'package:retail_control_platform/core/constants/app_colors.dart';
import 'package:retail_control_platform/core/constants/app_radius.dart';
import 'package:retail_control_platform/core/utils/style_helpers.dart';

/// Custom FAB with glass effect and shimmer (from design)
class FloatingActionButtonCustom extends StatelessWidget {
  final VoidCallback? onPressed;
  final IconData icon;
  final String? label;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final bool hasGlowEffect;

  const FloatingActionButtonCustom({
    super.key,
    required this.onPressed,
    required this.icon,
    this.label,
    this.backgroundColor,
    this.foregroundColor,
    this.hasGlowEffect = true,
  });

  @override
  Widget build(BuildContext context) {
    final fab = label != null
        ? FloatingActionButton.extended(
            onPressed: onPressed,
            icon: Icon(icon),
            label: Text(label!),
            backgroundColor: backgroundColor ?? AppColors.secondary,
            foregroundColor: foregroundColor ?? AppColors.white,
            elevation: hasGlowEffect ? 6 : 4,
            shape: RoundedRectangleBorder(
              borderRadius: AppRadius.radiusLG,
            ),
          )
        : FloatingActionButton(
            onPressed: onPressed,
            backgroundColor: backgroundColor ?? AppColors.secondary,
            foregroundColor: foregroundColor ?? AppColors.white,
            elevation: hasGlowEffect ? 6 : 4,
            shape: RoundedRectangleBorder(
              borderRadius: AppRadius.radiusLG,
            ),
            child: Icon(icon),
          );

    if (hasGlowEffect) {
      return Container(
        decoration: BoxDecoration(
          borderRadius: AppRadius.radiusLG,
          boxShadow: [AppShadows.glow],
        ),
        child: fab,
      );
    }

    return fab;
  }
}

/// Large FAB for main actions
class FloatingActionButtonLarge extends StatelessWidget {
  final VoidCallback? onPressed;
  final IconData icon;
  final String label;

  const FloatingActionButtonLarge({
    super.key,
    required this.onPressed,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButtonCustom(
      onPressed: onPressed,
      icon: icon,
      label: label,
      hasGlowEffect: true,
    );
  }
}

/// Mini FAB for secondary actions
class FloatingActionButtonMini extends StatelessWidget {
  final VoidCallback? onPressed;
  final IconData icon;

  const FloatingActionButtonMini({
    super.key,
    required this.onPressed,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.small(
      onPressed: onPressed,
      backgroundColor: AppColors.secondary,
      foregroundColor: AppColors.white,
      child: Icon(icon),
    );
  }
}
