import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:retail_control_platform/core/api/api_client.dart';
import 'package:retail_control_platform/core/api/api_endpoints.dart';
import 'package:retail_control_platform/core/providers/store_provider.dart';

part 'seller_performance_provider.g.dart';

/// Худалдагчийн гүйцэтгэлийн мэдээлэл
class SellerPerformance {
  final String sellerId;
  final String sellerName;
  final double totalSales;
  final int totalSalesCount;
  final int totalItemsSold;
  final double averageSale;
  final int shiftsCount;
  /// Мөнгөн тулгалтын нийт зөрүү (абсолют утга)
  final double totalDiscrepancy;
  /// Зөрүүтэй ээлжийн тоо (₮5,000-с дээш)
  final int discrepancyCount;
  /// Нийт хөнгөлөлт өгсөн дүн
  final double totalDiscountGiven;

  const SellerPerformance({
    required this.sellerId,
    required this.sellerName,
    required this.totalSales,
    required this.totalSalesCount,
    required this.totalItemsSold,
    required this.averageSale,
    required this.shiftsCount,
    this.totalDiscrepancy = 0,
    this.discrepancyCount = 0,
    this.totalDiscountGiven = 0,
  });

  factory SellerPerformance.fromJson(Map<String, dynamic> json) {
    return SellerPerformance(
      sellerId: json['seller_id'] as String,
      sellerName: json['seller_name'] as String,
      totalSales: (json['total_sales'] as num).toDouble(),
      totalSalesCount: (json['total_sales_count'] as num).toInt(),
      totalItemsSold: (json['total_items_sold'] as num?)?.toInt() ?? 0,
      averageSale: (json['average_sale'] as num?)?.toDouble() ?? 0,
      shiftsCount: (json['shifts_count'] as num?)?.toInt() ?? 0,
      totalDiscrepancy: (json['total_discrepancy'] as num?)?.toDouble() ?? 0,
      discrepancyCount: (json['discrepancy_count'] as num?)?.toInt() ?? 0,
      totalDiscountGiven: (json['total_discount_given'] as num?)?.toDouble() ?? 0,
    );
  }

  /// Мөнгөн зөрүү байгаа эсэх
  bool get hasDiscrepancyIssues => discrepancyCount > 0;
}

/// Худалдагчдын гүйцэтгэлийн жагсаалт (API-аас)
@riverpod
Future<List<SellerPerformance>> sellerPerformanceList(
  SellerPerformanceListRef ref,
) async {
  final storeId = ref.watch(storeIdProvider);
  if (storeId == null) return [];

  try {
    final response = await apiClient.get(
      ApiEndpoints.sellerPerformance(storeId),
    );

    if (response.statusCode == 200 && response.data['success'] == true) {
      final sellersData = response.data['sellers'] as List;
      return sellersData
          .map((data) => SellerPerformance.fromJson(data as Map<String, dynamic>))
          .toList();
    }
    return [];
  } catch (e) {
    // Error-г дамжуулж, UI дээр error state харуулах
    rethrow;
  }
}
