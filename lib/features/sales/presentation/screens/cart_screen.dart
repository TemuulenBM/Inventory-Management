import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:retail_control_platform/core/constants/app_colors.dart';
import 'package:retail_control_platform/core/constants/app_spacing.dart';
import 'package:retail_control_platform/core/constants/app_radius.dart';

/// Cart Screen (Quick Sale)
/// Дизайн: design/quick_sale_cart/screen.png
class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Mock cart items (will be replaced with actual cart provider)
    final cartItems = [
      {
        'name': 'Cashmere Scarf',
        'description': 'Саарал / M',
        'price': 120000,
        'quantity': 1,
        'discount': 0,
        'badge': 'NEW',
        'badgeColor': const Color(0xFFDC2626),
      },
      {
        'name': 'Leather Gloves',
        'description': 'Бор / L',
        'price': 85000,
        'quantity': 2,
        'discount': 0,
        'badge': null,
        'badgeColor': null,
      },
      {
        'name': 'Wool Socks',
        'description': 'Хар / Free Size',
        'price': 15000,
        'originalPrice': 16500,
        'quantity': 5,
        'discount': -10,
        'badge': '-10%',
        'badgeColor': const Color(0xFF00878F),
      },
    ];

    final totalItems = cartItems.fold<int>(
      0,
      (sum, item) => sum + (item['quantity'] as int),
    );

    final subtotal = cartItems.fold<int>(
      0,
      (sum, item) =>
          sum + ((item['price'] as int) * (item['quantity'] as int)),
    );

    final discountAmount = 1500;
    final total = subtotal - discountAmount;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundLight,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textMainLight),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Сагс',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.textMainLight,
          ),
        ),
        centerTitle: false,
        actions: [
          // Sync badge
          Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFDCFCE7),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: Color(0xFF10B981),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                const Text(
                  'SYNCED',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF059669),
                  ),
                ),
              ],
            ),
          ),

          // Clear button
          TextButton.icon(
            onPressed: () {
              // Clear cart
            },
            icon: const Icon(
              Icons.delete_outline,
              size: 18,
              color: Color(0xFFDC2626),
            ),
            label: const Text(
              'Цэвэрлэх',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFFDC2626),
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Cart items list
          ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 180),
            itemCount: cartItems.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = cartItems[index];
              return _buildCartItem(
                name: item['name'] as String,
                description: item['description'] as String,
                price: item['price'] as int,
                originalPrice: item['originalPrice'] as int?,
                quantity: item['quantity'] as int,
                badge: item['badge'] as String?,
                badgeColor: item['badgeColor'] as Color?,
                onIncrease: () {},
                onDecrease: () {},
              );
            },
          ),

          // Bottom summary
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildBottomSummary(
              totalItems: totalItems,
              subtotal: subtotal,
              discountAmount: discountAmount,
              total: total,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItem({
    required String name,
    required String description,
    required int price,
    int? originalPrice,
    required int quantity,
    String? badge,
    Color? badgeColor,
    required VoidCallback onIncrease,
    required VoidCallback onDecrease,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.radiusXL,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Product image placeholder with badge
          Stack(
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: AppColors.gray100,
                  borderRadius: AppRadius.radiusMD,
                ),
                child: const Icon(
                  Icons.inventory_2_outlined,
                  size: 32,
                  color: AppColors.gray400,
                ),
              ),
              if (badge != null)
                Positioned(
                  top: 0,
                  left: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: badgeColor ?? AppColors.primary,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        bottomRight: Radius.circular(8),
                      ),
                    ),
                    child: Text(
                      badge,
                      style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),

          // Product info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textMainLight,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: AppColors.gray500,
                  ),
                ),
                const SizedBox(height: 8),

                // Price
                Row(
                  children: [
                    if (originalPrice != null) ...[
                      Text(
                        '${originalPrice}₮',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.gray400,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                      const SizedBox(width: 6),
                    ],
                    Text(
                      '${price}₮',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFC96F53),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityControls({
    required int quantity,
    required VoidCallback onDecrease,
    required VoidCallback onIncrease,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Decrease button
        Material(
          color: AppColors.gray100,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            onTap: onDecrease,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              child: const Icon(
                Icons.remove,
                size: 18,
                color: AppColors.textMainLight,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),

        // Quantity
        Column(
          children: [
            Text(
              '$quantity',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textMainLight,
              ),
            ),
            const Text(
              'ш',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: AppColors.gray500,
              ),
            ),
          ],
        ),
        const SizedBox(width: 16),

        // Increase button
        Material(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            onTap: onIncrease,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              child: const Icon(
                Icons.add,
                size: 18,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomSummary({
    required int totalItems,
    required int subtotal,
    required int discountAmount,
    required int total,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Summary row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Барааны тоо',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.gray600,
                  ),
                ),
                Text(
                  '$totalItems ш',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textMainLight,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Total amount
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Нийт дүн',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textMainLight,
                  ),
                ),
                Text(
                  '${total}₮',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textMainLight,
                    fontFamily: 'Epilogue',
                    height: 1.0,
                  ),
                ),
              ],
            ),

            // Discount
            if (discountAmount > 0) ...[
              const SizedBox(height: 4),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'Хямдрал: -${discountAmount}₮',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF059669),
                  ),
                ),
              ),
            ],

            const SizedBox(height: 20),

            // Checkout button
            Material(
              color: const Color(0xFF00878F),
              borderRadius: AppRadius.radiusXL,
              elevation: 4,
              shadowColor: const Color(0xFF00878F).withOpacity(0.3),
              child: InkWell(
                onTap: () {
                  // Process checkout
                },
                borderRadius: AppRadius.radiusXL,
                child: Container(
                  height: 56,
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Төлөх',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.arrow_forward,
                        color: Colors.white,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
