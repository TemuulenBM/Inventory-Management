import 'package:flutter/material.dart';
import 'package:retail_control_platform/core/constants/app_colors.dart';
import 'package:retail_control_platform/core/constants/app_radius.dart';
import 'package:retail_control_platform/core/constants/app_spacing.dart';

/// Quantity selector with +/- buttons
/// Дизайн: [-] [12] [+] layout
class QuantitySelector extends StatelessWidget {
  final int quantity;
  final ValueChanged<int> onChanged;
  final int min;
  final int max;
  final bool compact;

  const QuantitySelector({
    super.key,
    required this.quantity,
    required this.onChanged,
    this.min = 1,
    this.max = 999,
    this.compact = false,
  });

  void _increment() {
    if (quantity < max) {
      onChanged(quantity + 1);
    }
  }

  void _decrement() {
    if (quantity > min) {
      onChanged(quantity - 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    final buttonSize = compact ? 32.0 : 40.0;
    final textSize = compact ? 14.0 : 18.0;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Decrease button
        _QuantityButton(
          icon: Icons.remove,
          onPressed: quantity > min ? _decrement : null,
          size: buttonSize,
        ),

        // Quantity display
        Container(
          width: compact ? 48 : 60,
          height: buttonSize,
          alignment: Alignment.center,
          child: Text(
            quantity.toString(),
            style: TextStyle(
              fontSize: textSize,
              fontWeight: FontWeight.w600,
              color: AppColors.textMainLight,
            ),
          ),
        ),

        // Increase button
        _QuantityButton(
          icon: Icons.add,
          onPressed: quantity < max ? _increment : null,
          size: buttonSize,
        ),
      ],
    );
  }
}

class _QuantityButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final double size;

  const _QuantityButton({
    required this.icon,
    this.onPressed,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon),
        iconSize: size * 0.5,
        color: onPressed != null ? AppColors.primary : AppColors.gray400,
        style: IconButton.styleFrom(
          backgroundColor:
              onPressed != null ? AppColors.primary.withOpacity(0.1) : AppColors.gray200,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.radiusSM,
          ),
          padding: EdgeInsets.zero,
        ),
      ),
    );
  }
}

/// Quantity selector with outlined style
class QuantitySelectorOutlined extends StatelessWidget {
  final int quantity;
  final ValueChanged<int> onChanged;
  final int min;
  final int max;

  const QuantitySelectorOutlined({
    super.key,
    required this.quantity,
    required this.onChanged,
    this.min = 1,
    this.max = 999,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.gray300),
        borderRadius: AppRadius.radiusMD,
      ),
      child: QuantitySelector(
        quantity: quantity,
        onChanged: onChanged,
        min: min,
        max: max,
      ),
    );
  }
}
