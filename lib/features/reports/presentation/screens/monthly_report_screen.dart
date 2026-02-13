import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:retail_control_platform/core/constants/app_colors.dart';
import 'package:retail_control_platform/core/constants/app_spacing.dart';
import 'package:retail_control_platform/core/constants/app_radius.dart';
import 'package:retail_control_platform/features/reports/domain/report_models.dart';
import 'package:retail_control_platform/features/reports/presentation/providers/report_provider.dart';

/// Сарын нэгдсэн тайлан — бүх KPI нэг дэлгэцэд
/// Орлого, ашиг, хөнгөлөлт, шилдэг бараа, шилжүүлэг, худалдагч
/// Өмнөх сартай харьцуулалт
class MonthlyReportScreen extends ConsumerWidget {
  const MonthlyReportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedMonth = ref.watch(selectedMonthProvider);
    final monthlyAsync = ref.watch(monthlyReportProvider);
    final numberFormat = NumberFormat('#,###', 'mn');

    // Сарын нэрийг форматлах (2026-02 → 2026 оны 2-р сар)
    final parts = selectedMonth.split('-');
    final year = parts[0];
    final month = int.parse(parts[1]);
    final monthTitle = '$year оны $month-р сар';

    // Ирээдүйн сар эсэхийг шалгах (next товч идэвхгүй болгоход)
    final now = DateTime.now();
    final currentMonthStr =
        '${now.year}-${now.month.toString().padLeft(2, '0')}';
    final isCurrentMonth = selectedMonth == currentMonthStr;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundLight,
        elevation: 0,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Өмнөх сар
            IconButton(
              onPressed: () =>
                  ref.read(selectedMonthProvider.notifier).previousMonth(),
              icon: const Icon(Icons.chevron_left, color: AppColors.primary),
              visualDensity: VisualDensity.compact,
            ),
            // Сарын нэр
            Text(
              monthTitle,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textMainLight,
              ),
            ),
            // Дараагийн сар
            IconButton(
              onPressed:
                  isCurrentMonth
                      ? null
                      : () =>
                          ref.read(selectedMonthProvider.notifier).nextMonth(),
              icon: Icon(
                Icons.chevron_right,
                color:
                    isCurrentMonth ? AppColors.gray300 : AppColors.primary,
              ),
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: monthlyAsync.when(
        data: (report) {
          if (report == null) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bar_chart_outlined,
                      size: 64, color: AppColors.gray300),
                  SizedBox(height: 16),
                  Text(
                    'Сарын мэдээлэл байхгүй',
                    style: TextStyle(
                      fontSize: 15,
                      color: AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(monthlyReportProvider);
            },
            color: AppColors.primary,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: AppSpacing.paddingMD,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ===== Hero KPI =====
                  _buildHeroCard(report, numberFormat),
                  AppSpacing.verticalMD,

                  // ===== 3 mini card =====
                  _buildMiniCards(report, numberFormat),
                  AppSpacing.verticalLG,

                  // ===== Төлбөрийн хэлбэр =====
                  if (report.paymentMethods.isNotEmpty) ...[
                    _buildSectionTitle('Төлбөрийн хэлбэр'),
                    AppSpacing.verticalSM,
                    _buildPaymentMethods(report, numberFormat),
                    AppSpacing.verticalLG,
                  ],

                  // ===== Шилдэг 5 бараа =====
                  if (report.topProducts.isNotEmpty) ...[
                    _buildSectionTitle('Шилдэг 5 бараа'),
                    AppSpacing.verticalSM,
                    ...report.topProducts.asMap().entries.map(
                          (entry) => _buildTopProductItem(
                              entry.key + 1, entry.value, numberFormat),
                        ),
                    AppSpacing.verticalLG,
                  ],

                  // ===== Шилжүүлэг =====
                  if (report.transfers.outgoingCount > 0 ||
                      report.transfers.incomingCount > 0) ...[
                    _buildSectionTitle('Салбар хоорондын шилжүүлэг'),
                    AppSpacing.verticalSM,
                    _buildTransferSummary(report.transfers),
                    AppSpacing.verticalLG,
                  ],

                  // ===== Худалдагч =====
                  if (report.sellerSummary.isNotEmpty) ...[
                    _buildSectionTitle('Худалдагчид'),
                    AppSpacing.verticalSM,
                    ...report.sellerSummary.map(
                        (s) => _buildSellerItem(s, numberFormat)),
                    AppSpacing.verticalLG,
                  ],

                  // Доод padding
                  const SizedBox(height: 32),
                ],
              ),
            ),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline,
                  size: 48, color: AppColors.danger),
              AppSpacing.verticalMD,
              const Text('Сарын тайлан ачаалахад алдаа гарлаа'),
              AppSpacing.verticalSM,
              TextButton(
                onPressed: () => ref.invalidate(monthlyReportProvider),
                child: const Text('Дахин оролдох'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Гол KPI card — орлого, ашиг, өсөлтийн хувь
  Widget _buildHeroCard(MonthlyReport report, NumberFormat numberFormat) {
    final isRevenueUp = report.revenueChangePercent >= 0;
    final isProfitUp = report.profitChangePercent >= 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, Color(0xFF1565C0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: AppRadius.cardRadius,
      ),
      child: Column(
        children: [
          // Орлого
          const Text(
            'Нийт орлого',
            style: TextStyle(fontSize: 13, color: Colors.white70),
          ),
          const SizedBox(height: 4),
          Text(
            '₮${numberFormat.format(report.totalRevenue)}',
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          _buildChangeChip(report.revenueChangePercent, isRevenueUp),
          const SizedBox(height: 16),

          // Ашиг + маржин
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                children: [
                  const Text(
                    'Цэвэр ашиг',
                    style: TextStyle(fontSize: 12, color: Colors.white70),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '₮${numberFormat.format(report.totalProfit)}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: report.totalProfit >= 0
                          ? Colors.greenAccent
                          : Colors.redAccent,
                    ),
                  ),
                  const SizedBox(height: 2),
                  _buildChangeChip(report.profitChangePercent, isProfitUp),
                ],
              ),
              const SizedBox(width: 32),
              Column(
                children: [
                  const Text(
                    'Маржин',
                    style: TextStyle(fontSize: 12, color: Colors.white70),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${report.profitMargin}%',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Өсөлт/бууралтын chip
  Widget _buildChangeChip(double percent, bool isUp) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isUp
            ? Colors.greenAccent.withValues(alpha: 0.2)
            : Colors.redAccent.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isUp ? Icons.arrow_upward : Icons.arrow_downward,
            size: 12,
            color: isUp ? Colors.greenAccent : Colors.redAccent,
          ),
          const SizedBox(width: 2),
          Text(
            '${percent.abs().toStringAsFixed(1)}%',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isUp ? Colors.greenAccent : Colors.redAccent,
            ),
          ),
        ],
      ),
    );
  }

  /// 3 mini card (гүйлгээ, бараа, хөнгөлөлт)
  Widget _buildMiniCards(MonthlyReport report, NumberFormat numberFormat) {
    return Row(
      children: [
        Expanded(
          child: _buildMiniCard(
            'Гүйлгээ',
            '${report.totalTransactions}',
            Icons.receipt_long_outlined,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildMiniCard(
            'Зарагдсан',
            '${report.totalItemsSold} ш',
            Icons.shopping_bag_outlined,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildMiniCard(
            'Хөнгөлөлт',
            '₮${numberFormat.format(report.totalDiscount)}',
            Icons.discount_outlined,
          ),
        ),
      ],
    );
  }

  Widget _buildMiniCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.cardRadius,
        border: Border.all(color: AppColors.gray200),
      ),
      child: Column(
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.textMainLight,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textTertiaryLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: AppColors.textMainLight,
      ),
    );
  }

  /// Төлбөрийн хэлбэрийн задаргаа
  Widget _buildPaymentMethods(
      MonthlyReport report, NumberFormat numberFormat) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.cardRadius,
        border: Border.all(color: AppColors.gray200),
      ),
      child: Column(
        children: report.paymentMethods
            .map((pm) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(_paymentIcon(pm.method),
                              size: 18, color: AppColors.primary),
                          const SizedBox(width: 8),
                          Text(
                            pm.displayName,
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.textMainLight,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '(${pm.count})',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textTertiaryLight,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '₮${numberFormat.format(pm.amount)}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textMainLight,
                        ),
                      ),
                    ],
                  ),
                ))
            .toList(),
      ),
    );
  }

  IconData _paymentIcon(String method) {
    switch (method) {
      case 'cash':
        return Icons.money;
      case 'card':
        return Icons.credit_card;
      case 'qpay':
        return Icons.qr_code;
      case 'bank':
        return Icons.account_balance;
      default:
        return Icons.payment;
    }
  }

  /// Шилдэг бараа item
  Widget _buildTopProductItem(
      int rank, MonthlyTopProduct product, NumberFormat numberFormat) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.cardRadius,
        border: Border.all(color: AppColors.gray200),
      ),
      child: Row(
        children: [
          // Дугаар badge
          Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: rank <= 3
                  ? AppColors.primary.withValues(alpha: 0.1)
                  : AppColors.gray100,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              '#$rank',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: rank <= 3
                    ? AppColors.primary
                    : AppColors.textSecondaryLight,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Нэр + тоо
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.productName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textMainLight,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${product.totalQuantity} ширхэг',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textTertiaryLight,
                  ),
                ),
              ],
            ),
          ),
          // Орлого
          Text(
            '₮${numberFormat.format(product.totalRevenue)}',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.textMainLight,
            ),
          ),
        ],
      ),
    );
  }

  /// Шилжүүлгийн хураангуй
  Widget _buildTransferSummary(TransferSummary transfers) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.cardRadius,
        border: Border.all(color: AppColors.gray200),
      ),
      child: Row(
        children: [
          // Гарсан
          Expanded(
            child: Column(
              children: [
                const Icon(Icons.arrow_upward,
                    color: AppColors.danger, size: 24),
                const SizedBox(height: 4),
                Text(
                  '${transfers.outgoingCount} удаа',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textMainLight,
                  ),
                ),
                Text(
                  '${transfers.outgoingItems} бараа',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textTertiaryLight,
                  ),
                ),
                const Text(
                  'Гарсан',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),
          // Хуваагч
          Container(
            width: 1,
            height: 60,
            color: AppColors.gray200,
          ),
          // Орсон
          Expanded(
            child: Column(
              children: [
                const Icon(Icons.arrow_downward,
                    color: AppColors.success, size: 24),
                const SizedBox(height: 4),
                Text(
                  '${transfers.incomingCount} удаа',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textMainLight,
                  ),
                ),
                Text(
                  '${transfers.incomingItems} бараа',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textTertiaryLight,
                  ),
                ),
                const Text(
                  'Орсон',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Худалдагчийн item
  Widget _buildSellerItem(SellerSummary seller, NumberFormat numberFormat) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.cardRadius,
        border: Border.all(color: AppColors.gray200),
      ),
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.primary.withValues(alpha: 0.1),
            child: Text(
              seller.sellerName.isNotEmpty
                  ? seller.sellerName[0].toUpperCase()
                  : '?',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Нэр + гүйлгээ тоо
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  seller.sellerName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textMainLight,
                  ),
                ),
                Text(
                  '${seller.totalTransactions} гүйлгээ',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textTertiaryLight,
                  ),
                ),
              ],
            ),
          ),
          // Борлуулалт
          Text(
            '₮${numberFormat.format(seller.totalSales)}',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.textMainLight,
            ),
          ),
        ],
      ),
    );
  }
}
