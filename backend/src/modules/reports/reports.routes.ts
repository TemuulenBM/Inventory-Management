/**
 * Reports Routes
 *
 * Reports endpoints:
 * - GET /stores/:storeId/reports/daily - Өдрийн тайлан
 * - GET /stores/:storeId/reports/top-products - Шилдэг барааны тайлан
 * - GET /stores/:storeId/reports/seller-performance - Худалдагчийн үзүүлэлт
 * - GET /stores/:storeId/reports/profit - Ашгийн тайлан
 * - GET /stores/:storeId/reports/slow-moving - Муу зарагддаг бараа
 */

import type { FastifyInstance, FastifyRequest, FastifyReply } from 'fastify';
import {
  dailyReportQuerySchema,
  topProductsQuerySchema,
  sellerPerformanceQuerySchema,
  profitReportQuerySchema,
  slowMovingQuerySchema,
  type DailyReportQueryParams,
  type TopProductsQueryParams,
  type SellerPerformanceQueryParams,
  type ProfitReportQueryParams,
  type SlowMovingQueryParams,
  type DailyReportResponse,
  type TopProductsResponse,
  type SellerPerformanceResponse,
  type ProfitReportResponse,
  type SlowMovingResponse,
} from './reports.schema.js';
import {
  getDailyReport,
  getTopProducts,
  getSellerPerformance,
  getProfitReport,
  getSlowMovingProducts,
} from './reports.service.js';
import { authorize, requireStore } from '../auth/auth.middleware.js';

/**
 * Reports routes register
 */
