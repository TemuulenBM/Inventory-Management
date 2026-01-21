/**
 * Inventory Module - Zod Validation Schemas
 *
 * Inventory event sourcing validation schemas.
 * Event types: INITIAL, SALE, ADJUST, RETURN
 */

import { z } from 'zod';

/**
 * Event Type Enum
 */
export const eventTypeEnum = z.enum(['INITIAL', 'SALE', 'ADJUST', 'RETURN']);
export type EventType = z.infer<typeof eventTypeEnum>;

/**
 * Create Inventory Event Schema (Manual Adjustment)
 * POST /stores/:storeId/inventory-events body validation
 */
export const createInventoryEventSchema = z.object({
  productId: z.string().uuid().describe('Барааны ID'),
  eventType: eventTypeEnum.describe('Event төрөл'),
  qtyChange: z.number().int().describe('Тоо хэмжээний өөрчлөлт (+ нэмэх, - хасах)'),
  reason: z.string().max(500).optional().describe('Шалтгаан'),
  shiftId: z.string().uuid().optional().describe('Ээлжийн ID'),
});

export type CreateInventoryEventBody = z.infer<typeof createInventoryEventSchema>;

/**
 * Inventory Events Query Schema
 * GET /stores/:storeId/inventory-events query validation
 */
export const inventoryEventsQuerySchema = z.object({
  page: z.coerce.number().int().min(1).default(1).describe('Хуудас'),
  limit: z.coerce.number().int().min(1).max(100).default(20).describe('Хуудас бүрт'),
  productId: z.string().uuid().optional().describe('Барааны ID-аар шүүх'),
  eventType: eventTypeEnum.optional().describe('Event төрлөөр шүүх'),
  startDate: z.string().optional().describe('Эхлэх огноо (ISO format)'),
  endDate: z.string().optional().describe('Дуусах огноо (ISO format)'),
});

export type InventoryEventsQueryParams = z.infer<typeof inventoryEventsQuerySchema>;

/**
 * Stock History Query Schema
 * GET /stores/:storeId/products/:productId/stock-history query validation
 */
export const stockHistoryQuerySchema = z.object({
  page: z.coerce.number().int().min(1).default(1).describe('Хуудас'),
  limit: z.coerce.number().int().min(1).max(100).default(50).describe('Хуудас бүрт'),
});

export type StockHistoryQueryParams = z.infer<typeof stockHistoryQuerySchema>;

/**
 * Response Types
 */

// Inventory event мэдээлэл
export interface InventoryEventInfo {
  id: string;
  storeId: string;
  productId: string;
  productName?: string;
  eventType: string;
  qtyChange: number;
  reason: string | null;
  actorId: string;
  actorName?: string;
  shiftId: string | null;
  timestamp: string;
}

// Inventory events list response
export interface InventoryEventsListResponse {
  success: true;
  events: InventoryEventInfo[];
  pagination: {
    page: number;
    limit: number;
    total: number;
    totalPages: number;
  };
}

// Single event response
export interface InventoryEventResponse {
  success: true;
  event: InventoryEventInfo;
}

// Stock level info
export interface StockLevelInfo {
  productId: string;
  productName: string;
  sku: string | null;
  currentStock: number;
  lowStockThreshold: number | null;
  isLowStock: boolean;
  lastUpdated: string | null;
}

// Stock levels list response
export interface StockLevelsListResponse {
  success: true;
  stockLevels: StockLevelInfo[];
  summary: {
    totalProducts: number;
    lowStockCount: number;
    outOfStockCount: number;
  };
}

// Stock history response
export interface StockHistoryResponse {
  success: true;
  productId: string;
  productName: string;
  currentStock: number;
  events: InventoryEventInfo[];
  pagination: {
    page: number;
    limit: number;
    total: number;
    totalPages: number;
  };
}
