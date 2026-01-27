import 'dart:io';

import 'package:dio/dio.dart';
import 'package:drift/drift.dart';
import 'package:retail_control_platform/core/api/api_endpoints.dart';
import 'package:retail_control_platform/core/api/api_result.dart';
import 'package:retail_control_platform/core/database/app_database.dart';
import 'package:retail_control_platform/core/services/base_service.dart';
import 'package:retail_control_platform/core/services/image_service.dart';
import 'package:retail_control_platform/features/inventory/domain/product_with_stock.dart';
import 'package:uuid/uuid.dart';

/// ProductService - Бараатай холбоотой бүх үйлдлүүд
/// API + Local Database integration with offline-first pattern
class ProductService extends BaseService {
  ProductService({required super.db});

  // ============================================================================
  // READ OPERATIONS
  // ============================================================================

  /// Бараануудын жагсаалт авах
  /// Offline-first: Local DB-аас эхлээд унших, background-д API-аас refresh
  Future<ApiResult<List<ProductWithStock>>> getProducts(
    String storeId, {
    String? searchQuery,
    String? category,
    bool forceRefresh = false,
  }) async {
    try {
      // 1. Local DB-аас унших
      final localProducts = await _getLocalProducts(storeId);

      // 2. Online бол background-д API-аас refresh
      if (await isOnline) {
        _refreshProductsFromApi(storeId);
      }

      // 3. Filter хийх
      var filtered = localProducts;

      if (searchQuery != null && searchQuery.isNotEmpty) {
        final query = searchQuery.toLowerCase();
        filtered = filtered
            .where((p) =>
                p.name.toLowerCase().contains(query) ||
                p.sku.toLowerCase().contains(query))
            .toList();
      }

      if (category != null && category.isNotEmpty) {
        filtered = filtered.where((p) => p.category == category).toList();
      }

      return ApiResult.success(filtered);
    } catch (e) {
      log('getProducts error: $e');
      return ApiResult.error('Бараа унших үед алдаа гарлаа: $e');
    }
  }

  /// Нэг барааны дэлгэрэнгүй
  Future<ApiResult<ProductWithStock?>> getProduct(
    String storeId,
    String productId,
  ) async {
    try {
      // Local DB-аас унших
      final product = await _getLocalProduct(productId);
      return ApiResult.success(product);
    } catch (e) {
      log('getProduct error: $e');
      return ApiResult.error('Бараа унших үед алдаа гарлаа');
    }
  }

  /// Бага үлдэгдэлтэй бараанууд
  Future<ApiResult<List<ProductWithStock>>> getLowStockProducts(
    String storeId,
  ) async {
    try {
      final allProducts = await _getLocalProducts(storeId);
      final lowStock = allProducts.where((p) => p.isLowStock).toList();
      return ApiResult.success(lowStock);
    } catch (e) {
      log('getLowStockProducts error: $e');
      return ApiResult.error('Бага үлдэгдэлтэй бараа унших үед алдаа гарлаа');
    }
  }

  /// Бараа хайх
  Future<ApiResult<List<ProductWithStock>>> searchProducts(
    String storeId,
    String query,
  ) async {
    if (query.isEmpty) {
      return const ApiResult.success([]);
    }

    final result = await getProducts(storeId, searchQuery: query);
    return result;
  }

  // ============================================================================
  // WRITE OPERATIONS
  // ============================================================================

