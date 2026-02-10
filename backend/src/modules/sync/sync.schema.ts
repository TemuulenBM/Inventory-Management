/**
 * Sync Module Schemas
 *
 * Zod validation schemas for offline-first synchronization:
 * - Batch sync operations (operation type бүрт typed data validation)
 * - Delta sync (changes since timestamp)
 * - Conflict resolution
 */

import { z } from 'zod';

/**
 * Sync operation types
 */
export const syncOperationTypeEnum = z.enum([
  'create_sale',
  'void_sale',
  'create_inventory_event',
  'update_product',
  'create_product',
  'open_shift',
  'close_shift',
  'create_transfer',
]);

// ============================================================================
// Operation type бүрийн data schema
// ============================================================================

/** Борлуулалт үүсгэх */
const createSaleDataSchema = z.object({
  items: z.array(z.object({
    product_id: z.string().uuid(),
    quantity: z.number().int().min(1),
    unit_price: z.number().int().min(0),
  })).min(1),
  payment_method: z.enum(['cash', 'card', 'qr', 'transfer']).default('cash'),
  shift_id: z.string().uuid().optional(),
});

/** Борлуулалт цуцлах */
const voidSaleDataSchema = z.object({
  sale_id: z.string().uuid(),
  reason: z.string().optional(),
});

/** Inventory event үүсгэх */
const createInventoryEventDataSchema = z.object({
  productId: z.string().uuid(),
  eventType: z.enum(['INITIAL', 'SALE', 'ADJUST', 'RETURN']),
  qtyChange: z.number().int(), // Сөрөг байж болно (SALE, ADJUST)
  reason: z.string().optional(),
  shiftId: z.string().uuid().optional(),
});

/** Бараа шинэчлэх */
const updateProductDataSchema = z.object({
  product_id: z.string().uuid(),
  name: z.string().min(1).optional(),
  sku: z.string().optional(),
  unit: z.string().optional(),
  sell_price: z.number().int().min(0).optional(),
  cost_price: z.number().int().min(0).nullable().optional(),
  low_stock_threshold: z.number().int().min(0).optional(),
  note: z.string().nullable().optional(),
});

/** Бараа үүсгэх */
const createProductDataSchema = z.object({
  name: z.string().min(1),
  sku: z.string().min(1),
  unit: z.string().min(1),
  sell_price: z.number().int().min(0),
  cost_price: z.number().int().min(0).nullable().optional(),
  low_stock_threshold: z.number().int().min(0).optional(),
  note: z.string().nullable().optional(),
});

/** Shift нээх */
const openShiftDataSchema = z.object({
  open_balance: z.number().int().min(0).default(0),
});

/** Shift хаах */
const closeShiftDataSchema = z.object({
  shift_id: z.string().uuid(),
  close_balance: z.number().int().min(0).default(0),
});

/** Салбар хоорондын шилжүүлэг үүсгэх */
const createTransferDataSchema = z.object({
  destination_store_id: z.string().uuid(),
  items: z.array(z.object({
    product_id: z.string().uuid(),
    quantity: z.number().int().min(1),
  })).min(1),
  notes: z.string().optional(),
});

/**
 * Single sync operation
 *
 * data: z.record(z.any()) — service давхарга destructure хийдэг тул any хэвээр.
 * .refine() дотор operation type бүрийн schema-р validate хийнэ.
 */
export const syncOperationSchema = z.object({
  operation_type: syncOperationTypeEnum,
  client_id: z.string(), // Mobile client-ийн unique ID (UUID)
  client_timestamp: z.string().datetime(), // Mobile дээр үүссэн цаг
  data: z.record(z.any()), // Service давхаргын destructure-тэй нийцтэй
}).refine(
  (op) => {
    // Operation type-д тохирсон data байгаа эсэхийг шалгах
    const schemas: Record<string, z.ZodType> = {
      create_sale: createSaleDataSchema,
      void_sale: voidSaleDataSchema,
      create_inventory_event: createInventoryEventDataSchema,
      update_product: updateProductDataSchema,
      create_product: createProductDataSchema,
      open_shift: openShiftDataSchema,
      close_shift: closeShiftDataSchema,
      create_transfer: createTransferDataSchema,
    };
    const schema = schemas[op.operation_type];
    if (!schema) return true; // Unknown type → service давхаргад шалгана
    return schema.safeParse(op.data).success;
  },
  {
    message: 'Operation data нь operation_type-д тохирохгүй байна',
  }
);

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
    products: Array<Record<string, unknown>>;
    sales: Array<Record<string, unknown>>;
    inventory_events: Array<Record<string, unknown>>;
    shifts: Array<Record<string, unknown>>;
    alerts: Array<Record<string, unknown>>;
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
