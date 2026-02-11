import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:retail_control_platform/core/constants/app_colors.dart';
import 'package:retail_control_platform/core/constants/app_spacing.dart';
import 'package:retail_control_platform/core/constants/app_radius.dart';
import 'package:retail_control_platform/features/employees/presentation/providers/seller_performance_provider.dart';

/// Худалдагчийн гүйцэтгэлийн дэлгэц
/// Борлуулалт, ээлж, мөнгөн тулгалт, хөнгөлөлт зэрэг KPI-ууд
class SellerPerformanceScreen extends ConsumerWidget {
  const SellerPerformanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final performanceAsync = ref.watch(sellerPerformanceListProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundLight,
        elevation: 0,
        title: const Text(
          'Худалдагчийн гүйцэтгэл',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.textMainLight,
          ),
        ),
        centerTitle: false,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(sellerPerformanceListProvider);
        },
        color: AppColors.primary,
        child: performanceAsync.when(
          data: (sellers) {
            if (sellers.isEmpty) {
              return _buildEmptyState();
            }
            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: sellers.length,
              itemBuilder: (context, index) {
                return _buildSellerCard(context, sellers[index], index + 1);
              },
            );
          },
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
          error: (error, _) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: AppColors.danger),
                AppSpacing.verticalMD,
                const Text('Мэдээлэл ачаалахад алдаа гарлаа'),
                AppSpacing.verticalSM,
                TextButton(
                  onPressed: () => ref.invalidate(sellerPerformanceListProvider),
                  child: const Text('Дахин оролдох'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Худалдагчийн гүйцэтгэлийн card
  Widget _buildSellerCard(
    BuildContext context,
    SellerPerformance seller,
    int rank,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.cardRadius,
        border: Border.all(
          color: seller.hasDiscrepancyIssues
              ? AppColors.danger.withValues(alpha: 0.3)
              : AppColors.gray200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Rank + Seller name
          Row(
            children: [
              // Байр
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: _rankColor(rank).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  '#$rank',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: _rankColor(rank),
                  ),
                ),
              ),
              AppSpacing.horizontalSM,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      seller.sellerName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textMainLight,
                      ),
                    ),
                    Text(
                      '${seller.shiftsCount} ээлж',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
              ),
              // Нийт борлуулалт
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '₮${_formatNumber(seller.totalSales)}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                  Text(
                    '${seller.totalSalesCount} гүйлгээ',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            ],
          ),

          AppSpacing.verticalMD,

          // KPI stats row
          Row(
            children: [
              Expanded(
                child: _buildKpiItem(
                  icon: Icons.shopping_bag_outlined,
                  label: 'Зарсан бараа',
                  value: '${seller.totalItemsSold}',
                ),
              ),
              Expanded(
                child: _buildKpiItem(
                  icon: Icons.analytics_outlined,
                  label: 'Дундаж',
                  value: '₮${_formatNumber(seller.averageSale)}',
                ),
              ),
              Expanded(
                child: _buildKpiItem(
                  icon: Icons.local_offer_outlined,
                  label: 'Хөнгөлөлт',
                  value: '₮${_formatNumber(seller.totalDiscountGiven)}',
                  valueColor: seller.totalDiscountGiven > 0
                      ? AppColors.warning
                      : null,
                ),
              ),
            ],
          ),

          // Мөнгөн тулгалтын зөрүү (хэрэв байвал)
          if (seller.hasDiscrepancyIssues) ...[
            AppSpacing.verticalMD,
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.danger.withValues(alpha: 0.05),
                borderRadius: AppRadius.radiusSM,
                border: Border.all(
                  color: AppColors.danger.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.warning_amber_outlined,
                    size: 20,
                    color: AppColors.danger,
                  ),
                  AppSpacing.horizontalSM,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Мөнгөн зөрүү: ${seller.discrepancyCount} удаа',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.danger,
                          ),
                        ),
                        Text(
                          'Нийт зөрүү: ₮${_formatNumber(seller.totalDiscrepancy)}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondaryLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// KPI item widget
  Widget _buildKpiItem({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: AppColors.textSecondaryLight),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textSecondaryLight,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: valueColor ?? AppColors.textMainLight,
          ),
        ),
      ],
    );
  }

  /// Хоосон дэлгэц
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 64, color: AppColors.gray300),
          AppSpacing.verticalMD,
          const Text(
            'Худалдагчийн мэдээлэл байхгүй',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textSecondaryLight,
            ),
          ),
          AppSpacing.verticalSM,
          const Text(
            'Борлуулалт эхэлсний дараа гүйцэтгэл\nхарагдах болно',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textTertiaryLight,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Байрын өнгө
  Color _rankColor(int rank) {
    switch (rank) {
      case 1:
        return const Color(0xFFFFB800); // Алт
      case 2:
        return const Color(0xFF8E8E93); // Мөнгө
      case 3:
        return const Color(0xFFCD7F32); // Хүрэл
      default:
        return AppColors.textSecondaryLight;
    }
  }

  /// Тоо форматлах (1000 → 1,000)
  String _formatNumber(double value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}сая';
    }
    if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(0)}мян';
    }
    return value.toStringAsFixed(0);
  }
}
