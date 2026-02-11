import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:retail_control_platform/core/api/api_client.dart';
import 'package:retail_control_platform/core/api/api_endpoints.dart';
import 'package:retail_control_platform/features/auth/presentation/providers/auth_provider.dart';

part 'multi_store_dashboard_provider.g.dart';

/// Нэг дэлгүүрийн dashboard хураангуй мэдээлэл
class StoreDashboardSummary {
  final String storeId;
  final String storeName;
  final String? storeLocation;
  final String role;
  final double todayRevenue;
  final double todayCost;
  final double todayProfit;
  final double todayDiscount;
  final int todaySalesCount;
  final int lowStockCount;
  final List<ActiveSeller> activeSellers;

  const StoreDashboardSummary({
    required this.storeId,
    required this.storeName,
    this.storeLocation,
    required this.role,
    required this.todayRevenue,
    required this.todayCost,
    required this.todayProfit,
    required this.todayDiscount,
    required this.todaySalesCount,
    required this.lowStockCount,
    required this.activeSellers,
  });

  factory StoreDashboardSummary.fromJson(Map<String, dynamic> json) {
    return StoreDashboardSummary(
      storeId: json['store_id'] as String,
      storeName: json['store_name'] as String,
      storeLocation: json['store_location'] as String?,
      role: json['role'] as String,
      todayRevenue: (json['today_revenue'] as num).toDouble(),
      todayCost: (json['today_cost'] as num).toDouble(),
      todayProfit: (json['today_profit'] as num).toDouble(),
      todayDiscount: (json['today_discount'] as num).toDouble(),
      todaySalesCount: (json['today_sales_count'] as num).toInt(),
      lowStockCount: (json['low_stock_count'] as num).toInt(),
      activeSellers: (json['active_sellers'] as List?)
              ?.map((s) => ActiveSeller.fromJson(s as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  /// Ашгийн хувь
  int get profitMargin =>
      todayRevenue > 0 ? (todayProfit / todayRevenue * 100).round() : 0;
}

/// Идэвхтэй худалдагч
class ActiveSeller {
  final String id;
  final String name;

  const ActiveSeller({required this.id, required this.name});

  factory ActiveSeller.fromJson(Map<String, dynamic> json) {
    return ActiveSeller(
      id: json['id'] as String,
      name: json['name'] as String,
    );
  }
}

/// Multi-store нэгдсэн dashboard мэдээлэл (API-аас)
@riverpod
Future<List<StoreDashboardSummary>> multiStoreDashboard(
  MultiStoreDashboardRef ref,
) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];

  try {
    final response = await apiClient.get(
      ApiEndpoints.multiStoreDashboard(user.id),
    );

    if (response.statusCode == 200 && response.data['success'] == true) {
      final storesData = response.data['stores'] as List;
      return storesData
          .map((data) =>
              StoreDashboardSummary.fromJson(data as Map<String, dynamic>))
          .toList();
    }
    return [];
  } catch (e) {
    // Алдааг rethrow хийж AsyncValue.error() харагдахаар болгох
    throw Exception('Dashboard мэдээлэл авахад алдаа гарлаа: $e');
  }
}
