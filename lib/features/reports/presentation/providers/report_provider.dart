import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:retail_control_platform/core/api/api_client.dart';
import 'package:retail_control_platform/core/api/api_endpoints.dart';
import 'package:retail_control_platform/core/providers/store_provider.dart';
import 'package:retail_control_platform/features/reports/domain/report_models.dart';

part 'report_provider.g.dart';

/// Огноо filter-ийн хамрах хүрээ
enum ReportDateRange { today, week, month, custom }

/// Сонгогдсон огнооны хүрээ — бүх тайлангийн tab-д хамаарна
/// Riverpod reactive: огноо солигдоход бүх provider автоматаар refresh болно
@riverpod
class SelectedDateRange extends _$SelectedDateRange {
  @override
  ({ReportDateRange range, DateTime from, DateTime to}) build() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return (
      range: ReportDateRange.month,
      from: today.subtract(const Duration(days: 30)),
      to: today,
    );
  }

  /// Preset огнооны хүрээ сонгох (Өнөөдөр / 7 хоног / 30 хоног)
  void setRange(ReportDateRange range) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    switch (range) {
      case ReportDateRange.today:
        state = (range: range, from: today, to: today);
      case ReportDateRange.week:
        state = (
          range: range,
          from: today.subtract(const Duration(days: 7)),
          to: today,
        );
      case ReportDateRange.month:
        state = (
          range: range,
          from: today.subtract(const Duration(days: 30)),
          to: today,
        );
      case ReportDateRange.custom:
        break; // Custom-д setCustomRange ашиглана
    }
  }

  /// Custom огнооны хүрээ (date picker-ээс)
  void setCustomRange(DateTime from, DateTime to) {
    state = (range: ReportDateRange.custom, from: from, to: to);
  }
}

/// Огноог YYYY-MM-DD формат руу хөрвүүлэх helper
String _formatDate(DateTime date) {
  return '${date.year}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';
}

/// Өдрийн борлуулалтын тайлан (Tab 1: Борлуулалт)
@riverpod
Future<DailyReport?> dailyReport(DailyReportRef ref) async {
  final storeId = ref.watch(storeIdProvider);
  if (storeId == null) return null;

  final dateRange = ref.watch(selectedDateRangeProvider);
  final dateStr = _formatDate(dateRange.to);

  try {
    final response = await apiClient.get(
      ApiEndpoints.dailyReport(storeId),
      queryParameters: {'date': dateStr},
    );

    if (response.statusCode == 200 && response.data['success'] == true) {
      return DailyReport.fromJson(
          response.data['report'] as Map<String, dynamic>);
    }
    return null;
  } catch (e) {
    rethrow;
  }
}

/// Шилдэг борлуулалттай бараа (Tab 2: Бараа)
@riverpod
Future<List<TopProductReport>> topProductsReport(
    TopProductsReportRef ref) async {
  final storeId = ref.watch(storeIdProvider);
  if (storeId == null) return [];

  final dateRange = ref.watch(selectedDateRangeProvider);

  try {
    final response = await apiClient.get(
      ApiEndpoints.topProductsReport(storeId),
      queryParameters: {
        'from': dateRange.from.toIso8601String(),
        'to': dateRange.to.toIso8601String(),
        'limit': '10',
      },
    );

    if (response.statusCode == 200 && response.data['success'] == true) {
      final productsData = response.data['products'] as List;
      return productsData
          .map((data) =>
              TopProductReport.fromJson(data as Map<String, dynamic>))
          .toList();
    }
    return [];
  } catch (e) {
    rethrow;
  }
}