  /// Шинэ бараа нэмэх
  Future<ApiResult<ProductWithStock>> createProduct(
    String storeId,
    String actorId, {
    required String name,
    required String sku,
    required String unit,
    required double sellPrice,
    double? costPrice,
    int? lowStockThreshold,
    int? initialStock,
    String? note,
    String? category, // Барааны ангилал (Хүнс, Ундаа, гэх мэт)
  }) async {
    final productId = const Uuid().v4();
    final now = DateTime.now();

    // Product companion
    final productCompanion = ProductsCompanion.insert(
      id: productId,
      storeId: storeId,
      name: name,
      sku: sku,
      unit: unit,
      sellPrice: sellPrice,
      costPrice: Value(costPrice),
      lowStockThreshold: Value(lowStockThreshold ?? 10),
      note: Value(note),
      category: Value(category), // Category талбар нэмэх
      createdAt: Value(now),
      updatedAt: Value(now),
    );

    try {
      // 1. Local DB-д хадгалах
      await db.into(db.products).insert(productCompanion);

      // 2. Initial stock байвал inventory event нэмэх
      if (initialStock != null && initialStock > 0) {
        final eventCompanion = InventoryEventsCompanion.insert(
          id: const Uuid().v4(),
          storeId: storeId,
          productId: productId,
          type: 'INITIAL',
          qtyChange: initialStock,
          actorId: actorId,
          timestamp: Value(now),
        );
        await db.into(db.inventoryEvents).insert(eventCompanion);
      }

      // 3. Online бол API руу илгээх, offline бол queue-д нэмэх
      if (await isOnline) {
        await _syncProductToApi(storeId, productId, 'create', {
          'name': name,
          'sku': sku,
          'unit': unit,
          'sellPrice': sellPrice,
          'costPrice': costPrice,
          'lowStockThreshold': lowStockThreshold ?? 10,
          if (category != null) 'category': category, // Category нэмэх
        });
      } else {
        await enqueueOperation(
          entityType: 'product',
          operation: 'create',
          payload: {
            'temp_id': productId,
            'store_id': storeId,
            'name': name,
            'sku': sku,
            'unit': unit,
            'sell_price': sellPrice,
            'cost_price': costPrice,
            'low_stock_threshold': lowStockThreshold ?? 10,
            'initial_stock': initialStock,
            if (category != null) 'category': category, // Category нэмэх
          },
        );
      }

      // 4. ProductWithStock буцаах
      final product = ProductWithStock(
        id: productId,
        name: name,
        sku: sku,
        sellPrice: sellPrice,
        costPrice: costPrice ?? 0,
        stockQuantity: initialStock ?? 0,
        isLowStock: (initialStock ?? 0) <= (lowStockThreshold ?? 10),
        storeId: storeId,
        unit: unit,
        category: category, // Category нэмэх
        lowStockThreshold: lowStockThreshold ?? 10,
        createdAt: now,
        updatedAt: now,
      );

      return ApiResult.success(product);
    } catch (e) {
      log('createProduct error: $e');
      return ApiResult.error('Бараа нэмэх үед алдаа гарлаа: $e');
    }
  }

  /// Бараа засах
  Future<ApiResult<ProductWithStock>> updateProduct(
    String storeId,
    String productId, {
    String? name,
    String? sku,
    String? unit,
    double? sellPrice,
    double? costPrice,
    int? lowStockThreshold,
    String? note,
    String? category, // Барааны ангилал
  }) async {
    try {
      // 1. Local DB-д засах
      await (db.update(db.products)..where((p) => p.id.equals(productId))).write(
        ProductsCompanion(
          name: name != null ? Value(name) : const Value.absent(),
          sku: sku != null ? Value(sku) : const Value.absent(),
          unit: unit != null ? Value(unit) : const Value.absent(),
          sellPrice: sellPrice != null ? Value(sellPrice) : const Value.absent(),
          costPrice: costPrice != null ? Value(costPrice) : const Value.absent(),
          lowStockThreshold:
              lowStockThreshold != null ? Value(lowStockThreshold) : const Value.absent(),
          note: note != null ? Value(note) : const Value.absent(),
          category: category != null ? Value(category) : const Value.absent(), // Category нэмэх
          updatedAt: Value(DateTime.now()),
        ),
      );

      // 2. Online бол API руу илгээх, offline бол queue-д нэмэх
      final updateData = <String, dynamic>{};
      if (name != null) updateData['name'] = name;
      if (sku != null) updateData['sku'] = sku;
      if (unit != null) updateData['unit'] = unit;
      if (sellPrice != null) updateData['sellPrice'] = sellPrice;
      if (costPrice != null) updateData['costPrice'] = costPrice;
      if (lowStockThreshold != null) updateData['lowStockThreshold'] = lowStockThreshold;
      if (category != null) updateData['category'] = category; // Category нэмэх

      if (await isOnline) {
        await _syncProductToApi(storeId, productId, 'update', updateData);
      } else {
        await enqueueOperation(
          entityType: 'product',
          operation: 'update',
          payload: {
            'product_id': productId,
            'store_id': storeId,
            ...updateData,
          },
        );
      }

      // 3. Updated product буцаах
      final product = await _getLocalProduct(productId);
      if (product == null) {
        return const ApiResult.error('Бараа олдсонгүй');
      }

      return ApiResult.success(product);
    } catch (e) {
      log('updateProduct error: $e');
      return ApiResult.error('Бараа засах үед алдаа гарлаа: $e');
    }
  }

