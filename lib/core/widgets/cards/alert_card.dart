import 'package:flutter/material.dart';
import 'package:retail_control_platform/core/constants/app_colors.dart';
import 'package:retail_control_platform/core/constants/app_radius.dart';
import 'package:retail_control_platform/core/constants/app_spacing.dart';

/// Alert severity types
enum AlertSeverity {
  lowStock,
  negative,
  suspicious,
  info,
}

/// Alert card with severity-colored left border
/// Дизайн: Colored left border + icon + text + action buttons
class AlertCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final AlertSeverity severity;
  final String? productImageUrl;
  final VoidCallback? onTap;
  final List<Widget>? actions;
  final bool isRead;

  const AlertCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.severity,
    this.productImageUrl,
    this.onTap,
    this.actions,
    this.isRead = false,
  });

  Color get _severityColor {
    switch (severity) {
      case AlertSeverity.lowStock:
        return AppColors.warningOrange;
      case AlertSeverity.negative:
        return AppColors.dangerRed;
      case AlertSeverity.suspicious:
        return AppColors.suspicious;
      case AlertSeverity.info:
        return AppColors.secondary;
    }
  }

  Color get _backgroundColor {
    switch (severity) {
      case AlertSeverity.lowStock:
        return AppColors.warningBackground;
      case AlertSeverity.negative:
        return AppColors.errorBackground;
      case AlertSeverity.suspicious:
        return AppColors.warningBackground;
      case AlertSeverity.info:
        return AppColors.infoBackground;
    }
  }

  IconData get _icon {
    switch (severity) {
      case AlertSeverity.lowStock:
        return Icons.inventory_2_outlined;
      case AlertSeverity.negative:
        return Icons.error_outline;
      case AlertSeverity.suspicious:
        return Icons.warning_amber_outlined;
      case AlertSeverity.info:
        return Icons.info_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: AppSpacing.cardPadding,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.cardRadius,
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                color: _severityColor,
                width: 4,
              ),
            ),
            color: isRead ? null : _backgroundColor.withOpacity(0.3),
          ),
          child: Padding(
            padding: AppSpacing.paddingMD,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _severityColor.withOpacity(0.1),
                    borderRadius: AppRadius.radiusSM,
                  ),
                  child: Icon(
                    _icon,
                    color: _severityColor,
                    size: 24,
                  ),
                ),
                AppSpacing.horizontalMD,

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: isRead ? FontWeight.w500 : FontWeight.w700,
                          color: AppColors.textMainLight,
                        ),
                      ),
                      AppSpacing.verticalXS,

                      // Subtitle
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textSecondaryLight,
                        ),
                      ),

                      // Actions
                      if (actions != null && actions!.isNotEmpty) ...[
                        AppSpacing.verticalSM,
                        Wrap(
                          spacing: 8,
                          children: actions!,
                        ),
                      ],
                    ],
                  ),
                ),

                // Product image (optional)
                if (productImageUrl != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: ClipRRect(
                      borderRadius: AppRadius.radiusSM,
                      child: SizedBox(
                        width: 48,
                        height: 48,
                        child: Image.network(
                          productImageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: AppColors.gray200,
                              child: const Icon(
                                Icons.inventory_2_outlined,
                                size: 24,
                                color: AppColors.gray400,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Alert action button
class AlertActionButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color? color;

  const AlertActionButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: color ?? AppColors.primary,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
