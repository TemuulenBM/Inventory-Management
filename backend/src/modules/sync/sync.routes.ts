/**
 * Sync Routes
 *
 * Offline-first synchronization endpoints:
 * - POST /sync - Batch sync operations from mobile
 * - GET /stores/:storeId/changes - Delta sync (pull changes)
 */

import type { FastifyInstance, FastifyRequest, FastifyReply } from 'fastify';
import {
  batchSyncSchema,
  changesQuerySchema,
  type BatchSyncBody,
  type BatchSyncResponse,
  type ChangesQueryParams,
  type ChangesResponse,
} from './sync.schema.js';
import { processBatchSync, getChanges } from './sync.service.js';
import { requireStore, type AuthRequest } from '../auth/auth.middleware.js';

/**
 * Sync routes register
 */
export async function syncRoutes(server: FastifyInstance) {
  /**
   * POST /stores/:storeId/sync
   * Batch sync operations from mobile
   * - Бүх role-д зориулагдсан
   * - Offline дээр хуримтлуулсан operations-г sync хийх
   */
  server.post<{
    Params: { storeId: string };
    Body: BatchSyncBody;
    Reply: BatchSyncResponse | { statusCode: number; error: string; message: string };
  }>(
    '/stores/:storeId/sync',
    {
      onRequest: [server.authenticate, requireStore()],
    },
    async (request: FastifyRequest, reply: FastifyReply) => {
      const authRequest = request as AuthRequest;
      const params = request.params as { storeId: string };
      const userId = authRequest.user.userId;
      const storeId = params.storeId;

      // Body validation
      const parseResult = batchSyncSchema.safeParse(request.body);
      if (!parseResult.success) {
        return reply.status(400).send({
          statusCode: 400,
          error: 'Bad Request',
          message: parseResult.error.errors[0].message,
        });
      }

      // Process batch sync
      const result = await processBatchSync(storeId, userId, parseResult.data);

      if (!result.success) {
        return reply.status(500).send({
          statusCode: 500,
          error: 'Internal Server Error',
          message: result.error,
        });
      }

      return reply.status(200).send({
        success: true,
        synced: result.synced,
        failed: result.failed,
        results: result.results,
      });
    }
  );

  /**
   * GET /stores/:storeId/changes
   * Delta sync - Server-ийн өөрчлөлтүүдийг татах
   */
  server.get<{
    Params: { storeId: string };
    Querystring: ChangesQueryParams;
    Reply: ChangesResponse | { statusCode: number; error: string; message: string };
  }>(
    '/stores/:storeId/changes',
    {
      onRequest: [server.authenticate, requireStore()],
    },
    async (request: FastifyRequest, reply: FastifyReply) => {
      const params = request.params as { storeId: string };
      const query = request.query as Record<string, unknown>;

      // Query validation
      const parseResult = changesQuerySchema.safeParse(query);
      if (!parseResult.success) {
        return reply.status(400).send({
          statusCode: 400,
          error: 'Bad Request',
          message: parseResult.error.errors[0].message,
        });
      }

      // Get changes
      const result = await getChanges(params.storeId, parseResult.data);

      if (!result.success) {
        return reply.status(500).send({
          statusCode: 500,
          error: 'Internal Server Error',
          message: result.error,
        });
      }

      return reply.status(200).send({
        success: true,
        changes: result.changes,
        timestamp: result.timestamp,
      });
    }
  );

  server.log.info('✓ Sync routes registered');
}
