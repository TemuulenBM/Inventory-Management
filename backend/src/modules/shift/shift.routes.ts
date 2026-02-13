/**
 * Shift Routes
 *
 * Shift management endpoints:
 * - POST /stores/:storeId/shifts/open - Ээлж нээх
 * - POST /stores/:storeId/shifts/close - Ээлж хаах
 * - GET /stores/:storeId/shifts - Ээлжийн түүх
 * - GET /stores/:storeId/shifts/:shiftId - Ээлж дэлгэрэнгүй
 * - GET /stores/:storeId/shifts/active - Идэвхтэй ээлж
 */

import type { FastifyInstance, FastifyRequest, FastifyReply } from 'fastify';
import {
  openShiftSchema,
  closeShiftSchema,
  shiftQuerySchema,
  type OpenShiftBody,
  type CloseShiftBody,
  type ShiftQueryParams,
  type OpenShiftResponse,
  type CloseShiftResponse,
  type ShiftListResponse,
  type ShiftDetailResponse,
  type ActiveShiftResponse,
} from './shift.schema.js';
import {
  openShift,
  closeShift,
  getShifts,
  getShift,
  getActiveShift,
  getShiftInventoryCounts,
} from './shift.service.js';
import { requireStore, type AuthRequest } from '../auth/auth.middleware.js';

/**
 * Shift routes register
 */