export async function reportsRoutes(server: FastifyInstance) {
  /**
   * GET /stores/:storeId/reports/daily
   * Өдрийн тайлан (owner, manager only)
   */
  server.get<{
    Params: { storeId: string };
    Querystring: DailyReportQueryParams;
    Reply: DailyReportResponse | { statusCode: number; error: string; message: string };
  }>(
    '/stores/:storeId/reports/daily',
    {
      onRequest: [server.authenticate, authorize(['owner', 'manager']), requireStore()],
    },
    async (request: FastifyRequest, reply: FastifyReply) => {
      const params = request.params as { storeId: string };
      const query = request.query as Record<string, unknown>;

      // Query validation
      const parseResult = dailyReportQuerySchema.safeParse(query);
      if (!parseResult.success) {
        return reply.status(400).send({
          statusCode: 400,
          error: 'Bad Request',
          message: parseResult.error.errors[0].message,
        });
      }

      // Өдрийн тайлан авах
      const result = await getDailyReport(params.storeId, parseResult.data);

      if (!result.success) {
        return reply.status(500).send({
          statusCode: 500,
          error: 'Internal Server Error',
          message: result.error,
        });
      }

      return reply.status(200).send({
        success: true,
        report: result.report,
      });
    }
  );

  /**
   * GET /stores/:storeId/reports/top-products
   * Шилдэг барааны тайлан (owner, manager only)
   */
  server.get<{
    Params: { storeId: string };
    Querystring: TopProductsQueryParams;
    Reply: TopProductsResponse | { statusCode: number; error: string; message: string };
  }>(
    '/stores/:storeId/reports/top-products',
    {
      onRequest: [server.authenticate, authorize(['owner', 'manager']), requireStore()],
    },
    async (request: FastifyRequest, reply: FastifyReply) => {
      const params = request.params as { storeId: string };
      const query = request.query as Record<string, unknown>;

      // Query validation
      const parseResult = topProductsQuerySchema.safeParse(query);
      if (!parseResult.success) {
        return reply.status(400).send({
          statusCode: 400,
          error: 'Bad Request',
          message: parseResult.error.errors[0].message,
        });
      }

      // Шилдэг бараанууд авах
      const result = await getTopProducts(params.storeId, parseResult.data);

      if (!result.success) {
        return reply.status(500).send({
          statusCode: 500,
          error: 'Internal Server Error',
          message: result.error,
        });
      }

      return reply.status(200).send({
        success: true,
        products: result.products,
      });
    }
  );

  /**
   * GET /stores/:storeId/reports/seller-performance
   * Худалдагчийн үзүүлэлт (owner, manager only)
   */
  server.get<{
    Params: { storeId: string };
    Querystring: SellerPerformanceQueryParams;
    Reply: SellerPerformanceResponse | { statusCode: number; error: string; message: string };
  }>(
    '/stores/:storeId/reports/seller-performance',
    {
      onRequest: [server.authenticate, authorize(['owner', 'manager']), requireStore()],
    },
    async (request: FastifyRequest, reply: FastifyReply) => {
      const params = request.params as { storeId: string };
      const query = request.query as Record<string, unknown>;

      // Query validation
      const parseResult = sellerPerformanceQuerySchema.safeParse(query);
      if (!parseResult.success) {
        return reply.status(400).send({
          statusCode: 400,
          error: 'Bad Request',
          message: parseResult.error.errors[0].message,
        });
      }

      // Худалдагчийн үзүүлэлт авах
      const result = await getSellerPerformance(params.storeId, parseResult.data);

      if (!result.success) {
        return reply.status(500).send({
          statusCode: 500,
          error: 'Internal Server Error',
          message: result.error,
        });
      }

      return reply.status(200).send({
        success: true,
        sellers: result.sellers,
      });
    }
  );

  /**
   * GET /stores/:storeId/reports/profit
   * Ашгийн тайлан (owner only)
   */
  server.get<{
    Params: { storeId: string };
    Querystring: ProfitReportQueryParams;
    Reply: ProfitReportResponse | { statusCode: number; error: string; message: string };
  }>(
    '/stores/:storeId/reports/profit',
    {
      onRequest: [server.authenticate, authorize(['owner']), requireStore()],
    },
    async (request: FastifyRequest, reply: FastifyReply) => {
      const params = request.params as { storeId: string };
      const query = request.query as Record<string, unknown>;

      // Query validation
      const parseResult = profitReportQuerySchema.safeParse(query);
      if (!parseResult.success) {
        return reply.status(400).send({
          statusCode: 400,
          error: 'Bad Request',
          message: parseResult.error.errors[0].message,
        });
      }

      // Ашгийн тайлан авах
      const result = await getProfitReport(params.storeId, parseResult.data);

      if (!result.success) {
        return reply.status(500).send({
          statusCode: 500,
          error: 'Internal Server Error',
          message: result.error,
        });
      }

      return reply.status(200).send({
        success: true,
        report: result.report,
      });
    }
  );

  /**
   * GET /stores/:storeId/reports/slow-moving
   * Муу зарагддаг бараа (owner, manager only)
   */
  server.get<{
    Params: { storeId: string };
    Querystring: SlowMovingQueryParams;
    Reply: SlowMovingResponse | { statusCode: number; error: string; message: string };
  }>(
    '/stores/:storeId/reports/slow-moving',
    {
      onRequest: [server.authenticate, authorize(['owner', 'manager']), requireStore()],
    },
    async (request: FastifyRequest, reply: FastifyReply) => {
      const params = request.params as { storeId: string };
      const query = request.query as Record<string, unknown>;

      // Query validation
      const parseResult = slowMovingQuerySchema.safeParse(query);
      if (!parseResult.success) {
        return reply.status(400).send({
          statusCode: 400,
          error: 'Bad Request',
          message: parseResult.error.errors[0].message,
        });
      }

      // Муу зарагддаг бараанууд авах
      const result = await getSlowMovingProducts(params.storeId, parseResult.data);

      if (!result.success) {
        return reply.status(500).send({
          statusCode: 500,
          error: 'Internal Server Error',
          message: result.error,
        });
      }

      return reply.status(200).send({
        success: true,
        products: result.products,
      });
    }
  );

  server.log.info('✓ Reports routes registered');
}
