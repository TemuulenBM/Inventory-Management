/**
 * Store Service
 *
 * Store CRUD business logic:
 * - Store үүсгэх, олох, засах
 * - Store статистик тооцоолох
 */

import { supabase } from '../../config/supabase.js';
import type { CreateStoreBody, UpdateStoreBody } from './store.schema.js';

/**
 * Store үүсгэх
 *
 * Шинэ дэлгүүр үүсгэж, хэрэглэгчийг owner болгоно.
 *
 * @param data - Store мэдээлэл
 * @param ownerId - Owner-ийн ID
 * @returns Үүссэн store
 */
export async function createStore(data: CreateStoreBody, ownerId: string) {
  // Store үүсгэх
  const { data: store, error: storeError } = await supabase
    .from('stores')
    .insert({
      name: data.name,
      location: data.location,
      owner_id: ownerId,
      timezone: data.timezone || 'Asia/Ulaanbaatar',
    })
    .select()
    .single();

  if (storeError) {
    console.error('Create store error:', storeError);
    return { success: false as const, error: 'Дэлгүүр үүсгэхэд алдаа гарлаа' };
  }

  // Owner хэрэглэгчийн store_id-г шинэчлэх (onboarding дараа storeId null биш болно)
  const { error: userUpdateError } = await supabase
    .from('users')
    .update({ store_id: store.id })
    .eq('id', ownerId);

  if (userUpdateError) {
    console.error('Update owner store_id error:', userUpdateError);
  }

  console.log(`✅ Store created: ${store.name} (owner: ${ownerId})`);

  return {
    success: true as const,
    store: {
      id: store.id,
      name: store.name,
      location: store.location,
      ownerId: store.owner_id,
      timezone: store.timezone,
      createdAt: store.created_at,
    },
  };
}

/**
 * Store мэдээлэл авах
 *
 * @param storeId - Store ID
 * @returns Store мэдээлэл
 */
export async function getStore(storeId: string) {
  const { data: store, error } = await supabase
    .from('stores')
    .select('*')
    .eq('id', storeId)
    .single();

  if (error || !store) {
    return { success: false as const, error: 'Дэлгүүр олдсонгүй' };
  }

  return {
    success: true as const,
    store: {
      id: store.id,
      name: store.name,
      location: store.location,
      ownerId: store.owner_id,
      timezone: store.timezone,
      createdAt: store.created_at,
    },
  };
}

/**
 * Store мэдээлэл засах
 *
 * @param storeId - Store ID
 * @param data - Шинэчлэх мэдээлэл
 * @returns Шинэчлэгдсэн store
 */
export async function updateStore(storeId: string, data: UpdateStoreBody) {
  const { data: store, error } = await supabase
    .from('stores')
    .update({
      ...(data.name && { name: data.name }),
      ...(data.location && { location: data.location }),
      ...(data.timezone && { timezone: data.timezone }),
    })
    .eq('id', storeId)
    .select()
    .single();

  if (error) {
    console.error('Update store error:', error);
    return { success: false as const, error: 'Дэлгүүр шинэчлэхэд алдаа гарлаа' };
  }

  return {
    success: true as const,
    store: {
      id: store.id,
      name: store.name,
      location: store.location,
      ownerId: store.owner_id,
      timezone: store.timezone,
      createdAt: store.created_at,
    },
  };
}

/**
 * Store статистик авах
 *
 * @param storeId - Store ID
 * @returns Store статистик
 */
export async function getStoreStats(storeId: string) {
  // Products тоо
  const { count: productsCount } = await supabase
    .from('products')
    .select('*', { count: 'exact', head: true })
    .eq('store_id', storeId);

  // Users тоо
  const { count: usersCount } = await supabase
    .from('users')
    .select('*', { count: 'exact', head: true })
    .eq('store_id', storeId);

  // Sales тоо
  const { count: salesCount } = await supabase
    .from('sales')
    .select('*', { count: 'exact', head: true })
    .eq('store_id', storeId);

  // Total revenue (sales-ийн нийт дүн)
  const { data: sales } = await supabase
    .from('sales')
    .select('total_amount')
    .eq('store_id', storeId);

  const totalRevenue = sales?.reduce((sum, sale) => sum + sale.total_amount, 0) || 0;

  // Low stock products (үлдэгдэл бага бараа)
  // product_stock_levels view-г ашиглана
  const { count: lowStockCount } = await supabase
    .from('product_stock_levels' as any)
    .select('*', { count: 'exact', head: true })
    .eq('store_id', storeId)
    .filter('is_low_stock', 'eq', true);

  return {
    success: true as const,
    stats: {
      totalProducts: productsCount || 0,
      totalUsers: usersCount || 0,
      totalSales: salesCount || 0,
      totalRevenue,
      lowStockProducts: lowStockCount || 0,
    },
  };
}
