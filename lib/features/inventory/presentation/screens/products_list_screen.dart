import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:retail_control_platform/core/constants/app_colors.dart';
import 'package:retail_control_platform/core/constants/app_spacing.dart';
import 'package:retail_control_platform/core/constants/app_radius.dart';
import 'package:retail_control_platform/core/routing/route_names.dart';
import 'package:retail_control_platform/features/inventory/presentation/providers/product_provider.dart';

/// Products List Screen (Inventory)
/// Pattern-based design (consistency with Quick Sale Select + Dashboard)
class ProductsListScreen extends ConsumerStatefulWidget {
  const ProductsListScreen({super.key});

  @override
  ConsumerState<ProductsListScreen> createState() =>
      _ProductsListScreenState();
}

class _ProductsListScreenState extends ConsumerState<ProductsListScreen> {
  final _searchController = TextEditingController();
  String _selectedFilter = 'Бүгд';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(),
            AppSpacing.verticalXS,

            // Search bar
            _buildSearchBar(),
            AppSpacing.verticalXS,

            // Filter pills
            _buildFilterPills(),
            AppSpacing.verticalMD,

            // Products grid
            Expanded(
              child: _buildProductsGrid(),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildAddProductFAB(),
    );
  }

  /// Header - Title болон Sync badge
  ///
  /// Back button устгасан учир:
  /// - Энэ screen нь Bottom Navigation tab screen юм
  /// - Tab screen-үүд routing stack дээр push хийгдэхгүй, зөвхөн replace хийгддэг
  /// - Тиймээс context.pop() хийх боломжгүй (stack хоосон байдаг)
  /// - Хэрэглэгч bottom navigation дээр дарж өөр tab руу шилжинэ
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Title (Back button-гүй болсон - bottom navigation pattern)
          const Text(
            'Барааны жагсаалт',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.textMainLight,
              fontFamily: 'Epilogue',
            ),
          ),

          // Sync badge
          Container(
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
          style: const TextStyle(
            fontSize: 15,
            color: AppColors.textMainLight,
          ),
          decoration: InputDecoration(
            hintText: 'Бараа хайх (нэр, SKU, код)...',
            hintStyle: TextStyle(
              fontSize: 15,
              color: AppColors.textSecondaryLight.withValues(alpha: 0.7),
            ),
            prefixIcon: const Icon(
              Icons.search,
              color: AppColors.textSecondaryLight,
              size: 22,
            ),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(
                      Icons.clear,
                      color: AppColors.gray400,
                      size: 20,
                    ),
                    onPressed: () {
                      setState(() {
                        _searchController.clear();
                      });
                    },
                  )
                : null,
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
          onChanged: (value) {
            setState(() {});
          },
        ),
      ),
    );
  }

  Widget _buildFilterPills() {
    // Бодит барааны категориудыг provider-аас авах (backward compatibility)
    final productsAsync = ref.watch(productListProvider());

    // Dynamic-only approach: Зөвхөн database-аас категориуд
    final filters = productsAsync.whenOrNull(
      data: (products) {
        // Зөвхөн database-аас категориуд авах
        final categorySet = <String>{};

        // Database-аас бүх категориуд цуглуулах
        for (final product in products) {
          if (product.category != null && product.category!.isNotEmpty) {
            categorySet.add(product.category!);
          }
        }

        // 3. Эрэмбэлэх
        final categories = categorySet.toList()..sort();

        return ['Бүгд', 'Бага үлдэгдэл', ...categories];
      },
    ) ?? ['Бүгд', 'Бага үлдэгдэл']; // Fallback - зөвхөн special filters

    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = _selectedFilter == filter;
          final isLowStock = filter == 'Бага үлдэгдэл';

          return Material(
            color: isSelected
                ? (isLowStock ? const Color(0xFFF59E0B) : AppColors.primary)
                : Colors.white,
            borderRadius: AppRadius.radiusLG,
            elevation: 0,
            child: InkWell(
              onTap: () {
                setState(() {
                  _selectedFilter = filter;
                });
              },
              borderRadius: AppRadius.radiusLG,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isSelected
                        ? Colors.transparent
                        : AppColors.gray100,
                    width: 1,
                  ),
                  borderRadius: AppRadius.radiusLG,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isLowStock && isSelected)
                      const Padding(
                        padding: EdgeInsets.only(right: 6),
                        child: Icon(
                          Icons.warning_amber_rounded,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    Text(
                      filter,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color:
                            isSelected ? Colors.white : AppColors.gray600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductsGrid() {
    // Provider-аас бодит өгөгдөл авах
    final productsAsync = ref.watch(productListProvider());

    return productsAsync.when(
      // ДАТА ИРСЭН
      data: (products) {
        // "Бага үлдэгдэл" filter (client-side)
        final filtered = _selectedFilter == 'Бага үлдэгдэл'
            ? products.where((p) => p.isLowStock).toList()
            : products;

        // Empty state - бараа байхгүй
        if (filtered.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.inventory_2_outlined,
                  size: 64,
                  color: Colors.grey[300],
                ),
                const SizedBox(height: 16),
                Text(
                  'Бараа байхгүй байна',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          );
        }

        // GridView - барааны жагсаалт
        return GridView.builder(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.7,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: filtered.length,
          itemBuilder: (context, index) {
            final product = filtered[index];
            return _buildProductCard(
              name: product.name,
              sku: product.sku,
              price: product.sellPrice,
              stock: product.stockQuantity,
              isLowStock: product.isLowStock,
              imageUrl: product.imageUrl,
              onTap: () {
                context.push(RouteNames.productDetailPath(product.id));
              },
            );
          },
        );
      },

      // LOADING STATE
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),

      // ERROR STATE
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 48,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Алдаа гарлаа: $error',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.invalidate(productListProvider()),
              child: const Text('Дахин оролдох'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard({
    required String name,
    required String sku,
    required int price,
    required int stock,
    required bool isLowStock,
    required VoidCallback onTap,
    String? imageUrl,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: AppRadius.radiusXL,
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.radiusXL,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.5),
              width: 1,
            ),
            borderRadius: AppRadius.radiusXL,
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
              // Product image
              Stack(
                children: [
                  Container(
                    height: 140,
                    decoration: const BoxDecoration(
                      color: AppColors.gray100,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                      ),
                      child: (imageUrl != null && imageUrl.isNotEmpty)
                          ? Image.network(
                              imageUrl,
                              height: 140,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                // Зураг ачаалагдаагүй бол placeholder харуулах
                                return _buildImagePlaceholder();
                              },
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                // Зураг ачаалж байх үед loading indicator харуулах
                                return Center(
                                  child: CircularProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes != null
                                        ? loadingProgress.cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                        : null,
                                  ),
                                );
                              },
                            )
                          : _buildImagePlaceholder(),
                    ),
                  ),
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
                        color: isLowStock
                            ? const Color(0xFFFEF3C7)
                            : const Color(0xFFDCFCE7),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isLowStock
                              ? const Color(0xFFF59E0B)
                              : const Color(0xFF10B981),
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isLowStock
                                ? Icons.warning_amber_rounded
                                : Icons.check_circle,
                            size: 12,
                            color: isLowStock
                                ? const Color(0xFFF59E0B)
                                : const Color(0xFF10B981),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '$stock',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: isLowStock
                                  ? const Color(0xFFF59E0B)
                                  : const Color(0xFF10B981),
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
                  padding: const EdgeInsets.fromLTRB(10, 8, 10, 6),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // SKU
                      Text(
                        sku,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: AppColors.gray400,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 3),

                      // Product name
                      Flexible(
                        child: Text(
                          name,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textMainLight,
                            height: 1.15,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: 2),

                      // Price
                      Text(
                        '$price₮',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                          fontFamily: 'Epilogue',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddProductFAB() {
    return FloatingActionButton.extended(
      onPressed: () {
        // Navigate to add product form
        context.push(RouteNames.addProduct);
      },
      backgroundColor: const Color(0xFF00878F),
      elevation: 8,
      icon: const Icon(
        Icons.add,
        color: Colors.white,
      ),
      label: const Text(
        'Бараа нэмэх',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return const Center(
      child: Icon(
        Icons.inventory_2_outlined,
        size: 48,
        color: AppColors.gray300,
      ),
    );
  }
}
