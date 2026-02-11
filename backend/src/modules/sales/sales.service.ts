/**
 * Sales Service
 *
 * Business logic for sales management:
 * - Create sale (with inventory event)
 * - List sales
 * - Get sale details
 * - Void sale (reverse inventory)
 */

import { supabase } from '../../config/supabase.js';
import type { SaleInsert, SaleItemInsert } from '../../config/supabase.js';
import type { CreateSaleBody, SalesQueryParams } from './sales.schema.js';
import { checkLowStock, checkNegativeStock, createAlert } from '../alerts/alerts.service.js';

type ServiceResult<T> =
  | { success: true } & T
  | { success: false; error: string };

/**
 * Борлуулалт бүртгэх
 * - Хөнгөлөлтийн validation (discount_amount <= original_price)
 * - Sale + Sale items үүсгэх (cost_price хадгалах)
 * - Inventory events үүсгэх (SALE)
 * - Stock шалгах (negative stock warning)
 */
export async function createSale(
  storeId: string,
  sellerId: string,
  data: CreateSaleBody
): Promise<ServiceResult<{ sale: Record<string, unknown> }>> {
  try {
    // 1. Бүх бараануудын мэдээллийг авах (cost_price-тай)
    const productIds = data.items.map((item) => item.product_id);
    const { data: products, error: productsError } = await supabase
      .from('products')
      .select('id, name, sku, sell_price, cost_price, is_deleted')
      .eq('store_id', storeId)
      .in('id', productIds);

    if (productsError || !products || products.length !== productIds.length) {
      return { success: false, error: 'Бараа олдсонгүй эсвэл алдаа гарлаа' };
    }

    // Устгагдсан бараа байгаа эсэх
    const deletedProduct = products.find((p) => p.is_deleted);
    if (deletedProduct) {
      return { success: false, error: `Бараа "${deletedProduct.name}" устгагдсан байна` };
    }

    // 2. Хөнгөлөлт validation
    for (const item of data.items) {
      if (item.discount_amount > 0) {
        const origPrice = item.original_price ?? item.unit_price + item.discount_amount;
        if (item.discount_amount > origPrice) {
          const product = products.find((p) => p.id === item.product_id);
          return {
            success: false,
            error: `"${product?.name}" барааны хөнгөлөлт (${item.discount_amount}) анхны үнээс (${origPrice}) хэтэрч байна`,
          };
        }
      }
    }

    // 3. Total amount + total discount тооцоолох
    const totalAmount = data.items.reduce((sum, item) => sum + item.quantity * item.unit_price, 0);
    const totalDiscount = data.items.reduce(
      (sum, item) => sum + item.quantity * (item.discount_amount ?? 0), 0
    );

    // 4. Sale үүсгэх (type-safe)
    const saleData: SaleInsert = {
      store_id: storeId,
      seller_id: sellerId,
      shift_id: data.shift_id ?? null,
      total_amount: totalAmount,
      total_discount: totalDiscount,
      payment_method: data.payment_method,
      synced_at: new Date().toISOString(),
    };

    const { data: sale, error: saleError } = await supabase
      .from('sales')
      .insert(saleData)
      .select()
      .single();

    if (saleError || !sale) {
      return { success: false, error: 'Борлуулалт үүсгэхэд алдаа гарлаа' };
    }

    // 5. Sale items үүсгэх (хөнгөлөлт + cost_price-тай)
    const saleItemsData: SaleItemInsert[] = data.items.map((item) => {
      const product = products.find((p) => p.id === item.product_id);
      const origPrice = item.original_price ?? item.unit_price + (item.discount_amount ?? 0);

      return {
        sale_id: sale.id,
        product_id: item.product_id,
        quantity: item.quantity,
        unit_price: item.unit_price,
        subtotal: item.quantity * item.unit_price,
        original_price: origPrice,
        discount_amount: item.discount_amount ?? 0,
        cost_price: product?.cost_price ?? 0,
      };
    });

    const { data: saleItems, error: saleItemsError } = await supabase
      .from('sale_items')
      .insert(saleItemsData)
      .select();

    if (saleItemsError || !saleItems) {
      await supabase.from('sales').delete().eq('id', sale.id);
      return { success: false, error: 'Sale items үүсгэхэд алдаа гарлаа' };
    }

    // 6. Inventory events үүсгэх (SALE)
    const inventoryEventsData = data.items.map((item) => ({
      store_id: storeId,
      product_id: item.product_id,
      event_type: 'SALE',
      qty_change: -item.quantity,
      actor_id: sellerId,
      shift_id: data.shift_id ?? null,
      reason: `Sale ${sale.id}`,
    }));

    const { error: eventsError } = await supabase
      .from('inventory_events')
      .insert(inventoryEventsData);

    if (eventsError) {
      // sale_items + sale хоёуланг нь cleanup хийх
      await supabase.from('sale_items').delete().eq('sale_id', sale.id);
      await supabase.from('sales').delete().eq('id', sale.id);
      return { success: false, error: 'Inventory events үүсгэхэд алдаа гарлаа' };
    }

    // 7. Materialized view шинэчлэх
    try { await supabase.rpc('refresh_product_stock_levels'); } catch { /* skip */ }

    // 8. Alert triggers (background)
    for (const item of data.items) {
      checkLowStock(storeId, item.product_id).catch((err) =>
        console.error('Low stock check failed:', err)
      );
      checkNegativeStock(storeId, item.product_id).catch((err) =>
        console.error('Negative stock check failed:', err)
      );
    }

    // 8.1 Хэт их хөнгөлөлтийн alert (EXCESSIVE_DISCOUNT)
    // Нэг борлуулалтад 20%-иас дээш хөнгөлөлт өгсөн бол сэрэмжлүүлэг
    if (totalDiscount > 0) {
      const originalTotal = totalAmount + totalDiscount;
      const discountPercent = (totalDiscount / originalTotal) * 100;
      if (discountPercent > 20) {
        // Худалдагчийн нэр авах
        const { data: seller } = await supabase
          .from('users')
          .select('name')
          .eq('id', sellerId)
          .single();

        createAlert(storeId, {
          alert_type: 'excessive_discount',
          message: `Худалдагч "${seller?.name ?? '?'}" ${discountPercent.toFixed(0)}% хөнгөлөлт өгсөн (₮${totalDiscount.toLocaleString()}) — Борлуулалт #${String(sale.id).substring(0, 8)}`,
          level: 'warning',
        }).catch(() => { /* silent */ });
      }
    }

    // 9. Response format
    const itemsWithNames = saleItems.map((item) => {
      const product = products.find((p) => p.id === item.product_id);
      return {
        id: item.id,
        product_id: item.product_id,
        product_name: product?.name ?? 'Unknown',
        quantity: item.quantity,
        unit_price: item.unit_price,
        original_price: item.original_price,
        discount_amount: item.discount_amount,
        subtotal: item.subtotal,
      };
    });

    return {
      success: true,
      sale: {
        id: sale.id,
        store_id: sale.store_id,
        seller_id: sale.seller_id,
        shift_id: sale.shift_id,
        total_amount: sale.total_amount,
        total_discount: sale.total_discount,
        payment_method: sale.payment_method,
        timestamp: sale.timestamp,
        items: itemsWithNames,
      },
    };
  } catch (error) {
    return { success: false, error: 'Серверийн алдаа' };
  }
}

