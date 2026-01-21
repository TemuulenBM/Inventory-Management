/**
 * Reports Service
 *
 * Business logic for reports:
 * - Daily report
 * - Top products
 * - Seller performance
 */

import { supabase } from '../../config/supabase.js';
import type {
  DailyReportQueryParams,
  TopProductsQueryParams,
  SellerPerformanceQueryParams,
} from './reports.schema.js';

type ServiceResult<T> =
  | { success: true } & T
  | { success: false; error: string };

/**
 * Өдрийн тайлан
 * - Өдрийн нийт борлуулалт
 * - Төлбөрийн хэлбэрээр задаргаа
 * - Цагаар задаргаа
 */
export async function getDailyReport(
  storeId: string,
  query: DailyReportQueryParams
): Promise<ServiceResult<{ report: any }>> {
  try {
    // Өнөөдрийн огноо (UTC)
    const date = query.date ?? new Date().toISOString().split('T')[0];
    const startOfDay = `${date}T00:00:00.000Z`;
    const endOfDay = `${date}T23:59:59.999Z`;

    // 1. Өдрийн борлуулалтууд
    const { data: sales, error: salesError } = await supabase
      .from('sales')
      .select('id, total_amount, payment_method, timestamp')
      .eq('store_id', storeId)
      .gte('timestamp', startOfDay)
      .lte('timestamp', endOfDay);

    if (salesError) {
      return { success: false, error: 'Борлуулалтын мэдээлэл авахад алдаа гарлаа' };
    }

    const salesData = sales ?? [];
    const totalSales = salesData.reduce((sum, sale) => sum + parseFloat(String(sale.total_amount)), 0);
    const totalSalesCount = salesData.length;

    // 2. Төлбөрийн хэлбэрээр задаргаа
    const paymentMethodsMap = new Map<string, { amount: number; count: number }>();
    salesData.forEach((sale) => {
      const existing = paymentMethodsMap.get(String(sale.payment_method)) ?? { amount: 0, count: 0 };
      paymentMethodsMap.set(String(sale.payment_method), {
        amount: existing.amount + parseFloat(String(sale.total_amount)),
        count: existing.count + 1,
      });
    });

    const paymentMethods = Array.from(paymentMethodsMap.entries()).map(([method, data]) => ({
      method,
      amount: data.amount,
      count: data.count,
    }));

    // 3. Цагаар задаргаа (0-23)
    const hourlyMap = new Map<number, { sales: number; count: number }>();
    salesData.forEach((sale) => {
      const hour = new Date(String(sale.timestamp)).getUTCHours();
      const existing = hourlyMap.get(hour) ?? { sales: 0, count: 0 };
      hourlyMap.set(hour, {
        sales: existing.sales + parseFloat(String(sale.total_amount)),
        count: existing.count + 1,
      });
    });

    const hourlyBreakdown = Array.from(hourlyMap.entries())
      .map(([hour, data]) => ({
        hour,
        sales: data.sales,
        count: data.count,
      }))
      .sort((a, b) => a.hour - b.hour);

    // 4. Нийт зарагдсан барааны тоо
    const saleIds = salesData.map((s) => s.id);
    let totalItemsSold = 0;

    if (saleIds.length > 0) {
      const { data: saleItems } = await supabase
        .from('sale_items')
        .select('quantity')
        .in('sale_id', saleIds);

      totalItemsSold = saleItems?.reduce((sum, item) => sum + item.quantity, 0) ?? 0;
    }

    return {
      success: true,
      report: {
        date,
        total_sales: totalSales,
        total_sales_count: totalSalesCount,
        total_items_sold: totalItemsSold,
        payment_methods: paymentMethods,
        hourly_breakdown: hourlyBreakdown,
      },
    };
  } catch (error) {
    return { success: false, error: 'Серверийн алдаа' };
  }
}

/**
 * Шилдэг барааны тайлан
 * - Хамгийн их зарагдсан бараанууд
 * - Тоо хэмжээ, орлого, борлуулалтын тоо
 */
