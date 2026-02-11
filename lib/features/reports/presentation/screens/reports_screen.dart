import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:retail_control_platform/core/constants/app_colors.dart';
import 'package:retail_control_platform/core/constants/app_spacing.dart';
import 'package:retail_control_platform/core/constants/app_radius.dart';
import 'package:retail_control_platform/features/auth/presentation/providers/auth_provider.dart';
import 'package:retail_control_platform/features/reports/domain/report_models.dart';
import 'package:retail_control_platform/features/reports/presentation/providers/report_provider.dart';

/// Тайлангийн дэлгэц — 3 tab (Борлуулалт, Бараа, Ашиг)
/// Backend-ын reports endpoint-уудаас бодит data татаж харуулна.
class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundLight,
        elevation: 0,
        title: const Text(
          'Тайлан',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.textMainLight,
          ),
        ),
        centerTitle: false,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondaryLight,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          labelStyle:
              const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          unselectedLabelStyle:
              const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          tabs: const [
            Tab(text: 'Борлуулалт'),
            Tab(text: 'Бараа'),
            Tab(text: 'Ашиг'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Огнооны filter — бүх tab-д хамаарна
          _buildDateFilter(),

          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                _SalesTab(),
                _ProductsTab(),
                _ProfitTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Огнооны filter chip-ууд (Өнөөдөр / 7 хоног / 30 хоног / Сонгох)
  Widget _buildDateFilter() {
    final dateRange = ref.watch(selectedDateRangeProvider);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: AppColors.backgroundLight,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterChip(
                'Өнөөдөр', ReportDateRange.today, dateRange.range),
            const SizedBox(width: 8),
            _buildFilterChip(
                '7 хоног', ReportDateRange.week, dateRange.range),
            const SizedBox(width: 8),
            _buildFilterChip(
                '30 хоног', ReportDateRange.month, dateRange.range),
            const SizedBox(width: 8),
            _buildFilterChip(
                'Сонгох', ReportDateRange.custom, dateRange.range),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(
      String label, ReportDateRange range, ReportDateRange selected) {
    final isSelected = range == selected;
    return GestureDetector(
      onTap: () async {
        if (range == ReportDateRange.custom) {
          await _showDateRangePicker();
        } else {
          ref.read(selectedDateRangeProvider.notifier).setRange(range);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.gray300,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : AppColors.textSecondaryLight,
          ),
        ),
      ),
    );
  }

  /// Custom огнооны хүрээ сонгох
  Future<void> _showDateRangePicker() async {
    final now = DateTime.now();
    final result = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 1),
      lastDate: now,
      locale: const Locale('mn'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (result != null) {
      ref
          .read(selectedDateRangeProvider.notifier)
          .setCustomRange(result.start, result.end);
    }
  }
}

// ============================================================
// Tab 1: Борлуулалт
// ============================================================
class _SalesTab extends ConsumerWidget {
  const _SalesTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dailyAsync = ref.watch(dailyReportProvider);
    final numberFormat = NumberFormat('#,###', 'mn');

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(dailyReportProvider);
      },
      color: AppColors.primary,
      child: dailyAsync.when(
        data: (report) {
          if (report == null) return _buildEmptyState('Борлуулалтын мэдээлэл байхгүй');
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Хураангуй KPI card
                _buildSummaryCard(report, numberFormat),
                AppSpacing.verticalMD,

                // Төлбөрийн хэлбэрийн задаргаа
                if (report.paymentMethods.isNotEmpty) ...[
                  _buildSectionTitle('Төлбөрийн хэлбэр'),
                  AppSpacing.verticalSM,
                  _buildPaymentMethodsCard(report.paymentMethods, numberFormat),
                  AppSpacing.verticalMD,
                ],

                // Цагаар задаргаа (bar chart)
                if (report.hourlyBreakdown.isNotEmpty) ...[
                  _buildSectionTitle('Цагаар задаргаа'),
                  AppSpacing.verticalSM,
                  _buildHourlyChart(report.hourlyBreakdown, numberFormat),
                ],

                AppSpacing.verticalXL,
              ],
            ),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (error, _) => _buildErrorState(
          'Мэдээлэл ачаалахад алдаа гарлаа',
          () => ref.invalidate(dailyReportProvider),
        ),
      ),
    );
  }

  /// Борлуулалтын хураангуй KPI card
  Widget _buildSummaryCard(DailyReport report, NumberFormat numberFormat) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFC2755B), Color(0xFFA8644D)],
        ),
        borderRadius: AppRadius.cardRadius,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Нийт борлуулалт',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '₮${numberFormat.format(report.totalSales.toInt())}',
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          AppSpacing.verticalMD,
          Row(
            children: [
              _buildKpiItem(
                Icons.receipt_long_outlined,
                '${report.totalSalesCount}',
                'Гүйлгээ',
              ),
              const SizedBox(width: 24),
              _buildKpiItem(
                Icons.shopping_bag_outlined,
                '${report.totalItemsSold}',
                'Бараа',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKpiItem(IconData icon, String value, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: Colors.white70),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: Colors.white60,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Төлбөрийн хэлбэрийн задаргаа
  Widget _buildPaymentMethodsCard(
      List<PaymentMethodBreakdown> methods, NumberFormat numberFormat) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.cardRadius,
        border: Border.all(color: AppColors.gray200),
      ),
      child: Column(
        children: methods.map((method) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: _paymentMethodColor(method.method)
                        .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _paymentMethodIcon(method.method),
                    size: 18,
                    color: _paymentMethodColor(method.method),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        method.displayName,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textMainLight,
                        ),
                      ),
                      Text(
                        '${method.count} гүйлгээ',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '₮${numberFormat.format(method.amount.toInt())}',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textMainLight,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  /// Цагаар задаргаа (simple bar chart)
  Widget _buildHourlyChart(
      List<HourlyBreakdown> hourly, NumberFormat numberFormat) {
    // Зөвхөн борлуулалт болсон цагуудыг шүүнэ
    final activeHours = hourly.where((h) => h.sales > 0).toList();
    if (activeHours.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: AppRadius.cardRadius,
          border: Border.all(color: AppColors.gray200),
        ),
        child: const Center(
          child: Text(
            'Цагийн мэдээлэл байхгүй',
            style: TextStyle(color: AppColors.textSecondaryLight),
          ),
        ),
      );
    }

    final maxSales =
        activeHours.map((h) => h.sales).reduce((a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.cardRadius,
        border: Border.all(color: AppColors.gray200),
      ),
      child: Column(
        children: activeHours.map((h) {
          final ratio = maxSales > 0 ? h.sales / maxSales : 0.0;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                SizedBox(
                  width: 44,
                  child: Text(
                    '${h.hour.toString().padLeft(2, '0')}:00',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondaryLight,
                    ),
                  ),
                ),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: ratio,
                      minHeight: 20,
                      backgroundColor: AppColors.gray100,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.primary),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 70,
                  child: Text(
                    '₮${numberFormat.format(h.sales.toInt())}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textMainLight,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Color _paymentMethodColor(String method) {
    switch (method) {
      case 'cash':
        return const Color(0xFF2E7D32);
      case 'card':
        return const Color(0xFF1565C0);
      case 'qpay':
        return const Color(0xFF7B1FA2);
      default:
        return AppColors.gray600;
    }
  }

  IconData _paymentMethodIcon(String method) {
    switch (method) {
      case 'cash':
        return Icons.payments_outlined;
      case 'card':
        return Icons.credit_card_outlined;
      case 'qpay':
        return Icons.qr_code_2;
      default:
        return Icons.payment_outlined;
    }
  }
}

// ============================================================
// Tab 2: Бараа (Шилдэг + Муу зарагддаг)
// ============================================================
class _ProductsTab extends ConsumerWidget {
  const _ProductsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final topProductsAsync = ref.watch(topProductsReportProvider);
    final slowMovingAsync = ref.watch(slowMovingProductsProvider);
    final numberFormat = NumberFormat('#,###', 'mn');

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(topProductsReportProvider);
        ref.invalidate(slowMovingProductsProvider);
      },
      color: AppColors.primary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Шилдэг бараа section
            _buildSectionTitle('Шилдэг бараа'),
            AppSpacing.verticalSM,
            topProductsAsync.when(
              data: (products) {
                if (products.isEmpty) {
                  return _buildEmptyCard('Борлуулалтын мэдээлэл байхгүй');
                }
                return _buildTopProductsList(products, numberFormat);
              },
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child:
                      CircularProgressIndicator(color: AppColors.primary),
                ),
              ),
              error: (_, __) => _buildErrorCard(
                'Ачаалахад алдаа гарлаа',
                () => ref.invalidate(topProductsReportProvider),
              ),
            ),

            AppSpacing.verticalLG,

            // Муу зарагддаг бараа section
            _buildSectionTitle('Муу зарагддаг бараа'),
            const SizedBox(height: 4),
            const Text(
              'Сүүлийн 30 хоногт 3-аас бага зарагдсан',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondaryLight,
              ),
            ),
            AppSpacing.verticalSM,
            slowMovingAsync.when(
              data: (products) {
                if (products.isEmpty) {
                  return _buildEmptyCard(
                      'Муу зарагддаг бараа байхгүй — сайн дээ!');
                }
                return _buildSlowMovingList(products, numberFormat);
              },
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child:
                      CircularProgressIndicator(color: AppColors.primary),
                ),
              ),
              error: (_, __) => _buildErrorCard(
                'Ачаалахад алдаа гарлаа',
                () => ref.invalidate(slowMovingProductsProvider),
              ),
            ),

            AppSpacing.verticalXL,
          ],
        ),
      ),
    );
  }

  /// Шилдэг барааны жагсаалт (rank, нэр, тоо, орлого)
  Widget _buildTopProductsList(
      List<TopProductReport> products, NumberFormat numberFormat) {
    return Column(
      children: products.asMap().entries.map((entry) {
        final index = entry.key;
        final product = entry.value;
        final rank = index + 1;

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: AppRadius.cardRadius,
            border: Border.all(color: AppColors.gray200),
          ),
          child: Row(
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
              const SizedBox(width: 12),
              // Барааны нэр + зарагдсан тоо
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
                      '${product.totalQuantity} ширхэг • ${product.salesCount} удаа',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
              ),
              // Орлого
              Text(
                '₮${numberFormat.format(product.totalRevenue.toInt())}',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  /// Муу зарагддаг барааны жагсаалт
  Widget _buildSlowMovingList(
      List<SlowMovingProduct> products, NumberFormat numberFormat) {
    return Column(
      children: products.map((product) {
        // Сүүлд хэзээ зарагдсаныг тооцоолох
        String lastSoldText = 'Огт зарагдаагүй';
        if (product.lastSoldAt != null) {
          final lastSold = DateTime.tryParse(product.lastSoldAt!);
          if (lastSold != null) {
            final daysAgo = DateTime.now().difference(lastSold).inDays;
            lastSoldText = '$daysAgo хоногийн өмнө';
          }
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: AppRadius.cardRadius,
            border: Border.all(
              color: AppColors.warning.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              // Warning icon
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.trending_down,
                  size: 18,
                  color: AppColors.warning,
                ),
              ),
              const SizedBox(width: 12),
              // Мэдээлэл
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textMainLight,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'Үлдэгдэл: ${product.stockQuantity} • Зарсан: ${product.soldQuantity}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondaryLight,
                      ),
                    ),
                    Text(
                      lastSoldText,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.warning,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              // Хөлдсөн cost
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '₮${numberFormat.format(product.costValue.toInt())}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.danger,
                    ),
                  ),
                  const Text(
                    'хөлдсөн',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Color _rankColor(int rank) {
    switch (rank) {
      case 1:
        return const Color(0xFFFFB800);
      case 2:
        return const Color(0xFF8E8E93);
      case 3:
        return const Color(0xFFCD7F32);
      default:
        return AppColors.textSecondaryLight;
    }
  }
}

// ============================================================
// Tab 3: Ашиг (зөвхөн owner)
// ============================================================
class _ProfitTab extends ConsumerWidget {
  const _ProfitTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Role шалгах — ашгийн тайлан зөвхөн owner-д
    final user = ref.watch(currentUserProvider);
    final isOwner = user?.role == 'owner';

    if (!isOwner) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock_outline, size: 64, color: AppColors.gray300),
            AppSpacing.verticalMD,
            const Text(
              'Зөвхөн эзэмшигч харах боломжтой',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondaryLight,
              ),
            ),
            AppSpacing.verticalSM,
            const Text(
              'Ашгийн тайлан нь зөвхөн дэлгүүрийн\nэзэмшигчид харагдана',
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

    final profitAsync = ref.watch(profitReportProvider);
    final numberFormat = NumberFormat('#,###', 'mn');

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(profitReportProvider);
      },
      color: AppColors.primary,
      child: profitAsync.when(
        data: (report) {
          if (report == null) {
            return _buildEmptyState('Ашгийн мэдээлэл байхгүй');
          }
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Ашгийн hero card
                _buildProfitHeroCard(report, numberFormat),
                AppSpacing.verticalMD,

                // Задаргаа (Орлого, Өртөг, Хөнгөлөлт)
                _buildBreakdownRow(report, numberFormat),
                AppSpacing.verticalLG,

                // Бараагаар задаргаа
                if (report.byProduct.isNotEmpty) ...[
                  _buildSectionTitle('Бараагаар задаргаа'),
                  AppSpacing.verticalSM,
                  _buildProductProfitList(report.byProduct, numberFormat),
                ],

                AppSpacing.verticalXL,
              ],
            ),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (error, _) => _buildErrorState(
          'Ашгийн тайлан ачаалахад алдаа гарлаа',
          () => ref.invalidate(profitReportProvider),
        ),
      ),
    );
  }

  /// Ашгийн hero card — цэвэр ашиг + margin
  Widget _buildProfitHeroCard(ProfitReport report, NumberFormat numberFormat) {
    final isPositive = report.grossProfit >= 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isPositive
              ? [const Color(0xFF00878F), const Color(0xFF006B72)]
              : [const Color(0xFFAF4D4D), const Color(0xFF8B3A3A)],
        ),
        borderRadius: AppRadius.cardRadius,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Цэвэр ашиг',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '₮${numberFormat.format(report.grossProfit.toInt())}',
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Margin: ${report.profitMargin.toStringAsFixed(1)}%',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Задаргаа: Орлого, Өртөг, Хөнгөлөлт — 3 mini card
  Widget _buildBreakdownRow(ProfitReport report, NumberFormat numberFormat) {
    return Row(
      children: [
        Expanded(
          child: _buildMiniCard(
            'Орлого',
            '₮${_shortFormat(report.totalRevenue)}',
            Icons.trending_up,
            AppColors.secondary,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildMiniCard(
            'Өртөг',
            '₮${_shortFormat(report.totalCost)}',
            Icons.receipt_outlined,
            AppColors.warning,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildMiniCard(
            'Хөнгөлөлт',
            '₮${_shortFormat(report.totalDiscount)}',
            Icons.local_offer_outlined,
            AppColors.danger,
          ),
        ),
      ],
    );
  }

  Widget _buildMiniCard(
      String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.cardRadius,
        border: Border.all(color: AppColors.gray200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textMainLight,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }

  /// Бараагаар задалсан ашгийн жагсаалт
  Widget _buildProductProfitList(
      List<ProductProfit> products, NumberFormat numberFormat) {
    return Column(
      children: products.map((product) {
        final isPositive = product.profit >= 0;

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: AppRadius.cardRadius,
            border: Border.all(color: AppColors.gray200),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textMainLight,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '${product.quantity} ширхэг • Margin: ${product.margin.toStringAsFixed(0)}%',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '₮${numberFormat.format(product.profit.toInt())}',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: isPositive
                      ? const Color(0xFF2E7D32)
                      : AppColors.danger,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  /// Тоо товчлох (1,500,000 → 1.5сая)
  String _shortFormat(double value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}сая';
    }
    if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(0)}мян';
    }
    return value.toStringAsFixed(0);
  }
}

// ============================================================
// Shared helper widgets
// ============================================================
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

Widget _buildEmptyState(String message) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.bar_chart_outlined, size: 64, color: AppColors.gray300),
        AppSpacing.verticalMD,
        Text(
          message,
          style: const TextStyle(
            fontSize: 15,
            color: AppColors.textSecondaryLight,
          ),
        ),
      ],
    ),
  );
}

Widget _buildErrorState(String message, VoidCallback onRetry) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.error_outline, size: 48, color: AppColors.danger),
        AppSpacing.verticalMD,
        Text(
          message,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textMainLight,
          ),
        ),
        AppSpacing.verticalSM,
        TextButton(
          onPressed: onRetry,
          child: const Text('Дахин оролдох'),
        ),
      ],
    ),
  );
}

Widget _buildEmptyCard(String message) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: AppRadius.cardRadius,
      border: Border.all(color: AppColors.gray200),
    ),
    child: Center(
      child: Text(
        message,
        style: const TextStyle(
          fontSize: 13,
          color: AppColors.textSecondaryLight,
        ),
      ),
    ),
  );
}

Widget _buildErrorCard(String message, VoidCallback onRetry) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.errorBackground,
      borderRadius: AppRadius.cardRadius,
    ),
    child: Column(
      children: [
        Text(
          message,
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.textMainLight,
          ),
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: onRetry,
          child: const Text('Дахин оролдох'),
        ),
      ],
    ),
  );
}
