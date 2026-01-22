import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:retail_control_platform/core/constants/app_colors.dart';
import 'package:retail_control_platform/core/constants/app_radius.dart';
import 'package:retail_control_platform/core/constants/app_spacing.dart';

/// Bottom action sheet with glass effect
/// Дизайн: Glassmorphic modal from bottom with drag handle
class BottomActionSheet extends StatelessWidget {
  final Widget child;
  final double? height;
  final bool hasGlassEffect;
  final EdgeInsetsGeometry? padding;

  const BottomActionSheet({
    super.key,
    required this.child,
    this.height,
    this.hasGlassEffect = true,
    this.padding,
  });

  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
    double? height,
    bool hasGlassEffect = true,
    EdgeInsetsGeometry? padding,
    bool isDismissible = true,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      isDismissible: isDismissible,
      builder: (context) => BottomActionSheet(
        height: height,
        hasGlassEffect: hasGlassEffect,
        padding: padding,
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final content = Container(
      height: height,
      padding: padding ?? AppSpacing.paddingLG,
      decoration: BoxDecoration(
        color: hasGlassEffect
            ? AppColors.surfaceLight.withOpacity(0.95)
            : AppColors.surfaceLight,
        borderRadius: AppRadius.bottomSheetRadius,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.gray300,
              borderRadius: AppRadius.radiusFull,
            ),
          ),
          AppSpacing.verticalMD,

          // Content
          Flexible(child: child),
        ],
      ),
    );

    if (hasGlassEffect) {
      return ClipRRect(
        borderRadius: AppRadius.bottomSheetRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: content,
        ),
      );
    }

    return content;
  }
}

/// Payment bottom sheet (for cart checkout)
class PaymentBottomSheet extends StatelessWidget {
  final double subtotal;
  final String paymentMethod;
  final ValueChanged<String> onPaymentMethodChanged;
  final VoidCallback onConfirm;
  final bool isProcessing;

  const PaymentBottomSheet({
    super.key,
    required this.subtotal,
    required this.paymentMethod,
    required this.onPaymentMethodChanged,
    required this.onConfirm,
    this.isProcessing = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        const Text(
          'Төлбөр',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        AppSpacing.verticalLG,

        // Subtotal
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Нийт дүн',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            ),
            Text(
              '₮${subtotal.toStringAsFixed(0)}',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
        AppSpacing.verticalLG,

        // Payment method selector
        const Text(
          'Төлбөрийн хэлбэр',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        AppSpacing.verticalSM,
        Wrap(
          spacing: 8,
          children: [
            _PaymentMethodChip(
              label: 'Бэлэн',
              icon: Icons.payments_outlined,
              isSelected: paymentMethod == 'cash',
              onTap: () => onPaymentMethodChanged('cash'),
            ),
            _PaymentMethodChip(
              label: 'Карт',
              icon: Icons.credit_card,
              isSelected: paymentMethod == 'card',
              onTap: () => onPaymentMethodChanged('card'),
            ),
            _PaymentMethodChip(
              label: 'QR',
              icon: Icons.qr_code,
              isSelected: paymentMethod == 'qr',
              onTap: () => onPaymentMethodChanged('qr'),
            ),
          ],
        ),
        AppSpacing.verticalXL,

        // Confirm button
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: isProcessing ? null : onConfirm,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: AppRadius.radiusLG,
              ),
            ),
            child: isProcessing
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(AppColors.white),
                    ),
                  )
                : const Text(
                    'Төлбөр баталгаажуулах',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}

class _PaymentMethodChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _PaymentMethodChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 18,
            color: isSelected ? AppColors.white : AppColors.textMainLight,
          ),
          const SizedBox(width: 6),
          Text(label),
        ],
      ),
      selected: isSelected,
      onSelected: (_) => onTap(),
      selectedColor: AppColors.primary,
      backgroundColor: AppColors.gray100,
      labelStyle: TextStyle(
        color: isSelected ? AppColors.white : AppColors.textMainLight,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
      ),
    );
  }
}
