import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:retail_control_platform/core/constants/app_colors.dart';
import 'package:retail_control_platform/core/constants/app_spacing.dart';
import 'package:retail_control_platform/core/constants/app_radius.dart';
import 'package:retail_control_platform/core/routing/route_names.dart';
import 'package:retail_control_platform/features/auth/presentation/providers/auth_provider.dart';
import 'package:retail_control_platform/features/dashboard/presentation/providers/multi_store_dashboard_provider.dart';
import 'package:retail_control_platform/features/store/presentation/providers/user_stores_provider.dart';

/// Multi-store нэгдсэн dashboard
/// Owner 2+ дэлгүүртэй үед бүх салбарыг нэг дэлгэцэд харуулна
class MultiStoreDashboardScreen extends ConsumerWidget {
  const MultiStoreDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(multiStoreDashboardProvider);
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(multiStoreDashboardProvider);
          },
          color: AppColors.primary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                _buildHeader(context, user?.name ?? 'Owner'),
                AppSpacing.verticalMD,

                // Нэгдсэн хураангуй
                dashboardAsync.when(
                  data: (stores) {
                    if (stores.isEmpty) {
                      return _buildEmptyState();
                    }
                    return Column(
                      children: [
                        // Нийт хураангуй
                        _buildTotalSummary(stores),
                        AppSpacing.verticalLG,

                        // Салбар бүрийн card
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            children: [
                              const Text(
                                'Салбарууд',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textMainLight,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                '${stores.length} салбар',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textSecondaryLight,
                                ),
                              ),
                            ],
                          ),
                        ),
                        AppSpacing.verticalMD,

                        // Store cards
                        ...stores.map((store) => _buildStoreCard(
                          context,
                          ref,
                          store,
                        )),

                        const SizedBox(height: 80),
                      ],
                    );
                  },
                  loading: () => const Padding(
                    padding: EdgeInsets.only(top: 100),
                    child: Center(
                      child: CircularProgressIndicator(color: AppColors.primary),
                    ),
                  ),
                  error: (error, _) => _buildErrorState(ref),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Header
  Widget _buildHeader(BuildContext context, String ownerName) {
    final now = DateTime.now();
    final dateFormat = DateFormat('yyyy.MM.dd, EEEE', 'mn');

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            dateFormat.format(now),
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondaryLight,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Сайн байна уу, $ownerName',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.textMainLight,
              fontFamily: 'Epilogue',
            ),
          ),
          const SizedBox(height: 2),
          const Text(
            'Нэгдсэн хяналтын самбар',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }

  /// Нийт хураангуй (бүх салбарын нийлбэр)
  Widget _buildTotalSummary(List<StoreDashboardSummary> stores) {
    final totalRevenue = stores.fold(0.0, (sum, s) => sum + s.todayRevenue);
    final totalProfit = stores.fold(0.0, (sum, s) => sum + s.todayProfit);
    final totalDiscount = stores.fold(0.0, (sum, s) => sum + s.todayDiscount);
    final totalSales = stores.fold(0, (sum, s) => sum + s.todaySalesCount);
    final totalLowStock = stores.fold(0, (sum, s) => sum + s.lowStockCount);
    final margin = totalRevenue > 0
        ? (totalProfit / totalRevenue * 100).round()
        : 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF00878F), Color(0xFF006B72)],
          ),
          borderRadius: AppRadius.radiusXL,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF00878F).withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'ӨНӨӨДРИЙН НИЙТ',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Colors.white70,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 12),

            // Борлуулалт
            Text(
              '₮${_formatNumber(totalRevenue)}',
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                fontFamily: 'Epilogue',
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '$totalSales гүйлгээ',
              style: const TextStyle(
                fontSize: 13,
                color: Colors.white60,
              ),
            ),

            const SizedBox(height: 20),

            // 3 stat mini cards
            Row(
              children: [
                Expanded(
                  child: _buildMiniStat(
                    'Ашиг',
                    '₮${_formatNumber(totalProfit)}',
                    '$margin%',
                    totalProfit >= 0,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildMiniStat(
                    'Хөнгөлөлт',
                    '₮${_formatNumber(totalDiscount)}',
                    null,
                    true,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildMiniStat(
                    'Бага үлдэгдэл',
                    '$totalLowStock',
                    'бараа',
                    totalLowStock == 0,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Mini stat widget (нэгдсэн summary дотор)
  Widget _buildMiniStat(
    String label,
    String value,
    String? subtitle,
    bool isPositive,
  ) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: AppRadius.radiusMD,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Colors.white60,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 10,
                color: isPositive ? Colors.white54 : const Color(0xFFFFAB91),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Салбарын card
  Widget _buildStoreCard(
    BuildContext context,
    WidgetRef ref,
    StoreDashboardSummary store,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      child: InkWell(
        onTap: () => _switchToStore(context, ref, store.storeId),
        borderRadius: AppRadius.radiusLG,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: AppRadius.radiusLG,
            border: Border.all(color: AppColors.gray200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Store header
              Row(
                children: [
                  // Store icon
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.store_outlined,
                      size: 22,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          store.storeName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textMainLight,
                          ),
                        ),
                        if (store.storeLocation != null)
                          Text(
                            store.storeLocation!,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondaryLight,
                            ),
                          ),
                      ],
                    ),
                  ),
                  // Борлуулалтын дүн
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '₮${_formatNumber(store.todayRevenue)}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                          fontFamily: 'Epilogue',
                        ),
                      ),
                      Text(
                        '${store.todaySalesCount} гүйлгээ',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              AppSpacing.verticalMD,

              // Stats row
              Row(
                children: [
                  _buildStoreStatItem(
                    Icons.trending_up_rounded,
                    'Ашиг',
                    '₮${_formatNumber(store.todayProfit)}',
                    store.todayProfit >= 0
                        ? const Color(0xFF2E7D32)
                        : AppColors.danger,
                  ),
                  const SizedBox(width: 16),
                  _buildStoreStatItem(
                    Icons.discount_outlined,
                    'Хөнгөлөлт',
                    '₮${_formatNumber(store.todayDiscount)}',
                    const Color(0xFFE65100),
                  ),
                  const SizedBox(width: 16),
                  _buildStoreStatItem(
                    Icons.warning_amber_rounded,
                    'Бага үлд.',
                    '${store.lowStockCount}',
                    store.lowStockCount > 0
                        ? const Color(0xFFE65100)
                        : AppColors.textSecondaryLight,
                  ),
                ],
              ),

              // Идэвхтэй ажилтнууд
              if (store.activeSellers.isNotEmpty) ...[
                AppSpacing.verticalMD,
                Row(
                  children: [
                    Icon(
                      Icons.person_outline,
                      size: 16,
                      color: AppColors.successGreen,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        store.activeSellers.map((s) => s.name).join(', '),
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.successGreen,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],

              // Нэвтрэх товч
              AppSpacing.verticalMD,
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Дэлгэрэнгүй',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 12,
                    color: AppColors.primary,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Store stat item
  Widget _buildStoreStatItem(
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    return Expanded(
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.textSecondaryLight,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Store руу шилжих
  Future<void> _switchToStore(
    BuildContext context,
    WidgetRef ref,
    String storeId,
  ) async {
    final success = await ref
        .read(userStoresProvider.notifier)
        .selectStore(storeId);

    if (success && context.mounted) {
      context.go(RouteNames.dashboard);
    }
  }

  /// Хоосон дэлгэц
  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.only(top: 80),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.store_outlined, size: 64, color: AppColors.gray300),
            AppSpacing.verticalMD,
            const Text(
              'Дэлгүүр байхгүй',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textSecondaryLight,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Алдааны дэлгэц
  Widget _buildErrorState(WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.only(top: 80),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.danger),
            AppSpacing.verticalMD,
            const Text('Мэдээлэл ачаалахад алдаа гарлаа'),
            AppSpacing.verticalSM,
            TextButton(
              onPressed: () => ref.invalidate(multiStoreDashboardProvider),
              child: const Text('Дахин оролдох'),
            ),
          ],
        ),
      ),
    );
  }

  /// Тоо форматлах
  String _formatNumber(double value) {
    if (value.abs() >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}сая';
    }
    if (value.abs() >= 1000) {
      return NumberFormat('#,###', 'mn').format(value.round());
    }
    return value.toStringAsFixed(0);
  }
}
