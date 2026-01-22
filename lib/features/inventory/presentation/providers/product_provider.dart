import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:retail_control_platform/core/database/app_database.dart';
import 'package:retail_control_platform/features/inventory/domain/product_with_stock.dart';

part 'product_provider.g.dart';

/// Database provider (singleton)
@riverpod
AppDatabase database(DatabaseRef ref) {
  return AppDatabase();
}

/// Product list with optional filters
@riverpod
Future<List<ProductWithStock>> productList(
  ProductListRef ref, {
  String? searchQuery,
  String? category,
  String? storeId,
}) async {
  final db = ref.watch(databaseProvider);

  // TODO: Implement actual query using Drift
  // For now, return mock data for Phase 3
  // Will be replaced with real DB query in Phase 4

  // Example query (when Drift queries are ready):
  // final products = await db.select(db.products).get();
  // final stockLevels = await db.getStockLevels(...);
  // Join and map to ProductWithStock

  return _getMockProducts(
    searchQuery: searchQuery,
    category: category,
  );
}

/// Single product detail
@riverpod
Future<ProductWithStock?> productDetail(
  ProductDetailRef ref,
  String productId,
) async {
  final db = ref.watch(databaseProvider);

  // TODO: Implement actual query
  // final product = await db.select(db.products).get().where(...);
  // final stock = await db.getCurrentStock(productId);

  return _getMockProducts()
      .firstWhere((p) => p.id == productId, orElse: () => _getMockProducts().first);
}

/// Low stock products (for alerts)
@riverpod
Future<List<ProductWithStock>> lowStockProducts(
  LowStockProductsRef ref,
  String storeId,
) async {
  final db = ref.watch(databaseProvider);

  // TODO: Implement db.getLowStockProducts(storeId)

  return _getMockProducts()
      .where((p) => p.isLowStock)
      .toList();
}

/// Search products (debounced)
@riverpod
Future<List<ProductWithStock>> searchProducts(
  SearchProductsRef ref,
  String query,
) async {
  if (query.isEmpty) return [];

  final db = ref.watch(databaseProvider);

  // TODO: Implement full-text search
  // await db.searchProducts(query);

  return _getMockProducts()
      .where((p) =>
          p.name.toLowerCase().contains(query.toLowerCase()) ||
          p.sku.toLowerCase().contains(query.toLowerCase()))
      .toList();
}

/// Mock products for Phase 3 (will be replaced)
List<ProductWithStock> _getMockProducts({
  String? searchQuery,
  String? category,
}) {
  final mockProducts = [
    const ProductWithStock(
      id: '1',
      name: 'Coca Cola 1.5L',
      sku: 'COCA-1.5L',
      sellPrice: 2500,
      costPrice: 1800,
      stockQuantity: 45,
      isLowStock: false,
      storeId: 'store-1',
      category: 'Drinks',
      unit: 'л',
      lowStockThreshold: 10,
    ),
    const ProductWithStock(
      id: '2',
      name: 'Sprite 1.5L',
      sku: 'SPRITE-1.5L',
      sellPrice: 2500,
      costPrice: 1800,
      stockQuantity: 8,
      isLowStock: true,
      storeId: 'store-1',
      category: 'Drinks',
      unit: 'л',
      lowStockThreshold: 10,
    ),
    const ProductWithStock(
      id: '3',
      name: 'Сахар 1кг',
      sku: 'SUGAR-1KG',
      sellPrice: 3200,
      costPrice: 2500,
      stockQuantity: 120,
      isLowStock: false,
      storeId: 'store-1',
      category: 'Food',
      unit: 'кг',
      lowStockThreshold: 20,
    ),
    const ProductWithStock(
      id: '4',
      name: 'Гурил 1кг',
      sku: 'FLOUR-1KG',
      sellPrice: 2800,
      costPrice: 2200,
      stockQuantity: 5,
      isLowStock: true,
      storeId: 'store-1',
      category: 'Food',
      unit: 'кг',
      lowStockThreshold: 15,
    ),
    const ProductWithStock(
      id: '5',
      name: 'Ус 1.5L',
      sku: 'WATER-1.5L',
      sellPrice: 1200,
      costPrice: 800,
      stockQuantity: 200,
      isLowStock: false,
      storeId: 'store-1',
      category: 'Drinks',
      unit: 'л',
      lowStockThreshold: 50,
    ),
  ];

  var filtered = mockProducts;

  if (searchQuery != null && searchQuery.isNotEmpty) {
    filtered = filtered
        .where((p) =>
            p.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
            p.sku.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();
  }

  if (category != null && category.isNotEmpty) {
    filtered = filtered.where((p) => p.category == category).toList();
  }

  return filtered;
}
