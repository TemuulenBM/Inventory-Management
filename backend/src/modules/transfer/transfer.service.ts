/**
 * Transfer Service
 *
 * Салбар хоорондын бараа шилжүүлгийн бизнес логик.
 * Атомик transaction: source store-д TRANSFER_OUT, destination store-д TRANSFER_IN
 *
 * Type-safe: Supabase generated types ашигладаг (npm run db:types).
 */

import { supabase } from '../../config/supabase.js';
import type { TransferInsert, TransferItemInsert } from '../../config/supabase.js';
import type { CreateTransferBody, TransfersQueryParams, TransferInfo } from './transfer.schema.js';

/**
 * Шилжүүлэг үүсгэх + inventory events автомат үүсгэх
 */
export async function createTransfer(
  sourceStoreId: string,
  actorId: string,
  data: CreateTransferBody
) {
  // 1. Очих салбар байгаа эсэхийг шалгах
  const { data: destStore } = await supabase
    .from('stores')
    .select('id, name')
    .eq('id', data.destination_store_id)
    .single();

  if (!destStore) {
    return { success: false as const, error: 'Очих салбар олдсонгүй' };
  }

  // 2. Бараанууд source store-д байгаа эсэх + stock шалгах
  const productIds = data.items.map(item => item.product_id);
  const { data: products } = await supabase
    .from('products')
    .select('id, name, is_deleted')
    .in('id', productIds)
    .eq('store_id', sourceStoreId);

  if (!products || products.length !== productIds.length) {
    const foundIds = new Set(products?.map(p => p.id) || []);
    const missing = productIds.filter(id => !foundIds.has(id));
    return { success: false as const, error: `Бараа олдсонгүй: ${missing.join(', ')}` };
  }

  const deletedProduct = products.find(p => p.is_deleted);
  if (deletedProduct) {
    return { success: false as const, error: `"${deletedProduct.name}" устгагдсан бараа шилжүүлэх боломжгүй` };
  }

  // Stock хангалттай эсэхийг шалгах
  const { data: stockData } = await supabase
    .from('inventory_events')
    .select('product_id, qty_change')
    .in('product_id', productIds)
    .eq('store_id', sourceStoreId);

  const stockMap = new Map<string, number>();
  for (const event of stockData || []) {
    const current = stockMap.get(event.product_id) || 0;
    stockMap.set(event.product_id, current + event.qty_change);
  }

  for (const item of data.items) {
    const currentStock = stockMap.get(item.product_id) || 0;
    const product = products.find(p => p.id === item.product_id);
    if (currentStock < item.quantity) {
      return {
        success: false as const,
        error: `"${product?.name}" үлдэгдэл хүрэлцэхгүй байна (${currentStock} ширхэг байгаа, ${item.quantity} шилжүүлэх гэж байна)`,
      };
    }
  }

  // 3. Transfer үүсгэх (type-safe insert)
  const transferData: TransferInsert = {
    source_store_id: sourceStoreId,
    destination_store_id: data.destination_store_id,
    initiated_by: actorId,
    status: 'completed',
    notes: data.notes || null,
    completed_at: new Date().toISOString(),
  };

  const { data: transfer, error: transferError } = await supabase
    .from('transfers')
    .insert(transferData)
    .select()
    .single();

  if (transferError || !transfer) {
    return { success: false as const, error: `Шилжүүлэг үүсгэхэд алдаа: ${transferError?.message}` };
  }

  // 4. Transfer items үүсгэх
  const transferItems: TransferItemInsert[] = data.items.map(item => ({
    transfer_id: transfer.id,
    product_id: item.product_id,
    quantity: item.quantity,
  }));

  const { error: itemsError } = await supabase
    .from('transfer_items')
    .insert(transferItems);

  if (itemsError) {
    // Rollback: transfer устгах
    await supabase.from('transfers').delete().eq('id', transfer.id);
    return { success: false as const, error: `Шилжүүлгийн бараа нэмэхэд алдаа: ${itemsError.message}` };
  }

  // 5. Inventory events үүсгэх (TRANSFER_OUT + TRANSFER_IN)
  const inventoryEvents = [];

  for (const item of data.items) {
    // Source store: TRANSFER_OUT (хасах)
    inventoryEvents.push({
      store_id: sourceStoreId,
      product_id: item.product_id,
      event_type: 'TRANSFER_OUT',
      qty_change: -item.quantity,
      actor_id: actorId,
      reason: `Шилжүүлэг #${transfer.id.substring(0, 8)} → ${destStore.name}`,
    });

    // Destination store: TRANSFER_IN (нэмэх)
    inventoryEvents.push({
      store_id: data.destination_store_id,
      product_id: item.product_id,
      event_type: 'TRANSFER_IN',
      qty_change: item.quantity,
      actor_id: actorId,
      reason: `Шилжүүлэг #${transfer.id.substring(0, 8)} ← ${sourceStoreId.substring(0, 8)}`,
    });
  }

  const { error: eventsError } = await supabase
    .from('inventory_events')
    .insert(inventoryEvents);

  if (eventsError) {
    // Rollback: transfer устгах (CASCADE-ээр transfer_items мөн устна)
    await supabase.from('transfers').delete().eq('id', transfer.id);
    return { success: false as const, error: `Inventory event үүсгэхэд алдаа: ${eventsError.message}` };
  }

  // 6. Materialized view refresh (алдаа гарвал шилжүүлгийг зогсоохгүй)
  try {
    await supabase.rpc('refresh_product_stock_levels');
  } catch {
    // Materialized view refresh амжилтгүй болсон ч шилжүүлэг хийгдсэн
  }

  const productNameMap = new Map(products.map(p => [p.id, p.name]));

  return {
    success: true as const,
    transfer: {
      id: transfer.id,
      sourceStoreId,
      destinationStoreId: data.destination_store_id,
      destinationStoreName: destStore.name,
      status: 'completed',
      notes: data.notes || null,
      items: data.items.map(item => ({
        productId: item.product_id,
        productName: productNameMap.get(item.product_id) || '',
        quantity: item.quantity,
      })),
      createdAt: transfer.created_at || new Date().toISOString(),
    },
  };
}

