import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:retail_control_platform/core/constants/app_colors.dart';
import 'package:retail_control_platform/core/constants/app_spacing.dart';
import 'package:retail_control_platform/core/constants/app_radius.dart';
import 'package:retail_control_platform/core/routing/route_names.dart';
import 'package:retail_control_platform/core/sync/sync_provider.dart';
import 'package:retail_control_platform/core/sync/sync_state.dart';
import 'package:retail_control_platform/core/providers/store_provider.dart';
import 'package:retail_control_platform/features/sales/presentation/providers/cart_provider.dart';
import 'package:retail_control_platform/features/inventory/presentation/providers/product_provider.dart';

/// Owner Dashboard Screen
/// Дизайн: design/owner_dashboard/screen.png
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Stack(
          children: [
            // Main scrollable content with Pull-to-Refresh
            RefreshIndicator(
              onRefresh: () => _handleRefresh(ref),
              color: const Color(0xFF00878F),
              backgroundColor: Colors.white,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    _buildHeader(context, ref),
                    AppSpacing.verticalMD,

                    // Today's Sales Hero Card
                    _buildSalesHeroCard(ref),
                    AppSpacing.verticalLG,

                    // Low Stock Alerts
                    _buildLowStockSection(context, ref),
                    AppSpacing.verticalLG,

                    // Top Products (динамик)
                    _buildTopProductsSection(ref),

                    // Bottom spacing for FAB
                    const SizedBox(height: 120),
                  ],
                ),
              ),
            ),

            // Floating Action Button (New Sale)
            Positioned(
              bottom: 24,
              left: 20,
              right: 20,
              child: _buildNewSaleFAB(context),
            ),
          ],
        ),
      ),
    );
  }

  /// Pull-to-refresh handler
  Future<void> _handleRefresh(WidgetRef ref) async {
    // Sync эхлүүлэх
    await ref.read(syncNotifierProvider.notifier).sync();
    // Providers шинэчлэх
    ref.invalidate(todaySalesTotalProvider);
    ref.invalidate(yesterdaySalesTotalProvider);
    ref.invalidate(topProductsProvider);
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref) {
    final now = DateTime.now();
    final timeFormat = DateFormat('h:mm a');
    final currentTime = timeFormat.format(now).toUpperCase();

    // Watch sync state
    final syncState = ref.watch(syncNotifierProvider);

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Time + Greeting
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                currentTime,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondaryLight,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Сайн байна уу,\nДэлгүүр',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  height: 1.1,
                  color: AppColors.textMainLight,
                  fontFamily: 'Epilogue',
                ),
              ),
            ],
          ),

          // Sync status badge - tap-to-retry нэмсэн
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              InkWell(
                onTap: () => _handleSyncTap(context, ref, syncState),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getSyncBgColor(syncState.status),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _getSyncColor(syncState.status).withOpacity(0.1),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getSyncIcon(syncState.status),
                        size: 16,
                        color: _getSyncColor(syncState.status),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _getSyncStatusText(syncState.status),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: _getSyncColor(syncState.status),
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _formatLastSync(syncState.lastSyncTime),
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: AppColors.gray400,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Sync helper methods
  String _getSyncStatusText(SyncStatus status) {
    switch (status) {
      case SyncStatus.synced:
        return 'SYNCED';
      case SyncStatus.syncing:
        return 'SYNCING...';
      case SyncStatus.pendingChanges:
        return 'PENDING';
      case SyncStatus.offline:
        return 'OFFLINE';
      case SyncStatus.error:
        return 'ERROR';
    }
  }

  Color _getSyncColor(SyncStatus status) {
    switch (status) {
      case SyncStatus.synced:
        return const Color(0xFF3D7A6E);
      case SyncStatus.syncing:
        return const Color(0xFF1976D2);
      case SyncStatus.pendingChanges:
        return const Color(0xFFE65100);
      case SyncStatus.offline:
        return const Color(0xFF757575);
      case SyncStatus.error:
        return const Color(0xFFC62828);
    }
  }

  Color _getSyncBgColor(SyncStatus status) {
    switch (status) {
      case SyncStatus.synced:
        return const Color(0xFFE6F0EE);
      case SyncStatus.syncing:
        return const Color(0xFFE3F2FD);
      case SyncStatus.pendingChanges:
        return const Color(0xFFFFF4E6);
      case SyncStatus.offline:
        return const Color(0xFFF5F5F5);
      case SyncStatus.error:
        return const Color(0xFFFFEBEE);
    }
  }

  IconData _getSyncIcon(SyncStatus status) {
    switch (status) {
      case SyncStatus.synced:
        return Icons.cloud_done;
      case SyncStatus.syncing:
        return Icons.sync;
      case SyncStatus.pendingChanges:
        return Icons.cloud_upload;
      case SyncStatus.offline:
        return Icons.cloud_off;
      case SyncStatus.error:
        return Icons.error_outline;
    }
  }

  String _formatLastSync(DateTime? time) {
    if (time == null) return 'Синк хийгдээгүй';
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return 'Дөнгөж сая';
    if (diff.inMinutes < 60) return 'Сүүлд: ${diff.inMinutes} мин өмнө';
    if (diff.inHours < 24) return 'Сүүлд: ${diff.inHours} цаг өмнө';
    return 'Сүүлд: ${DateFormat('MMM d').format(time)}';
  }

  /// Sync badge дарахад - manual sync эхлүүлэх
  void _handleSyncTap(BuildContext context, WidgetRef ref, SyncState syncState) {
    if (syncState.status == SyncStatus.syncing) {
      // Аль хэдийн sync хийж байгаа бол юу ч хийхгүй
      return;
    }

    if (syncState.status == SyncStatus.error ||
        syncState.status == SyncStatus.offline ||
        syncState.status == SyncStatus.pendingChanges) {
      // Manual sync эхлүүлэх
      ref.read(syncNotifierProvider.notifier).sync();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Синк эхэллээ...'),
          backgroundColor: const Color(0xFF00878F),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          duration: const Duration(seconds: 2),
        ),
      );
    } else if (syncState.status == SyncStatus.synced) {
      // Sync info харуулах
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Сүүлд синк хийсэн: ${_formatLastSync(syncState.lastSyncTime)}'),
          backgroundColor: const Color(0xFF3D7A6E),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Widget _buildSalesHeroCard(WidgetRef ref) {
    final todaySalesAsync = ref.watch(todaySalesTotalProvider);
    final yesterdaySalesAsync = ref.watch(yesterdaySalesTotalProvider);

    return todaySalesAsync.when(
      data: (todaySales) {
        return yesterdaySalesAsync.when(
          data: (yesterdaySales) {
            // Calculate growth percentage
            final growthPercent = yesterdaySales > 0
                ? ((todaySales - yesterdaySales) / yesterdaySales * 100).round()
                : 0;
            final isPositive = growthPercent >= 0;

            return _buildSalesCardContent(
              todayAmount: todaySales,
              yesterdayAmount: yesterdaySales,
              growthPercent: growthPercent,
              isPositive: isPositive,
            );
          },
          loading: () => _buildSalesCardContent(
            todayAmount: todaySales,
            yesterdayAmount: 0,
            growthPercent: 0,
            isPositive: true,
            isLoading: true,
          ),
          error: (_, __) => _buildSalesCardContent(
            todayAmount: todaySales,
            yesterdayAmount: 0,
            growthPercent: 0,
            isPositive: true,
          ),
        );
      },
      loading: () => _buildSalesCardLoading(),
      error: (_, __) => _buildSalesCardError(),
    );
  }

  Widget _buildSalesCardContent({
    required double todayAmount,
    required double yesterdayAmount,
    required int growthPercent,
    required bool isPositive,
    bool isLoading = false,
  }) {
    final formattedToday = NumberFormat('#,###', 'mn').format(todayAmount.round());
    final formattedYesterday = NumberFormat('#,###', 'mn').format(yesterdayAmount.round());

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: AppRadius.radiusXL,
          border: Border.all(
            color: Colors.white.withOpacity(0.6),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 40,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Decorative blobs
            Positioned(
              right: -40,
              top: -40,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFFC96F53).withOpacity(0.05),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              left: -40,
              bottom: -40,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFFFEEBC8).withOpacity(0.2),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // Content
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 4,
                          height: 16,
                          decoration: BoxDecoration(
                            color: const Color(0xFFC96F53),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'ӨНӨӨДРИЙН БОРЛУУЛАЛТ',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textSecondaryLight,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                    // Growth badge - dynamic
                    if (!isLoading && yesterdayAmount > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isPositive
                              ? const Color(0xFFEBF5EC)
                              : const Color(0xFFFFEBEE),
                          borderRadius: AppRadius.radiusSM,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isPositive ? Icons.trending_up : Icons.trending_down,
                              size: 14,
                              color: isPositive
                                  ? const Color(0xFF2E7D32)
                                  : const Color(0xFFC62828),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${isPositive ? '+' : ''}$growthPercent%',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: isPositive
                                    ? const Color(0xFF2E7D32)
                                    : const Color(0xFFC62828),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),

                // Amount - dynamic
                Text(
                  '₮ $formattedToday',
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFFC96F53),
                    height: 1.0,
                    letterSpacing: -0.5,
                    fontFamily: 'Epilogue',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Өчигдөр: ₮ $formattedYesterday',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppColors.gray400,
                  ),
                ),
                const SizedBox(height: 20),

                // Sparkline (placeholder - simple line)
                CustomPaint(
                  size: const Size(double.infinity, 60),
                  painter: _SparklinePainter(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSalesCardLoading() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        height: 200,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: AppRadius.radiusXL,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 40,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: const Center(
          child: CircularProgressIndicator(
            color: Color(0xFFC96F53),
            strokeWidth: 2,
          ),
        ),
      ),
    );
  }

  Widget _buildSalesCardError() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        height: 200,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: AppRadius.radiusXL,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 40,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, color: AppColors.gray400, size: 32),
              SizedBox(height: 8),
              Text(
                'Өгөгдөл ачаалахад алдаа гарлаа',
                style: TextStyle(color: AppColors.gray400, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLowStockSection(BuildContext context, WidgetRef ref) {
    final storeId = ref.watch(storeIdProvider);
    if (storeId == null) {
      return const SizedBox.shrink();
    }

    final lowStockAsync = ref.watch(lowStockProductsProvider(storeId));

    return lowStockAsync.when(
      data: (products) {
        if (products.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with dynamic count
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Бага үлдэгдэлтэй',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textMainLight,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF4E6),
                      borderRadius: AppRadius.radiusSM,
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.warning_amber_rounded,
                          size: 14,
                          color: Color(0xFFE65100),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${products.length} сэрэмжлүүлэг',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFE65100),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            AppSpacing.verticalMD,

            // Dynamic alert cards
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: products.take(3).map((product) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildAlertCard(
                      icon: Icons.inventory_2_outlined,
                      iconColor: const Color(0xFFE65100),
                      iconBg: const Color(0xFFFFF4E6),
                      title: product.name,
                      subtitle: product.unit ?? product.category ?? '',
                      stockCount: product.stockQuantity,
                    ),
                  );
                }).toList(),
              ),
            ),

            // "See all" link
            if (products.length > 3)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: TextButton(
                  onPressed: () {
                    context.push('/alerts');
                  },
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Бүгдийг харах',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondaryLight,
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward,
                        size: 14,
                        color: AppColors.textSecondaryLight,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
      loading: () => _buildLowStockLoading(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildLowStockLoading() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: AppRadius.radiusLG,
        ),
        child: const Center(
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Color(0xFFE65100),
          ),
        ),
      ),
    );
  }

  Widget _buildAlertCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String title,
    required String subtitle,
    required int stockCount,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.radiusLG,
        border: Border.all(
          color: AppColors.gray100,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: AppRadius.radiusSM,
            ),
            child: Icon(
              icon,
              size: 20,
              color: iconColor,
            ),
          ),
          const SizedBox(width: 12),

          // Text
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
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: AppColors.gray500,
                  ),
                ),
              ],
            ),
          ),

          // Stock count badge
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFFFEBEE),
              borderRadius: AppRadius.radiusSM,
            ),
            child: Text(
              '$stockCount үлдсэн',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Color(0xFFC62828),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopProductsSection(WidgetRef ref) {
    final topProductsAsync = ref.watch(topProductsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            'Шилдэг бүтээгдэхүүн',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textMainLight,
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Динамик product cards
        topProductsAsync.when(
          data: (products) {
            if (products.isEmpty) {
              return _buildEmptyTopProducts();
            }
            return SizedBox(
              height: 180,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: products.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final product = products[index];
                  return _buildTopProductCard(
                    rank: index + 1,
                    name: product.name,
                    salesCount: product.salesCount,
                    bgColor: _getProductColor(index),
                  );
                },
              ),
            );
          },
          loading: () => _buildTopProductsLoading(),
          error: (_, __) => _buildTopProductsError(),
        ),
      ],
    );
  }

  /// Top products-ийн өнгө (rank-д тулгуурласан)
  Color _getProductColor(int index) {
    final colors = [
      const Color(0xFFFFCDD2), // Улаан
      const Color(0xFFC8E6C9), // Ногоон
      const Color(0xFFFFE0B2), // Улбар
      const Color(0xFFBBDEFB), // Цэнхэр
      const Color(0xFFE1BEE7), // Ягаан
    ];
    return colors[index % colors.length];
  }

  /// Top products хоосон үед
  Widget _buildEmptyTopProducts() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        height: 140,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: AppRadius.radiusLG,
          border: Border.all(color: AppColors.gray100),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.inventory_2_outlined, size: 40, color: AppColors.gray300),
              SizedBox(height: 8),
              Text(
                'Өнөөдөр борлуулалт байхгүй',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.gray400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Top products loading state
  Widget _buildTopProductsLoading() {
    return SizedBox(
      height: 180,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: 3,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          return Container(
            width: 140,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: AppRadius.radiusLG,
            ),
            child: const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        },
      ),
    );
  }

  /// Top products error state
  Widget _buildTopProductsError() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        height: 140,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: AppRadius.radiusLG,
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 32, color: AppColors.gray400),
              SizedBox(height: 8),
              Text(
                'Өгөгдөл ачаалахад алдаа гарлаа',
                style: TextStyle(fontSize: 12, color: AppColors.gray400),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopProductCard({
    required int rank,
    required String name,
    required int salesCount,
    required Color bgColor,
  }) {
    return Container(
      width: 140,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.radiusLG,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product image placeholder
          Container(
            height: 90,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: AppRadius.radiusMD,
            ),
            child: Stack(
              children: [
                // Rank badge
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        '#$rank',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textMainLight,
                        ),
                      ),
                    ),
                  ),
                ),
                // Placeholder icon
                const Center(
                  child: Icon(
                    Icons.inventory_2_outlined,
                    size: 40,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Product name
          Text(
            name,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textMainLight,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const Spacer(),

          // Sales count
          Text(
            '$salesCount зарагдсан',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppColors.gray500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNewSaleFAB(BuildContext context) {
    return Material(
      color: const Color(0xFF00878F),
      borderRadius: AppRadius.radiusXL,
      elevation: 8,
      shadowColor: const Color(0xFF00878F).withOpacity(0.4),
      child: InkWell(
        onTap: () {
          context.push(RouteNames.quickSaleSelect);
        },
        borderRadius: AppRadius.radiusXL,
        child: Container(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.add,
                color: Colors.white,
                size: 24,
              ),
              const SizedBox(width: 8),
              const Text(
                'Шинэ борлуулалт',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Simple sparkline painter (curved line)
class _SparklinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFC96F53)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();

    // Sample data points for sparkline curve
    final points = [
      Offset(0, size.height * 0.7),
      Offset(size.width * 0.15, size.height * 0.5),
      Offset(size.width * 0.35, size.height * 0.6),
      Offset(size.width * 0.55, size.height * 0.4),
      Offset(size.width * 0.75, size.height * 0.5),
      Offset(size.width, size.height * 0.2),
    ];

    path.moveTo(points[0].dx, points[0].dy);

    // Create smooth curve
    for (int i = 0; i < points.length - 1; i++) {
      final current = points[i];
      final next = points[i + 1];
      final controlX = (current.dx + next.dx) / 2;

      path.quadraticBezierTo(
        controlX,
        current.dy,
        controlX,
        (current.dy + next.dy) / 2,
      );
      path.quadraticBezierTo(
        controlX,
        next.dy,
        next.dx,
        next.dy,
      );
    }

    canvas.drawPath(path, paint);

    // Draw end point
    canvas.drawCircle(
      points.last,
      4,
      Paint()
        ..color = const Color(0xFFC96F53)
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
