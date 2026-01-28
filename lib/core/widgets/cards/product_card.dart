import 'package:flutter/material.dart';
import 'package:retail_control_platform/core/constants/app_colors.dart';
import 'package:retail_control_platform/core/constants/app_radius.dart';
import 'package:retail_control_platform/core/constants/app_spacing.dart';
import 'package:retail_control_platform/core/widgets/indicators/stock_level_badge.dart';

/// Product card for grid display (2-column)
/// Дизайн: Image + name + price + stock badge + add button
class ProductCard extends StatelessWidget {
  final String imageUrl;
  final String name;
  final double price;
  final int stockQuantity;
  final int? lowStockThreshold;
  final VoidCallback onTap;
  final VoidCallback? onAddToCart;

  const ProductCard({
    super.key,
    required this.imageUrl,
    required this.name,
    required this.price,
    required this.stockQuantity,
    this.lowStockThreshold,
    required this.onTap,
    this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product image with stock badge
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 1.0,
                  child: imageUrl.isNotEmpty
                      ? Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return _buildPlaceholder();
                          },
                        )
                      : _buildPlaceholder(),
                ),

                // Stock level badge
                Positioned(
                  top: 8,
                  right: 8,
                  child: StockLevelBadge(
                    stockQuantity: stockQuantity,
                    lowStockThreshold: lowStockThreshold ?? 10,
                    compact: true,
                  ),
                ),
              ],
            ),

            // Product info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 6),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product name
                    Flexible(
                      child: Text(
                        name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          height: 1.2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),

                    // Price and add button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          '₮${price.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                        if (onAddToCart != null)
                          SizedBox(
                            width: 28,
                            height: 28,
                            child: IconButton(
                              onPressed: stockQuantity > 0 ? onAddToCart : null,
                              icon: const Icon(Icons.add_shopping_cart),
                              iconSize: 16,
                              color: AppColors.secondary,
                              style: IconButton.styleFrom(
                                backgroundColor: stockQuantity > 0
                                    ? AppColors.secondary.withValues(alpha: 0.1)
                                    : AppColors.gray200,
                                shape: RoundedRectangleBorder(
                                  borderRadius: AppRadius.radiusSM,
                                ),
                                padding: EdgeInsets.zero,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
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
      child: const Center(
        child: Icon(
          Icons.inventory_2_outlined,
          size: 48,
          color: AppColors.gray400,
        ),
      ),
    );
  }
}

/// Compact product card (list view)
class ProductCardCompact extends StatelessWidget {
  final String imageUrl;
  final String name;
  final double price;
  final int stockQuantity;
  final VoidCallback onTap;

  const ProductCardCompact({
    super.key,
    required this.imageUrl,
    required this.name,
    required this.price,
    required this.stockQuantity,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: AppSpacing.paddingSM,
          child: Row(
            children: [
              // Image
              ClipRRect(
                borderRadius: AppRadius.radiusSM,
                child: SizedBox(
                  width: 60,
                  height: 60,
                  child: imageUrl.isNotEmpty
                      ? Image.network(imageUrl, fit: BoxFit.cover)
                      : Container(
                          color: AppColors.gray200,
                          child: const Icon(Icons.inventory_2_outlined),
                        ),
                ),
              ),
              AppSpacing.horizontalMD,

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    AppSpacing.verticalXS,
                    Text(
                      '₮${price.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),

              // Stock badge
              StockLevelBadge(
                stockQuantity: stockQuantity,
                lowStockThreshold: 10,
                compact: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
