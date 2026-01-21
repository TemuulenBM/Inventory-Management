/**
 * Inventory Service
 *
 * Event sourcing based inventory management.
 * Current stock = SUM(qty_change) for a product.
 */

import { supabase } from '../../config/supabase.js';
import type {
  CreateInventoryEventBody,
  InventoryEventsQueryParams,
  StockHistoryQueryParams,
  InventoryEventInfo,
  StockLevelInfo,
} from './inventory.schema.js';

/**
 * Inventory event-үүд авах (pagination, filter)
 *
 * @param storeId - Store ID
 * @param query - Query parameters
 * @returns Event жагсаалт + pagination
 */
export async function getInventoryEvents(storeId: string, query: InventoryEventsQueryParams) {
  const { page, limit, productId, eventType, startDate, endDate } = query;
  const offset = (page - 1) * limit;

  let queryBuilder = supabase
    .from('inventory_events')
    .select('*, products(name), users(name)', { count: 'exact' })
    .eq('store_id', storeId);

  // Product filter
  if (productId) {
    queryBuilder = queryBuilder.eq('product_id', productId);
  }

  // Event type filter
  if (eventType) {
    queryBuilder = queryBuilder.eq('event_type', eventType);
  }

  // Date range filter
  if (startDate) {
    queryBuilder = queryBuilder.gte('timestamp', startDate);
  }
  if (endDate) {
    queryBuilder = queryBuilder.lte('timestamp', endDate);
  }

  // Pagination + sorting (newest first)
  queryBuilder = queryBuilder
    .order('timestamp', { ascending: false })
    .range(offset, offset + limit - 1);

  const { data: events, error, count } = await queryBuilder;

  if (error) {
    console.error('Get inventory events error:', error);
    return { success: false as const, error: 'Inventory event-үүд авахад алдаа гарлаа' };
  }

  const eventList: InventoryEventInfo[] = (events || []).map((e: any) => ({
    id: e.id,
    storeId: e.store_id,
    productId: e.product_id,
    productName: e.products?.name ?? undefined,
    eventType: e.event_type,
    qtyChange: e.qty_change,
    reason: e.reason,
    actorId: e.actor_id,
    actorName: e.users?.name ?? undefined,
    shiftId: e.shift_id,
    timestamp: e.timestamp ?? new Date().toISOString(),
  }));

  const total = count || 0;
  const totalPages = Math.ceil(total / limit);

  return {
    success: true as const,
    events: eventList,
    pagination: {
      page,
      limit,
      total,
      totalPages,
    },
  };
}

/**
 * Шинэ inventory event үүсгэх (Manual adjustment)
 *
 * @param storeId - Store ID
 * @param actorId - Хэн үүсгэсэн (user ID)
 * @param data - Event мэдээлэл
 * @returns Үүссэн event
 */
export async function createInventoryEvent(
  storeId: string,
  actorId: string,
  data: CreateInventoryEventBody
) {
  // Бараа байгаа эсэх шалгах
  const { data: product } = await supabase
    .from('products')
    .select('id, name')
    .eq('id', data.productId)
    .eq('store_id', storeId)
    .eq('is_deleted', false)
    .single();

  if (!product) {
    return { success: false as const, error: 'Бараа олдсонгүй' };
  }

  // Event үүсгэх
  const { data: event, error } = await supabase
    .from('inventory_events')
    .insert({
      store_id: storeId,
      product_id: data.productId,
      event_type: data.eventType,
      qty_change: data.qtyChange,
      reason: data.reason ?? null,
      actor_id: actorId,
      shift_id: data.shiftId ?? null,
    })
    .select()
    .single();

  if (error) {
    console.error('Create inventory event error:', error);
    return { success: false as const, error: 'Inventory event үүсгэхэд алдаа гарлаа' };
  }

  console.log(
    `📦 Inventory event: ${data.eventType} ${data.qtyChange > 0 ? '+' : ''}${data.qtyChange} for ${product.name}`
  );

  return {
    success: true as const,
    event: {
      id: event.id,
      storeId: event.store_id,
      productId: event.product_id,
      productName: product.name,
      eventType: event.event_type,
      qtyChange: event.qty_change,
      reason: event.reason,
      actorId: event.actor_id,
      shiftId: event.shift_id,
      timestamp: event.timestamp ?? new Date().toISOString(),
    },
  };
}

