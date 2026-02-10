/**
 * Transfer Routes
 *
 * Салбар хоорондын бараа шилжүүлгийн endpoint-ууд:
 * - POST /stores/:storeId/transfers — Шилжүүлэг үүсгэх
 * - GET /stores/:storeId/transfers — Шилжүүлгийн жагсаалт
 * - PATCH /stores/:storeId/transfers/:id/cancel — Цуцлах
 */

import type { FastifyInstance, FastifyRequest, FastifyReply } from 'fastify';
import {
  createTransferSchema,
  transfersQuerySchema,
  type CreateTransferBody,
} from './transfer.schema.js';
import {
  createTransfer,
  getTransfers,
  cancelTransfer,
} from './transfer.service.js';
import { authorize, requireStore, type AuthRequest } from '../auth/auth.middleware.js';

export async function transferRoutes(server: FastifyInstance) {
  /**
   * POST /stores/:storeId/transfers
   * Шилжүүлэг үүсгэх (зөвхөн owner)
   */
  server.post<{
    Params: { storeId: string };
    Body: CreateTransferBody;
  }>(
    '/stores/:storeId/transfers',
    {
      onRequest: [server.authenticate, authorize(['owner']), requireStore()],
    },
    async (request: FastifyRequest, reply: FastifyReply) => {
      const { storeId } = request.params as { storeId: string };
      const authRequest = request as AuthRequest;
      const userId = authRequest.user.userId;

      if (!userId) {
        return reply.status(401).send({
          statusCode: 401,
          error: 'Unauthorized',
          message: 'Нэвтрэх шаардлагатай',
        });
      }

      // Validate body
      const parseResult = createTransferSchema.safeParse(request.body);
      if (!parseResult.success) {
        return reply.status(400).send({
          statusCode: 400,
          error: 'Bad Request',
          message: parseResult.error.errors[0].message,
        });
      }

      const result = await createTransfer(storeId, userId, parseResult.data);

      if (!result.success) {
        return reply.status(400).send({
          statusCode: 400,
          error: 'Bad Request',
          message: result.error,
        });
      }

      return reply.status(201).send({
        success: true,
        transfer: result.transfer,
      });
    }
  );

  /**
   * GET /stores/:storeId/transfers
   * Шилжүүлгийн жагсаалт
   */
  server.get<{
    Params: { storeId: string };
  }>(
    '/stores/:storeId/transfers',
    {
      onRequest: [server.authenticate, authorize(['owner', 'manager']), requireStore()],
    },
    async (request: FastifyRequest, reply: FastifyReply) => {
      const { storeId } = request.params as { storeId: string };
      const query = request.query as Record<string, unknown>;

      const parseResult = transfersQuerySchema.safeParse(query);
      if (!parseResult.success) {
        return reply.status(400).send({
          statusCode: 400,
          error: 'Bad Request',
          message: parseResult.error.errors[0].message,
        });
      }

      const result = await getTransfers(storeId, parseResult.data);

      if (!result.success) {
        return reply.status(500).send({
          statusCode: 500,
          error: 'Internal Server Error',
          message: result.error,
        });
      }

      return reply.status(200).send({
        success: true,
        transfers: result.transfers,
        pagination: result.pagination,
      });
    }
  );

  /**
   * PATCH /stores/:storeId/transfers/:id/cancel
   * Шилжүүлэг цуцлах
   */
  server.patch<{
    Params: { storeId: string; id: string };
  }>(
    '/stores/:storeId/transfers/:id/cancel',
    {
      onRequest: [server.authenticate, authorize(['owner']), requireStore()],
    },
    async (request: FastifyRequest, reply: FastifyReply) => {
      const { id } = request.params as { storeId: string; id: string };
      const authRequest = request as AuthRequest;
      const userId = authRequest.user.userId;

      if (!userId) {
        return reply.status(401).send({
          statusCode: 401,
          error: 'Unauthorized',
          message: 'Нэвтрэх шаардлагатай',
        });
      }

      const result = await cancelTransfer(id, userId);

      if (!result.success) {
        return reply.status(400).send({
          statusCode: 400,
          error: 'Bad Request',
          message: result.error,
        });
      }

      return reply.status(200).send({ success: true });
    }
  );

  server.log.info('✓ Transfer routes registered');
}
