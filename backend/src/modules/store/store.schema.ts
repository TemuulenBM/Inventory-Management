/**
 * Store Module - Zod Validation Schemas
 *
 * Store CRUD validation schemas.
 */

import { z } from 'zod';

/**
 * Create Store Schema
 * POST /stores body validation
 */
export const createStoreSchema = z.object({
  name: z.string().min(1).max(100).describe('Дэлгүүрийн нэр'),
  location: z.string().min(1).max(200).describe('Хаяг'),
  timezone: z.string().default('Asia/Ulaanbaatar').describe('Цагийн бүс'),
});

export type CreateStoreBody = z.infer<typeof createStoreSchema>;

/**
 * Update Store Schema
 * PUT /stores/:id body validation
 */
export const updateStoreSchema = z.object({
  name: z.string().min(1).max(100).optional().describe('Дэлгүүрийн нэр'),
  location: z.string().min(1).max(200).optional().describe('Хаяг'),
  timezone: z.string().optional().describe('Цагийн бүс'),
});

export type UpdateStoreBody = z.infer<typeof updateStoreSchema>;

/**
 * Store Response Types
 */

// Store мэдээлэл
export interface StoreResponse {
  success: true;
  store: {
    id: string;
    name: string;
    location: string;
    ownerId: string;
    timezone: string;
    createdAt: string;
  };
}

// Store статистик
export interface StoreStatsResponse {
  success: true;
  stats: {
    totalProducts: number;
    totalUsers: number;
    totalSales: number;
    totalRevenue: number;
    lowStockProducts: number;
  };
}