/**
 * Борлуулалтын түүх авах
 */
export async function getSales(
  storeId: string,
  query: SalesQueryParams
): Promise<ServiceResult<{ sales: any[]; pagination: any }>> {
  try {
    // 1. Query үүсгэх
    let queryBuilder = supabase
      .from('sales')
      .select('*, users!inner(name)', { count: 'exact' })
      .eq('store_id', storeId)
      .order('timestamp', { ascending: false });

    // Filters
    if (query.seller_id) {
      queryBuilder = queryBuilder.eq('seller_id', query.seller_id);
    }
    if (query.shift_id) {
      queryBuilder = queryBuilder.eq('shift_id', query.shift_id);
    }
    if (query.payment_method) {
      queryBuilder = queryBuilder.eq('payment_method', query.payment_method);
    }
    if (query.from) {
      queryBuilder = queryBuilder.gte('timestamp', query.from);
    }
    if (query.to) {
      queryBuilder = queryBuilder.lte('timestamp', query.to);
    }

    // Pagination
    queryBuilder = queryBuilder.range(query.offset, query.offset + query.limit - 1);

    const { data: sales, error, count } = await queryBuilder;

    if (error || !sales) {
      return { success: false, error: 'Борлуулалтын түүх авахад алдаа гарлаа' };
    }

    // 2. Response format
    const formattedSales = sales.map((sale: any) => ({
      id: sale.id,
      store_id: sale.store_id,
      seller_id: sale.seller_id,
      seller_name: sale.users.name,
      shift_id: sale.shift_id,
      total_amount: parseFloat(sale.total_amount),
      payment_method: sale.payment_method,
      timestamp: sale.timestamp,
      synced_at: sale.synced_at,
    }));

    return {
      success: true,
      sales: formattedSales,
      pagination: {
        total: count ?? 0,
        limit: query.limit,
        offset: query.offset,
      },
    };
  } catch (error) {
    return { success: false, error: 'Серверийн алдаа' };
  }
}

/**
 * Борлуулалт дэлгэрэнгүй авах
 */