export async function getTopProducts(
  storeId: string,
  query: TopProductsQueryParams
): Promise<ServiceResult<{ products: any[] }>> {
  try {
    // Default: сүүлийн 30 хоног
    const to = query.to ?? new Date().toISOString();
    const from =
      query.from ??
      new Date(Date.now() - 30 * 24 * 60 * 60 * 1000).toISOString();

    // 1. Хугацааны борлуулалтууд
    const { data: sales, error: salesError } = await supabase
      .from('sales')
      .select('id')
      .eq('store_id', storeId)
      .gte('timestamp', from)
      .lte('timestamp', to);

    if (salesError) {
      return { success: false, error: 'Борлуулалтын мэдээлэл авахад алдаа гарлаа' };
    }

    const saleIds = (sales ?? []).map((s) => s.id);

    if (saleIds.length === 0) {
      return { success: true, products: [] };
    }

    // 2. Sale items + Products
    const { data: saleItems, error: itemsError } = await supabase
      .from('sale_items')
      .select('product_id, quantity, subtotal, products!inner(name, sku)')
      .in('sale_id', saleIds);

    if (itemsError) {
      return { success: false, error: 'Sale items авахад алдаа гарлаа' };
    }

    // 3. Product-аар нэгтгэх
    const productsMap = new Map<
      string,
      {
        name: string;
        sku: string;
        totalQuantity: number;
        totalRevenue: number;
        salesCount: number;
      }
    >();

    (saleItems ?? []).forEach((item: any) => {
      const existing = productsMap.get(item.product_id) ?? {
        name: item.products.name,
        sku: item.products.sku,
        totalQuantity: 0,
        totalRevenue: 0,
        salesCount: 0,
      };

      productsMap.set(item.product_id, {
        name: existing.name,
        sku: existing.sku,
        totalQuantity: existing.totalQuantity + item.quantity,
        totalRevenue: existing.totalRevenue + parseFloat(item.subtotal),
        salesCount: existing.salesCount + 1,
      });
    });

    // 4. Эрэмбэлэх (totalRevenue-ээр)
    const topProducts = Array.from(productsMap.entries())
      .map(([productId, data]) => ({
        product_id: productId,
        product_name: data.name,
        product_sku: data.sku,
        total_quantity: data.totalQuantity,
        total_revenue: data.totalRevenue,
        sales_count: data.salesCount,
      }))
      .sort((a, b) => b.total_revenue - a.total_revenue)
      .slice(0, query.limit);

    return { success: true, products: topProducts };
  } catch (error) {
    return { success: false, error: 'Серверийн алдаа' };
  }
}

/**
 * Худалдагчийн үзүүлэлт
 * - Худалдагч бүрийн борлуулалт
 * - Нийт дүн, тоо, дундаж, ээлжийн тоо
 */
export async function getSellerPerformance(
  storeId: string,
  query: SellerPerformanceQueryParams
): Promise<ServiceResult<{ sellers: any[] }>> {
  try {
    // Default: сүүлийн 30 хоног
    const to = query.to ?? new Date().toISOString();
    const from =
      query.from ??
      new Date(Date.now() - 30 * 24 * 60 * 60 * 1000).toISOString();

    // 1. Query үүсгэх
    let queryBuilder = supabase
      .from('sales')
      .select('seller_id, total_amount, users!inner(name)')
      .eq('store_id', storeId)
      .gte('timestamp', from)
      .lte('timestamp', to);

    if (query.seller_id) {
      queryBuilder = queryBuilder.eq('seller_id', query.seller_id);
    }

    const { data: sales, error: salesError } = await queryBuilder;

    if (salesError) {
      return { success: false, error: 'Борлуулалтын мэдээлэл авахад алдаа гарлаа' };
    }

    // 2. Seller-ээр нэгтгэх
    const sellersMap = new Map<
      string,
      {
        name: string;
        totalSales: number;
        totalSalesCount: number;
      }
    >();

    (sales ?? []).forEach((sale: any) => {
      const existing = sellersMap.get(sale.seller_id) ?? {
        name: sale.users.name,
        totalSales: 0,
        totalSalesCount: 0,
      };

      sellersMap.set(sale.seller_id, {
        name: existing.name,
        totalSales: existing.totalSales + parseFloat(sale.total_amount),
        totalSalesCount: existing.totalSalesCount + 1,
      });
    });

    // 3. Ээлжийн тоог тооцоолох
    const sellerIds = Array.from(sellersMap.keys());
    const { data: shifts } = await supabase
      .from('shifts')
      .select('seller_id')
      .eq('store_id', storeId)
      .in('seller_id', sellerIds)
      .gte('opened_at', from)
      .lte('opened_at', to);

    const shiftsCountMap = new Map<string, number>();
    (shifts ?? []).forEach((shift) => {
      shiftsCountMap.set(shift.seller_id, (shiftsCountMap.get(shift.seller_id) ?? 0) + 1);
    });

    // 4. Sale items тооцоолох (нийт зарагдсан бараа)
    const saleIds = (sales ?? []).map((s: any) => s.id);
    let itemsSoldMap = new Map<string, number>();

    if (saleIds.length > 0) {
      const { data: saleItems } = await supabase
        .from('sale_items')
        .select('sale_id, quantity')
        .in('sale_id', saleIds);

      // sale_id -> seller_id mapping
      const saleSellerMap = new Map<string, string>();
      (sales ?? []).forEach((sale: any) => {
        saleSellerMap.set(sale.id, sale.seller_id);
      });

      (saleItems ?? []).forEach((item: any) => {
        const sellerId = saleSellerMap.get(item.sale_id);
        if (sellerId) {
          itemsSoldMap.set(sellerId, (itemsSoldMap.get(sellerId) ?? 0) + item.quantity);
        }
      });
    }

    // 5. Response format
    const sellersPerformance = Array.from(sellersMap.entries())
      .map(([sellerId, data]) => ({
        seller_id: sellerId,
        seller_name: data.name,
        total_sales: data.totalSales,
        total_sales_count: data.totalSalesCount,
        total_items_sold: itemsSoldMap.get(sellerId) ?? 0,
        average_sale: data.totalSalesCount > 0 ? data.totalSales / data.totalSalesCount : 0,
        shifts_count: shiftsCountMap.get(sellerId) ?? 0,
      }))
      .sort((a, b) => b.total_sales - a.total_sales);

    return { success: true, sellers: sellersPerformance };
  } catch (error) {
    return { success: false, error: 'Серверийн алдаа' };
  }
}
