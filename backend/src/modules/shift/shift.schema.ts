/**
 * Shift Module Schemas
 *
 * Zod validation schemas for shift management:
 * - Open shift
 * - Close shift
 * - List shifts
 * - Get shift details
 */

import { z } from 'zod';

/**
 * POST /stores/:storeId/shifts/open
 * Ээлж нээх
 */
export const openShiftSchema = z.object({
  open_balance: z.number().min(0).optional(),
});

export type OpenShiftBody = z.infer<typeof openShiftSchema>;

export type OpenShiftResponse = {
  success: true;
  shift: {
    id: string;
    store_id: string;
    seller_id: string;
    opened_at: string;
    closed_at: null;
    open_balance: number | null;
    close_balance: null;
  };
};

/**
 * POST /stores/:storeId/shifts/close
 * Ээлж хаах
 */
export const closeShiftSchema = z.object({
  close_balance: z.number().min(0).optional(),
});

export type CloseShiftBody = z.infer<typeof closeShiftSchema>;

export type CloseShiftResponse = {
  success: true;
  shift: {
    id: string;
    store_id: string;
    seller_id: string;
    opened_at: string;
    closed_at: string;
    open_balance: number | null;
    close_balance: number | null;
    total_sales: number;
    total_sales_count: number;
  };
};

/**
 * GET /stores/:storeId/shifts
 * Ээлжийн түүх харах
 */
export const shiftQuerySchema = z.object({
  seller_id: z.string().uuid().optional(),
  limit: z.coerce.number().min(1).max(100).default(20),
  offset: z.coerce.number().min(0).default(0),
});

export type ShiftQueryParams = z.infer<typeof shiftQuerySchema>;

export type ShiftListResponse = {
  success: true;
  shifts: Array<{
    id: string;
    store_id: string;
    seller_id: string;
    seller_name: string;
    opened_at: string;
    closed_at: string | null;
    open_balance: number | null;
    close_balance: number | null;
    synced_at: string;
  }>;
  pagination: {
    total: number;
    limit: number;
    offset: number;
  };
};

/**
 * GET /stores/:storeId/shifts/:shiftId
 * Ээлж дэлгэрэнгүй харах
 */
export type ShiftDetailResponse = {
  success: true;
  shift: {
    id: string;
    store_id: string;
    seller_id: string;
    seller_name: string;
    opened_at: string;
    closed_at: string | null;
    open_balance: number | null;
    close_balance: number | null;
    synced_at: string;
    total_sales: number;
    total_sales_count: number;
    sales: Array<{
      id: string;
      total_amount: number;
      payment_method: string;
      timestamp: string;
    }>;
  };
};

/**
 * GET /stores/:storeId/shifts/active
 * Идэвхтэй ээлж харах
 */
export type ActiveShiftResponse = {
  success: true;
  shift: {
    id: string;
    store_id: string;
    seller_id: string;
    seller_name: string;
    opened_at: string;
    open_balance: number | null;
    total_sales: number;
    total_sales_count: number;
  } | null;
};
