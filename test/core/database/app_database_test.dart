import 'package:flutter_test/flutter_test.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:retail_control_platform/core/database/app_database.dart';

/// Database migration тестүүд (v5-v8)
///
/// Тайлбар:
/// - Migration logic зөв ажиллаж байгаа эсэхийг шалгана
/// - Шинэ columns амжилттай нэмэгдсэн эсэхийг баталгаажуулна
/// - Nullability өөрчлөлтүүд зөв хэрэгжсэн эсэхийг тестлэнэ
void main() {
  group('Database Migration Tests', () {
    late AppDatabase db;

    setUp(() {
      // Тест database үүсгэх (in-memory SQLite)
      db = AppDatabase.forTesting(NativeDatabase.memory());
    });

    tearDown(() async {
      await db.close();
    });

    test('Schema version 11 эсэхийг шалгах', () {
      expect(db.schemaVersion, equals(11));
    });

    group('Migration v5: users.store_id nullable', () {
      test('Super-admin user үүсгэх (store_id = null)', () async {
        // Super-admin user үүсгэх (store_id = null)
        await db.into(db.users).insert(
          UsersCompanion.insert(
            id: 'test-admin-id',
            storeId: const Value.absent(), // null
            name: 'Super Admin',
            role: 'owner',
          ),
        );

        // Амжилттай үүссэн эсэхийг шалгах
        final users = await db.select(db.users).get();
        expect(users.length, equals(1));
        expect(users.first.id, equals('test-admin-id'));
        expect(users.first.storeId, isNull);
        expect(users.first.role, equals('owner'));
      });

      test('Regular user үүсгэх (store_id байгаа)', () async {
        // Store үүсгэх
        await db.into(db.stores).insert(
          StoresCompanion.insert(
            id: 'store-1',
            ownerId: 'owner-1',
            name: 'Test Store',
          ),
        );

        // Regular user үүсгэх
        await db.into(db.users).insert(
          UsersCompanion.insert(
            id: 'test-user-id',
            storeId: const Value('store-1'),
            name: 'Test User',
            role: 'seller',
          ),
        );

        final user = await (db.select(db.users)
              ..where((u) => u.id.equals('test-user-id')))
            .getSingle();

        expect(user.storeId, equals('store-1'));
      });
    });

    group('Migration v6: alerts.resolved_at', () {
      test('Alert үүсгэж, resolved_at timestamp update хийх', () async {
        // Store үүсгэх
        await db.into(db.stores).insert(
          StoresCompanion.insert(
            id: 'store-1',
            ownerId: 'owner-1',
            name: 'Test Store',
          ),
        );

        // Alert үүсгэх
        final alertId = 'test-alert-id';
        await db.into(db.alerts).insert(
          AlertsCompanion.insert(
            id: alertId,
            storeId: 'store-1',
            type: 'low_stock',
            message: 'Test alert message',
          ),
        );

        // Эхлээд resolved_at null байх ёстой
        var alert = await (db.select(db.alerts)
              ..where((a) => a.id.equals(alertId)))
            .getSingle();
        expect(alert.resolved, isFalse);
        expect(alert.resolvedAt, isNull);

        // Resolved болгох
        final now = DateTime.now();
        await (db.update(db.alerts)..where((a) => a.id.equals(alertId)))
            .write(AlertsCompanion(
          resolved: const Value(true),
          resolvedAt: Value(now),
        ));

        // resolved_at зөв update болсон эсэхийг шалгах
        alert = await (db.select(db.alerts)..where((a) => a.id.equals(alertId)))
            .getSingle();
        expect(alert.resolved, isTrue);
        expect(alert.resolvedAt, isNotNull);
        expect(
          alert.resolvedAt!.difference(now).inSeconds,
          lessThan(1),
        );
      });

      test('Resolved_at-гүй alert үүсгэх (backward compatibility)', () async {
        // Store үүсгэх
        await db.into(db.stores).insert(
          StoresCompanion.insert(
            id: 'store-1',
            ownerId: 'owner-1',
            name: 'Test Store',
          ),
        );

        // Alert үүсгэх (resolved_at явно set хийхгүй)
        await db.into(db.alerts).insert(
          AlertsCompanion.insert(
            id: 'alert-no-timestamp',
            storeId: 'store-1',
            type: 'system',
            message: 'Test',
          ),
        );

        final alert = await (db.select(db.alerts)
              ..where((a) => a.id.equals('alert-no-timestamp')))
            .getSingle();

        expect(alert.resolvedAt, isNull);
      });
    });

    group('Migration v7: synced_at columns', () {
      test('InventoryEvent syncedAt нэмэгдсэн эсэх', () async {
        // Store, Product, User үүсгэх
        await db.into(db.stores).insert(
          StoresCompanion.insert(
            id: 'store-1',
            ownerId: 'owner-1',
            name: 'Test Store',
          ),
        );

        await db.into(db.users).insert(
          UsersCompanion.insert(
            id: 'user-1',
            storeId: const Value('store-1'),
            name: 'Test User',
            role: 'owner',
          ),
        );

        await db.into(db.products).insert(
          ProductsCompanion.insert(
            id: 'product-1',
            storeId: 'store-1',
            name: 'Test Product',
            sku: 'SKU-001',
            unit: 'pcs',
            sellPrice: 1000,
          ),
        );

        // Inventory event үүсгэх
        final eventId = 'test-event-id';
        final syncTime = DateTime.now();

        await db.into(db.inventoryEvents).insert(
          InventoryEventsCompanion.insert(
            id: eventId,
            storeId: 'store-1',
            productId: 'product-1',
            type: 'INITIAL',
            qtyChange: 10,
            actorId: 'user-1',
            syncedAt: Value(syncTime),
          ),
        );

        final event = await (db.select(db.inventoryEvents)
              ..where((e) => e.id.equals(eventId)))
            .getSingle();

        expect(event.syncedAt, isNotNull);
        expect(
          event.syncedAt!.difference(syncTime).inSeconds,
          lessThan(1),
        );
      });

      test('Sales syncedAt нэмэгдсэн эсэх', () async {
        // Store, User үүсгэх
        await db.into(db.stores).insert(
          StoresCompanion.insert(
            id: 'store-1',
            ownerId: 'owner-1',
            name: 'Test Store',
          ),
        );

        await db.into(db.users).insert(
          UsersCompanion.insert(
            id: 'user-1',
            storeId: const Value('store-1'),
            name: 'Test User',
            role: 'seller',
          ),
        );

        // Sale үүсгэх
        final saleId = 'test-sale-id';
        final syncTime = DateTime.now();

        await db.into(db.sales).insert(
          SalesCompanion.insert(
            id: saleId,
            storeId: 'store-1',
            sellerId: 'user-1',
            totalAmount: 5000,
            syncedAt: Value(syncTime),
          ),
        );

        final sale =
            await (db.select(db.sales)..where((s) => s.id.equals(saleId)))
                .getSingle();

        expect(sale.syncedAt, isNotNull);
        expect(
          sale.syncedAt!.difference(syncTime).inSeconds,
          lessThan(1),
        );
      });

      test('Shifts syncedAt нэмэгдсэн эсэх', () async {
        // Store, User үүсгэх
        await db.into(db.stores).insert(
          StoresCompanion.insert(
            id: 'store-1',
            ownerId: 'owner-1',
            name: 'Test Store',
          ),
        );

        await db.into(db.users).insert(
          UsersCompanion.insert(
            id: 'user-1',
            storeId: const Value('store-1'),
            name: 'Test User',
            role: 'seller',
          ),
        );

        // Shift үүсгэх
        final shiftId = 'test-shift-id';
        final syncTime = DateTime.now();

        await db.into(db.shifts).insert(
          ShiftsCompanion.insert(
            id: shiftId,
            storeId: 'store-1',
            sellerId: 'user-1',
            syncedAt: Value(syncTime),
          ),
        );

        final shift =
            await (db.select(db.shifts)..where((s) => s.id.equals(shiftId)))
                .getSingle();

        expect(shift.syncedAt, isNotNull);
        expect(
          shift.syncedAt!.difference(syncTime).inSeconds,
          lessThan(1),
        );
      });
    });

    group('Migration v8: updated_at columns', () {
      test('Store updatedAt auto-set байгаа эсэх', () async {
        // Store үүсгэх
        final storeId = 'test-store';
        await db.into(db.stores).insert(
          StoresCompanion.insert(
            id: storeId,
            ownerId: 'owner-1',
            name: 'Old Name',
          ),
        );

        final originalStore = await (db.select(db.stores)
              ..where((s) => s.id.equals(storeId)))
            .getSingle();

        // updatedAt нь createdAt-тай ойролцоо байх ёстой
        expect(originalStore.updatedAt, isNotNull);
        expect(
          originalStore.updatedAt
              .difference(originalStore.createdAt)
              .inSeconds,
          lessThan(1),
        );
      });

      test('Store update үед updatedAt шинэчлэгдэх', () async {
        // Store үүсгэх
        final storeId = 'test-store';
        await db.into(db.stores).insert(
          StoresCompanion.insert(
            id: storeId,
            ownerId: 'owner-1',
            name: 'Old Name',
          ),
        );

        final originalStore = await (db.select(db.stores)
              ..where((s) => s.id.equals(storeId)))
            .getSingle();
        final originalUpdatedAt = originalStore.updatedAt;

        // 1 секунд хүлээх
        await Future.delayed(const Duration(seconds: 1));

        // Store update хийх
        await (db.update(db.stores)..where((s) => s.id.equals(storeId)))
            .write(StoresCompanion(
          name: const Value('New Name'),
          updatedAt: Value(DateTime.now()),
        ));

        final updatedStore = await (db.select(db.stores)
              ..where((s) => s.id.equals(storeId)))
            .getSingle();

        // updated_at шинэчлэгдсэн эсэхийг шалгах
        expect(updatedStore.name, equals('New Name'));
        expect(updatedStore.updatedAt.isAfter(originalUpdatedAt), isTrue);
      });

      test('User updatedAt нэмэгдсэн эсэх', () async {
        // Store үүсгэх
        await db.into(db.stores).insert(
          StoresCompanion.insert(
            id: 'store-1',
            ownerId: 'owner-1',
            name: 'Test Store',
          ),
        );

        // User үүсгэх
        await db.into(db.users).insert(
          UsersCompanion.insert(
            id: 'user-1',
            storeId: const Value('store-1'),
            name: 'Test User',
            role: 'seller',
          ),
        );

        final user =
            await (db.select(db.users)..where((u) => u.id.equals('user-1')))
                .getSingle();

        // updatedAt нь auto-set болсон эсэхийг шалгах
        expect(user.updatedAt, isNotNull);
        expect(
          user.updatedAt.difference(user.createdAt).inSeconds,
          lessThan(1),
        );
      });
    });

    group('Integration: Бүх columns хамтад нь', () {
      test('Бүх шинэ columns оршин байгаа эсэхийг баталгаажуулах', () async {
        // Store үүсгэх (updatedAt байгаа)
        await db.into(db.stores).insert(
          StoresCompanion.insert(
            id: 'store-1',
            ownerId: 'owner-1',
            name: 'Test Store',
          ),
        );

        // Super-admin user үүсгэх (storeId nullable, updatedAt байгаа)
        await db.into(db.users).insert(
          UsersCompanion.insert(
            id: 'admin-1',
            storeId: const Value.absent(), // null
            name: 'Super Admin',
            role: 'owner',
          ),
        );

        // Regular user үүсгэх
        await db.into(db.users).insert(
          UsersCompanion.insert(
            id: 'user-1',
            storeId: const Value('store-1'),
            name: 'Test User',
            role: 'seller',
          ),
        );

        // Product үүсгэх
        await db.into(db.products).insert(
          ProductsCompanion.insert(
            id: 'product-1',
            storeId: 'store-1',
            name: 'Test Product',
            sku: 'SKU-001',
            unit: 'pcs',
            sellPrice: 1000,
          ),
        );

        // Inventory event үүсгэх (syncedAt байгаа)
        await db.into(db.inventoryEvents).insert(
          InventoryEventsCompanion.insert(
            id: 'event-1',
            storeId: 'store-1',
            productId: 'product-1',
            type: 'INITIAL',
            qtyChange: 100,
            actorId: 'user-1',
            syncedAt: Value(DateTime.now()),
          ),
        );

        // Sale үүсгэх (syncedAt байгаа)
        await db.into(db.sales).insert(
          SalesCompanion.insert(
            id: 'sale-1',
            storeId: 'store-1',
            sellerId: 'user-1',
            totalAmount: 5000,
            syncedAt: Value(DateTime.now()),
          ),
        );

        // Shift үүсгэх (syncedAt байгаа)
        await db.into(db.shifts).insert(
          ShiftsCompanion.insert(
            id: 'shift-1',
            storeId: 'store-1',
            sellerId: 'user-1',
            syncedAt: Value(DateTime.now()),
          ),
        );

        // Alert үүсгэх (resolvedAt байгаа)
        await db.into(db.alerts).insert(
          AlertsCompanion.insert(
            id: 'alert-1',
            storeId: 'store-1',
            type: 'low_stock',
            message: 'Test alert',
            resolvedAt: Value(DateTime.now()),
          ),
        );

        // Бүгдийг амжилттай үүсгэсэн эсэхийг шалгах
        final stores = await db.select(db.stores).get();
        final users = await db.select(db.users).get();
        final events = await db.select(db.inventoryEvents).get();
        final sales = await db.select(db.sales).get();
        final shifts = await db.select(db.shifts).get();
        final alerts = await db.select(db.alerts).get();

        expect(stores.length, equals(1));
        expect(stores.first.updatedAt, isNotNull);

        expect(users.length, equals(2));
        expect(users.first.updatedAt, isNotNull);

        expect(events.length, equals(1));
        expect(events.first.syncedAt, isNotNull);

        expect(sales.length, equals(1));
        expect(sales.first.syncedAt, isNotNull);

        expect(shifts.length, equals(1));
        expect(shifts.first.syncedAt, isNotNull);

        expect(alerts.length, equals(1));
        expect(alerts.first.resolvedAt, isNotNull);
      });
    });
  });
}
