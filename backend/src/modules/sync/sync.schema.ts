/**
 * Sync Module Schemas
 *
 * Zod validation schemas for offline-first synchronization:
 * - Batch sync operations
 * - Delta sync (changes since timestamp)
 * - Conflict resolution
 */

import { z } from 'zod';

/**
 * Sync operation types
 */
export const syncOperationTypeEnum = z.enum([
  'create_sale',
  'create_inventory_event',
  'update_product',
  'create_product',
  'open_shift',
  'close_shift',
]);

/**
 * Single sync operation
 */
export const syncOperationSchema = z.object({
  operation_type: syncOperationTypeEnum,
  client_id: z.string(), // Mobile client-ийн unique ID (UUID)
  client_timestamp: z.string().datetime(), // Mobile дээр үүссэн цаг
  data: z.record(z.any()), // Operation-ийн өгөгдөл (flexible)
});

/**
 * POST /sync
 * Batch sync request
 */
export const batchSyncSchema = z.object({
  device_id: z.string(), // Төхөөрөмжийн ID
  operations: z.array(syncOperationSchema).min(1).max(100), // Max 100 operations per batch
});

export type BatchSyncBody = z.infer<typeof batchSyncSchema>;

export type SyncOperation = z.infer<typeof syncOperationSchema>;

export type BatchSyncResponse = {
  success: true;
  synced: number;
  failed: number;
  results: Array<{
    client_id: string;
    status: 'success' | 'failed' | 'conflict';
    error?: string;
    server_id?: string; // Server дээр үүссэн ID (create operations-д)
  }>;
};

/**
 * GET /stores/:storeId/changes
 * Delta sync - өөрчлөлт татах
 */
export const changesQuerySchema = z.object({
  since: z.string().datetime(), // Энэ цагаас хойших өөрчлөлтүүд
  limit: z.coerce.number().min(1).max(500).default(100),
});

export type ChangesQueryParams = z.infer<typeof changesQuerySchema>;

export type ChangesResponse = {
  success: true;
  changes: {
    products: Array<any>;
    sales: Array<any>;
    inventory_events: Array<any>;
    shifts: Array<any>;
    alerts: Array<any>;
  };
  timestamp: string; // Server-ийн timestamp (дараагийн sync-д ашиглана)
};

/**
 * Conflict resolution strategies
 */
export type ConflictResolutionStrategy =
  | 'server_wins' // Server-ийн өгөгдөл ялна
  | 'client_wins' // Client-ийн өгөгдөл ялна
  | 'last_write_wins' // Хамгийн сүүлд бичсэн ялна (timestamp харах)
  | 'manual'; // Manual resolution шаардлагатай (error буцаана)
