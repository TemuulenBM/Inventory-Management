import 'package:flutter/material.dart';
import 'package:retail_control_platform/core/constants/app_radius.dart';
import 'package:retail_control_platform/core/utils/style_helpers.dart';

/// Custom icon button with glass background option
class IconButtonCustom extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? iconColor;
  final Color? backgroundColor;
  final double size;
  final bool hasGlassEffect;
  final String? tooltip;

  const IconButtonCustom({
    super.key,
    required this.icon,
    this.onPressed,
    this.iconColor,
    this.backgroundColor,
    this.size = 40.0,
    this.hasGlassEffect = false,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final button = IconButton(
      onPressed: onPressed,
      icon: Icon(icon),
      iconSize: size * 0.6,
      color: iconColor ?? context.colorScheme.onSurface,
      tooltip: tooltip,
      style: IconButton.styleFrom(
        backgroundColor: backgroundColor,
        minimumSize: Size(size, size),
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.radiusMD,
        ),
      ),
    );

    if (hasGlassEffect) {
      return ClipRRect(
        borderRadius: AppRadius.radiusMD,
        child: GlassContainer(
          blur: 8,
          padding: EdgeInsets.zero,
          width: size,
          height: size,
          child: button,
        ),
      );
    }

    return button;
  }
}

/// Circular icon button
class CircularIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? iconColor;
  final Color? backgroundColor;
  final double size;

  const CircularIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.iconColor,
    this.backgroundColor,
    this.size = 40.0,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(icon),
      iconSize: size * 0.5,
      color: iconColor ?? context.colorScheme.onSurface,
      style: IconButton.styleFrom(
        backgroundColor: backgroundColor ?? context.colorScheme.surface,
        minimumSize: Size(size, size),
        shape: const CircleBorder(),
      ),
    );
  }
}

/// Small icon button (for compact UI)
class IconButtonSmall extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? iconColor;

  const IconButtonSmall({
    super.key,
    required this.icon,
    this.onPressed,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return IconButtonCustom(
      icon: icon,
      onPressed: onPressed,
      iconColor: iconColor,
      size: 32.0,
    );
  }
}
