/**
 * Sales Module Schemas
 *
 * Zod validation schemas for sales management:
 * - Create sale
 * - List sales
 * - Get sale details
 * - Void sale
 */

import { z } from 'zod';

/**
 * POST /stores/:storeId/sales
 * Борлуулалт бүртгэх
 */
export const createSaleSchema = z.object({
  items: z
    .array(
      z.object({
        product_id: z.string().uuid(),
        quantity: z.number().int().min(1),
        unit_price: z.number().min(0),
        // Хөнгөлөлтийн талбарууд (optional - backward compatible)
        original_price: z.number().min(0).optional(),
        discount_amount: z.number().min(0).default(0),
      })
    )
    .min(1),
  payment_method: z.enum(['cash', 'card', 'qr', 'transfer']).default('cash'),
  shift_id: z.string().uuid().optional(),
});

export type CreateSaleBody = z.infer<typeof createSaleSchema>;

export type CreateSaleResponse = {
  success: true;
  sale: {
    id: string;
    store_id: string;
    seller_id: string;
    shift_id: string | null;
    total_amount: number;
    total_discount: number;
    payment_method: string;
    timestamp: string;
    items: Array<{
      id: string;
      product_id: string;
      product_name: string;
      quantity: number;
      unit_price: number;
      original_price: number;
      discount_amount: number;
      subtotal: number;
    }>;
  };
};

/**
 * GET /stores/:storeId/sales
 * Борлуулалтын түүх харах
 */
export const salesQuerySchema = z.object({
  seller_id: z.string().uuid().optional(),
  shift_id: z.string().uuid().optional(),
  from: z.string().datetime().optional(),
  to: z.string().datetime().optional(),
  payment_method: z.enum(['cash', 'card', 'qr', 'transfer']).optional(),
  limit: z.coerce.number().min(1).max(100).default(20),
  offset: z.coerce.number().min(0).default(0),
});

export type SalesQueryParams = z.infer<typeof salesQuerySchema>;

export type SalesListResponse = {
  success: true;
  sales: Array<{
    id: string;
    store_id: string;
    seller_id: string;
    seller_name: string;
    shift_id: string | null;
    total_amount: number;
    payment_method: string;
    timestamp: string;
    synced_at: string;
  }>;
  pagination: {
    total: number;
    limit: number;
    offset: number;
  };
};

/**
 * GET /stores/:storeId/sales/:saleId
 * Борлуулалт дэлгэрэнгүй харах
 */
export type SaleDetailResponse = {
  success: true;
  sale: {
    id: string;
    store_id: string;
    seller_id: string;
    seller_name: string;
    shift_id: string | null;
    total_amount: number;
    payment_method: string;
    timestamp: string;
    synced_at: string;
    items: Array<{
      id: string;
      product_id: string;
      product_name: string;
      product_sku: string;
      quantity: number;
      unit_price: number;
      subtotal: number;
    }>;
  };
};

/**
 * POST /stores/:storeId/sales/:saleId/void
 * Борлуулалт цуцлах
 */
export type VoidSaleResponse = {
  success: true;
  message: string;
};
