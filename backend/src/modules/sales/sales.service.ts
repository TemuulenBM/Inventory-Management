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
import type { CreateSaleBody, SalesQueryParams } from './sales.schema.js';

type ServiceResult<T> =
  | { success: true } & T
  | { success: false; error: string };

/**
 * Борлуулалт бүртгэх
 * - Sale үүсгэх
 * - Sale items үүсгэх
 * - Inventory events үүсгэх (SALE)
 * - Stock-ыг шалгах (negative stock warning)
 */
export async function createSale(
  storeId: string,
  sellerId: string,
  data: CreateSaleBody
): Promise<ServiceResult<{ sale: any }>> {
  try {
    // 1. Бүх бараануудын үнийг шалгах (product_id-ууд олдох эсэх)
    const productIds = data.items.map((item) => item.product_id);
    const { data: products, error: productsError } = await supabase
      .from('products')
      .select('id, name, sku, sell_price, is_deleted')
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

    // 2. Total amount тооцоолох
    const totalAmount = data.items.reduce((sum, item) => sum + item.quantity * item.unit_price, 0);

    // 3. Sale үүсгэх
    const { data: sale, error: saleError } = await supabase
      .from('sales')
      .insert({
        store_id: storeId,
        seller_id: sellerId,
        shift_id: data.shift_id ?? null,
        total_amount: totalAmount,
        payment_method: data.payment_method,
      })
      .select()
      .single();

    if (saleError || !sale) {
      return { success: false, error: 'Борлуулалт үүсгэхэд алдаа гарлаа' };
    }

    // 4. Sale items үүсгэх
    const saleItemsData = data.items.map((item) => ({
      sale_id: sale.id,
      product_id: item.product_id,
      quantity: item.quantity,
      unit_price: item.unit_price,
      subtotal: item.quantity * item.unit_price,
    }));

    const { data: saleItems, error: saleItemsError } = await supabase
      .from('sale_items')
      .insert(saleItemsData)
      .select();

    if (saleItemsError || !saleItems) {
      // Rollback sale
      await supabase.from('sales').delete().eq('id', sale.id);
      return { success: false, error: 'Sale items үүсгэхэд алдаа гарлаа' };
    }

    // 5. Inventory events үүсгэх (SALE)
    const inventoryEventsData = data.items.map((item) => ({
      store_id: storeId,
      product_id: item.product_id,
      event_type: 'SALE',
      qty_change: -item.quantity, // Борлуулалт нь хасах
      actor_id: sellerId,
      shift_id: data.shift_id ?? null,
      reason: `Sale ${sale.id}`,
    }));

    const { error: eventsError } = await supabase
      .from('inventory_events')
      .insert(inventoryEventsData);

    if (eventsError) {
      // Rollback sale & items
      await supabase.from('sales').delete().eq('id', sale.id);
      return { success: false, error: 'Inventory events үүсгэхэд алдаа гарлаа' };
    }

    // 6. Materialized view-г шинэчлэх
    await supabase.rpc('refresh_product_stock_levels');

    // 7. Response format
    const itemsWithNames = saleItems.map((item: any) => {
      const product = products.find((p) => p.id === item.product_id);
      return {
        id: item.id,
        product_id: item.product_id,
        product_name: product?.name ?? 'Unknown',
        quantity: item.quantity,
        unit_price: parseFloat(String(item.unit_price)),
        subtotal: parseFloat(String(item.subtotal)),
      };
    });

    return {
      success: true,
      sale: {
        id: sale.id,
        store_id: sale.store_id,
        seller_id: sale.seller_id,
        shift_id: sale.shift_id,
        total_amount: parseFloat(String(sale.total_amount)),
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

    return {
      success: true,
      message: 'Борлуулалт амжилттай цуцлагдлаа',
    };
  } catch (error) {
    return { success: false, error: 'Серверийн алдаа' };
  }
}
