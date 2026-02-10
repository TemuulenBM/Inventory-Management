/**
 * Reports Module Schemas
 *
 * Zod validation schemas for reports:
 * - Daily report
 * - Top products report
 * - Seller performance report
 */

import { z } from 'zod';

/**
 * GET /stores/:storeId/reports/daily
 * Өдрийн тайлан
 */
export const dailyReportQuerySchema = z.object({
  date: z.string().regex(/^\d{4}-\d{2}-\d{2}$/).optional(), // YYYY-MM-DD format
});

export type DailyReportQueryParams = z.infer<typeof dailyReportQuerySchema>;

export type DailyReportResponse = {
  success: true;
  report: {
    date: string;
    total_sales: number;
    total_sales_count: number;
    total_items_sold: number;
    payment_methods: Array<{
      method: string;
      amount: number;
      count: number;
    }>;
    hourly_breakdown: Array<{
      hour: number;
      sales: number;
      count: number;
    }>;
  };
};

/**
 * GET /stores/:storeId/reports/top-products
 * Шилдэг барааны тайлан
 */
export const topProductsQuerySchema = z.object({
  from: z.string().datetime().optional(),
  to: z.string().datetime().optional(),
  limit: z.coerce.number().min(1).max(100).default(10),
});

export type TopProductsQueryParams = z.infer<typeof topProductsQuerySchema>;

export type TopProductsResponse = {
  success: true;
  products: Array<{
    product_id: string;
    product_name: string;
    product_sku: string;
    total_quantity: number;
    total_revenue: number;
    sales_count: number;
  }>;
};

/**
 * GET /stores/:storeId/reports/seller-performance
 * Худалдагчийн үзүүлэлт
 */
export const sellerPerformanceQuerySchema = z.object({
  from: z.string().datetime().optional(),
  to: z.string().datetime().optional(),
  seller_id: z.string().uuid().optional(),
});

export type SellerPerformanceQueryParams = z.infer<typeof sellerPerformanceQuerySchema>;

export type SellerPerformanceResponse = {
  success: true;
  sellers: Array<{
    seller_id: string;
    seller_name: string;
    total_sales: number;
    total_sales_count: number;
    total_items_sold: number;
    average_sale: number;
    shifts_count: number;
  }>;
};

/**
 * GET /stores/:storeId/reports/profit
 * Ашгийн тайлан
 */
export const profitReportQuerySchema = z.object({
  startDate: z.string().regex(/^\d{4}-\d{2}-\d{2}$/).optional(),
  endDate: z.string().regex(/^\d{4}-\d{2}-\d{2}$/).optional(),
});

export type ProfitReportQueryParams = z.infer<typeof profitReportQuerySchema>;

export type ProfitReportResponse = {
  success: true;
  report: {
    totalRevenue: number;
    totalCost: number;
    totalDiscount: number;
    grossProfit: number;
    profitMargin: number;
    byProduct: Array<{
      product_id: string;
      name: string;
      revenue: number;
      cost: number;
      discount: number;
      profit: number;
      margin: number;
      quantity: number;
    }>;
  };
};

/**
 * GET /stores/:storeId/reports/slow-moving
 * Муу зарагддаг бараа
 */
export const slowMovingQuerySchema = z.object({
  days: z.coerce.number().min(1).max(365).default(30),
  maxSold: z.coerce.number().min(0).max(100).default(3),
});

export type SlowMovingQueryParams = z.infer<typeof slowMovingQuerySchema>;

export type SlowMovingResponse = {
  success: true;
  products: Array<{
    product_id: string;
    name: string;
    sku: string;
    stock_quantity: number;
    sold_quantity: number;
    last_sold_at: string | null;
    cost_value: number;
  }>;
};