export async function shiftRoutes(server: FastifyInstance) {
  /**
   * POST /stores/:storeId/shifts/open
   * Ээлж нээх (seller only)
   */
  server.post<{
    Params: { storeId: string };
    Body: OpenShiftBody;
    Reply: OpenShiftResponse | { statusCode: number; error: string; message: string };
  }>(
    '/stores/:storeId/shifts/open',
    {
      onRequest: [server.authenticate, requireStore()],
    },
    async (request: FastifyRequest, reply: FastifyReply) => {
      const params = request.params as { storeId: string };
      const authRequest = request as AuthRequest;
      const userId = authRequest.user.userId;

      if (!userId) {
        return reply.status(401).send({
          statusCode: 401,
          error: 'Unauthorized',
          message: 'Нэвтрэх шаардлагатай',
        });
      }

      // Body validation
      const parseResult = openShiftSchema.safeParse(request.body);
      if (!parseResult.success) {
        return reply.status(400).send({
          statusCode: 400,
          error: 'Bad Request',
          message: parseResult.error.errors[0].message,
        });
      }

      // Ээлж нээх
      const result = await openShift(params.storeId, userId, parseResult.data);

      if (!result.success) {
        return reply.status(400).send({
          statusCode: 400,
          error: 'Bad Request',
          message: result.error,
        });
      }

      return reply.status(201).send({
        success: true,
        shift: result.shift,
      });
    }
  );

  /**
   * POST /stores/:storeId/shifts/close
   * Ээлж хаах (seller only)
   */
  server.post<{
    Params: { storeId: string };
    Body: CloseShiftBody;
    Reply: CloseShiftResponse | { statusCode: number; error: string; message: string };
  }>(
    '/stores/:storeId/shifts/close',
    {
      onRequest: [server.authenticate, requireStore()],
    },
    async (request: FastifyRequest, reply: FastifyReply) => {
      const params = request.params as { storeId: string };
      const authRequest = request as AuthRequest;
      const userId = authRequest.user.userId;

      if (!userId) {
        return reply.status(401).send({
          statusCode: 401,
          error: 'Unauthorized',
          message: 'Нэвтрэх шаардлагатай',
        });
      }

      // Body validation
      const parseResult = closeShiftSchema.safeParse(request.body);
      if (!parseResult.success) {
        return reply.status(400).send({
          statusCode: 400,
          error: 'Bad Request',
          message: parseResult.error.errors[0].message,
        });
      }

      // Ээлж хаах
      const result = await closeShift(params.storeId, userId, parseResult.data);

      if (!result.success) {
        return reply.status(400).send({
          statusCode: 400,
          error: 'Bad Request',
          message: result.error,
        });
      }

      return reply.status(200).send({
        success: true,
        shift: result.shift,
      });
    }
  );

  /**
   * GET /stores/:storeId/shifts
   * Ээлжийн түүх харах (owner, manager, seller - өөрийн ээлжүүдийг харна)
   */
  server.get<{
    Params: { storeId: string };
    Querystring: ShiftQueryParams;
    Reply: ShiftListResponse | { statusCode: number; error: string; message: string };
  }>(
    '/stores/:storeId/shifts',
    {
      onRequest: [server.authenticate, requireStore()],
    },
    async (request: FastifyRequest, reply: FastifyReply) => {
      const params = request.params as { storeId: string };
      const query = request.query as Record<string, unknown>;
      const authRequest = request as AuthRequest;
      const userRole = authRequest.user.role;
      const userId = authRequest.user.userId;

      // Query validation
      const parseResult = shiftQuerySchema.safeParse(query);
      if (!parseResult.success) {
        return reply.status(400).send({
          statusCode: 400,
          error: 'Bad Request',
          message: parseResult.error.errors[0].message,
        });
      }

      // Seller зөвхөн өөрийн ээлжүүдийг харна
      const queryData = parseResult.data;
      if (userRole === 'seller' && userId) {
        queryData.seller_id = userId;
      }

      // Ээлжийн түүх авах
      const result = await getShifts(params.storeId, queryData);

      if (!result.success) {
        return reply.status(500).send({
          statusCode: 500,
          error: 'Internal Server Error',
          message: result.error,
        });
      }

      return reply.status(200).send({
        success: true,
        shifts: result.shifts,
        pagination: result.pagination,
      });
    }
  );

  /**
   * GET /stores/:storeId/shifts/:shiftId
   * Ээлж дэлгэрэнгүй харах
   */
  server.get<{
    Params: { storeId: string; shiftId: string };
    Reply: ShiftDetailResponse | { statusCode: number; error: string; message: string };
  }>(
    '/stores/:storeId/shifts/:shiftId',
    {
      onRequest: [server.authenticate, requireStore()],
    },
    async (request: FastifyRequest, reply: FastifyReply) => {
      const params = request.params as { storeId: string; shiftId: string };

      // Ээлж дэлгэрэнгүй авах
      const result = await getShift(params.shiftId, params.storeId);

      if (!result.success) {
        return reply.status(404).send({
          statusCode: 404,
          error: 'Not Found',
          message: result.error,
        });
      }

      // Seller зөвхөн өөрийн ээлжийг харна
      const authRequest = request as AuthRequest;
      const userRole = authRequest.user.role;
      const userId = authRequest.user.userId;
      if (userRole === 'seller' && result.shift.seller_id !== userId) {
        return reply.status(403).send({
          statusCode: 403,
          error: 'Forbidden',
          message: 'Та зөвхөн өөрийн ээлжийг харах эрхтэй',
        });
      }

      return reply.status(200).send({
        success: true,
        shift: result.shift,
      });
    }
  );

  /**
   * GET /stores/:storeId/shifts/active
   * Идэвхтэй ээлж харах (seller - өөрийнхөө)
   */
  server.get<{
    Params: { storeId: string };
    Reply: ActiveShiftResponse | { statusCode: number; error: string; message: string };
  }>(
    '/stores/:storeId/shifts/active',
    {
      onRequest: [server.authenticate, requireStore()],
    },
    async (request: FastifyRequest, reply: FastifyReply) => {
      const params = request.params as { storeId: string };
      const authRequest = request as AuthRequest;
      const userId = authRequest.user.userId;

      if (!userId) {
        return reply.status(401).send({
          statusCode: 401,
          error: 'Unauthorized',
          message: 'Нэвтрэх шаардлагатай',
        });
      }

      // Идэвхтэй ээлж авах
      const result = await getActiveShift(params.storeId, userId);

      if (!result.success) {
        return reply.status(500).send({
          statusCode: 500,
          error: 'Internal Server Error',
          message: result.error,
        });
      }

      return reply.status(200).send({
        success: true,
        shift: result.shift,
      });
    }
  );

  /**
   * GET /stores/:storeId/shifts/:shiftId/inventory-counts
   * Тухайн ээлжийн бараа тоолгын зөрүү (owner, manager only)
   */
  server.get<{
    Params: { storeId: string; shiftId: string };
  }>(
    '/stores/:storeId/shifts/:shiftId/inventory-counts',
    {
      onRequest: [server.authenticate, requireStore()],
    },
    async (request: FastifyRequest, reply: FastifyReply) => {
      const params = request.params as { storeId: string; shiftId: string };

      const result = await getShiftInventoryCounts(params.shiftId, params.storeId);

      if (!result.success) {
        return reply.status(500).send({
          statusCode: 500,
          error: 'Internal Server Error',
          message: result.error,
        });
      }

      return reply.status(200).send({
        success: true,
        counts: result.counts,
        summary: result.summary,
      });
    }
  );

  server.log.info('✓ Shift routes registered');
}