  /// Бараа устгах (soft delete)
  Future<ApiResult<void>> deleteProduct(
    String storeId,
    String productId,
  ) async {
    try {
      // 1. Local DB-д soft delete
      await (db.update(db.products)..where((p) => p.id.equals(productId))).write(
        const ProductsCompanion(
          isDeleted: Value(true),
        ),
      );

      // 2. Sync
      if (await isOnline) {
        await api.delete(ApiEndpoints.product(storeId, productId));
      } else {
        await enqueueOperation(
          entityType: 'product',
          operation: 'delete',
          payload: {
            'product_id': productId,
            'store_id': storeId,
          },
        );
      }

      return const ApiResult.success(null);
    } catch (e) {
      log('deleteProduct error: $e');
      return ApiResult.error('Бараа устгах үед алдаа гарлаа: $e');
    }
  }

  // ============================================================================
  // PRIVATE HELPERS
  // ============================================================================

  /// Local DB-аас бараанууд унших
  Future<List<ProductWithStock>> _getLocalProducts(String storeId) async {
    final products = await (db.select(db.products)
          ..where((p) => p.storeId.equals(storeId) & p.isDeleted.equals(false)))
        .get();

    if (products.isEmpty) return [];

    // Stock levels тооцоолох
    final productIds = products.map((p) => p.id).toList();
    final stockLevels = await db.getStockLevels(productIds);

    return products.map((p) {
      final stock = stockLevels[p.id] ?? 0;
      return ProductWithStock(
        id: p.id,
        name: p.name,
        sku: p.sku,
        sellPrice: p.sellPrice,
        costPrice: p.costPrice ?? 0,
        stockQuantity: stock,
        isLowStock: stock <= p.lowStockThreshold,
        storeId: p.storeId,
        unit: p.unit,
        category: p.category, // Category map нэмэх
        imageUrl: p.localImagePath ?? p.imageUrl,
        lowStockThreshold: p.lowStockThreshold,
        createdAt: p.createdAt,
        updatedAt: p.updatedAt,
      );
    }).toList();
  }

  /// Local DB-аас нэг бараа унших
  Future<ProductWithStock?> _getLocalProduct(String productId) async {
    final product = await (db.select(db.products)
          ..where((p) => p.id.equals(productId) & p.isDeleted.equals(false)))
        .getSingleOrNull();

    if (product == null) return null;

    final stock = await db.getCurrentStock(productId);

    return ProductWithStock(
      id: product.id,
      name: product.name,
      sku: product.sku,
      sellPrice: product.sellPrice,
      costPrice: product.costPrice ?? 0,
      stockQuantity: stock,
      isLowStock: stock <= product.lowStockThreshold,
      storeId: product.storeId,
      unit: product.unit,
      category: product.category, // Category map нэмэх
      imageUrl: product.localImagePath ?? product.imageUrl,
      lowStockThreshold: product.lowStockThreshold,
      createdAt: product.createdAt,
      updatedAt: product.updatedAt,
    );
  }

  /// API-аас бараануудыг refresh хийх (background)
  Future<void> _refreshProductsFromApi(String storeId) async {
    try {
      final response = await api.get(
        ApiEndpoints.products(storeId),
        queryParameters: {'limit': 100},
      );

      if (response.data['success'] == true) {
        final productsData = response.data['products'] as List? ?? [];

        for (final data in productsData) {
          final companion = ProductsCompanion(
            id: Value(data['id']),
            storeId: Value(storeId),
            name: Value(data['name']),
            sku: Value(data['sku'] ?? ''),
            unit: Value(data['unit'] ?? 'piece'),
            sellPrice: Value((data['sellPrice'] as num?)?.toDouble() ?? 0),
            costPrice: Value((data['costPrice'] as num?)?.toDouble()),
            lowStockThreshold: Value(data['lowStockThreshold'] ?? 10),
            imageUrl: Value(data['imageUrl'] as String?),
            updatedAt: Value(DateTime.now()),
          );

          await db
              .into(db.products)
              .insertOnConflictUpdate(companion);
        }

        log('Refreshed ${productsData.length} products from API');
      }
    } catch (e) {
      log('_refreshProductsFromApi error: $e');
    }
  }

