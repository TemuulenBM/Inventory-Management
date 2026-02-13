/**
 * Alerts Module Schemas
 *
 * Zod validation schemas for alerts management:
 * - List alerts
 * - Get alert details
 * - Resolve alert
 * - Create alert (system use)
 */

import { z } from 'zod';

/**
 * Alert types
 */
export const alertTypeEnum = z.enum([
  'low_stock',
  'negative_inventory',
  'suspicious_activity',
  'cash_discrepancy',
  'excessive_discount',
  'high_void_rate',
  'inventory_discrepancy',
  'system',
]);

export const alertLevelEnum = z.enum(['info', 'warning', 'error', 'critical']);

/**
 * GET /stores/:storeId/alerts
 * Сэрэмжлүүлэг жагсаалт харах
 */
export const alertsQuerySchema = z.object({
  alert_type: alertTypeEnum.optional(),
  level: alertLevelEnum.optional(),
  resolved: z
    .string()
    .transform((val) => val === 'true')
    .optional(),
  product_id: z.string().uuid().optional(),
  limit: z.coerce.number().min(1).max(100).default(20),
  offset: z.coerce.number().min(0).default(0),
});

export type AlertsQueryParams = z.infer<typeof alertsQuerySchema>;

export type AlertsListResponse = {
  success: true;
  alerts: Array<{
    id: string;
    store_id: string;
    alert_type: string;
    product_id: string | null;
    product_name?: string;
    product_sku?: string;
    message: string;
    level: string;
    resolved: boolean;
    created_at: string;
    resolved_at: string | null;
  }>;
  pagination: {
    total: number;
    limit: number;
    offset: number;
  };
};

/**
 * GET /stores/:storeId/alerts/:alertId
 * Сэрэмжлүүлэг дэлгэрэнгүй харах
 */
export type AlertDetailResponse = {
  success: true;
  alert: {
    id: string;
    store_id: string;
    alert_type: string;
    product_id: string | null;
    product_name?: string;
    product_sku?: string;
    message: string;
    level: string;
    resolved: boolean;
    created_at: string;
    resolved_at: string | null;
  };
};

/**
 * PUT /stores/:storeId/alerts/:alertId/resolve
 * Сэрэмжлүүлэг шийдвэрлэсэн гэж тэмдэглэх
 */
export type ResolveAlertResponse = {
  success: true;
  message: string;
  alert: {
    id: string;
    resolved: boolean;
    resolved_at: string;
  };
};

/**
 * POST /stores/:storeId/alerts (internal/system use)
 * Шинэ сэрэмжлүүлэг үүсгэх
 */
export const createAlertSchema = z.object({
  alert_type: alertTypeEnum,
  product_id: z.string().uuid().optional(),
  message: z.string().min(1),
  level: alertLevelEnum.default('info'),
});

export type CreateAlertBody = z.infer<typeof createAlertSchema>;

export type CreateAlertResponse = {
  success: true;
  alert: {
    id: string;
    store_id: string;
    alert_type: string;
    product_id: string | null;
    message: string;
    level: string;
    resolved: boolean;
    created_at: string;
  };
};
