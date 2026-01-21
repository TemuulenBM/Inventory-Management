/**
 * Sales Routes
 *
 * Sales management endpoints:
 * - POST /stores/:storeId/sales - Борлуулалт бүртгэх
 * - GET /stores/:storeId/sales - Борлуулалтын түүх
 * - GET /stores/:storeId/sales/:saleId - Борлуулалт дэлгэрэнгүй
 * - POST /stores/:storeId/sales/:saleId/void - Борлуулалт цуцлах
 */

import type { FastifyInstance, FastifyRequest, FastifyReply } from 'fastify';
import {
  createSaleSchema,
  salesQuerySchema,
  type CreateSaleBody,
  type SalesQueryParams,
  type CreateSaleResponse,
  type SalesListResponse,
  type SaleDetailResponse,
  type VoidSaleResponse,
} from './sales.schema.js';
import { createSale, getSales, getSale, voidSale } from './sales.service.js';
import { authorize, requireStore, type AuthRequest } from '../auth/auth.middleware.js';

/**
 * Sales routes register
 */
export async function salesRoutes(server: FastifyInstance) {
  /**
   * POST /stores/:storeId/sales
   * Борлуулалт бүртгэх (бүх role)
   */
  server.post<{
    Params: { storeId: string };
    Body: CreateSaleBody;
    Reply: CreateSaleResponse | { statusCode: number; error: string; message: string };
  }>(
    '/stores/:storeId/sales',
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
      const parseResult = createSaleSchema.safeParse(request.body);
      if (!parseResult.success) {
        return reply.status(400).send({
          statusCode: 400,
          error: 'Bad Request',
          message: parseResult.error.errors[0].message,
        });
      }

      // Борлуулалт үүсгэх
      const result = await createSale(params.storeId, userId, parseResult.data);

      if (!result.success) {
        return reply.status(400).send({
          statusCode: 400,
          error: 'Bad Request',
          message: result.error,
        });
      }

      return reply.status(201).send({
        success: true,
        sale: result.sale,
      });
    }
  );

  /**
   * GET /stores/:storeId/sales
   * Борлуулалтын түүх харах
   * - Owner, Manager: бүх борлуулалт
   * - Seller: зөвхөн өөрийн борлуулалт
   */
  server.get<{
    Params: { storeId: string };
    Querystring: SalesQueryParams;
    Reply: SalesListResponse | { statusCode: number; error: string; message: string };
  }>(
    '/stores/:storeId/sales',
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
      const parseResult = salesQuerySchema.safeParse(query);
      if (!parseResult.success) {
        return reply.status(400).send({
          statusCode: 400,
          error: 'Bad Request',
          message: parseResult.error.errors[0].message,
        });
      }

      // Seller зөвхөн өөрийн борлуулалтыг харна
      const queryData = parseResult.data;
      if (userRole === 'seller' && userId) {
        queryData.seller_id = userId;
      }

      // Борлуулалтын түүх авах
      const result = await getSales(params.storeId, queryData);

      if (!result.success) {
        return reply.status(500).send({
          statusCode: 500,
          error: 'Internal Server Error',
          message: result.error,
        });
      }

      return reply.status(200).send({
        success: true,
        sales: result.sales,
        pagination: result.pagination,
      });
    }
  );

  /**
   * GET /stores/:storeId/sales/:saleId
   * Борлуулалт дэлгэрэнгүй харах
   */
  server.get<{
    Params: { storeId: string; saleId: string };
    Reply: SaleDetailResponse | { statusCode: number; error: string; message: string };
  }>(
    '/stores/:storeId/sales/:saleId',
    {
      onRequest: [server.authenticate, requireStore()],
    },
    async (request: FastifyRequest, reply: FastifyReply) => {
      const params = request.params as { storeId: string; saleId: string };

      // Борлуулалт дэлгэрэнгүй авах
      const result = await getSale(params.saleId, params.storeId);

      if (!result.success) {
        return reply.status(404).send({
          statusCode: 404,
          error: 'Not Found',
          message: result.error,
        });
      }

      // Seller зөвхөн өөрийн борлуулалтыг харна
      const authRequest = request as AuthRequest;
      const userRole = authRequest.user.role;
      const userId = authRequest.user.userId;
      if (userRole === 'seller' && result.sale.seller_id !== userId) {
        return reply.status(403).send({
          statusCode: 403,
          error: 'Forbidden',
          message: 'Та зөвхөн өөрийн борлуулалтыг харах эрхтэй',
        });
      }

      return reply.status(200).send({
        success: true,
        sale: result.sale,
      });
    }
  );

  /**
   * POST /stores/:storeId/sales/:saleId/void
   * Борлуулалт цуцлах (owner, manager only)
   */
  server.post<{
    Params: { storeId: string; saleId: string };
    Reply: VoidSaleResponse | { statusCode: number; error: string; message: string };
  }>(
    '/stores/:storeId/sales/:saleId/void',
    {
      onRequest: [server.authenticate, authorize(['owner', 'manager']), requireStore()],
    },
    async (request: FastifyRequest, reply: FastifyReply) => {
      const params = request.params as { storeId: string; saleId: string };
      const authRequest = request as AuthRequest;
      const userId = authRequest.user.userId;

      if (!userId) {
        return reply.status(401).send({
          statusCode: 401,
          error: 'Unauthorized',
          message: 'Нэвтрэх шаардлагатай',
        });
      }

      // Борлуулалт цуцлах
      const result = await voidSale(params.saleId, params.storeId, userId);

      if (!result.success) {
        return reply.status(400).send({
          statusCode: 400,
          error: 'Bad Request',
          message: result.error,
        });
      }

      return reply.status(200).send({
        success: true,
        message: result.message,
      });
    }
  );

  server.log.info('✓ Sales routes registered');
}
