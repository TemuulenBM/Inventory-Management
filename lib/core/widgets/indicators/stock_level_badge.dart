import 'package:flutter/material.dart';
import 'package:retail_control_platform/core/constants/app_colors.dart';
import 'package:retail_control_platform/core/constants/app_radius.dart';

/// Stock level badge with color coding
/// Дизайн: Green (ok) / Orange (low) / Red (out of stock)
class StockLevelBadge extends StatelessWidget {
  final int stockQuantity;
  final int lowStockThreshold;
  final bool compact;
  final bool showLabel;

  const StockLevelBadge({
    super.key,
    required this.stockQuantity,
    this.lowStockThreshold = 10,
    this.compact = false,
    this.showLabel = true,
  });

  Color get _backgroundColor {
    if (stockQuantity <= 0) {
      return AppColors.statusOutOfStock; // Red
    } else if (stockQuantity <= lowStockThreshold) {
      return AppColors.statusLowStock; // Orange
    }
    return AppColors.statusNormal; // Green/Teal
  }

  String get _label {
    if (stockQuantity <= 0) {
      return 'Дууссан';
    } else if (stockQuantity <= lowStockThreshold) {
      return 'Бага';
    }
    return stockQuantity.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: compact
          ? const EdgeInsets.symmetric(horizontal: 6, vertical: 2)
          : const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: compact ? AppRadius.radiusSM : AppRadius.radiusMD,
      ),
      child: Text(
        showLabel ? _label : stockQuantity.toString(),
        style: TextStyle(
          fontSize: compact ? 11 : 12,
          fontWeight: FontWeight.w600,
          color: AppColors.white,
        ),
      ),
    );
  }
}

/// Stock status indicator (icon + text)
class StockStatusIndicator extends StatelessWidget {
  final int stockQuantity;
  final int lowStockThreshold;

  const StockStatusIndicator({
    super.key,
    required this.stockQuantity,
    this.lowStockThreshold = 10,
  });

  IconData get _icon {
    if (stockQuantity <= 0) {
      return Icons.remove_circle_outline;
    } else if (stockQuantity <= lowStockThreshold) {
      return Icons.warning_amber_outlined;
    }
    return Icons.check_circle_outline;
  }

  Color get _color {
    if (stockQuantity <= 0) {
      return AppColors.statusOutOfStock;
    } else if (stockQuantity <= lowStockThreshold) {
      return AppColors.statusLowStock;
    }
    return AppColors.statusNormal;
  }

  String get _text {
    if (stockQuantity <= 0) {
      return 'Дууссан';
    } else if (stockQuantity <= lowStockThreshold) {
      return 'Бага үлдэгдэл';
    }
    return 'Хангалттай';
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(_icon, size: 18, color: _color),
        const SizedBox(width: 4),
        Text(
          _text,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: _color,
          ),
        ),
      ],
    );
  }
}
