/**
 * Sync Service
 *
 * Business logic for offline-first synchronization:
 * - Batch sync operations from mobile
 * - Delta sync (changes since timestamp)
 * - Conflict resolution (last-write-wins)
 */

import { supabase } from '../../config/supabase.js';
import type { BatchSyncBody, SyncOperation, ChangesQueryParams } from './sync.schema.js';
import { createSale, voidSale } from '../sales/sales.service.js';
import { createInventoryEvent } from '../inventory/inventory.service.js';

type ServiceResult<T> =
  | { success: true } & T
  | { success: false; error: string };

/**
 * Batch sync - Mobile-аас ирсэн offline operations-г sync хийх
 */
export async function processBatchSync(
  storeId: string,
  userId: string,
  data: BatchSyncBody
): Promise<
  ServiceResult<{
    synced: number;
    failed: number;
    results: Array<{
      client_id: string;
      status: 'success' | 'failed' | 'conflict';
      error?: string;
      server_id?: string;
    }>;
  }>
> {
  const results: Array<{
    client_id: string;
    status: 'success' | 'failed' | 'conflict';
    error?: string;
    server_id?: string;
  }> = [];

  let synced = 0;
  let failed = 0;

  // Process each operation
  for (const operation of data.operations) {
    try {
      const result = await processSingleOperation(storeId, userId, operation);

      if (result.success) {
        results.push({
          client_id: operation.client_id,
          status: 'success',
          server_id: result.server_id,
        });
        synced++;
      } else {
        results.push({
          client_id: operation.client_id,
          status: result.status || 'failed',
          error: result.error,
        });
        failed++;
      }
    } catch (err: any) {
      results.push({
        client_id: operation.client_id,
        status: 'failed',
        error: err.message || 'Unexpected error',
      });
      failed++;
    }
  }

  return {
    success: true,
    synced,
    failed,
    results,
  };
}

/**
 * Single operation process хийх
 */
async function processSingleOperation(
  storeId: string,
  userId: string,
  operation: SyncOperation
): Promise<
  | { success: true; server_id?: string }
  | { success: false; status?: 'conflict'; error: string }
> {
  switch (operation.operation_type) {
    case 'create_sale':
      return await syncCreateSale(storeId, userId, operation);

    case 'void_sale':
      return await syncVoidSale(storeId, userId, operation);

    case 'create_inventory_event':
      return await syncCreateInventoryEvent(storeId, userId, operation);

    case 'update_product':
      return await syncUpdateProduct(storeId, operation);

    case 'create_product':
      return await syncCreateProduct(storeId, operation);

    case 'open_shift':
      return await syncOpenShift(storeId, userId, operation);

    case 'close_shift':
      return await syncCloseShift(storeId, operation);

    default:
      return { success: false, error: 'Unknown operation type' };
  }
}

/**
 * Sale sync
 */
async function syncCreateSale(
  storeId: string,
  userId: string,
  operation: SyncOperation
): Promise<{ success: true; server_id: string } | { success: false; error: string }> {
  const { items, payment_method, shift_id } = operation.data;

  if (!items || !Array.isArray(items)) {
    return { success: false, error: 'Invalid sale items' };
  }

  const result = await createSale(storeId, userId, {
    items,
    payment_method: payment_method || 'cash',
    shift_id,
  });

  if (!result.success) {
    return { success: false, error: result.error };
  }

  return { success: true, server_id: result.sale.id };
}

/**
 * Inventory event sync
 */
async function syncCreateInventoryEvent(
  storeId: string,
  userId: string,
  operation: SyncOperation
): Promise<{ success: true; server_id: string } | { success: false; error: string }> {
  const { productId, eventType, qtyChange, reason, shiftId } = operation.data;

  if (!productId || !eventType || qtyChange === undefined) {
    return { success: false, error: 'Invalid inventory event data' };
  }

  const result = await createInventoryEvent(storeId, userId, {
    productId,
    eventType,
    qtyChange,
    reason,
    shiftId,
  });

  if (!result.success) {
    return { success: false, error: result.error };
  }

  return { success: true, server_id: result.event.id };
}

/**
 * Product update sync (conflict resolution: last-write-wins)
 */
async function syncUpdateProduct(
  storeId: string,
  operation: SyncOperation
): Promise<
  { success: true } | { success: false; status?: 'conflict'; error: string }
> {
  const { product_id, name, sku, unit, sell_price, cost_price, low_stock_threshold, note } =
    operation.data;

  if (!product_id) {
    return { success: false, error: 'Product ID required' };
  }

  // Check if product exists
  const { data: existingProduct } = await supabase
    .from('products')
    .select('id, updated_at')
    .eq('id', product_id)
    .eq('store_id', storeId)
    .single();

  if (!existingProduct) {
    return { success: false, error: 'Product not found' };
  }

  // Conflict detection: last-write-wins
  // Server шинэ өгөгдөл байвал warning log хийх, гэхдээ client update-ийг proceed хийх
  // Энэ нь offline client-ийн өгөгдөл алдагдахаас сэргийлнэ
  const clientTimestamp = new Date(operation.client_timestamp);
  const serverTimestamp = existingProduct.updated_at ? new Date(existingProduct.updated_at) : new Date(0);

  if (serverTimestamp > clientTimestamp) {
    // Server дээрх өгөгдөл шинэ байна - conflict warning
    console.warn(
      `Product update conflict detected: product_id=${product_id}, ` +
        `server=${serverTimestamp.toISOString()}, client=${clientTimestamp.toISOString()}. ` +
        `Proceeding with client update (last-write-wins).`
    );
    // PROCEED with update (reject хийхгүй)
  }

  // Update product
  const { error } = await supabase
    .from('products')
    .update({
      name,
      sku,
      unit,
      sell_price,
      cost_price,
      low_stock_threshold,
      note,
      updated_at: new Date().toISOString(),
    })
    .eq('id', product_id)
    .eq('store_id', storeId);

  if (error) {
    return { success: false, error: 'Failed to update product' };
  }

  return { success: true };
}

