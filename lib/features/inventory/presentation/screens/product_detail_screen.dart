import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:retail_control_platform/core/constants/app_colors.dart';
import 'package:retail_control_platform/core/constants/app_spacing.dart';
import 'package:retail_control_platform/core/constants/app_radius.dart';
import 'package:retail_control_platform/core/providers/admin_browse_provider.dart';
import 'package:retail_control_platform/core/routing/route_names.dart';
import 'package:retail_control_platform/features/inventory/domain/inventory_event_model.dart';
import 'package:retail_control_platform/features/inventory/domain/product_with_stock.dart';
import 'package:retail_control_platform/features/inventory/presentation/providers/inventory_event_provider.dart';
import 'package:retail_control_platform/features/inventory/presentation/providers/product_provider.dart';
import 'package:retail_control_platform/features/inventory/presentation/widgets/adjustment_bottom_sheet.dart';
import 'package:retail_control_platform/core/utils/currency_formatter.dart';

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
    // Provider-аас бодит data авах
    final productAsync = ref.watch(productDetailProvider(productId));
    final eventsAsync = ref.watch(productInventoryEventsProvider(productId));

    return productAsync.when(
      data: (product) {
        if (product == null) {
          return _buildErrorScreen(context, 'Бараа олдсонгүй');
        }
        return _buildContent(context, ref, product, eventsAsync);
      },
      loading: () => _buildLoadingScreen(),
      error: (error, _) => _buildErrorScreen(context, error.toString()),
    );
  }

  /// Loading screen
  Widget _buildLoadingScreen() {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundLight,
        elevation: 0,
        title: const Text('БҮТЭЭГДЭХҮҮН'),
      ),
      body: const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
    );
  }

  /// Error screen
  Widget _buildErrorScreen(BuildContext context, String message) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundLight,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textMainLight),
          onPressed: () => context.pop(),
        ),
        title: const Text('БҮТЭЭГДЭХҮҮН'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: AppColors.gray400),
            AppSpacing.verticalMD,
            Text(
              message,
              style: const TextStyle(color: AppColors.gray500),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// Main content
  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    ProductWithStock product,
    AsyncValue<List<InventoryEventModel>> eventsAsync,
  ) {
    // Stock status тодорхойлох
    final stockStatus = product.isLowStock
        ? (product.stockQuantity <= 0 ? 'дууссан' : 'бага')
        : 'хэвийн';

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
            // Read-only mode-д доод товчнууд нуугдах тул padding багасна
            padding: EdgeInsets.fromLTRB(20, 0, 20,
                ref.watch(isReadOnlyModeProvider) ? 20 : 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Барааны зураг (байвал)
                if (product.imageUrl != null && product.imageUrl!.isNotEmpty)
                  _buildProductImage(product.imageUrl!),

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
                          product.category ?? 'БАРАА',
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
                    product.name,
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

                // Product unit
                Center(
                  child: Text(
                    product.unit ?? 'ширхэг',
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
                  stock: product.stockQuantity,
                  status: stockStatus,
                ),
                AppSpacing.verticalLG,

                // Info cards grid
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoCard(
                        icon: Icons.monetization_on_outlined,
                        label: 'ҮНЭ',
                        value: CurrencyFormatter.formatWithSymbolAtEnd(product.sellPrice),
                        valueSize: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildInfoCard(
                        icon: Icons.qr_code_2,
                        label: 'SKU',
                        value: product.sku,
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
                        value: '${product.lowStockThreshold ?? 10}',
                        valueSize: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildInfoCard(
                        icon: Icons.store_outlined,
                        label: 'ӨРТӨГ',
                        value: CurrencyFormatter.formatWithSymbolAtEnd(product.costPrice),
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
                      onPressed: () {
                        // Navigate to inventory events screen
                        context.push(RouteNames.inventoryEventsPath(productId));
                      },
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

                // History items - Provider-аас авах
                eventsAsync.when(
                  data: (events) {
                    if (events.isEmpty) {
                      return Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: AppRadius.radiusLG,
                        ),
                        child: const Center(
                          child: Text(
                            'Түүх байхгүй байна',
                            style: TextStyle(color: AppColors.gray500),
                          ),
                        ),
                      );
                    }
                    // Сүүлийн 3 event харуулах
                    return Column(
                      children: events.take(3).map((event) {
                        return _buildHistoryItemFromEvent(event);
                      }).toList(),
                    );
                  },
                  loading: () => const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                  error: (_, __) => Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: AppRadius.radiusLG,
                    ),
                    child: const Center(
                      child: Text(
                        'Түүх унших үед алдаа гарлаа',
                        style: TextStyle(color: AppColors.gray500),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Bottom action buttons — super-admin browse mode-д нуугдана (read-only)
          if (!ref.watch(isReadOnlyModeProvider))
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
                      color: Colors.black.withValues(alpha: 0.05),
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
                              color: AppColors.primary.withValues(alpha: 0.3),
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
                            // AdjustmentBottomSheet нээх
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.white,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(20),
                                ),
                              ),
                              builder: (_) => AdjustmentBottomSheet(
                                productId: productId,
                                productName: product.name,
                              ),
                            );
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

  /// Барааны зураг харуулах widget
  Widget _buildProductImage(String imageUrl) {
    return Container(
      width: double.infinity,
      height: 200,
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.radiusXXL,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: AppRadius.radiusXXL,
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          placeholder: (context, url) => Container(
            color: AppColors.gray100,
            child: const Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
                strokeWidth: 2,
              ),
            ),
          ),
          errorWidget: (context, url, error) => Container(
            color: AppColors.gray100,
            child: const Center(
              child: Icon(
                Icons.image_not_supported_outlined,
                size: 48,
                color: AppColors.gray400,
              ),
            ),
          ),
        ),
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
            color: Colors.black.withValues(alpha: 0.04),
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
              color: statusColor.withValues(alpha: 0.1),
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
            color: Colors.black.withValues(alpha: 0.03),
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

  /// InventoryEventModel-ээс history item widget үүсгэх
  Widget _buildHistoryItemFromEvent(InventoryEventModel event) {
    // Event type-д тохирох өнгө, icon тодорхойлох
    IconData icon;
    Color color;

    switch (event.type) {
      case InventoryEventType.sale:
        icon = Icons.shopping_cart_outlined;
        color = const Color(0xFFDC2626); // улаан
        break;
      case InventoryEventType.initial:
        icon = Icons.inventory_2_outlined;
        color = const Color(0xFF059669); // ногоон
        break;
      case InventoryEventType.return_:
        icon = Icons.assignment_return_outlined;
        color = const Color(0xFF3B82F6); // цэнхэр
        break;
      case InventoryEventType.adjust:
        icon = Icons.edit_outlined;
        color = event.qtyChange >= 0
            ? const Color(0xFF059669) // ногоон (нэмэх)
            : const Color(0xFFDC2626); // улаан (хасах)
        break;
    }

    // Огноо форматлах
    String dateStr;
    if (event.isToday) {
      dateStr = 'Өнөөдөр, ${DateFormat('HH:mm').format(event.timestamp)}';
    } else if (event.isYesterday) {
      dateStr = 'Өчигдөр, ${DateFormat('HH:mm').format(event.timestamp)}';
    } else {
      dateStr = DateFormat('MMM d, HH:mm').format(event.timestamp);
    }

    return _buildHistoryItem(
      icon: icon,
      title: event.type.label,
      date: dateStr,
      quantity: event.qtyChange,
      color: color,
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
            color: Colors.black.withValues(alpha: 0.02),
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
              color: color.withValues(alpha: 0.1),
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
