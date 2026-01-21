/**
 * Store Routes
 *
 * Store management endpoints:
 * - POST /stores - Store үүсгэх
 * - GET /stores/:id - Store мэдээлэл
 * - PUT /stores/:id - Store засах
 * - GET /stores/:id/stats - Store статистик
 */

import type { FastifyInstance, FastifyRequest, FastifyReply } from 'fastify';
import { createStoreSchema, updateStoreSchema, type StoreResponse, type StoreStatsResponse } from './store.schema.js';
import { createStore, getStore, updateStore, getStoreStats } from './store.service.js';
import { authorize, requireStore } from '../auth/auth.middleware.js';
import type { AuthRequest } from '../auth/auth.middleware.js';

/**
 * Store routes register
 */
export async function storeRoutes(server: FastifyInstance) {
  /**
   * POST /stores
   * Store үүсгэх endpoint (зөвхөн нэвтэрсэн хэрэглэгч)
   */
  server.post<{
    Body: { name: string; location: string; timezone?: string };
    Reply: StoreResponse | { statusCode: number; error: string; message: string };
  }>(
    '/stores',
    {
      onRequest: [server.authenticate], // JWT required, role хязгаарлалтгүй
    },
    async (request: FastifyRequest, reply: FastifyReply) => {
      const authRequest = request as AuthRequest;

      // 1. Request validation
      const parseResult = createStoreSchema.safeParse(request.body);
      if (!parseResult.success) {
        return reply.status(400).send({
          statusCode: 400,
          error: 'Bad Request',
          message: parseResult.error.errors[0].message,
        });
      }

      const { name, location, timezone } = parseResult.data;

      // 2. Store үүсгэх
      const result = await createStore({ name, location, timezone }, authRequest.user.userId);

      if (!result.success) {
        return reply.status(500).send({
          statusCode: 500,
          error: 'Internal Server Error',
          message: result.error,
        });
      }

      // 3. Амжилттай
      return reply.status(201).send({
        success: true,
        store: result.store,
      });
    }
  );

  /**
   * GET /stores/:id
   * Store мэдээлэл авах endpoint
   */
  server.get<{
    Params: { id: string };
    Reply: StoreResponse | { statusCode: number; error: string; message: string };
  }>(
    '/stores/:id',
    {
      onRequest: [server.authenticate, requireStore()], // JWT + store ownership required
    },
    async (request: FastifyRequest, reply: FastifyReply) => {
      const params = request.params as { id: string };

      // Store мэдээлэл авах
      const result = await getStore(params.id);

      if (!result.success) {
        return reply.status(404).send({
          statusCode: 404,
          error: 'Not Found',
          message: result.error,
        });
      }

      return reply.status(200).send({
        success: true,
        store: result.store,
      });
    }
  );

  /**
   * PUT /stores/:id
   * Store мэдээлэл засах endpoint (owner only)
   */
  server.put<{
    Params: { id: string };
    Body: { name?: string; location?: string; timezone?: string };
    Reply: StoreResponse | { statusCode: number; error: string; message: string };
  }>(
    '/stores/:id',
    {
      onRequest: [server.authenticate, authorize(['owner']), requireStore()], // Owner only
    },
    async (request: FastifyRequest, reply: FastifyReply) => {
      const params = request.params as { id: string };

      // 1. Request validation
      const parseResult = updateStoreSchema.safeParse(request.body);
      if (!parseResult.success) {
        return reply.status(400).send({
          statusCode: 400,
          error: 'Bad Request',
          message: parseResult.error.errors[0].message,
        });
      }

      const data = parseResult.data;

      // 2. Store шинэчлэх
      const result = await updateStore(params.id, data);

      if (!result.success) {
        return reply.status(500).send({
          statusCode: 500,
          error: 'Internal Server Error',
          message: result.error,
        });
      }

      return reply.status(200).send({
        success: true,
        store: result.store,
      });
    }
  );

  /**
   * GET /stores/:id/stats
   * Store статистик авах endpoint (owner, manager)
   */
  server.get<{
    Params: { id: string };
    Reply: StoreStatsResponse | { statusCode: number; error: string; message: string };
  }>(
    '/stores/:id/stats',
    {
      onRequest: [server.authenticate, authorize(['owner', 'manager']), requireStore()], // Owner + Manager
    },
    async (request: FastifyRequest, reply: FastifyReply) => {
      const params = request.params as { id: string };

      // Store статистик авах
      const result = await getStoreStats(params.id);

      if (!result.success) {
        return reply.status(500).send({
          statusCode: 500,
          error: 'Internal Server Error',
          message: 'Статистик авахад алдаа гарлаа',
        });
      }

      return reply.status(200).send({
        success: true,
        stats: result.stats,
      });
    }
  );

  server.log.info('✓ Store routes registered');
}