/**
 * Product create sync
 */
async function syncCreateProduct(
  storeId: string,
  operation: SyncOperation
): Promise<{ success: true; server_id: string } | { success: false; error: string }> {
  const { name, sku, unit, sell_price, cost_price, low_stock_threshold, note } = operation.data;

  if (!name || !sku || !unit || sell_price === undefined) {
    return { success: false, error: 'Invalid product data' };
  }

  // Check duplicate SKU
  const { data: existingProduct } = await supabase
    .from('products')
    .select('id')
    .eq('store_id', storeId)
    .eq('sku', sku)
    .maybeSingle();

  if (existingProduct) {
    return { success: false, error: 'Product with this SKU already exists' };
  }

  // Create product
  const { data, error } = await supabase
    .from('products')
    .insert({
      store_id: storeId,
      name,
      sku,
      unit,
      sell_price,
      cost_price,
      low_stock_threshold,
      note,
    })
    .select()
    .single();

  if (error || !data) {
    return { success: false, error: 'Failed to create product' };
  }

  return { success: true, server_id: data.id };
}

/**
 * Open shift sync
 */
async function syncOpenShift(
  storeId: string,
  userId: string,
  operation: SyncOperation
): Promise<{ success: true; server_id: string } | { success: false; error: string }> {
  const { open_balance } = operation.data;

  // Check if user already has an open shift
  const { data: existingShift } = await supabase
    .from('shifts')
    .select('id')
    .eq('store_id', storeId)
    .eq('seller_id', userId)
    .is('closed_at', null)
    .maybeSingle();

  if (existingShift) {
    return { success: false, error: 'User already has an open shift' };
  }

  // Create shift
  const { data, error } = await supabase
    .from('shifts')
    .insert({
      store_id: storeId,
      seller_id: userId,
      open_balance,
      synced_at: new Date().toISOString(), // Sync timestamp auto-set
    })
    .select()
    .single();

  if (error || !data) {
    return { success: false, error: 'Failed to open shift' };
  }

  return { success: true, server_id: data.id };
}

/**
 * Close shift sync
 */
async function syncCloseShift(
  storeId: string,
  operation: SyncOperation
): Promise<{ success: true } | { success: false; error: string }> {
  const { shift_id, close_balance } = operation.data;

  if (!shift_id) {
    return { success: false, error: 'Shift ID required' };
  }

  // Update shift
  const { error } = await supabase
    .from('shifts')
    .update({
      closed_at: new Date().toISOString(),
      close_balance,
      synced_at: new Date().toISOString(), // Sync timestamp update
    })
    .eq('id', shift_id)
    .eq('store_id', storeId);

  if (error) {
    return { success: false, error: 'Failed to close shift' };
  }

  return { success: true };
}

/**
 * Void sale sync - Борлуулалт цуцлах (offline sync)
 * Mobile-аас offline void sale хийхдээ sync queue-д хадгална,
 * online болоход энэ функц ашиглан server дээр void хийнэ
 */
async function syncVoidSale(
  storeId: string,
  userId: string,
  operation: SyncOperation
): Promise<{ success: true } | { success: false; error: string }> {
  const { sale_id, actor_id } = operation.data;

  if (!sale_id) {
    return { success: false, error: 'Sale ID required' };
  }

  // Одоо байгаа voidSale() service функцыг дуудах
  // (sales.service.ts:290-364 - sale_items устгах, RETURN inventory events үүсгэх)
  const result = await voidSale(sale_id, storeId, actor_id || userId);

  if (!result.success) {
    return { success: false, error: result.error };
  }

  return { success: true };
}

/**
 * Delta sync - өөрчлөлт татах
 * Mobile app-д server-ийн шинэ өгөгдлүүдийг татаж авах
 */
export async function getChanges(
  storeId: string,
  params: ChangesQueryParams
): Promise<ServiceResult<{ changes: any; timestamp: string }>> {
  try {
    const since = params.since;
    const limit = params.limit;

    // Products өөрчлөлт
    const { data: products } = await supabase
      .from('products')
      .select('*')
      .eq('store_id', storeId)
      .gte('updated_at', since)
      .limit(limit);

    // Sales өөрчлөлт
    const { data: sales } = await supabase
      .from('sales')
      .select('*, sale_items(*)')
      .eq('store_id', storeId)
      .gte('synced_at', since)
      .limit(limit);

    // Inventory events өөрчлөлт
    const { data: inventory_events } = await supabase
      .from('inventory_events')
      .select('*')
      .eq('store_id', storeId)
      .gte('synced_at', since)
      .limit(limit);

    // Shifts өөрчлөлт
    const { data: shifts } = await supabase
      .from('shifts')
      .select('*')
      .eq('store_id', storeId)
      .gte('synced_at', since)
      .limit(limit);

    // Alerts өөрчлөлт (unresolved + recently resolved)
    const { data: alerts } = await supabase
      .from('alerts')
      .select('*')
      .eq('store_id', storeId)
      .or(`resolved.is.false,and(resolved.is.true,resolved_at.gte.${since})`)
      .limit(limit);

    return {
      success: true,
      changes: {
        products: products || [],
        sales: sales || [],
        inventory_events: inventory_events || [],
        shifts: shifts || [],
        alerts: alerts || [],
      },
      timestamp: new Date().toISOString(),
    };
  } catch (err: any) {
    return { success: false, error: err.message };
  }
}
