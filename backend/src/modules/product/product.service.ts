/**
 * Product Service
 *
 * Product CRUD business logic with stock information.
 */

import { supabase } from '../../config/supabase.js';
import type { CreateProductBody, UpdateProductBody, ProductQueryParams, ProductInfo, ProductWithStock } from './product.schema.js';

/**
 * Барааны жагсаалт авах (pagination, search, filter)
 *
 * @param storeId - Store ID
 * @param query - Query parameters (page, limit, search, filter)
 * @returns Барааны жагсаалт + pagination
 */
export async function getProducts(storeId: string, query: ProductQueryParams) {
  const { page, limit, search, unit, lowStock } = query;
  const offset = (page - 1) * limit;

  // product_stock_levels view ашиглана (current_stock, is_low_stock багтсан)
  let queryBuilder = supabase
    .from('product_stock_levels' as any)
    .select('*', { count: 'exact' })
    .eq('store_id', storeId);

  // Search filter (name эсвэл SKU)
  if (search) {
    queryBuilder = queryBuilder.or(`name.ilike.%${search}%,sku.ilike.%${search}%`);
  }

  // Unit filter
  if (unit) {
    queryBuilder = queryBuilder.eq('unit', unit);
  }

  // Low stock filter
  if (lowStock) {
    queryBuilder = queryBuilder.eq('is_low_stock', true);
  }

  // Pagination + sorting
  queryBuilder = queryBuilder
    .order('created_at', { ascending: false })
    .range(offset, offset + limit - 1);

  const { data: products, error, count } = await queryBuilder;

  if (error) {
    console.error('Get products error:', error);
    return { success: false as const, error: 'Барааны жагсаалт авахад алдаа гарлаа' };
  }

  const productList: ProductWithStock[] = (products || []).map((p: any) => ({
    id: p.product_id,
    storeId: p.store_id,
    name: p.name,
    sku: p.sku,
    unit: p.unit,
    costPrice: p.cost_price,
    sellPrice: p.sell_price,
    lowStockThreshold: p.low_stock_threshold,
    currentStock: p.current_stock || 0,
    isLowStock: p.is_low_stock || false,
    createdAt: p.created_at,
  }));

  const total = count || 0;
  const totalPages = Math.ceil(total / limit);

  return {
    success: true as const,
    products: productList,
    pagination: {
      page,
      limit,
      total,
      totalPages,
    },
  };
}

/**
 * Бараа дэлгэрэнгүй мэдээлэл авах
 *
 * @param productId - Product ID
 * @param storeId - Store ID
 * @returns Бараа + stock level
 */
export async function getProduct(productId: string, storeId: string) {
  // product_stock_levels view ашиглана
  const { data: product, error } = await supabase
    .from('product_stock_levels' as any)
    .select('*')
    .eq('product_id', productId)
    .eq('store_id', storeId)
    .single();

  if (error || !product) {
    return { success: false as const, error: 'Бараа олдсонгүй' };
  }

  const productWithStock: ProductWithStock = {
    id: product.product_id,
    storeId: product.store_id,
    name: product.name,
    sku: product.sku,
    unit: product.unit,
    costPrice: product.cost_price,
    sellPrice: product.sell_price,
    lowStockThreshold: product.low_stock_threshold,
    currentStock: product.current_stock || 0,
    isLowStock: product.is_low_stock || false,
    createdAt: product.created_at,
  };

  return {
    success: true as const,
    product: productWithStock,
  };
}

/**
 * Шинэ бараа нэмэх
 *
 * @param storeId - Store ID
 * @param data - Барааны мэдээлэл
 * @returns Үүссэн бараа
 */
export async function createProduct(storeId: string, data: CreateProductBody) {
  // SKU давхцаж байгаа эсэх шалгах (хэрэв байвал)
  if (data.sku) {
    const { data: existing } = await supabase
      .from('products')
      .select('id')
      .eq('store_id', storeId)
      .eq('sku', data.sku)
      .limit(1);

    if (existing && existing.length > 0) {
      return { success: false as const, error: 'Энэ SKU код аль хэдийн ашиглагдаж байна' };
    }
  }

  // Product үүсгэх
  const { data: product, error } = await supabase
    .from('products')
    .insert({
      store_id: storeId,
      name: data.name,
      sku: data.sku || null,
      unit: data.unit,
      cost_price: data.costPrice,
      sell_price: data.sellPrice,
      low_stock_threshold: data.lowStockThreshold || null,
    })
    .select()
    .single();

  if (error) {
    console.error('Create product error:', error);
    return { success: false as const, error: 'Бараа үүсгэхэд алдаа гарлаа' };
  }

  console.log(`✅ Product created: ${product.name} (${product.sku || 'no SKU'})`);

  return {
    success: true as const,
    product: {
      id: product.id,
      storeId: product.store_id,
      name: product.name,
      sku: product.sku,
      unit: product.unit,
      costPrice: product.cost_price,
      sellPrice: product.sell_price,
      lowStockThreshold: product.low_stock_threshold,
      createdAt: product.created_at,
    },
  };
}

