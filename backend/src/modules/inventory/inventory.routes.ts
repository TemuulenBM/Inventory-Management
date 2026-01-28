/**
 * Inventory Routes
 *
 * Inventory event sourcing endpoints:
 * - GET /stores/:storeId/inventory-events - Event түүх
 * - POST /stores/:storeId/inventory-events - Manual adjustment
 * - GET /stores/:storeId/stock-levels - Бүх барааны үлдэгдэл
 * - GET /stores/:storeId/products/:productId/stock-history - Нэг барааны түүх
 */

import type { FastifyInstance, FastifyRequest, FastifyReply } from 'fastify';
import {
  createInventoryEventSchema,
  inventoryEventsQuerySchema,
  stockHistoryQuerySchema,
  type CreateInventoryEventBody,
  type InventoryEventsQueryParams,
  type StockHistoryQueryParams,
  type InventoryEventsListResponse,
  type InventoryEventResponse,
  type StockLevelsListResponse,
  type StockHistoryResponse,
} from './inventory.schema.js';
import {
  getInventoryEvents,
  createInventoryEvent,
  getStockLevels,
  getProductStockHistory,
} from './inventory.service.js';
import { authorize, requireStore } from '../auth/auth.middleware.js';
import type { AuthRequest } from '../auth/auth.middleware.js';
// Alert triggers - Inventory өөрчлөлтийн үед automatic alert үүсгэх
import { checkLowStock, checkNegativeStock } from '../alerts/alerts.service.js';

/**
 * Inventory routes register
 */
export async function inventoryRoutes(server: FastifyInstance) {
  /**
   * GET /stores/:storeId/inventory-events
   * Inventory event түүх авах (pagination, filter)
   */
  server.get<{
    Params: { storeId: string };
    Querystring: InventoryEventsQueryParams;
    Reply: InventoryEventsListResponse | { statusCode: number; error: string; message: string };
  }>(
    '/stores/:storeId/inventory-events',
    {
      onRequest: [server.authenticate, authorize(['owner', 'manager']), requireStore()],
    },
    async (request: FastifyRequest, reply: FastifyReply) => {
      const params = request.params as { storeId: string };
      const query = request.query as Record<string, unknown>;

      // Query validation
      const parseResult = inventoryEventsQuerySchema.safeParse(query);
      if (!parseResult.success) {
        return reply.status(400).send({
          statusCode: 400,
          error: 'Bad Request',
          message: parseResult.error.errors[0].message,
        });
      }

      // Event жагсаалт авах
      const result = await getInventoryEvents(params.storeId, parseResult.data);

      if (!result.success) {
        return reply.status(500).send({
          statusCode: 500,
          error: 'Internal Server Error',
          message: result.error,
        });
      }

      return reply.status(200).send({
        success: true,
        events: result.events,
        pagination: result.pagination,
      });
    }
  );

  /**
   * POST /stores/:storeId/inventory-events
   * Шинэ inventory event үүсгэх (Manual adjustment)
   */
  server.post<{
    Params: { storeId: string };
    Body: CreateInventoryEventBody;
    Reply: InventoryEventResponse | { statusCode: number; error: string; message: string };
  }>(
    '/stores/:storeId/inventory-events',
    {
      onRequest: [server.authenticate, authorize(['owner', 'manager']), requireStore()],
    },
    async (request: FastifyRequest, reply: FastifyReply) => {
      const authRequest = request as AuthRequest;
      const params = request.params as { storeId: string };

      // Body validation
      const parseResult = createInventoryEventSchema.safeParse(request.body);
      if (!parseResult.success) {
        return reply.status(400).send({
          statusCode: 400,
          error: 'Bad Request',
          message: parseResult.error.errors[0].message,
        });
      }

      // Event үүсгэх
      const result = await createInventoryEvent(
        params.storeId,
        authRequest.user.userId,
        parseResult.data
      );

      if (!result.success) {
        return reply.status(400).send({
          statusCode: 400,
          error: 'Bad Request',
          message: result.error,
        });
      }

      // ✅ Alert triggers - Бага үлдэгдэл болон сөрөг үлдэгдэл шалгах
      // Background дээр ажиллана (await хийхгүй бол API response саадлахгүй)
      checkLowStock(params.storeId, parseResult.data.product_id).catch((err) => {
        server.log.error({ err, productId: parseResult.data.product_id }, 'Low stock check failed');
      });
      checkNegativeStock(params.storeId, parseResult.data.product_id).catch((err) => {
        server.log.error({ err, productId: parseResult.data.product_id }, 'Negative stock check failed');
      });

      return reply.status(201).send({
        success: true,
        event: result.event,
      });
    }
  );

  /**
   * GET /stores/:storeId/stock-levels
   * Бүх барааны stock level авах
   */
  server.get<{
    Params: { storeId: string };
    Reply: StockLevelsListResponse | { statusCode: number; error: string; message: string };
  }>(
    '/stores/:storeId/stock-levels',
    {
      onRequest: [server.authenticate, requireStore()], // Бүх role хандах эрхтэй
    },
    async (request: FastifyRequest, reply: FastifyReply) => {
      const params = request.params as { storeId: string };

      // Stock levels авах
      const result = await getStockLevels(params.storeId);

      if (!result.success) {
        return reply.status(500).send({
          statusCode: 500,
          error: 'Internal Server Error',
          message: result.error,
        });
      }

      return reply.status(200).send({
        success: true,
        stockLevels: result.stockLevels,
        summary: result.summary,
      });
    }
  );

  /**
   * GET /stores/:storeId/products/:productId/stock-history
   * Нэг барааны stock түүх авах
   */
  server.get<{
    Params: { storeId: string; productId: string };
    Querystring: StockHistoryQueryParams;
    Reply: StockHistoryResponse | { statusCode: number; error: string; message: string };
  }>(
    '/stores/:storeId/products/:productId/stock-history',
    {
      onRequest: [server.authenticate, authorize(['owner', 'manager']), requireStore()],
    },
    async (request: FastifyRequest, reply: FastifyReply) => {
      const params = request.params as { storeId: string; productId: string };
      const query = request.query as Record<string, unknown>;

      // Query validation
      const parseResult = stockHistoryQuerySchema.safeParse(query);
      if (!parseResult.success) {
        return reply.status(400).send({
          statusCode: 400,
          error: 'Bad Request',
          message: parseResult.error.errors[0].message,
        });
      }

      // Stock түүх авах
      const result = await getProductStockHistory(params.storeId, params.productId, parseResult.data);

      if (!result.success) {
        return reply.status(404).send({
          statusCode: 404,
          error: 'Not Found',
          message: result.error,
        });
      }

      return reply.status(200).send({
        success: true,
        productId: result.productId,
        productName: result.productName,
        currentStock: result.currentStock,
        events: result.events,
        pagination: result.pagination,
      });
    }
  );

  server.log.info('✓ Inventory routes registered');
}
