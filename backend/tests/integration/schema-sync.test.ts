/**
 * Schema Sync Validation Tests
 *
 * Эдгээр тестүүд нь Backend ба Mobile хоорондын schema consistency шалгана.
 * Хэрэв schema өөрчлөгдөх үед нэг талыг шинэчлээгүй бол тест FAIL хийнэ.
 *
 * АНХААР: Энэ тестүүд CI/CD дээр ажиллах ёстой - merge хийхээс өмнө барьдаг!
 */

import { test, expect, describe } from 'vitest';
import { supabase } from '../../src/config/supabase.js';

describe('Schema Sync Validation - Backend → Mobile', () => {
  /**
   * TEST 1: Product Schema
   * Mobile _upsertProduct() функц эдгээр талбаруудыг бүгдийг handle хийх ёстой
   */
  test('Product schema: Backend /changes бүх шаардлагатай талбартай', async () => {
    // TRUTH SOURCE: Mobile-д ХЭРЭГТЭЙ талбарууд
    // Хэрэв энэ жагсаалт өөрчлөгдвөл mobile sync_queue_manager.dart бас өөрчлөгдөх ёстой!
    const requiredFields = [
      'id',
      'store_id',
      'name',
      'sku',
      'unit',
      'sell_price',
      'cost_price',
      'low_stock_threshold',
      'category', // FIX 1.1: Энэ алдагдаж байсан
      'note', // FIX 1.1: Энэ алдагдаж байсан
      'image_url', // FIX 1.1: Энэ алдагдаж байсан
      'created_at',
      'updated_at',
      'is_deleted',
    ];

    // Backend query (sync endpoint /changes-ийн адил)
    const { data: products, error } = await supabase
      .from('products')
      .select('*')
      .limit(1);

    expect(error).toBeNull();

    if (products && products.length > 0) {
      const product = products[0];

      // Verify: Бүх талбар байгаа эсэх
      for (const field of requiredFields) {
        expect(
          product,
          `❌ Missing field: "${field}" in products table! Mobile sync алдана!`
        ).toHaveProperty(field);
      }

      console.log('✅ Product schema: Бүх талбар байна');
    } else {
      console.warn('⚠️ No products in database - test skipped');
    }
  });

  /**
   * TEST 2: Sale + SaleItems Schema
   * Mobile _upsertSale() embedded sale_items handle хийх ёстой
   */
  test('Sale schema: sale_items embedded байгаа эсэх', async () => {
    const requiredSaleFields = [
      'id',
      'store_id',
      'seller_id',
      'shift_id',
      'total_amount',
      'payment_method',
      'timestamp',
      'synced_at',
    ];

    const requiredSaleItemFields = [
      'id',
      'sale_id',
      'product_id',
      'quantity',
      'unit_price',
      'subtotal',
    ];

    // Backend query (sync endpoint-ийн адил - embedded sale_items)
    const { data: sales, error } = await supabase
      .from('sales')
      .select('*, sale_items(*)')
      .limit(1);

    expect(error).toBeNull();

    if (sales && sales.length > 0) {
      const sale = sales[0];

      // Verify: Sale fields
      for (const field of requiredSaleFields) {
        expect(
          sale,
          `❌ Missing field: "${field}" in sales table!`
        ).toHaveProperty(field);
      }

      // Verify: sale_items embedded байгаа эсэх
      expect(sale, '❌ sale_items embedded байхгүй байна!').toHaveProperty(
        'sale_items'
      );
      expect(
        Array.isArray(sale.sale_items),
        '❌ sale_items array биш байна!'
      ).toBe(true);

      // Verify: SaleItem fields (хэрэв items байвал)
      if (sale.sale_items.length > 0) {
        const item = sale.sale_items[0];
        for (const field of requiredSaleItemFields) {
          expect(
            item,
            `❌ Missing field: "${field}" in sale_items!`
          ).toHaveProperty(field);
        }
      }

      console.log('✅ Sale schema: sale_items embedded зөв');
    } else {
      console.warn('⚠️ No sales in database - test skipped');
    }
  });

  /**
   * TEST 3: Shift Schema
   * Mobile _updateLocalShiftId() функц эдгээр FK-уудыг update хийх ёстой
   */
  test('Shift schema: Бүх FK fields байгаа эсэх', async () => {
    const requiredFields = [
      'id',
      'store_id',
      'seller_id', // FK → users
      'opened_at',
      'closed_at',
      'open_balance',
      'close_balance',
      'synced_at',
    ];

    const { data: shifts, error } = await supabase
      .from('shifts')
      .select('*')
      .limit(1);

    expect(error).toBeNull();

    if (shifts && shifts.length > 0) {
      const shift = shifts[0];

      for (const field of requiredFields) {
        expect(
          shift,
          `❌ Missing field: "${field}" in shifts table!`
        ).toHaveProperty(field);
      }

      console.log('✅ Shift schema: Бүх FK fields байна');
    } else {
      console.warn('⚠️ No shifts in database - test skipped');
    }
  });

  /**
   * TEST 4: Inventory Events Schema
   */
  test('Inventory Events schema: event_type болон FK fields', async () => {
    const requiredFields = [
      'id',
      'store_id',
      'product_id', // FK → products
      'event_type', // INITIAL, SALE, ADJUST, RETURN
      'qty_change',
      'actor_id', // FK → users
      'shift_id', // FK → shifts (nullable)
      'reason',
      'timestamp',
      'synced_at',
    ];

    const { data: events, error } = await supabase
      .from('inventory_events')
      .select('*')
      .limit(1);

    expect(error).toBeNull();

    if (events && events.length > 0) {
      const event = events[0];

      for (const field of requiredFields) {
        expect(
          event,
          `❌ Missing field: "${field}" in inventory_events table!`
        ).toHaveProperty(field);
      }

      // Verify: event_type valid values
      expect(['INITIAL', 'SALE', 'ADJUST', 'RETURN']).toContain(
        event.event_type
      );

      console.log('✅ Inventory Events schema: Зөв');
    } else {
      console.warn('⚠️ No inventory events in database - test skipped');
    }
  });

  /**
   * TEST 5: Alerts Schema
   */
  test('Alerts schema: alert_type болон бүх fields', async () => {
    const requiredFields = [
      'id',
      'store_id',
      'alert_type', // low_stock, negative_inventory, suspicious_activity, system
      'product_id', // FK → products (nullable)
      'message',
      'level', // info, warning, error
      'resolved',
      'created_at',
      'resolved_at',
    ];

    const { data: alerts, error } = await supabase
      .from('alerts')
      .select('*')
      .limit(1);

    expect(error).toBeNull();

    if (alerts && alerts.length > 0) {
      const alert = alerts[0];

      for (const field of requiredFields) {
        expect(
          alert,
          `❌ Missing field: "${field}" in alerts table!`
        ).toHaveProperty(field);
      }

      console.log('✅ Alerts schema: Зөв');
    } else {
      console.warn('⚠️ No alerts in database - test skipped');
    }
  });

  /**
   * TEST 6: Data Types Consistency
   * Mobile INTEGER ↔ Backend INTEGER (Mongolian Tugrug - no decimals)
   */
  test('Price fields: INTEGER type (no decimals)', async () => {
    const { data: products } = await supabase
      .from('products')
      .select('sell_price, cost_price')
      .limit(1);

    if (products && products.length > 0) {
      const product = products[0];

      // Verify: INTEGER type (жинхэнэ тоо байх ёстой, decimal биш)
      expect(Number.isInteger(product.sell_price)).toBe(true);

      if (product.cost_price !== null) {
        expect(Number.isInteger(product.cost_price)).toBe(true);
      }

      console.log('✅ Price fields: INTEGER type зөв');
    }
  });
});

/**
 * ХЭРХЭН АШИГЛАХ ВЭ:
 *
 * 1. Local test:
 *    cd backend
 *    npm test -- schema-sync.test.ts
 *
 * 2. CI/CD:
 *    .github/workflows/test.yml дээр ажиллуулах
 *
 * 3. Schema өөрчлөх үед:
 *    - Backend column нэмсэн → requiredFields array update
 *    - Mobile _upsert* functions update
 *    - Тест дахин ажиллуулах → PASS хийх ёстой
 *
 * 4. Хэрэв тест FAIL:
 *    - Schema mismatch байна гэсэн үг
 *    - SCHEMA_CHANGE_CHECKLIST.md-г дагаж мөрдөөгүй
 *    - Merge хийхгүй! Schema sync хийх хэрэгтэй
 */
