import 'package:flutter/material.dart';
import 'package:retail_control_platform/core/constants/app_colors.dart';
import 'package:retail_control_platform/core/constants/app_radius.dart';
import 'package:retail_control_platform/core/constants/app_spacing.dart';
import 'package:retail_control_platform/core/widgets/inputs/quantity_selector.dart';

/// Cart item card (for shopping cart)
/// Дизайн: Product image + name + quantity selector + subtotal + delete
class CartItemCard extends StatelessWidget {
  final String productName;
  final String? imageUrl;
  final double price;
  final int quantity;
  final ValueChanged<int> onQuantityChanged;
  final VoidCallback onRemove;
  final int? maxQuantity;

  const CartItemCard({
    super.key,
    required this.productName,
    this.imageUrl,
    required this.price,
    required this.quantity,
    required this.onQuantityChanged,
    required this.onRemove,
    this.maxQuantity,
  });

  double get subtotal => price * quantity;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Padding(
        padding: AppSpacing.paddingSM,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product image
            ClipRRect(
              borderRadius: AppRadius.radiusSM,
              child: SizedBox(
                width: 64,
                height: 64,
                child: imageUrl != null && imageUrl!.isNotEmpty
                    ? Image.network(
                        imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return _buildPlaceholder();
                        },
                      )
                    : _buildPlaceholder(),
              ),
            ),
            AppSpacing.horizontalMD,

            // Product info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product name
                  Text(
                    productName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      height: 1.3,
                    ),
                  ),
                  AppSpacing.verticalXS,

                  // Price per unit
                  Text(
                    '₮${price.toStringAsFixed(0)} / ширхэг',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondaryLight,
                    ),
                  ),
                  AppSpacing.verticalSM,

                  // Quantity selector and subtotal
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Quantity selector
                      QuantitySelector(
                        quantity: quantity,
                        onChanged: onQuantityChanged,
                        min: 1,
                        max: maxQuantity ?? 999,
                        compact: true,
                      ),

                      // Subtotal
                      Text(
                        '₮${subtotal.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Delete button
            IconButton(
              onPressed: onRemove,
              icon: const Icon(Icons.delete_outline),
              iconSize: 20,
              color: AppColors.danger,
              style: IconButton.styleFrom(
                minimumSize: const Size(32, 32),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: AppColors.gray200,
      child: const Icon(
        Icons.inventory_2_outlined,
        size: 32,
        color: AppColors.gray400,
      ),
    );
  }
}

/// Compact cart item (for order summary)
class CartItemCompact extends StatelessWidget {
  final String productName;
  final double price;
  final int quantity;

  const CartItemCompact({
    super.key,
    required this.productName,
    required this.price,
    required this.quantity,
  });

  double get subtotal => price * quantity;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          // Quantity badge
          Container(
            width: 24,
            height: 24,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.gray200,
              borderRadius: AppRadius.radiusSM,
            ),
            child: Text(
              '${quantity}x',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.textMainLight,
              ),
            ),
          ),
          AppSpacing.horizontalSM,

          // Product name
          Expanded(
            child: Text(
              productName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),

          // Subtotal
          Text(
            '₮${subtotal.toStringAsFixed(0)}',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textMainLight,
            ),
          ),
        ],
      ),
    );
  }
}
