// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'report_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$dailyReportHash() => r'ddd5e0c0d80d940eea1ecbcd97dd7dbf34f580ff';

/// Өдрийн борлуулалтын тайлан (Tab 1: Борлуулалт)
///
/// Copied from [dailyReport].
@ProviderFor(dailyReport)
final dailyReportProvider = AutoDisposeFutureProvider<DailyReport?>.internal(
  dailyReport,
  name: r'dailyReportProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$dailyReportHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef DailyReportRef = AutoDisposeFutureProviderRef<DailyReport?>;
String _$topProductsReportHash() => r'88511812054d11de55d89fb45239ce6a76ba0abc';

/// Шилдэг борлуулалттай бараа (Tab 2: Бараа)
///
/// Copied from [topProductsReport].
@ProviderFor(topProductsReport)
final topProductsReportProvider =
    AutoDisposeFutureProvider<List<TopProductReport>>.internal(
  topProductsReport,
  name: r'topProductsReportProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$topProductsReportHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef TopProductsReportRef
    = AutoDisposeFutureProviderRef<List<TopProductReport>>;
String _$profitReportHash() => r'ecbaa9912e5a1534de84ed2cb53d9508ed74fddc';

/// Ашгийн тайлан (Tab 3: Ашиг — зөвхөн owner)
///
/// Copied from [profitReport].
@ProviderFor(profitReport)
final profitReportProvider = AutoDisposeFutureProvider<ProfitReport?>.internal(
  profitReport,
  name: r'profitReportProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$profitReportHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef ProfitReportRef = AutoDisposeFutureProviderRef<ProfitReport?>;
String _$monthlyReportHash() => r'13d89526694e9d0ea1db2cdcaaaba0b99d88560b';

/// Сарын нэгдсэн тайлан — бүх KPI нэг дэлгэцэд
///
/// Copied from [monthlyReport].
@ProviderFor(monthlyReport)
final monthlyReportProvider =
    AutoDisposeFutureProvider<MonthlyReport?>.internal(
  monthlyReport,
  name: r'monthlyReportProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$monthlyReportHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef MonthlyReportRef = AutoDisposeFutureProviderRef<MonthlyReport?>;
String _$categoryReportHash() => r'dca2af647177b61da2a9899582b1171896431096';

/// Категори аналитик (Tab 4: Категори)
/// Категори тус бүрийн борлуулалт, ашиг, тоо хэмжээний задаргаа
///
/// Copied from [categoryReport].
@ProviderFor(categoryReport)
final categoryReportProvider =
    AutoDisposeFutureProvider<List<CategoryReport>>.internal(
  categoryReport,
  name: r'categoryReportProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$categoryReportHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef CategoryReportRef = AutoDisposeFutureProviderRef<List<CategoryReport>>;
String _$slowMovingProductsHash() =>
    r'c25768914eff5efd9bb45ebfd5acd1133bbb1aae';

/// Муу зарагддаг бараа (Tab 2: Бараа)
///
/// Copied from [slowMovingProducts].
@ProviderFor(slowMovingProducts)
final slowMovingProductsProvider =
    AutoDisposeFutureProvider<List<SlowMovingProduct>>.internal(
  slowMovingProducts,
  name: r'slowMovingProductsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$slowMovingProductsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef SlowMovingProductsRef
    = AutoDisposeFutureProviderRef<List<SlowMovingProduct>>;
String _$selectedDateRangeHash() => r'2f15e9dad7294e48de241b3a56af1a2946519a26';

/// Сонгогдсон огнооны хүрээ — бүх тайлангийн tab-д хамаарна
/// Riverpod reactive: огноо солигдоход бүх provider автоматаар refresh болно
///
/// Copied from [SelectedDateRange].
@ProviderFor(SelectedDateRange)
final selectedDateRangeProvider = AutoDisposeNotifierProvider<SelectedDateRange,
    ({ReportDateRange range, DateTime from, DateTime to})>.internal(
  SelectedDateRange.new,
  name: r'selectedDateRangeProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$selectedDateRangeHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SelectedDateRange = AutoDisposeNotifier<
    ({ReportDateRange range, DateTime from, DateTime to})>;
String _$selectedMonthHash() => r'482f2a81c8f43e960e22bdf3274acc379ee60552';

/// Сарын тайлангийн сонгогдсон сар (YYYY-MM format)
///
/// Copied from [SelectedMonth].
@ProviderFor(SelectedMonth)
final selectedMonthProvider =
    AutoDisposeNotifierProvider<SelectedMonth, String>.internal(
  SelectedMonth.new,
  name: r'selectedMonthProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$selectedMonthHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SelectedMonth = AutoDisposeNotifier<String>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