export async function getSale(
  saleId: string,
  storeId: string
): Promise<ServiceResult<{ sale: any }>> {
  try {
    // 1. Sale авах
    const { data: sale, error: saleError } = await supabase
      .from('sales')
      .select('*, users!inner(name)')
      .eq('id', saleId)
      .eq('store_id', storeId)
      .single();

    if (saleError || !sale) {
      return { success: false, error: 'Борлуулалт олдсонгүй' };
    }

    // 2. Sale items авах
    const { data: saleItems, error: itemsError } = await supabase
      .from('sale_items')
      .select('*, products!inner(name, sku)')
      .eq('sale_id', saleId);

    if (itemsError || !saleItems) {
      return { success: false, error: 'Sale items авахад алдаа гарлаа' };
    }

    // 3. Response format
    const formattedItems = saleItems.map((item: any) => ({
      id: item.id,
      product_id: item.product_id,
      product_name: item.products.name,
      product_sku: item.products.sku,
      quantity: item.quantity,
      unit_price: parseFloat(item.unit_price),
      subtotal: parseFloat(item.subtotal),
    }));

    return {
      success: true,
      sale: {
        id: sale.id,
        store_id: sale.store_id,
        seller_id: sale.seller_id,
        seller_name: sale.users.name,
        shift_id: sale.shift_id,
        total_amount: parseFloat(String(sale.total_amount)),
        payment_method: sale.payment_method,
        timestamp: sale.timestamp,
        synced_at: sale.synced_at,
        items: formattedItems,
      },
    };
  } catch (error) {
    return { success: false, error: 'Серверийн алдаа' };
  }
}

/**
 * Борлуулалт цуцлах
 * - RETURN event үүсгэнэ
 * - Stock-ыг буцаана
 */
export async function voidSale(
  saleId: string,
  storeId: string,
  actorId: string
): Promise<ServiceResult<{ message: string }>> {
  try {
    // 1. Sale олох
    const { data: sale, error: saleError } = await supabase
      .from('sales')
      .select('id, store_id, seller_id, shift_id')
      .eq('id', saleId)
      .eq('store_id', storeId)
      .single();

    if (saleError || !sale) {
      return { success: false, error: 'Борлуулалт олдсонгүй' };
    }

    // 2. Sale items олох
    const { data: saleItems, error: itemsError } = await supabase
      .from('sale_items')
      .select('product_id, quantity')
      .eq('sale_id', saleId);

    if (itemsError || !saleItems) {
      return { success: false, error: 'Sale items олдсонгүй' };
    }

    // 3. RETURN inventory events үүсгэх
    const returnEventsData = saleItems.map((item: any) => ({
      store_id: storeId,
      product_id: item.product_id,
      event_type: 'RETURN',
      qty_change: item.quantity, // Буцаалт нь нэмэх
      actor_id: actorId,
      shift_id: sale.shift_id ?? null,
      reason: `Void sale ${saleId}`,
    }));

    const { error: eventsError } = await supabase
      .from('inventory_events')
      .insert(returnEventsData);

    if (eventsError) {
      return { success: false, error: 'Inventory events үүсгэхэд алдаа гарлаа' };
    }

    // 4. Sale устгах (soft delete биш, бодит устгах)
    const { error: deleteError } = await supabase.from('sales').delete().eq('id', saleId);

    if (deleteError) {
      return { success: false, error: 'Борлуулалт устгахад алдаа гарлаа' };
    }

    // 5. Materialized view шинэчлэх
    await supabase.rpc('refresh_product_stock_levels');

    // 6. Alert triggers - return хийсний дараа stock шалгах
    for (const item of saleItems) {
      checkLowStock(storeId, item.product_id).catch((err) =>
        console.error('Low stock check failed:', err)
      );
      checkNegativeStock(storeId, item.product_id).catch((err) =>
        console.error('Negative stock check failed:', err)
      );
    }

    // 7. HIGH_VOID_RATE alert шалгах
    // Өнөөдөр 3-с олон void хийсэн бол сэрэмжлүүлэг
    const todayStart = new Date();
    todayStart.setHours(0, 0, 0, 0);
    const { count: voidCount } = await supabase
      .from('inventory_events')
      .select('*', { count: 'exact', head: true })
      .eq('store_id', storeId)
      .eq('event_type', 'RETURN')
      .eq('actor_id', actorId)
      .gte('timestamp', todayStart.toISOString());

    if (voidCount !== null && voidCount >= 3) {
      const { data: actor } = await supabase
        .from('users')
        .select('name')
        .eq('id', actorId)
        .single();

      createAlert(storeId, {
        alert_type: 'high_void_rate',
        message: `Худалдагч "${actor?.name ?? '?'}" өнөөдөр ${voidCount} борлуулалт цуцалсан`,
        level: 'warning',
      }).catch(() => { /* silent */ });
    }

    return {
      success: true,
      message: 'Борлуулалт амжилттай цуцлагдлаа',
    };
  } catch (error) {
    return { success: false, error: 'Серверийн алдаа' };
  }
}
