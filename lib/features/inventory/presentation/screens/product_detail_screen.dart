import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:retail_control_platform/core/constants/app_colors.dart';
import 'package:retail_control_platform/core/constants/app_spacing.dart';
import 'package:retail_control_platform/core/constants/app_radius.dart';
import 'package:retail_control_platform/core/routing/route_names.dart';

/// Product Detail Screen
/// Дизайн: design/product_detail_view/screen.png
class ProductDetailScreen extends ConsumerWidget {
  final String productId;

  const ProductDetailScreen({
    super.key,
    required this.productId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Mock product data (will be replaced with actual provider)
    final product = {
      'name': 'Ноолуур ороолт',
      'category': 'ХУВЦАС',
      'color': 'Шаргал',
      'stock': 156,
      'stockStatus': 'хэвийн',
      'price': 125000,
      'sku': 'CSH-001-BGE',
      'lowStockThreshold': 10,
      'location': 'Төв дэлгүүр',
    };

    final historyItems = [
      {
        'type': 'sale',
        'title': 'Борлуулалт',
        'date': 'Өнөөдөр, 14:30',
        'quantity': -2,
        'color': const Color(0xFFDC2626),
        'icon': Icons.shopping_cart_outlined,
      },
      {
        'type': 'restock',
        'title': 'Орлого',
        'date': 'Өчигдөр, 10:15',
        'quantity': 50,
        'color': const Color(0xFF059669),
        'icon': Icons.inventory_2_outlined,
      },
      {
        'type': 'adjust',
        'title': 'Засвар',
        'date': 'Oct 24, 18:00',
        'quantity': 0,
        'color': AppColors.gray500,
        'icon': Icons.edit_outlined,
      },
    ];

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
          'БҮТЭЭГДЭХҮҮН',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textMainLight,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF00878F),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.cloud_done,
              size: 16,
              color: Colors.white,
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Main content
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category badge
                Center(
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.gray100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.checkroom,
                          size: 16,
                          color: AppColors.gray600,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          product['category'] as String,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.gray600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Product name
                Center(
                  child: Text(
                    product['name'] as String,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textMainLight,
                      fontFamily: 'Epilogue',
                      height: 1.1,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 8),

                // Product color/variant
                Center(
                  child: Text(
                    product['color'] as String,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColors.gray500,
                    ),
                  ),
                ),
                AppSpacing.verticalLG,

                // Stock card (large)
                _buildStockCard(
                  stock: product['stock'] as int,
                  status: product['stockStatus'] as String,
                ),
                AppSpacing.verticalLG,

                // Info cards grid
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoCard(
                        icon: Icons.monetization_on_outlined,
                        label: 'ҮНЭ',
                        value: '${product['price']}₮',
                        valueSize: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildInfoCard(
                        icon: Icons.qr_code_2,
                        label: 'SKU',
                        value: product['sku'] as String,
                        valueSize: 16,
                      ),
                    ),
                  ],
                ),
                AppSpacing.verticalMD,

                Row(
                  children: [
                    Expanded(
                      child: _buildInfoCard(
                        icon: Icons.notifications_outlined,
                        label: 'БОСГО',
                        value: '${product['lowStockThreshold']}',
                        valueSize: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildInfoCard(
                        icon: Icons.store_outlined,
                        label: 'АГУУЛАХ',
                        value: product['location'] as String,
                        valueSize: 16,
                      ),
                    ),
                  ],
                ),
                AppSpacing.verticalLG,

                // History section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Түүх',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textMainLight,
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: const Text(
                        'Бүгд',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // History items
                ...historyItems.map((item) => _buildHistoryItem(
                      icon: item['icon'] as IconData,
                      title: item['title'] as String,
                      date: item['date'] as String,
                      quantity: item['quantity'] as int,
                      color: item['color'] as Color,
                    )),
              ],
            ),
          ),

          // Bottom action buttons
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 20,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Row(
                  children: [
                    // Edit button
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          // Navigate to edit screen
                          context.push(RouteNames.editProductPath(productId));
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: BorderSide(
                            color: AppColors.primary.withOpacity(0.3),
                            width: 2,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: AppRadius.radiusLG,
                          ),
                        ),
                        child: const Text(
                          'Засах',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Adjust stock button
                    Expanded(
                      flex: 2,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // Adjust stock
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00878F),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: AppRadius.radiusLG,
                          ),
                        ),
                        icon: const Icon(
                          Icons.edit,
                          size: 20,
                          color: Colors.white,
                        ),
                        label: const Text(
                          'Үлдэгдэл засах',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStockCard({
    required int stock,
    required String status,
  }) {
    Color statusColor;
    if (status == 'хэвийн') {
      statusColor = const Color(0xFF059669);
    } else if (status == 'бага') {
      statusColor = const Color(0xFFF59E0B);
    } else {
      statusColor = const Color(0xFFDC2626);
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.radiusXXL,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'ҮЛДЭГДЭЛ',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.gray500,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          RichText(
            text: TextSpan(
              style: const TextStyle(
                fontSize: 72,
                fontWeight: FontWeight.w900,
                color: AppColors.textMainLight,
                fontFamily: 'Epilogue',
                height: 0.9,
              ),
              children: [
                TextSpan(text: '$stock'),
                const TextSpan(
                  text: ' ш',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: AppColors.gray400,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: statusColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  status,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: statusColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
    required double valueSize,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.radiusLG,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 18,
                color: AppColors.gray500,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.gray500,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: valueSize,
              fontWeight: FontWeight.w700,
              color: AppColors.textMainLight,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryItem({
    required IconData icon,
    required String title,
    required String date,
    required int quantity,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.radiusLG,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              size: 22,
              color: color,
            ),
          ),
          const SizedBox(width: 12),

          // Text info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textMainLight,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  date,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: AppColors.gray500,
                  ),
                ),
              ],
            ),
          ),

          // Quantity
          Text(
            quantity >= 0 ? '+$quantity' : '$quantity',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: color,
              fontFamily: 'Epilogue',
            ),
          ),
        ],
      ),
    );
  }
}
