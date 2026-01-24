import 'package:drift/drift.dart';
import 'package:retail_control_platform/core/api/api_endpoints.dart';
import 'package:retail_control_platform/core/api/api_result.dart';
import 'package:retail_control_platform/core/database/app_database.dart';
import 'package:retail_control_platform/core/services/base_service.dart';
import 'package:retail_control_platform/features/sales/domain/cart_item.dart';
import 'package:uuid/uuid.dart';

/// SalesService - Борлуулалттай холбоотой бүх үйлдлүүд
/// API + Local Database integration with offline-first pattern
class SalesService extends BaseService {
  SalesService({required super.db});

  // ============================================================================
  // CHECKOUT - Create Sale with inventory events
  // ============================================================================

  /// Борлуулалт хийх (checkout)
  /// Offline-first: Local DB-д хадгалаад, online бол API руу sync хийнэ
  Future<ApiResult<String>> completeSale({
    required String storeId,
    required String sellerId,
    required List<CartItem> items,
    required String paymentMethod,
    String? shiftId,
  }) async {
    if (items.isEmpty) {
      return const ApiResult.error('Сагс хоосон байна');
    }

    final saleId = const Uuid().v4();
    final now = DateTime.now();
    final totalAmount = items.fold(0.0, (sum, item) => sum + item.subtotal);

    try {
      // Transaction - бүгд амжилттай эсвэл бүгд буцаах
      await db.transaction(() async {
        // 1. Sale бүртгэл үүсгэх
        final saleCompanion = SalesCompanion.insert(
          id: saleId,
          storeId: storeId,
          sellerId: sellerId,
          shiftId: Value(shiftId),
          totalAmount: totalAmount,
          paymentMethod: Value(paymentMethod),
          timestamp: Value(now),
        );
        await db.into(db.sales).insert(saleCompanion);

        // 2. Sale items үүсгэх
        for (final item in items) {
          final saleItemCompanion = SaleItemsCompanion.insert(
            id: const Uuid().v4(),
            saleId: saleId,
            productId: item.product.id,
            quantity: item.quantity,
            unitPrice: item.product.sellPrice,
            subtotal: item.subtotal,
          );
          await db.into(db.saleItems).insert(saleItemCompanion);
        }

        // 3. Inventory events үүсгэх (SALE type, сөрөг qty)
        for (final item in items) {
          final eventCompanion = InventoryEventsCompanion.insert(
            id: const Uuid().v4(),
            storeId: storeId,
            productId: item.product.id,
            type: 'SALE',
            qtyChange: -item.quantity, // Сөрөг - борлуулалт
            actorId: sellerId,
            shiftId: Value(shiftId),
            timestamp: Value(now),
          );
          await db.into(db.inventoryEvents).insert(eventCompanion);
        }
      });

      // 4. Online бол API руу sync хийх
      if (await isOnline) {
        _syncSaleToApi(storeId, saleId, items, paymentMethod, shiftId);
      } else {
        // Offline - queue-д нэмэх
        await enqueueOperation(
          entityType: 'sale',
          operation: 'create_sale',
          payload: {
            'temp_id': saleId,
            'store_id': storeId,
            'seller_id': sellerId,
            'shift_id': shiftId,
            'total_amount': totalAmount,
            'payment_method': paymentMethod,
            'items': items
                .map((item) => {
                      'product_id': item.product.id,
                      'quantity': item.quantity,
                      'unit_price': item.product.sellPrice,
                    })
                .toList(),
          },
        );
      }

      log('Sale completed: $saleId, total: $totalAmount');
      return ApiResult.success(saleId);
    } catch (e) {
      log('completeSale error: $e');
      return ApiResult.error('Борлуулалт хийхэд алдаа гарлаа: $e');
    }
  }

  // ============================================================================
  // READ OPERATIONS
  // ============================================================================

  /// Борлуулалтын түүх
  Future<ApiResult<List<SaleWithItems>>> getSalesHistory(
    String storeId, {
    String? sellerId,
    String? shiftId,
    DateTime? fromDate,
    DateTime? toDate,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      // 1. Local DB-аас унших
      final localSales = await _getLocalSales(
        storeId,
        sellerId: sellerId,
        shiftId: shiftId,
        fromDate: fromDate,
        toDate: toDate,
        limit: limit,
        offset: offset,
      );

      // 2. Online бол refresh
      if (await isOnline) {
        _refreshSalesFromApi(storeId, sellerId, shiftId);
      }

      return ApiResult.success(localSales);
    } catch (e) {
      log('getSalesHistory error: $e');
      return ApiResult.error('Борлуулалтын түүх унших үед алдаа гарлаа');
    }
  }

