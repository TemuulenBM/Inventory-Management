import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

// ============================================================================
// TABLE DEFINITIONS
// ============================================================================

/// Store - Дэлгүүрийн мэдээлэл
class Stores extends Table {
  TextColumn get id => text()();
  TextColumn get ownerId => text()();
  TextColumn get name => text()();
  TextColumn get location => text().nullable()();
  TextColumn get timezone => text().withDefault(const Constant('Asia/Ulaanbaatar'))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

/// Users - Хэрэглэгчид (Owner, Seller)
class Users extends Table {
  TextColumn get id => text()();
  TextColumn get storeId => text().references(Stores, #id)();
  TextColumn get name => text()();
  TextColumn get phone => text().nullable()();
  TextColumn get role => text()(); // 'owner', 'manager', 'seller'
  DateTimeColumn get lastOnline => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

/// Products - Бараа
class Products extends Table {
  TextColumn get id => text()();
  TextColumn get storeId => text().references(Stores, #id)();
  TextColumn get name => text()();
  TextColumn get sku => text()(); // Auto-generated эсвэл manual
  TextColumn get unit => text()(); // 'pcs', 'kg', 'liter', гэх мэт
  IntColumn get sellPrice => integer()();
  IntColumn get costPrice => integer().nullable()();
  IntColumn get lowStockThreshold => integer().withDefault(const Constant(10))();
  TextColumn get note => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();

  // Зургийн талбарууд
  TextColumn get imageUrl => text().nullable()(); // Supabase Storage URL
  TextColumn get localImagePath => text().nullable()(); // Offline үед local path
  BoolColumn get imageSynced =>
      boolean().withDefault(const Constant(true))(); // Зураг sync хийгдсэн эсэх

  // Ангилал талбар
  TextColumn get category => text().nullable()(); // Барааны ангилал (Хүнс, Ундаа, Гэр ахуй гэх мэт)

  @override
  Set<Column> get primaryKey => {id};
}

/// InventoryEvents - Үлдэгдлийн өөрчлөлт (Event Sourcing)
/// Энэ нь системийн гол суурь - бүх үлдэгдлийн өөрчлөлтийг event хэлбэрээр хадгална
class InventoryEvents extends Table {
  TextColumn get id => text()();
  TextColumn get storeId => text().references(Stores, #id)();
  TextColumn get productId => text().references(Products, #id)();
  TextColumn get type => text()(); // 'INITIAL', 'SALE', 'ADJUST', 'RETURN'
  IntColumn get qtyChange => integer()(); // +10 or -5
  TextColumn get actorId => text().references(Users, #id)();
  TextColumn get shiftId => text().nullable().references(Shifts, #id)();
  TextColumn get reason => text().nullable()(); // Manual adjustment шалтгаан
  DateTimeColumn get timestamp => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

/// Sales - Борлуулалт
class Sales extends Table {
  TextColumn get id => text()();
  TextColumn get storeId => text().references(Stores, #id)();
  TextColumn get sellerId => text().references(Users, #id)();
  TextColumn get shiftId => text().nullable().references(Shifts, #id)();
  IntColumn get totalAmount => integer()();
  TextColumn get paymentMethod => text().withDefault(const Constant('cash'))(); // 'cash', 'card', 'qr'
  DateTimeColumn get timestamp => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

/// SaleItems - Борлуулалтын бараанууд (One Sale → Many Items)
class SaleItems extends Table {
  TextColumn get id => text()();
  TextColumn get saleId => text().references(Sales, #id, onDelete: KeyAction.cascade)();
  TextColumn get productId => text().references(Products, #id)();
  IntColumn get quantity => integer()();
  IntColumn get unitPrice => integer()(); // Тухайн үеийн үнэ
  IntColumn get subtotal => integer()(); // quantity * unitPrice

  @override
  Set<Column> get primaryKey => {id};
}

/// Shifts - Ээлж
class Shifts extends Table {
  TextColumn get id => text()();
  TextColumn get storeId => text().references(Stores, #id)();
  TextColumn get sellerId => text().references(Users, #id)();
  DateTimeColumn get openedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get closedAt => dateTime().nullable()();
  IntColumn get openBalance => integer().nullable()(); // Эхлэх мөнгө (optional)
  IntColumn get closeBalance => integer().nullable()(); // Хаах мөнгө

  @override
  Set<Column> get primaryKey => {id};
}

/// Alerts - Сэрэмжлүүлэг
class Alerts extends Table {
  TextColumn get id => text()();
  TextColumn get storeId => text().references(Stores, #id)();
  TextColumn get type => text()(); // 'low_stock', 'negative_inventory', 'suspicious_activity'
  TextColumn get productId => text().nullable().references(Products, #id)();
  TextColumn get message => text()();
  TextColumn get level => text().withDefault(const Constant('info'))(); // 'info', 'warning', 'error'
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get resolved => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

/// SyncQueue - Offline sync queue (CRITICAL for offline-first)
/// Offline үед хийсэн бүх өөрчлөлтийг энд хадгалж, online болоход sync хийнэ
class SyncQueue extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get entityType => text()(); // 'product', 'sale', 'inventory_event', гэх мэт
  TextColumn get operation => text()(); // 'create', 'update', 'delete'
  TextColumn get payload => text()(); // JSON serialized өгөгдөл
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get synced => boolean().withDefault(const Constant(false))();
  IntColumn get retryCount => integer().withDefault(const Constant(0))();
  TextColumn get errorMessage => text().nullable()(); // Sync failed бол шалтгаан
}

// ============================================================================
// DATABASE CLASS
// ============================================================================

@DriftDatabase(tables: [
  Stores,
  Users,
  Products,
  InventoryEvents,
  Sales,
  SaleItems,
  Shifts,
  Alerts,
  SyncQueue,
])
class AppDatabase extends _$AppDatabase {
  /// Singleton instance - Нэг л database instance ашиглах
  static AppDatabase? _instance;

  /// Singleton factory constructor
  factory AppDatabase() {
    return _instance ??= AppDatabase._internal();
  }

  /// Private constructor
  AppDatabase._internal() : super(_openConnection());

  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            // Version 2: Products table-д зургийн талбарууд нэмэх
            await m.addColumn(products, products.imageUrl);
            await m.addColumn(products, products.localImagePath);
            await m.addColumn(products, products.imageSynced);
          }
          if (from < 3) {
            // Version 3: Products table-д ангилал (category) нэмэх
            await m.addColumn(products, products.category);
          }
          if (from < 4) {
            // Version 4: Үнийн төрлийг REAL → INTEGER өөрчлөх
            // Монгол төгрөг бүтэн тоо (ам байхгүй)
            // Одоо байгаа өгөгдөл байхгүй (database хоосон), migration logic хэрэггүй
          }
        },
      );

  // Database connection with encryption support
  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'retail_control_db');
  }

  // ============================================================================
  // CUSTOM QUERIES - Үлдэгдэл тооцоолох (Event Sourcing pattern)
  // ============================================================================

  /// Тухайн барааны одоогийн үлдэгдлийг тооцоолох
  /// Event Sourcing: Бүх events-ийг нэгтгэж, qtyChange-ийг нийлүүлнэ
  Future<int> getCurrentStock(String productId) async {
    final events = await (select(inventoryEvents)
          ..where((e) => e.productId.equals(productId)))
        .get();

    return events.fold<int>(0, (sum, event) => sum + event.qtyChange);
  }

  /// Олон барааны үлдэгдлийг нэгэн зэрэг тооцоолох (Dashboard-д ашиглах)
  Future<Map<String, int>> getStockLevels(List<String> productIds) async {
    final Map<String, int> stockMap = {};

    for (final productId in productIds) {
      stockMap[productId] = await getCurrentStock(productId);
    }

    return stockMap;
  }

  /// Бага үлдэгдэлтэй бараанууд олох (Alert engine-д ашиглах)
  Future<List<Product>> getLowStockProducts(String storeId) async {
    final allProducts = await (select(products)
          ..where((p) => p.storeId.equals(storeId) & p.isDeleted.equals(false)))
        .get();

    final lowStockProducts = <Product>[];

    for (final product in allProducts) {
      final currentStock = await getCurrentStock(product.id);
      if (currentStock <= product.lowStockThreshold) {
        lowStockProducts.add(product);
      }
    }

    return lowStockProducts;
  }

  /// Өнөөдрийн нийт борлуулалт (Dashboard)
  Future<int> getTodayTotalSales(String storeId) async {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);

    final result = await (select(sales)
          ..where((s) =>
              s.storeId.equals(storeId) & s.timestamp.isBiggerOrEqualValue(startOfDay)))
        .get();

    return result.fold<int>(0, (sum, sale) => sum + sale.totalAmount);
  }

  /// Өчигдрийн нийт борлуулалт (Dashboard - өсөлтийн хувь тооцоход)
  Future<int> getYesterdayTotalSales(String storeId) async {
    final today = DateTime.now();
    final startOfYesterday = DateTime(today.year, today.month, today.day)
        .subtract(const Duration(days: 1));
    final endOfYesterday = DateTime(today.year, today.month, today.day);

    final result = await (select(sales)
          ..where((s) =>
              s.storeId.equals(storeId) &
              s.timestamp.isBiggerOrEqualValue(startOfYesterday) &
              s.timestamp.isSmallerThanValue(endOfYesterday)))
        .get();

    return result.fold<int>(0, (sum, sale) => sum + sale.totalAmount);
  }

  /// Шилдэг борлуулалттай бараанууд
  ///
  /// [dateRange] options:
  /// - 'today': Өнөөдөр борлуулсан (default)
  /// - 'week': 7 хоногийн
  /// - 'month': Сарын
  /// - 'all': Бүх цагийн
  Future<List<Map<String, dynamic>>> getTopSellingProducts(
    String storeId, {
    int limit = 5,
    String dateRange = 'all',
  }) async {
    // Join: Sales → SaleItems → Products
    // Group by product, sum quantities
    final whereClause = _getDateFilter(dateRange);

    final query = customSelect(
      '''
      SELECT
        p.id,
        p.name,
        SUM(si.quantity) as total_quantity,
        SUM(si.subtotal) as total_revenue
      FROM sale_items si
      INNER JOIN sales s ON si.sale_id = s.id
      INNER JOIN products p ON si.product_id = p.id
      WHERE s.store_id = ?
        $whereClause
      GROUP BY p.id
      ORDER BY total_quantity DESC
      LIMIT ?
      ''',
      variables: [Variable(storeId), Variable(limit)],
    );

    final result = await query.get();
    return result.map((row) => row.data).toList();
  }

  /// Date filter helper for getTopSellingProducts
  String _getDateFilter(String dateRange) {
    switch (dateRange) {
      case 'today':
        return "AND s.timestamp >= date('now', 'start of day')";
      case 'week':
        return "AND s.timestamp >= date('now', '-7 days')";
      case 'month':
        return "AND s.timestamp >= date('now', '-1 month')";
      case 'all':
      default:
        return ''; // No date filter
    }
  }

  // ============================================================================
  // SYNC QUEUE METHODS
  // ============================================================================

  /// Sync queue-д үйлдэл нэмэх
  Future<int> enqueueSyncOperation({
    required String entityType,
    required String operation,
    required String payload,
  }) async {
    return await into(syncQueue).insert(
      SyncQueueCompanion.insert(
        entityType: entityType,
        operation: operation,
        payload: payload,
        createdAt: Value(DateTime.now()),
      ),
    );
  }

  /// Sync хийгдээгүй үйлдлүүдийг авах
  Future<List<SyncQueueData>> getPendingSyncOperations({int limit = 50}) async {
    return await (select(syncQueue)
          ..where((sq) => sq.synced.equals(false))
          ..orderBy([(sq) => OrderingTerm(expression: sq.createdAt)])
          ..limit(limit))
        .get();
  }

  /// Sync амжилттай болсныг тэмдэглэх
  Future<void> markSynced(int syncId) async {
    await (update(syncQueue)..where((sq) => sq.id.equals(syncId)))
        .write(const SyncQueueCompanion(synced: Value(true)));
  }

  /// Sync failed - retry count нэмэх
  Future<void> incrementRetryCount(int syncId, String errorMsg) async {
    final current = await (select(syncQueue)..where((sq) => sq.id.equals(syncId)))
        .getSingle();

    await (update(syncQueue)..where((sq) => sq.id.equals(syncId))).write(
      SyncQueueCompanion(
        retryCount: Value(current.retryCount + 1),
        errorMessage: Value(errorMsg),
      ),
    );
  }
}