/**
 * Бүх барааны stock level авах
 *
 * @param storeId - Store ID
 * @returns Stock level жагсаалт + summary
 */
export async function getStockLevels(storeId: string) {
  // product_stock_levels view ашиглана
  const { data: stockLevels, error } = await supabase
    .from('product_stock_levels' as any)
    .select('*')
    .eq('store_id', storeId);

  if (error) {
    console.error('Get stock levels error:', error);
    return { success: false as const, error: 'Stock level авахад алдаа гарлаа' };
  }

  const stockList: StockLevelInfo[] = (stockLevels || []).map((s: any) => ({
    productId: s.product_id,
    productName: s.product_name ?? s.name ?? '',
    sku: s.sku,
    currentStock: s.current_stock ?? 0,
    lowStockThreshold: s.low_stock_threshold,
    isLowStock: s.is_low_stock ?? false,
    lastUpdated: s.last_updated,
  }));

  // Summary тооцоолох
  const totalProducts = stockList.length;
  const lowStockCount = stockList.filter((s) => s.isLowStock).length;
  const outOfStockCount = stockList.filter((s) => s.currentStock <= 0).length;

  return {
    success: true as const,
    stockLevels: stockList,
    summary: {
      totalProducts,
      lowStockCount,
      outOfStockCount,
    },
  };
}

/**
 * Нэг барааны stock түүх авах
 *
 * @param storeId - Store ID
 * @param productId - Product ID
 * @param query - Query parameters
 * @returns Stock түүх + pagination
 */
export async function getProductStockHistory(
  storeId: string,
  productId: string,
  query: StockHistoryQueryParams
) {
  const { page, limit } = query;
  const offset = (page - 1) * limit;

  // Бараа байгаа эсэх шалгах
  const { data: product } = await supabase
    .from('products')
    .select('id, name')
    .eq('id', productId)
    .eq('store_id', storeId)
    .eq('is_deleted', false)
    .single();

  if (!product) {
    return { success: false as const, error: 'Бараа олдсонгүй' };
  }

  // Current stock авах
  const { data: stockLevel } = await supabase
    .from('product_stock_levels' as any)
    .select('current_stock')
    .eq('product_id', productId)
    .single();

  const currentStock = (stockLevel as any)?.current_stock ?? 0;

  // Event түүх авах
  const { data: events, error, count } = await supabase
    .from('inventory_events')
    .select('*, users(name)', { count: 'exact' })
    .eq('store_id', storeId)
    .eq('product_id', productId)
    .order('timestamp', { ascending: false })
    .range(offset, offset + limit - 1);

  if (error) {
    console.error('Get product stock history error:', error);
    return { success: false as const, error: 'Stock түүх авахад алдаа гарлаа' };
  }

  const eventList: InventoryEventInfo[] = (events || []).map((e: any) => ({
    id: e.id,
    storeId: e.store_id,
    productId: e.product_id,
    eventType: e.event_type,
    qtyChange: e.qty_change,
    reason: e.reason,
    actorId: e.actor_id,
    actorName: e.users?.name ?? undefined,
    shiftId: e.shift_id,
    timestamp: e.timestamp ?? new Date().toISOString(),
  }));

  const total = count || 0;
  const totalPages = Math.ceil(total / limit);

  return {
    success: true as const,
    productId,
    productName: product.name,
    currentStock,
    events: eventList,
    pagination: {
      page,
      limit,
      total,
      totalPages,
    },
  };
}