  /// Нэг борлуулалтын дэлгэрэнгүй
  Future<ApiResult<SaleWithItems?>> getSaleDetail(
    String storeId,
    String saleId,
  ) async {
    try {
      final sale = await _getLocalSaleWithItems(saleId);
      return ApiResult.success(sale);
    } catch (e) {
      log('getSaleDetail error: $e');
      return ApiResult.error('Борлуулалт унших үед алдаа гарлаа');
    }
  }

  /// Өнөөдрийн борлуулалт
  Future<ApiResult<double>> getTodaySales(String storeId) async {
    try {
      final total = await db.getTodayTotalSales(storeId);
      return ApiResult.success(total);
    } catch (e) {
      log('getTodaySales error: $e');
      return ApiResult.error('Өнөөдрийн борлуулалт унших үед алдаа гарлаа');
    }
  }

  /// Өчигдрийн борлуулалт
  Future<ApiResult<double>> getYesterdaySales(String storeId) async {
    try {
      final total = await db.getYesterdayTotalSales(storeId);
      return ApiResult.success(total);
    } catch (e) {
      log('getYesterdaySales error: $e');
      return ApiResult.error('Өчигдрийн борлуулалт унших үед алдаа гарлаа');
    }
  }

  /// Борлуулалт цуцлах (void)
  Future<ApiResult<void>> voidSale(
    String storeId,
    String saleId,
    String actorId,
  ) async {
    try {
      // 1. Sale items авах
      final saleItems = await (db.select(db.saleItems)
            ..where((si) => si.saleId.equals(saleId)))
          .get();

      // 2. Transaction
      await db.transaction(() async {
        // 3. Inventory events үүсгэх (RETURN type, эерэг qty)
        for (final item in saleItems) {
          final eventCompanion = InventoryEventsCompanion.insert(
            id: const Uuid().v4(),
            storeId: storeId,
            productId: item.productId,
            type: 'RETURN',
            qtyChange: item.quantity, // Эерэг - буцаалт
            actorId: actorId,
            reason: const Value('Борлуулалт цуцлагдсан'),
            timestamp: Value(DateTime.now()),
          );
          await db.into(db.inventoryEvents).insert(eventCompanion);
        }

        // 4. Sale items устгах
        await (db.delete(db.saleItems)..where((si) => si.saleId.equals(saleId))).go();

        // 5. Sale устгах
        await (db.delete(db.sales)..where((s) => s.id.equals(saleId))).go();
      });

      // 6. Online бол API руу
      if (await isOnline) {
        try {
          await api.post(ApiEndpoints.voidSale(storeId, saleId));
        } catch (e) {
          log('API voidSale error: $e');
          await enqueueOperation(
            entityType: 'sale',
            operation: 'void_sale',
            payload: {
              'sale_id': saleId,
              'store_id': storeId,
              'actor_id': actorId,
            },
          );
        }
      } else {
        await enqueueOperation(
          entityType: 'sale',
          operation: 'void_sale',
          payload: {
            'sale_id': saleId,
            'store_id': storeId,
            'actor_id': actorId,
          },
        );
      }

      return const ApiResult.success(null);
    } catch (e) {
      log('voidSale error: $e');
      return ApiResult.error('Борлуулалт цуцлахад алдаа гарлаа: $e');
    }
  }

  // ============================================================================
  // PRIVATE HELPERS
  // ============================================================================

