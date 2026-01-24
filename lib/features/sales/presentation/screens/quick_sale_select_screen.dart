import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:retail_control_platform/core/constants/app_colors.dart';
import 'package:retail_control_platform/core/constants/app_spacing.dart';
import 'package:retail_control_platform/core/constants/app_radius.dart';
import 'package:retail_control_platform/core/routing/route_names.dart';

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
                _buildCategoryPills(),
                AppSpacing.verticalXS,

                // Tabs (Онцлох/Сүүлд)
                _buildTabs(),
                AppSpacing.verticalSM,

                // Product grid
                Expanded(
                  child: _buildProductGrid(),
                ),
              ],
            ),

            // Bottom cart summary (if cart has items)
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: _buildCartSummary(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Title + sync badge
          Column(
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
                            color: const Color(0xFF10B981).withOpacity(0.5),
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

          // Barcode scanner button
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
          color: Colors.white.withOpacity(0.6),
          borderRadius: AppRadius.radiusXL,
          border: Border.all(
            color: Colors.transparent,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
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
            hintText: 'Бараа хайх, код уншуулах...',
            hintStyle: TextStyle(
              fontSize: 15,
              color: AppColors.textSecondaryLight.withOpacity(0.7),
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
                color: AppColors.primary.withOpacity(0.3),
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

  Widget _buildCategoryPills() {
    final categories = ['Бүгд', 'Хүнс', 'Ундаа', 'Гэр ахуй', 'Гоо сайхан'];

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
                            color: AppColors.primary.withOpacity(0.3),
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

  Widget _buildProductGrid() {
    // Mock products data
    final products = [
      {
        'name': 'Талх Атар (Өдөр тутмын)',
        'price': '2,400',
        'stock': 12,
        'color': const Color(0xFFFFE4CC),
      },
      {
        'name': 'Сүү ІЛ 1л',
        'price': '3,200',
        'stock': 8,
        'color': const Color(0xFFCDE7F0),
      },
      {
        'name': 'Coca Cola 500мл',
        'price': '2,000',
        'stock': 24,
        'color': const Color(0xFFFFD4CC),
      },
      {
        'name': 'Зөгийн бал',
        'price': '15,000',
        'stock': 5,
        'color': const Color(0xFFFFF0CC),
      },
      {
        'name': 'Жүрж Импорт',
        'price': '8,600',
        'stock': 15,
        'color': const Color(0xFFFFE5CC),
      },
      {
        'name': 'Сүү Ундаа 200мл',
        'price': '4,000',
        'stock': 18,
        'color': const Color(0xFFD4E4FF),
      },
    ];

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return _buildProductCard(
          name: product['name'] as String,
          price: product['price'] as String,
          stock: product['stock'] as int,
          bgColor: product['color'] as Color,
        );
      },
    );
  }

  Widget _buildProductCard({
    required String name,
    required String price,
    required int stock,
    required Color bgColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.radiusXL,
        border: Border.all(
          color: Colors.white.withOpacity(0.5),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product image placeholder with stock badge
          Stack(
            children: [
              Container(
                height: 130,
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
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
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
                        decoration: const BoxDecoration(
                          color: Color(0xFF10B981),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${stock}ш',
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
                children: [
                  // Product name
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textMainLight,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(),

                  // Price + Add button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      RichText(
                        text: TextSpan(
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textMainLight,
                            fontFamily: 'Epilogue',
                          ),
                          children: [
                            TextSpan(text: price),
                            const TextSpan(
                              text: '₮',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Material(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        child: InkWell(
                          onTap: () {
                            // Add to cart
                          },
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            width: 32,
                            height: 32,
                            alignment: Alignment.center,
                            child: const Icon(
                              Icons.add,
                              size: 18,
                              color: AppColors.primary,
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

  Widget _buildCartSummary() {
    // Mock cart data (will be replaced with actual cart provider)
    final cartItemCount = 0;

    if (cartItemCount == 0) {
      return const SizedBox.shrink();
    }

    return Material(
      color: const Color(0xFF00878F),
      borderRadius: AppRadius.radiusXL,
      elevation: 8,
      shadowColor: const Color(0xFF00878F).withOpacity(0.4),
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
                        '$cartItemCount',
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
              const Text(
                '7,200₮',
                style: TextStyle(
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
