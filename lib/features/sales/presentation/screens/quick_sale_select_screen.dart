import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:retail_control_platform/core/constants/app_colors.dart';
import 'package:retail_control_platform/core/constants/app_spacing.dart';
import 'package:retail_control_platform/core/constants/app_radius.dart';
import 'package:retail_control_platform/core/routing/route_names.dart';
import 'package:retail_control_platform/features/inventory/presentation/providers/product_provider.dart';
import 'package:retail_control_platform/features/inventory/presentation/providers/top_selling_provider.dart';
import 'package:retail_control_platform/features/sales/presentation/providers/cart_provider.dart';
import 'package:retail_control_platform/features/inventory/domain/product_with_stock.dart';
import 'package:retail_control_platform/features/sales/domain/cart_item.dart';

/// Quick Sale - Product Selection Screen
/// Дизайн: design/quick_sale_select/screen.png
class QuickSaleSelectScreen extends ConsumerStatefulWidget {
  const QuickSaleSelectScreen({super.key});

  @override
  ConsumerState<QuickSaleSelectScreen> createState() =>
      _QuickSaleSelectScreenState();
}

class _QuickSaleSelectScreenState
    extends ConsumerState<QuickSaleSelectScreen> {
  final _searchController = TextEditingController();
  String _selectedCategory = 'Бүгд';
  String _selectedTab = 'Онцлох';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Provider-уудаас дата авах
    final productsAsync = ref.watch(productListProvider());
    final topSellingIdsAsync = ref.watch(topSellingProductIdsProvider);
    final cartItems = ref.watch(cartNotifierProvider);
    final cartCount = ref.watch(cartItemCountProvider);
    final cartTotal = ref.watch(cartTotalProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Stack(
          children: [
            // Main content
            Column(
              children: [
                // Header
                _buildHeader(),

                // Search bar
                _buildSearchBar(),
                AppSpacing.verticalXS,

                // Category pills
                _buildCategoryPills(productsAsync),
                AppSpacing.verticalXS,

                // Tabs (Онцлох/Сүүлд)
                _buildTabs(),
                AppSpacing.verticalSM,

                // Product grid
                Expanded(
                  child: productsAsync.when(
                    data: (products) => _buildProductGrid(
                      products,
                      cartItems,
                      topSellingIdsAsync,
                    ),
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline, size: 48, color: Colors.grey),
                          const SizedBox(height: 16),
                          Text('Алдаа: $e', textAlign: TextAlign.center),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => ref.invalidate(productListProvider()),
                            child: const Text('Дахин оролдох'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Bottom cart summary (if cart has items)
            if (cartCount > 0)
              Positioned(
                bottom: 16,
                left: 16,
                right: 16,
                child: _buildCartSummary(cartCount, cartTotal),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final canGoBack = GoRouter.of(context).canPop();

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          // Back button (зүүн өнцөг)
          if (canGoBack) ...[
            Material(
              color: Colors.white,
              borderRadius: AppRadius.radiusLG,
              elevation: 0,
              child: InkWell(
                onTap: () => context.pop(),
                borderRadius: AppRadius.radiusLG,
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: AppColors.gray100,
                      width: 1,
                    ),
                    borderRadius: AppRadius.radiusLG,
                  ),
                  child: const Icon(
                    Icons.arrow_back,
                    color: AppColors.textMainLight,
                    size: 24,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
          ],

          // Title + sync badge (expand to fill)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Sync indicator
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFF10B981),
                        shape: BoxShape.circle,
                      ),
                      child: Container(
                        margin: const EdgeInsets.all(1.5),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF10B981).withValues(alpha: 0.5),
                              blurRadius: 4,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'SYNCED',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF059669),
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const Text(
                  'Хурдан борлуулалт',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textMainLight,
                    fontFamily: 'Epilogue',
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // Barcode scanner button (баруун өнцөг)
          Material(
            color: Colors.white,
            borderRadius: AppRadius.radiusLG,
            elevation: 0,
            child: InkWell(
              onTap: () {
                // Barcode scanner
              },
              borderRadius: AppRadius.radiusLG,
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: AppColors.gray100,
                    width: 1,
                  ),
                  borderRadius: AppRadius.radiusLG,
                ),
                child: const Icon(
                  Icons.qr_code_scanner,
                  color: AppColors.textMainLight,
                  size: 24,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.6),
          borderRadius: AppRadius.radiusXL,
          border: Border.all(
            color: Colors.transparent,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (value) {
            setState(() {}); // UI-г шинэчлэх
          },
          style: const TextStyle(
            fontSize: 15,
            color: AppColors.textMainLight,
          ),
          decoration: InputDecoration(
            hintText: 'Бараа хайх, код уншуулах...',
            hintStyle: TextStyle(
              fontSize: 15,
              color: AppColors.textSecondaryLight.withValues(alpha: 0.7),
            ),
            prefixIcon: const Icon(
              Icons.search,
              color: AppColors.textSecondaryLight,
              size: 22,
            ),
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: OutlineInputBorder(
              borderRadius: AppRadius.radiusXL,
              borderSide: BorderSide(
                color: AppColors.primary.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryPills(AsyncValue<List<ProductWithStock>> productsAsync) {
    // Products-аас unique categories гаргах
    final categories = productsAsync.whenOrNull(
      data: (products) {
        final cats = products
            .map((p) => p.category ?? 'Бусад')
            .toSet()
            .toList();
        cats.sort();
        return ['Бүгд', ...cats];
      },
    ) ?? ['Бүгд', 'Хүнс', 'Ундаа', 'Гэр ахуй'];

    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = _selectedCategory == category;

          return Material(
            color: isSelected ? AppColors.primary : Colors.white,
            borderRadius: AppRadius.radiusLG,
            elevation: 0,
            child: InkWell(
              onTap: () {
                setState(() {
                  _selectedCategory = category;
                });
              },
              borderRadius: AppRadius.radiusLG,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.gray100,
                    width: 1,
                  ),
                  borderRadius: AppRadius.radiusLG,
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  category,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : AppColors.gray600,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTabs() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: const Color(0xFFF0ECEA),
          borderRadius: AppRadius.radiusLG,
        ),
        child: Row(
          children: [
            Expanded(
              child: _buildTabButton('Онцлох', isActive: _selectedTab == 'Онцлох'),
            ),
            Expanded(
              child: _buildTabButton('Сүүлд', isActive: _selectedTab == 'Сүүлд'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton(String label, {required bool isActive}) {
    return Material(
      color: isActive ? Colors.white : Colors.transparent,
      borderRadius: AppRadius.radiusSM,
      elevation: isActive ? 1 : 0,
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedTab = label;
          });
        },
        borderRadius: AppRadius.radiusSM,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              color: isActive
                  ? AppColors.textMainLight
                  : AppColors.textSecondaryLight,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProductGrid(
    List<ProductWithStock> products,
    List<CartItem> cartItems,
    AsyncValue<List<String>> topSellingIdsAsync,
  ) {
    // 1. Category filter
    final filtered = _selectedCategory == 'Бүгд'
        ? products
        : products.where((p) => p.category == _selectedCategory).toList();

    // 2. Search filter
    final searchText = _searchController.text.toLowerCase();
    final searchFiltered = searchText.isEmpty
        ? filtered
        : filtered.where((p) => p.name.toLowerCase().contains(searchText)).toList();

    // 3. TAB FILTER (Онцлох/Сүүлд)
    List<ProductWithStock> tabFiltered;

    if (_selectedTab == 'Онцлох') {
      // "Онцлох" = Top-selling products
      final topSellingIds = topSellingIdsAsync.valueOrNull ?? [];

      if (topSellingIds.isEmpty) {
        // Sales data байхгүй үед бүх барааг харуулах (fallback)
        tabFiltered = searchFiltered;
      } else {
        // Top-selling products filter + sort
        tabFiltered = searchFiltered
            .where((p) => topSellingIds.contains(p.id))
            .toList();

        // Борлуулалтын дараалал дагуу эрэмбэлэх
        tabFiltered.sort((a, b) {
          final aIndex = topSellingIds.indexOf(a.id);
          final bIndex = topSellingIds.indexOf(b.id);
          return aIndex.compareTo(bIndex);
        });
      }
    } else {
      // "Сүүлд" = Recently added products (createdAt DESC)
      tabFiltered = searchFiltered;
      tabFiltered.sort((a, b) {
        final aTime = a.createdAt ?? DateTime(1970);
        final bTime = b.createdAt ?? DateTime(1970);
        return bTime.compareTo(aTime); // Newest first
      });
    }

    // Empty state
    if (tabFiltered.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              products.isEmpty ? 'Бараа байхгүй байна' : 'Бараа олдсонгүй',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    // Grid view
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.7,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: tabFiltered.length,
      itemBuilder: (context, index) {
        final product = tabFiltered[index];
        final inCart = cartItems.any((item) => item.product.id == product.id);
        return _buildProductCard(product: product, inCart: inCart);
      },
    );
  }

  Widget _buildProductCard({
    required ProductWithStock product,
    required bool inCart,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.radiusXL,
        border: Border.all(
          color: inCart ? AppColors.primary : Colors.white.withValues(alpha: 0.5),
          width: inCart ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Бүтээгдэхүүний зураг эсвэл placeholder with stock badge
          Stack(
            children: [
              // Зураг харуулах (offline-first pattern ашиглана)
              _buildProductImage(product),
              // Stock badge
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: product.isLowStock
                              ? Colors.orange
                              : const Color(0xFF10B981),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${product.stockQuantity}ш',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppColors.gray600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Product info
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Product name
                  Flexible(
                    child: Text(
                      product.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textMainLight,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  // Price + Add button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${product.sellPrice.toStringAsFixed(0)}₮',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textMainLight,
                          fontFamily: 'Epilogue',
                        ),
                      ),
                      Material(
                        color: inCart
                            ? AppColors.primary
                            : AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        child: InkWell(
                          onTap: () {
                            // Add to cart
                            ref.read(cartNotifierProvider.notifier).addProduct(product);
                          },
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            width: 32,
                            height: 32,
                            alignment: Alignment.center,
                            child: Icon(
                              Icons.add,
                              size: 18,
                              color: inCart ? Colors.white : AppColors.primary,
                            ),
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
    );
  }

  /// Категориас хамаарч өнгө буцаах
  Color _getProductColor(String? category) {
    switch (category) {
      case 'Хүнс':
        return const Color(0xFFFFE4CC);
      case 'Ундаа':
        return const Color(0xFFCDE7F0);
      case 'Гэр ахуй':
        return const Color(0xFFFFF0CC);
      case 'Гоо сайхан':
        return const Color(0xFFFFD4CC);
      default:
        return const Color(0xFFD4E4FF);
    }
  }

  /// Бүтээгдэхүүний зураг харуулах (offline-first pattern)
  /// 1. localImagePath байвал Image.file() ашиглах
  /// 2. imageUrl байвал Image.network() ашиглах
  /// 3. Хоёулаа байхгүй бол category өнгө + icon placeholder харуулах
  Widget _buildProductImage(ProductWithStock product) {
    const borderRadius = BorderRadius.only(
      topLeft: Radius.circular(24),
      topRight: Radius.circular(24),
    );

    // 1. Орон нутгийн зураг эхлээд шалгах (offline-first)
    if (product.localImagePath != null && product.localImagePath!.isNotEmpty) {
      return ClipRRect(
        borderRadius: borderRadius,
        child: SizedBox(
          height: 140,
          child: Image.file(
            File(product.localImagePath!),
            height: 140,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              // Файл олдохгүй бол cloud зураг эсвэл placeholder руу шилжинэ
              return _buildImagePlaceholder(product.category);
            },
          ),
        ),
      );
    }

    // 2. Cloud зураг fallback (imageUrl байвал)
    if (product.imageUrl != null && product.imageUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: borderRadius,
        child: SizedBox(
          height: 140,
          child: Image.network(
            product.imageUrl!,
            height: 140,
            width: double.infinity,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              // Ачаалж байх үед placeholder харуулах
              if (loadingProgress == null) return child;
              return _buildImagePlaceholder(product.category);
            },
            errorBuilder: (context, error, stackTrace) {
              // Network алдаа гарвал placeholder харуулах
              return _buildImagePlaceholder(product.category);
            },
          ),
        ),
      );
    }

    // 3. Fallback: Category өнгө + icon placeholder
    return _buildImagePlaceholder(product.category);
  }

  /// Зураг байхгүй үед харуулах placeholder (category өнгө + icon)
  Widget _buildImagePlaceholder(String? category) {
    final bgColor = _getProductColor(category);

    return Container(
      height: 140,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: const Center(
        child: Icon(
          Icons.inventory_2_outlined,
          size: 48,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildCartSummary(int cartCount, double cartTotal) {
    return Material(
      color: const Color(0xFF00878F),
      borderRadius: AppRadius.radiusXL,
      elevation: 8,
      shadowColor: const Color(0xFF00878F).withValues(alpha: 0.4),
      child: InkWell(
        onTap: () {
          context.push(RouteNames.quickSaleCart);
        },
        borderRadius: AppRadius.radiusXL,
        child: Container(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              // Cart icon with badge
              Stack(
                clipBehavior: Clip.none,
                children: [
                  const Icon(
                    Icons.shopping_cart_outlined,
                    color: Colors.white,
                    size: 24,
                  ),
                  Positioned(
                    top: -4,
                    right: -8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '$cartCount',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF00878F),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),

              // Text
              const Expanded(
                child: Text(
                  'Сагсыг харах',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),

              // Total amount
              Text(
                '${cartTotal.toStringAsFixed(0)}₮',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  fontFamily: 'Epilogue',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
