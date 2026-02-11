import 'dart:io';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:retail_control_platform/core/api/api_result.dart';
import 'package:retail_control_platform/core/database/app_database.dart';
import 'package:retail_control_platform/core/providers/store_provider.dart';
import 'package:retail_control_platform/core/providers/admin_browse_provider.dart';
import 'package:retail_control_platform/core/services/product_service.dart';
import 'package:retail_control_platform/features/inventory/domain/product_with_stock.dart';

part 'product_provider.g.dart';

/// Database provider (singleton)
@riverpod
AppDatabase database(DatabaseRef ref) {
  return AppDatabase();
}

/// ProductService provider
@riverpod
ProductService productService(ProductServiceRef ref) {
  final db = ref.watch(databaseProvider);
  return ProductService(db: db);
}

/// Product list with optional filters
/// Offline-first: Local DB эхлээд, background-д API refresh
@riverpod
Future<List<ProductWithStock>> productList(
  ProductListRef ref, {
  String? searchQuery,
  String? category,
}) async {
  // Super-admin browse mode-д effectiveStoreId ашиглана
  final storeId = ref.watch(effectiveStoreIdProvider);
  if (storeId == null) {
    return [];
  }

  final service = ref.watch(productServiceProvider);
  final result = await service.getProducts(
    storeId,
    searchQuery: searchQuery,
    category: category,
  );

  return result.when(
    success: (products) => products,
    error: (message, statusCode, _) {
      throw Exception(message);
    },
  );
}

/// Single product detail
@riverpod
Future<ProductWithStock?> productDetail(
  ProductDetailRef ref,
  String productId,
) async {
  final storeId = ref.watch(storeIdProvider);
  if (storeId == null) return null;

  final service = ref.watch(productServiceProvider);
  final result = await service.getProduct(storeId, productId);

  return result.when(
    success: (product) => product,
    error: (_, __, ___) => null,
  );
}

/// Low stock products (for alerts)
@riverpod
Future<List<ProductWithStock>> lowStockProducts(
  LowStockProductsRef ref,
  String storeId,
) async {
  final service = ref.watch(productServiceProvider);
  final result = await service.getLowStockProducts(storeId);

  return result.when(
    success: (products) => products,
    error: (_, __, ___) => [],
  );
}

/// Search products (debounced)
@riverpod
Future<List<ProductWithStock>> searchProducts(
  SearchProductsRef ref,
  String query,
) async {
  if (query.isEmpty) return [];

  final storeId = ref.watch(storeIdProvider);
  if (storeId == null) return [];

  final service = ref.watch(productServiceProvider);
  final result = await service.searchProducts(storeId, query);

  return result.when(
    success: (products) => products,
    error: (_, __, ___) => [],
  );
}

/// Product actions (create, update, delete)
@riverpod
class ProductActions extends _$ProductActions {
  @override
  FutureOr<void> build() {}

  /// Шинэ бараа нэмэх
  /// Амжилттай бол productId буцаана, амжилтгүй бол null
  Future<String?> createProduct({
    required String name,
    required String sku,
    required String unit,
    required int sellPrice,
    int? costPrice,
    int? lowStockThreshold,
    int? initialStock,
    String? category, // Барааны ангилал
    File? imageFile,
  }) async {
    state = const AsyncValue.loading();

    final storeId = ref.read(storeIdProvider);
    final userId = ref.read(currentUserIdProvider);

    if (storeId == null || userId == null) {
      state = AsyncValue.error('Хэрэглэгч нэвтрээгүй байна', StackTrace.current);
      return null;
    }

    final service = ref.read(productServiceProvider);
    final result = await service.createProduct(
      storeId,
      userId,
      name: name,
      sku: sku,
      unit: unit,
      sellPrice: sellPrice,
      costPrice: costPrice,
      lowStockThreshold: lowStockThreshold,
      initialStock: initialStock,
      category: category, // Category дамжуулах
    );

    if (result.isError) {
      state = AsyncValue.error(result.errorMessage ?? 'Алдаа гарлаа', StackTrace.current);
      return null;
    }

    // Null шалгалт — dataOrNull null байвал crash-аас сэргийлэх
    final product = result.dataOrNull;
    if (product == null) {
      state = AsyncValue.error('Бүтээгдэхүүний мэдээлэл олдсонгүй', StackTrace.current);
      return null;
    }

    // Зураг хадгалах (байвал)
    if (imageFile != null) {
      await service.saveAndUploadProductImage(storeId, product.id, imageFile);
    }

    state = const AsyncValue.data(null);
    ref.invalidate(productListProvider);
    return product.id;
  }

  /// Бараа засах
  Future<bool> updateProduct(
    String productId, {
    String? name,
    String? sku,
    String? unit,
    int? sellPrice,
    int? costPrice,
    int? lowStockThreshold,
    String? category, // Барааны ангилал
    File? imageFile,
  }) async {
    state = const AsyncValue.loading();

    final storeId = ref.read(storeIdProvider);
    if (storeId == null) {
      state = AsyncValue.error('Хэрэглэгч нэвтрээгүй байна', StackTrace.current);
      return false;
    }

    final service = ref.read(productServiceProvider);
    final result = await service.updateProduct(
      storeId,
      productId,
      name: name,
      sku: sku,
      unit: unit,
      sellPrice: sellPrice,
      costPrice: costPrice,
      lowStockThreshold: lowStockThreshold,
      category: category, // Category дамжуулах
    );

    if (result.isError) {
      state = AsyncValue.error(result.errorMessage ?? 'Алдаа гарлаа', StackTrace.current);
      return false;
    }

    // Зураг хадгалах (байвал)
    if (imageFile != null) {
      await service.saveAndUploadProductImage(storeId, productId, imageFile);
    }

    state = const AsyncValue.data(null);
    ref.invalidate(productListProvider);
    ref.invalidate(productDetailProvider(productId));
    return true;
  }

  /// Бараа устгах
  Future<bool> deleteProduct(String productId) async {
    state = const AsyncValue.loading();

    final storeId = ref.read(storeIdProvider);
    if (storeId == null) {
      state = AsyncValue.error('Хэрэглэгч нэвтрээгүй байна', StackTrace.current);
      return false;
    }

    final service = ref.read(productServiceProvider);
    final result = await service.deleteProduct(storeId, productId);

    return result.when(
      success: (_) {
        state = const AsyncValue.data(null);
        ref.invalidate(productListProvider);
        return true;
      },
      error: (message, _, __) {
        state = AsyncValue.error(message, StackTrace.current);
        return false;
      },
    );
  }
}
