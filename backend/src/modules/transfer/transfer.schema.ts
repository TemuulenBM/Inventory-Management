/**
 * Transfer Module Schemas
 *
 * Салбар хоорондын бараа шилжүүлгийн Zod validation schema-ууд.
 * Жишээ: Sunday Plaza → Алтжин Бөмбөгөр, 5ш цамц
 */

import { z } from 'zod';

/**
 * Шилжүүлэг үүсгэх
 * POST /stores/:storeId/transfers
 */
export const createTransferSchema = z.object({
  destination_store_id: z.string().uuid().describe('Очих салбарын ID'),
  items: z.array(z.object({
    product_id: z.string().uuid().describe('Барааны ID'),
    quantity: z.number().int().min(1).describe('Тоо ширхэг'),
  })).min(1, 'Хамгийн багадаа 1 бараа шилжүүлэх шаардлагатай'),
  notes: z.string().max(500).optional().describe('Тэмдэглэл'),
});

export type CreateTransferBody = z.infer<typeof createTransferSchema>;

/**
 * Шилжүүлгийн жагсаалт query
 * GET /stores/:storeId/transfers
 */
export const transfersQuerySchema = z.object({
  status: z.enum(['pending', 'completed', 'cancelled']).optional(),
  direction: z.enum(['outgoing', 'incoming', 'all']).default('all'),
  limit: z.coerce.number().min(1).max(100).default(20),
  offset: z.coerce.number().min(0).default(0),
});

export type TransfersQueryParams = z.infer<typeof transfersQuerySchema>;

/**
 * Transfer response type
 */
export interface TransferInfo {
  id: string;
  sourceStore: { id: string; name: string };
  destinationStore: { id: string; name: string };
  initiatedBy: { id: string; name: string };
  status: 'pending' | 'completed' | 'cancelled';
  notes: string | null;
  items: Array<{
    id: string;
    productId: string;
    productName: string;
    quantity: number;
  }>;
  createdAt: string;
  completedAt: string | null;
}

export interface TransferListResponse {
  success: true;
  transfers: TransferInfo[];
  pagination: {
    total: number;
    limit: number;
    offset: number;
  };
}