  /// Local DB-аас борлуулалтууд унших
  Future<List<SaleWithItems>> _getLocalSales(
    String storeId, {
    String? sellerId,
    String? shiftId,
    DateTime? fromDate,
    DateTime? toDate,
    int limit = 20,
    int offset = 0,
  }) async {
    var query = db.select(db.sales)
      ..where((s) => s.storeId.equals(storeId))
      ..orderBy([(s) => OrderingTerm.desc(s.timestamp)])
      ..limit(limit, offset: offset);

    if (sellerId != null) {
      query = query..where((s) => s.sellerId.equals(sellerId));
    }
    if (shiftId != null) {
      query = query..where((s) => s.shiftId.equals(shiftId));
    }
    if (fromDate != null) {
      query = query..where((s) => s.timestamp.isBiggerOrEqualValue(fromDate));
    }
    if (toDate != null) {
      query = query..where((s) => s.timestamp.isSmallerOrEqualValue(toDate));
    }

    final sales = await query.get();
    final salesWithItems = <SaleWithItems>[];

    for (final sale in sales) {
      final items = await (db.select(db.saleItems)
            ..where((si) => si.saleId.equals(sale.id)))
          .get();

      // Seller name авах
      final seller = await (db.select(db.users)..where((u) => u.id.equals(sale.sellerId)))
          .getSingleOrNull();

      salesWithItems.add(SaleWithItems(
        id: sale.id,
        storeId: sale.storeId,
        sellerId: sale.sellerId,
        sellerName: seller?.name ?? 'Unknown',
        shiftId: sale.shiftId,
        totalAmount: sale.totalAmount,
        paymentMethod: sale.paymentMethod,
        timestamp: sale.timestamp,
        items: items,
      ));
    }

    return salesWithItems;
  }

  /// Local DB-аас нэг борлуулалт унших
  Future<SaleWithItems?> _getLocalSaleWithItems(String saleId) async {
    final sale = await (db.select(db.sales)..where((s) => s.id.equals(saleId)))
        .getSingleOrNull();

    if (sale == null) return null;

    final items = await (db.select(db.saleItems)
          ..where((si) => si.saleId.equals(saleId)))
        .get();

    final seller = await (db.select(db.users)..where((u) => u.id.equals(sale.sellerId)))
        .getSingleOrNull();

    return SaleWithItems(
      id: sale.id,
      storeId: sale.storeId,
      sellerId: sale.sellerId,
      sellerName: seller?.name ?? 'Unknown',
      shiftId: sale.shiftId,
      totalAmount: sale.totalAmount,
      paymentMethod: sale.paymentMethod,
      timestamp: sale.timestamp,
      items: items,
    );
  }

  /// API руу борлуулалт sync хийх
  Future<void> _syncSaleToApi(
    String storeId,
    String saleId,
    List<CartItem> items,
    String paymentMethod,
    String? shiftId,
  ) async {
    try {
      await api.post(
        ApiEndpoints.sales(storeId),
        data: {
          'items': items
              .map((item) => {
                    'product_id': item.product.id,
                    'quantity': item.quantity,
                    'unit_price': item.product.sellPrice,
                  })
              .toList(),
          'payment_method': paymentMethod,
          if (shiftId != null) 'shift_id': shiftId,
        },
      );
    } catch (e) {
      log('_syncSaleToApi error: $e');
      // Queue for later
      await enqueueOperation(
        entityType: 'sale',
        operation: 'create_sale',
        payload: {
          'temp_id': saleId,
          'store_id': storeId,
          'shift_id': shiftId,
          'payment_method': paymentMethod,
          'items': items
              .map((item) => {
                    'product_id': item.product.id,
                    'quantity': item.quantity,
                    'unit_price': item.product.sellPrice,
                  })
              .toList(),
        },
      );
    }
  }

  /// API-аас борлуулалт refresh
  Future<void> _refreshSalesFromApi(
    String storeId,
    String? sellerId,
    String? shiftId,
  ) async {
    try {
      final response = await api.get(
        ApiEndpoints.sales(storeId),
        queryParameters: {
          if (sellerId != null) 'seller_id': sellerId,
          if (shiftId != null) 'shift_id': shiftId,
          'limit': 20,
        },
      );

      if (response.data['success'] == true) {
        final salesData = response.data['sales'] as List? ?? [];
        log('Refreshed ${salesData.length} sales from API');
      }
    } catch (e) {
      log('_refreshSalesFromApi error: $e');
    }
  }
}

/// Sale with items model (for display)
class SaleWithItems {
  final String id;
  final String storeId;
  final String sellerId;
  final String sellerName;
  final String? shiftId;
  final double totalAmount;
  final String paymentMethod;
  final DateTime timestamp;
  final List<SaleItem> items;

  SaleWithItems({
    required this.id,
    required this.storeId,
    required this.sellerId,
    required this.sellerName,
    this.shiftId,
    required this.totalAmount,
    required this.paymentMethod,
    required this.timestamp,
    required this.items,
  });
}
