/**
 * Product Routes
 *
 * Product management endpoints:
 * - GET /stores/:storeId/products - Бараа жагсаалт
 * - GET /stores/:storeId/products/:productId - Бараа дэлгэрэнгүй
 * - POST /stores/:storeId/products - Бараа нэмэх
 * - PUT /stores/:storeId/products/:productId - Бараа засах
 * - DELETE /stores/:storeId/products/:productId - Бараа устгах (soft delete)
 * - POST /stores/:storeId/products/bulk - Олон бараа нэмэх
 */

import type { FastifyInstance, FastifyRequest, FastifyReply } from 'fastify';
import {
  createProductSchema,
  updateProductSchema,
  bulkCreateProductsSchema,
  productQuerySchema,
  type CreateProductBody,
  type UpdateProductBody,
  type BulkCreateProductsBody,
  type ProductQueryParams,
  type ProductsListResponse,
  type ProductResponse,
  type BulkCreateResponse,
} from './product.schema.js';
import {
  getProducts,
  getProduct,
  createProduct,
  updateProduct,
  deleteProduct,
  bulkCreateProducts,
} from './product.service.js';
import { authorize, requireStore } from '../auth/auth.middleware.js';

/**
 * Product routes register
 */
export async function productRoutes(server: FastifyInstance) {
  /**
   * GET /stores/:storeId/products
   * Барааны жагсаалт авах (pagination, search, filter)
   */
  server.get<{
    Params: { storeId: string };
    Querystring: ProductQueryParams;
    Reply: ProductsListResponse | { statusCode: number; error: string; message: string };
  }>(
    '/stores/:storeId/products',
    {
      onRequest: [server.authenticate, requireStore()], // Бүх role хандах эрхтэй
    },
    async (request: FastifyRequest, reply: FastifyReply) => {
      const params = request.params as { storeId: string };
      const query = request.query as Record<string, unknown>;

      // Query validation
      const parseResult = productQuerySchema.safeParse(query);
      if (!parseResult.success) {
        return reply.status(400).send({
          statusCode: 400,
          error: 'Bad Request',
          message: parseResult.error.errors[0].message,
        });
      }

      // Барааны жагсаалт авах
      const result = await getProducts(params.storeId, parseResult.data);

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
        pagination: result.pagination,
      });
    }
  );

  /**
   * GET /stores/:storeId/products/:productId
   * Бараа дэлгэрэнгүй мэдээлэл авах
   */
  server.get<{
    Params: { storeId: string; productId: string };
    Reply: ProductResponse | { statusCode: number; error: string; message: string };
  }>(
    '/stores/:storeId/products/:productId',
    {
      onRequest: [server.authenticate, requireStore()], // Бүх role хандах эрхтэй
    },
    async (request: FastifyRequest, reply: FastifyReply) => {
      const params = request.params as { storeId: string; productId: string };

      // Бараа авах
      const result = await getProduct(params.productId, params.storeId);

      if (!result.success) {
        return reply.status(404).send({
          statusCode: 404,
          error: 'Not Found',
          message: result.error,
        });
      }

      return reply.status(200).send({
        success: true,
        product: result.product,
      });
    }
  );

  /**
   * POST /stores/:storeId/products
   * Шинэ бараа нэмэх (owner, manager)
   */
  server.post<{
    Params: { storeId: string };
    Body: CreateProductBody;
    Reply: ProductResponse | { statusCode: number; error: string; message: string };
  }>(
    '/stores/:storeId/products',
    {
      onRequest: [server.authenticate, authorize(['owner', 'manager']), requireStore()],
    },
    async (request: FastifyRequest, reply: FastifyReply) => {
      const params = request.params as { storeId: string };

      // Body validation
      const parseResult = createProductSchema.safeParse(request.body);
      if (!parseResult.success) {
        return reply.status(400).send({
          statusCode: 400,
          error: 'Bad Request',
          message: parseResult.error.errors[0].message,
        });
      }

      // Бараа үүсгэх
      const result = await createProduct(params.storeId, parseResult.data);

      if (!result.success) {
        return reply.status(400).send({
          statusCode: 400,
          error: 'Bad Request',
          message: result.error,
        });
      }

      return reply.status(201).send({
        success: true,
        product: result.product,
      });
    }
  );

  /**
   * PUT /stores/:storeId/products/:productId
   * Бараа мэдээлэл засах (owner, manager)
   */
  server.put<{
    Params: { storeId: string; productId: string };
    Body: UpdateProductBody;
    Reply: ProductResponse | { statusCode: number; error: string; message: string };
  }>(
    '/stores/:storeId/products/:productId',
    {
      onRequest: [server.authenticate, authorize(['owner', 'manager']), requireStore()],
    },
    async (request: FastifyRequest, reply: FastifyReply) => {
      const params = request.params as { storeId: string; productId: string };

      // Body validation
      const parseResult = updateProductSchema.safeParse(request.body);
      if (!parseResult.success) {
        return reply.status(400).send({
          statusCode: 400,
          error: 'Bad Request',
          message: parseResult.error.errors[0].message,
        });
      }

      // Бараа шинэчлэх
      const result = await updateProduct(params.productId, params.storeId, parseResult.data);

      if (!result.success) {
        return reply.status(400).send({
          statusCode: 400,
          error: 'Bad Request',
          message: result.error,
        });
      }

      return reply.status(200).send({
        success: true,
        product: result.product,
      });
    }
  );

  /**
   * DELETE /stores/:storeId/products/:productId
   * Бараа устгах - soft delete (owner, manager)
   */
  server.delete<{
    Params: { storeId: string; productId: string };
    Reply: { success: true } | { statusCode: number; error: string; message: string };
  }>(
    '/stores/:storeId/products/:productId',
    {
      onRequest: [server.authenticate, authorize(['owner', 'manager']), requireStore()],
    },
    async (request: FastifyRequest, reply: FastifyReply) => {
      const params = request.params as { storeId: string; productId: string };

      // Бараа устгах (soft delete)
      const result = await deleteProduct(params.productId, params.storeId);

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

  /**
   * POST /stores/:storeId/products/bulk
   * Олон бараа нэгэн зэрэг нэмэх (owner, manager)
   */
  server.post<{
    Params: { storeId: string };
    Body: BulkCreateProductsBody;
    Reply: BulkCreateResponse | { statusCode: number; error: string; message: string };
  }>(
    '/stores/:storeId/products/bulk',
    {
      onRequest: [server.authenticate, authorize(['owner', 'manager']), requireStore()],
    },
    async (request: FastifyRequest, reply: FastifyReply) => {
      const params = request.params as { storeId: string };

      // Body validation
      const parseResult = bulkCreateProductsSchema.safeParse(request.body);
      if (!parseResult.success) {
        return reply.status(400).send({
          statusCode: 400,
          error: 'Bad Request',
          message: parseResult.error.errors[0].message,
        });
      }

      // Олон бараа үүсгэх
      const result = await bulkCreateProducts(params.storeId, parseResult.data.products);

      if (!result.success) {
        return reply.status(400).send({
          statusCode: 400,
          error: 'Bad Request',
          message: result.error,
        });
      }

      return reply.status(201).send({
        success: true,
        created: result.created,
        products: result.products,
      });
    }
  );

  server.log.info('✓ Product routes registered');
}