  /// API руу бараа sync хийх
  Future<void> _syncProductToApi(
    String storeId,
    String productId,
    String operation,
    Map<String, dynamic> data,
  ) async {
    try {
      if (operation == 'create') {
        await api.post(ApiEndpoints.products(storeId), data: data);
      } else if (operation == 'update') {
        await api.put(ApiEndpoints.product(storeId, productId), data: data);
      }
    } catch (e) {
      log('_syncProductToApi error: $e');
      // Sync failed - queue for later
      await enqueueOperation(
        entityType: 'product',
        operation: operation,
        payload: {
          'product_id': productId,
          'store_id': storeId,
          ...data,
        },
      );
    }
  }

  // ============================================================================
  // IMAGE OPERATIONS
  // ============================================================================

  final ImageService _imageService = ImageService();

  /// Барааны зургийг local-д хадгалж, DB-д path бичих
  ///
  /// Offline-first: эхлээд local-д хадгалж, дараа нь server рүү upload хийнэ.
  /// [storeId] - Store ID
  /// [productId] - Product ID
  /// [imageFile] - Зураг файл (камер эсвэл галерейгаас)
  /// Returns: Local файлын path
  Future<ApiResult<String>> saveProductImageLocally(
    String storeId,
    String productId,
    File imageFile,
  ) async {
    try {
      // 1. Зургийг компресс хийх
      final Uint8List? compressed = await _imageService.compressImage(imageFile);
      if (compressed == null) {
        return const ApiResult.error('Зургийг компресс хийх боломжгүй');
      }

      // 2. Local-д хадгалах
      final localPath = await _imageService.saveImageLocally(compressed, productId);

      // 3. DB-д local path хадгалах
      await (db.update(db.products)..where((p) => p.id.equals(productId))).write(
        ProductsCompanion(
          localImagePath: Value(localPath),
          imageSynced: const Value(false),
          updatedAt: Value(DateTime.now()),
        ),
      );

      log('Image saved locally for product $productId: $localPath');
      return ApiResult.success(localPath);
    } catch (e) {
      log('saveProductImageLocally error: $e');
      return ApiResult.error('Зураг хадгалахад алдаа гарлаа: $e');
    }
  }

  /// Барааны зургийг backend руу upload хийх
  ///
  /// [storeId] - Store ID
  /// [productId] - Product ID
  /// [imageFile] - Зураг файл
  /// Returns: Server дээрх image URL
  Future<ApiResult<String>> uploadProductImage(
    String storeId,
    String productId,
    File imageFile,
  ) async {
    try {
      // Multipart form data бэлдэх
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(
          imageFile.path,
          filename: 'product_$productId.jpg',
        ),
      });

      final response = await api.post(
        ApiEndpoints.productImage(storeId, productId),
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
        ),
      );

      if (response.data['success'] == true) {
        final imageUrl = response.data['imageUrl'] as String;

        // DB-д server URL хадгалах, imageSynced = true
        await (db.update(db.products)..where((p) => p.id.equals(productId))).write(
          ProductsCompanion(
            imageUrl: Value(imageUrl),
            imageSynced: const Value(true),
            updatedAt: Value(DateTime.now()),
          ),
        );

        log('Image uploaded for product $productId: $imageUrl');
        return ApiResult.success(imageUrl);
      } else {
        return ApiResult.error(response.data['error'] ?? 'Зураг upload хийхэд алдаа');
      }
    } catch (e) {
      log('uploadProductImage error: $e');
      return ApiResult.error('Зураг upload хийхэд алдаа гарлаа: $e');
    }
  }

  /// Барааны зургийг local-д хадгалж, online бол server рүү upload хийх
  ///
  /// Offline-first flow: local save → online бол upload
  Future<ApiResult<String>> saveAndUploadProductImage(
    String storeId,
    String productId,
    File imageFile,
  ) async {
    // 1. Local-д хадгалах
    final localResult = await saveProductImageLocally(storeId, productId, imageFile);
    if (!localResult.isSuccess) {
      return localResult;
    }

    // 2. Online бол server рүү upload хийх
    if (await isOnline) {
      final uploadResult = await uploadProductImage(storeId, productId, imageFile);
      if (uploadResult.isSuccess) {
        return uploadResult;
      }
      // Upload амжилтгүй бол local path буцаана (дараа sync хийгдэнэ)
      log('Upload failed, will sync later');
    }

    return localResult;
  }
}