/**
 * Шилжүүлгийн жагсаалт авах
 */
export async function getTransfers(
  storeId: string,
  query: TransfersQueryParams
): Promise<{ success: true; transfers: TransferInfo[]; pagination: { total: number; limit: number; offset: number } } | { success: false; error: string }> {
  // Суурь query — nested select ашиглан холбоотой мэдээлэл татах
  // ТАЙЛБАР: Supabase typed client-д nested FK select string-р дамжуулдаг
  // тул select() дотор `!fkey_name` ашиглана
  let baseQuery = supabase
    .from('transfers')
    .select(`
      id, status, notes, created_at, completed_at,
      source_store_id, destination_store_id, initiated_by
    `, { count: 'exact' });

  // Чиглэл шүүлт
  if (query.direction === 'outgoing') {
    baseQuery = baseQuery.eq('source_store_id', storeId);
  } else if (query.direction === 'incoming') {
    baseQuery = baseQuery.eq('destination_store_id', storeId);
  } else {
    baseQuery = baseQuery.or(`source_store_id.eq.${storeId},destination_store_id.eq.${storeId}`);
  }

  if (query.status) {
    baseQuery = baseQuery.eq('status', query.status);
  }

  const { data, error, count } = await baseQuery
    .order('created_at', { ascending: false })
    .range(query.offset, query.offset + query.limit - 1);

  if (error) {
    return { success: false, error: `Шилжүүлгийн жагсаалт авахад алдаа: ${error.message}` };
  }

  if (!data || data.length === 0) {
    return {
      success: true,
      transfers: [],
      pagination: { total: count || 0, limit: query.limit, offset: query.offset },
    };
  }

  // Холбоотой store, user, transfer_items мэдээлэл тус тусад нь авах
  // (nested FK select-ийн оронд — type safety-г хадгалахын тулд)
  const transferIds = data.map(t => t.id);
  const storeIds = [...new Set(data.flatMap(t => [t.source_store_id, t.destination_store_id]))];
  const userIds = [...new Set(data.map(t => t.initiated_by))];

  // Зэрэг query-үүдийг parallel ажиллуулна
  const [storesResult, usersResult, itemsResult] = await Promise.all([
    supabase.from('stores').select('id, name').in('id', storeIds),
    supabase.from('users').select('id, name').in('id', userIds),
    supabase.from('transfer_items').select('id, transfer_id, product_id, quantity').in('transfer_id', transferIds),
  ]);

  const storeMap = new Map((storesResult.data || []).map(s => [s.id, s.name]));
  const userMap = new Map((usersResult.data || []).map(u => [u.id, u.name]));
  const items = itemsResult.data || [];

  // Бараануудын нэр авах
  const productIds = [...new Set(items.map(i => i.product_id))];
  let productMap = new Map<string, string>();
  if (productIds.length > 0) {
    const { data: productsData } = await supabase
      .from('products')
      .select('id, name')
      .in('id', productIds);
    productMap = new Map((productsData || []).map(p => [p.id, p.name]));
  }

  // Transfer бүрт items-г map хийх
  const itemsByTransfer = new Map<string, typeof items>();
  for (const item of items) {
    const existing = itemsByTransfer.get(item.transfer_id) || [];
    existing.push(item);
    itemsByTransfer.set(item.transfer_id, existing);
  }

  const transfers: TransferInfo[] = data.map(t => ({
    id: t.id,
    sourceStore: {
      id: t.source_store_id,
      name: storeMap.get(t.source_store_id) || '',
    },
    destinationStore: {
      id: t.destination_store_id,
      name: storeMap.get(t.destination_store_id) || '',
    },
    initiatedBy: {
      id: t.initiated_by,
      name: userMap.get(t.initiated_by) || '',
    },
    status: t.status as TransferInfo['status'],
    notes: t.notes,
    items: (itemsByTransfer.get(t.id) || []).map(item => ({
      id: item.id,
      productId: item.product_id,
      productName: productMap.get(item.product_id) || '',
      quantity: item.quantity,
    })),
    createdAt: t.created_at || '',
    completedAt: t.completed_at,
  }));

  return {
    success: true,
    transfers,
    pagination: {
      total: count || 0,
      limit: query.limit,
      offset: query.offset,
    },
  };
}

/**
 * Шилжүүлэг цуцлах (зөвхөн pending статустай бол)
 */
export async function cancelTransfer(transferId: string, _actorId: string) {
  const { data: transfer } = await supabase
    .from('transfers')
    .select('id, status')
    .eq('id', transferId)
    .single();

  if (!transfer) {
    return { success: false as const, error: 'Шилжүүлэг олдсонгүй' };
  }

  if (transfer.status !== 'pending') {
    return { success: false as const, error: `"${transfer.status}" статустай шилжүүлэг цуцлах боломжгүй` };
  }

  const { error } = await supabase
    .from('transfers')
    .update({ status: 'cancelled' })
    .eq('id', transferId);

  if (error) {
    return { success: false as const, error: `Цуцлахад алдаа: ${error.message}` };
  }

  return { success: true as const };
}
