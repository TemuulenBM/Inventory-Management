/**
 * Alerts Service
 *
 * Business logic for alerts management:
 * - List alerts
 * - Get alert details
 * - Resolve alert
 * - Create alert (system use)
 * - Check triggers (low stock, negative inventory)
 */

import { supabase } from '../../config/supabase.js';
import type { AlertsQueryParams, CreateAlertBody } from './alerts.schema.js';

type ServiceResult<T> =
  | { success: true } & T
  | { success: false; error: string };

/**
 * Сэрэмжлүүлэг жагсаалт авах
 */
export async function getAlerts(
  storeId: string,
  params: AlertsQueryParams
): Promise<ServiceResult<{ alerts: any[]; total: number }>> {
  try {
    // Query бэлтгэх
    let query = supabase
      .from('alerts')
      .select('*, products(name, sku)', { count: 'exact' })
      .eq('store_id', storeId)
      .order('created_at', { ascending: false });

    // Filters
    if (params.alert_type) {
      query = query.eq('alert_type', params.alert_type);
    }

    if (params.level) {
      query = query.eq('level', params.level);
    }

    if (params.resolved !== undefined) {
      query = query.eq('resolved', params.resolved);
    }

    if (params.product_id) {
      query = query.eq('product_id', params.product_id);
    }

    // Pagination
    query = query.range(params.offset, params.offset + params.limit - 1);

    const { data, error, count } = await query;

    if (error) {
      return { success: false, error: 'Сэрэмжлүүлэг татахад алдаа гарлаа' };
    }

    // Format response
    const alerts = (data || []).map((alert) => ({
      id: alert.id,
      store_id: alert.store_id,
      alert_type: alert.alert_type,
      product_id: alert.product_id,
      product_name: alert.products?.name,
      product_sku: alert.products?.sku,
      message: alert.message,
      level: alert.level,
      resolved: alert.resolved,
      created_at: alert.created_at,
      resolved_at: alert.resolved_at,
    }));

    return { success: true, alerts, total: count || 0 };
  } catch (err: any) {
    return { success: false, error: err.message };
  }
}

/**
 * Сэрэмжлүүлэг дэлгэрэнгүй авах
 */
export async function getAlertById(
  storeId: string,
  alertId: string
): Promise<ServiceResult<{ alert: any }>> {
  try {
    const { data, error } = await supabase
      .from('alerts')
      .select('*, products(name, sku)')
      .eq('id', alertId)
      .eq('store_id', storeId)
      .single();

    if (error || !data) {
      return { success: false, error: 'Сэрэмжлүүлэг олдсонгүй' };
    }

    const alert = {
      id: data.id,
      store_id: data.store_id,
      alert_type: data.alert_type,
      product_id: data.product_id,
      product_name: data.products?.name,
      product_sku: data.products?.sku,
      message: data.message,
      level: data.level,
      resolved: data.resolved,
      created_at: data.created_at,
      resolved_at: data.resolved_at,
    };

    return { success: true, alert };
  } catch (err: any) {
    return { success: false, error: err.message };
  }
}

/**
 * Сэрэмжлүүлэг шийдвэрлэх
 */
export async function resolveAlert(
  storeId: string,
  alertId: string
): Promise<ServiceResult<{ alert: any }>> {
  try {
    const { data, error } = await supabase
      .from('alerts')
      .update({
        resolved: true,
        resolved_at: new Date().toISOString(),
      })
      .eq('id', alertId)
      .eq('store_id', storeId)
      .select()
      .single();

    if (error || !data) {
      return { success: false, error: 'Сэрэмжлүүлэг олдсонгүй эсвэл алдаа гарлаа' };
    }

    return {
      success: true,
      alert: {
        id: data.id,
        resolved: data.resolved,
        resolved_at: data.resolved_at,
      },
    };
  } catch (err: any) {
    return { success: false, error: err.message };
  }
}

/**
 * Шинэ сэрэмжлүүлэг үүсгэх (system internal use)
 */
export async function createAlert(
  storeId: string,
  data: CreateAlertBody
): Promise<ServiceResult<{ alert: any }>> {
  try {
    const { data: alert, error } = await supabase
      .from('alerts')
      .insert({
        store_id: storeId,
        alert_type: data.alert_type,
        product_id: data.product_id ?? null,
        message: data.message,
        level: data.level,
      })
      .select()
      .single();

    if (error || !alert) {
      return { success: false, error: 'Сэрэмжлүүлэг үүсгэхэд алдаа гарлаа' };
    }

    return { success: true, alert };
  } catch (err: any) {
    return { success: false, error: err.message };
  }
}

/**
 * Бага үлдэгдэл шалгах + alert үүсгэх
 */
export async function checkLowStock(
  storeId: string,
  productId: string
): Promise<void> {
  try {
    // Product-ийн low_stock_threshold + одоогийн stock авах
    const { data: product } = await supabase
      .from('products')
      .select('id, name, sku, low_stock_threshold')
      .eq('id', productId)
      .eq('store_id', storeId)
      .single();

    if (!product) return;

    // Current stock авах (materialized view-аас)
    const { data: stockLevel } = await supabase
      .from('product_stock_levels')
      .select('current_stock')
      .eq('product_id', productId)
      .single();

    if (!stockLevel) return;

    const currentStock = stockLevel.current_stock || 0;
    const threshold = product.low_stock_threshold || 10;

    // Low stock check
    if (currentStock <= threshold && currentStock > 0) {
      // Already resolved check (same product, same type, not resolved)
      const { data: existingAlert } = await supabase
        .from('alerts')
        .select('id')
        .eq('store_id', storeId)
        .eq('product_id', productId)
        .eq('alert_type', 'low_stock')
        .eq('resolved', false)
        .maybeSingle();

      // Alert байхгүй бол үүсгэх
      if (!existingAlert) {
        await createAlert(storeId, {
          alert_type: 'low_stock',
          product_id: productId,
          message: `"${product.name}" (${product.sku}) барааны үлдэгдэл бага байна: ${currentStock} ${threshold <= currentStock ? '≤' : '<'} ${threshold}`,
          level: 'warning',
        });
      }
    }
  } catch (err) {
    console.error('Low stock check error:', err);
  }
}

/**
 * Сөрөг үлдэгдэл шалгах + alert үүсгэх
 */
export async function checkNegativeStock(
  storeId: string,
  productId: string
): Promise<void> {
  try {
    // Product мэдээлэл авах
    const { data: product } = await supabase
      .from('products')
      .select('id, name, sku')
      .eq('id', productId)
      .eq('store_id', storeId)
      .single();

    if (!product) return;

    // Current stock авах
    const { data: stockLevel } = await supabase
      .from('product_stock_levels')
      .select('current_stock')
      .eq('product_id', productId)
      .single();

    if (!stockLevel) return;

    const currentStock = stockLevel.current_stock || 0;

    // Negative stock check
    if (currentStock < 0) {
      // Already resolved check
      const { data: existingAlert } = await supabase
        .from('alerts')
        .select('id')
        .eq('store_id', storeId)
        .eq('product_id', productId)
        .eq('alert_type', 'negative_inventory')
        .eq('resolved', false)
        .maybeSingle();

      // Alert байхгүй бол үүсгэх
      if (!existingAlert) {
        await createAlert(storeId, {
          alert_type: 'negative_inventory',
          product_id: productId,
          message: `"${product.name}" (${product.sku}) барааны үлдэгдэл сөрөг болсон: ${currentStock}`,
          level: 'error',
        });
      }
    }
  } catch (err) {
    console.error('Negative stock check error:', err);
  }
}