/// Ашгийн тайлан (Tab 3: Ашиг — зөвхөн owner)
@riverpod
Future<ProfitReport?> profitReport(ProfitReportRef ref) async {
  final storeId = ref.watch(storeIdProvider);
  if (storeId == null) return null;

  final dateRange = ref.watch(selectedDateRangeProvider);

  try {
    final response = await apiClient.get(
      ApiEndpoints.profitReport(storeId),
      queryParameters: {
        'startDate': _formatDate(dateRange.from),
        'endDate': _formatDate(dateRange.to),
      },
    );

    if (response.statusCode == 200 && response.data['success'] == true) {
      return ProfitReport.fromJson(
          response.data['report'] as Map<String, dynamic>);
    }
    return null;
  } catch (e) {
    rethrow;
  }
}

/// Сарын тайлангийн сонгогдсон сар (YYYY-MM format)
@riverpod
class SelectedMonth extends _$SelectedMonth {
  @override
  String build() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}';
  }

  void setMonth(String month) => state = month;

  /// Өмнөх сар руу шилжих
  void previousMonth() {
    final parts = state.split('-');
    var year = int.parse(parts[0]);
    var month = int.parse(parts[1]);
    month--;
    if (month < 1) {
      month = 12;
      year--;
    }
    state = '$year-${month.toString().padLeft(2, '0')}';
  }

  /// Дараагийн сар руу шилжих
  void nextMonth() {
    final now = DateTime.now();
    final parts = state.split('-');
    var year = int.parse(parts[0]);
    var month = int.parse(parts[1]);
    month++;
    if (month > 12) {
      month = 1;
      year++;
    }
    // Ирээдүйн сар руу шилжихгүй
    if (year > now.year || (year == now.year && month > now.month)) return;
    state = '$year-${month.toString().padLeft(2, '0')}';
  }
}

/// Сарын нэгдсэн тайлан — бүх KPI нэг дэлгэцэд
@riverpod
Future<MonthlyReport?> monthlyReport(MonthlyReportRef ref) async {
  final storeId = ref.watch(storeIdProvider);
  if (storeId == null) return null;

  final month = ref.watch(selectedMonthProvider);

  try {
    final response = await apiClient.get(
      ApiEndpoints.monthlyReport(storeId),
      queryParameters: {'month': month},
    );

    if (response.statusCode == 200 && response.data['success'] == true) {
      return MonthlyReport.fromJson(
          response.data['report'] as Map<String, dynamic>);
    }
    return null;
  } catch (e) {
    rethrow;
  }
}

/// Категори аналитик (Tab 4: Категори)
/// Категори тус бүрийн борлуулалт, ашиг, тоо хэмжээний задаргаа
@riverpod
Future<List<CategoryReport>> categoryReport(CategoryReportRef ref) async {
  final storeId = ref.watch(storeIdProvider);
  if (storeId == null) return [];

  final dateRange = ref.watch(selectedDateRangeProvider);

  try {
    final response = await apiClient.get(
      ApiEndpoints.categoryReport(storeId),
      queryParameters: {
        'from': dateRange.from.toIso8601String(),
        'to': dateRange.to.toIso8601String(),
      },
    );

    if (response.statusCode == 200 && response.data['success'] == true) {
      final categoriesData = response.data['categories'] as List;
      return categoriesData
          .map((data) =>
              CategoryReport.fromJson(data as Map<String, dynamic>))
          .toList();
    }
    return [];
  } catch (e) {
    rethrow;
  }
}

/// Муу зарагддаг бараа (Tab 2: Бараа)
@riverpod
Future<List<SlowMovingProduct>> slowMovingProducts(
    SlowMovingProductsRef ref) async {
  final storeId = ref.watch(storeIdProvider);
  if (storeId == null) return [];

  try {
    final response = await apiClient.get(
      ApiEndpoints.slowMovingReport(storeId),
      queryParameters: {
        'days': '30',
        'maxSold': '3',
      },
    );

    if (response.statusCode == 200 && response.data['success'] == true) {
      final productsData = response.data['products'] as List;
      return productsData
          .map((data) =>
              SlowMovingProduct.fromJson(data as Map<String, dynamic>))
          .toList();
    }
    return [];
  } catch (e) {
    rethrow;
  }
}