/**
 * Бараа мэдээлэл засах
 *
 * @param productId - Product ID
 * @param storeId - Store ID
 * @param data - Шинэчлэх мэдээлэл
 * @returns Шинэчлэгдсэн бараа
 */
export async function updateProduct(productId: string, storeId: string, data: UpdateProductBody) {
  // SKU шинэчлэх бол давхцаж байгаа эсэх шалгах
  if (data.sku) {
    const { data: existing } = await supabase
      .from('products')
      .select('id')
      .eq('store_id', storeId)
      .eq('sku', data.sku)
      .neq('id', productId)
      .limit(1);

    if (existing && existing.length > 0) {
      return { success: false as const, error: 'Энэ SKU код бусад бараа ашиглаж байна' };
    }
  }

  // Product шинэчлэх
  const { data: product, error } = await supabase
    .from('products')
    .update({
      ...(data.name && { name: data.name }),
      ...(data.sku !== undefined && { sku: data.sku }),
      ...(data.unit && { unit: data.unit }),
      ...(data.costPrice !== undefined && { cost_price: data.costPrice }),
      ...(data.sellPrice !== undefined && { sell_price: data.sellPrice }),
      ...(data.lowStockThreshold !== undefined && { low_stock_threshold: data.lowStockThreshold }),
    })
    .eq('id', productId)
    .eq('store_id', storeId)
    .select()
    .single();

  if (error) {
    console.error('Update product error:', error);
    return { success: false as const, error: 'Бараа шинэчлэхэд алдаа гарлаа' };
  }

  return {
    success: true as const,
    product: {
      id: product.id,
      storeId: product.store_id,
      name: product.name,
      sku: product.sku,
      unit: product.unit,
      costPrice: product.cost_price,
      sellPrice: product.sell_price,
      lowStockThreshold: product.low_stock_threshold,
      createdAt: product.created_at,
    },
  };
}

/**
 * Бараа устгах (hard delete - production дээр soft delete хийх)
 *
 * @param productId - Product ID
 * @param storeId - Store ID
 * @returns Амжилттай бол { success: true }
 */
export async function deleteProduct(productId: string, storeId: string) {
  const { error } = await supabase
    .from('products')
    .delete()
    .eq('id', productId)
    .eq('store_id', storeId);

  if (error) {
    console.error('Delete product error:', error);
    return { success: false as const, error: 'Бараа устгахад алдаа гарлаа' };
  }

  console.log(`🗑️  Product deleted: ${productId}`);
  return { success: true as const };
}

/**
 * Олон бараа нэгэн зэрэг нэмэх (bulk create)
 *
 * @param storeId - Store ID
 * @param products - Барааны жагсаалт
 * @returns Үүссэн барааны тоо + жагсаалт
 */
export async function bulkCreateProducts(storeId: string, products: CreateProductBody[]) {
  // SKU давхцал шалгах
  const skus = products.filter((p) => p.sku).map((p) => p.sku!);
  if (skus.length > 0) {
    const { data: existing } = await supabase
      .from('products')
      .select('sku')
      .eq('store_id', storeId)
      .in('sku', skus);

    if (existing && existing.length > 0) {
      const duplicates = existing.map((e) => e.sku).join(', ');
      return { success: false as const, error: `Эдгээр SKU код аль хэдийн байна: ${duplicates}` };
    }
  }

  // Bulk insert
  const productsData = products.map((p) => ({
    store_id: storeId,
    name: p.name,
    sku: p.sku || null,
    unit: p.unit,
    cost_price: p.costPrice,
    sell_price: p.sellPrice,
    low_stock_threshold: p.lowStockThreshold || null,
  }));

  const { data: created, error } = await supabase.from('products').insert(productsData).select();

  if (error) {
    console.error('Bulk create products error:', error);
    return { success: false as const, error: 'Бараа үүсгэхэд алдаа гарлаа' };
  }

  console.log(`✅ Bulk created ${created.length} products`);

  const productList: ProductInfo[] = created.map((p) => ({
    id: p.id,
    storeId: p.store_id,
    name: p.name,
    sku: p.sku,
    unit: p.unit,
    costPrice: p.cost_price,
    sellPrice: p.sell_price,
    lowStockThreshold: p.low_stock_threshold,
    createdAt: p.created_at,
  }));

  return {
    success: true as const,
    created: productList.length,
    products: productList,
  };
}
