/**
 * Alerts Routes
 *
 * Alerts management endpoints:
 * - GET /stores/:storeId/alerts - Сэрэмжлүүлэг жагсаалт
 * - GET /stores/:storeId/alerts/:alertId - Сэрэмжлүүлэг дэлгэрэнгүй
 * - PUT /stores/:storeId/alerts/:alertId/resolve - Сэрэмжлүүлэг шийдвэрлэх
 */

import type { FastifyInstance, FastifyRequest, FastifyReply } from 'fastify';
import {
  alertsQuerySchema,
  type AlertsQueryParams,
  type AlertsListResponse,
  type AlertDetailResponse,
  type ResolveAlertResponse,
} from './alerts.schema.js';
import { getAlerts, getAlertById, resolveAlert } from './alerts.service.js';
import { authorize, requireStore } from '../auth/auth.middleware.js';

/**
 * Alerts routes register
 */
export async function alertsRoutes(server: FastifyInstance) {
  /**
   * GET /stores/:storeId/alerts
   * Сэрэмжлүүлэг жагсаалт харах (owner, manager)
   */
  server.get<{
    Params: { storeId: string };
    Querystring: AlertsQueryParams;
    Reply: AlertsListResponse | { statusCode: number; error: string; message: string };
  }>(
    '/stores/:storeId/alerts',
    {
      onRequest: [server.authenticate, authorize(['owner', 'manager']), requireStore()],
    },
    async (request: FastifyRequest, reply: FastifyReply) => {
      const params = request.params as { storeId: string };
      const query = request.query as Record<string, unknown>;

      // Query validation
      const parseResult = alertsQuerySchema.safeParse(query);
      if (!parseResult.success) {
        return reply.status(400).send({
          statusCode: 400,
          error: 'Bad Request',
          message: parseResult.error.errors[0].message,
        });
      }

      // Сэрэмжлүүлэг авах
      const result = await getAlerts(params.storeId, parseResult.data);

      if (!result.success) {
        return reply.status(500).send({
          statusCode: 500,
          error: 'Internal Server Error',
          message: result.error,
        });
      }

      return reply.status(200).send({
        success: true,
        alerts: result.alerts,
        pagination: {
          total: result.total,
          limit: parseResult.data.limit,
          offset: parseResult.data.offset,
        },
      });
    }
  );

  /**
   * GET /stores/:storeId/alerts/:alertId
   * Сэрэмжлүүлэг дэлгэрэнгүй харах (owner, manager)
   */
  server.get<{
    Params: { storeId: string; alertId: string };
    Reply: AlertDetailResponse | { statusCode: number; error: string; message: string };
  }>(
    '/stores/:storeId/alerts/:alertId',
    {
      onRequest: [server.authenticate, authorize(['owner', 'manager']), requireStore()],
    },
    async (request: FastifyRequest, reply: FastifyReply) => {
      const params = request.params as { storeId: string; alertId: string };

      // Сэрэмжлүүлэг дэлгэрэнгүй авах
      const result = await getAlertById(params.storeId, params.alertId);

      if (!result.success) {
        return reply.status(404).send({
          statusCode: 404,
          error: 'Not Found',
          message: result.error,
        });
      }

      return reply.status(200).send({
        success: true,
        alert: result.alert,
      });
    }
  );

  /**
   * PUT /stores/:storeId/alerts/:alertId/resolve
   * Сэрэмжлүүлэг шийдвэрлэх (owner, manager)
   */
  server.put<{
    Params: { storeId: string; alertId: string };
    Reply: ResolveAlertResponse | { statusCode: number; error: string; message: string };
  }>(
    '/stores/:storeId/alerts/:alertId/resolve',
    {
      onRequest: [server.authenticate, authorize(['owner', 'manager']), requireStore()],
    },
    async (request: FastifyRequest, reply: FastifyReply) => {
      const params = request.params as { storeId: string; alertId: string };

      // Сэрэмжлүүлэг шийдвэрлэх
      const result = await resolveAlert(params.storeId, params.alertId);

      if (!result.success) {
        return reply.status(400).send({
          statusCode: 400,
          error: 'Bad Request',
          message: result.error,
        });
      }

      return reply.status(200).send({
        success: true,
        message: 'Сэрэмжлүүлэг амжилттай шийдвэрлэгдлээ',
        alert: result.alert,
      });
    }
  );

  server.log.info('✓ Alerts routes registered');
}
