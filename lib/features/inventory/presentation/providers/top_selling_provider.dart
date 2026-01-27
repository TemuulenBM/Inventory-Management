/// Top-Selling Products Provider
///
/// "Онцлох" tab-д харуулах борлуулалт их бараануудын ID жагсаалт.
/// Бүх цагийн (all-time) борлуулалт дээр үндэслэнэ.
library;

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:retail_control_platform/core/providers/store_provider.dart';
import 'package:retail_control_platform/features/inventory/presentation/providers/product_provider.dart';

part 'top_selling_provider.g.dart';

/// Top-selling product IDs (all-time sales)
///
/// Returns: Product IDs-ийн жагсаалт, борлуулалтын дарааллаар (desc)
/// Empty list: Sales data байхгүй бол
@riverpod
Future<List<String>> topSellingProductIds(TopSellingProductIdsRef ref) async {
  final db = ref.watch(databaseProvider);
  final storeId = ref.watch(requireStoreIdProvider);

  final results = await db.getTopSellingProducts(
    storeId,
    limit: 100, // Top 100 авах (бараа олон үед хангалттай)
    dateRange: 'all', // Бүх цагийн борлуулалт
  );

  // Product IDs л буцаана (name, quantity бусад мэдээлэл хэрэггүй)
  return results.map((r) => r['id'] as String).toList();
}
