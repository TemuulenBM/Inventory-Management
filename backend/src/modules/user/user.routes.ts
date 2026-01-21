/**
 * User Routes
 *
 * User management endpoints:
 * - GET /stores/:storeId/users - Хэрэглэгчдийн жагсаалт
 * - POST /stores/:storeId/users - Хэрэглэгч нэмэх
 * - PUT /stores/:storeId/users/:userId - Хэрэглэгч засах
 * - DELETE /stores/:storeId/users/:userId - Хэрэглэгч устгах
 * - PUT /stores/:storeId/users/:userId/role - Role солих
 */

import type { FastifyInstance, FastifyRequest, FastifyReply } from 'fastify';
import {
  createUserSchema,
  updateUserSchema,
  updateUserRoleSchema,
  type UsersListResponse,
  type UserResponse,
} from './user.schema.js';
import { getUsers, createUser, updateUser, deleteUser, updateUserRole } from './user.service.js';
import { authorize, requireStore } from '../auth/auth.middleware.js';

/**
 * User routes register
 */
export async function userRoutes(server: FastifyInstance) {
  /**
   * GET /stores/:storeId/users
   * Хэрэглэгчдийн жагсаалт (owner, manager)
   */
  server.get<{
    Params: { storeId: string };
    Reply: UsersListResponse | { statusCode: number; error: string; message: string };
  }>(
    '/stores/:storeId/users',
    {
      onRequest: [server.authenticate, authorize(['owner', 'manager']), requireStore()],
    },
    async (request: FastifyRequest, reply: FastifyReply) => {
      const params = request.params as { storeId: string };

      const result = await getUsers(params.storeId);

      if (!result.success) {
        return reply.status(500).send({
          statusCode: 500,
          error: 'Internal Server Error',
          message: result.error,
        });
      }

      return reply.status(200).send({
        success: true,
        users: result.users,
        total: result.total,
      });
    }
  );

  /**
   * POST /stores/:storeId/users
   * Шинэ хэрэглэгч нэмэх (owner only)
   */
  server.post<{
    Params: { storeId: string };
    Body: { phone: string; name: string; role: 'manager' | 'seller' };
    Reply: UserResponse | { statusCode: number; error: string; message: string };
  }>(
    '/stores/:storeId/users',
    {
      onRequest: [server.authenticate, authorize(['owner']), requireStore()],
    },
    async (request: FastifyRequest, reply: FastifyReply) => {
      const params = request.params as { storeId: string };

      // 1. Request validation
      const parseResult = createUserSchema.safeParse(request.body);
      if (!parseResult.success) {
        return reply.status(400).send({
          statusCode: 400,
          error: 'Bad Request',
          message: parseResult.error.errors[0].message,
        });
      }

      const data = parseResult.data;

      // 2. User үүсгэх
      const result = await createUser(params.storeId, data);

      if (!result.success) {
        return reply.status(400).send({
          statusCode: 400,
          error: 'Bad Request',
          message: result.error,
        });
      }

      return reply.status(201).send({
        success: true,
        user: result.user,
      });
    }
  );

  /**
   * PUT /stores/:storeId/users/:userId
   * Хэрэглэгч засах (owner, manager)
   */
  server.put<{
    Params: { storeId: string; userId: string };
    Body: { name?: string; phone?: string };
    Reply: UserResponse | { statusCode: number; error: string; message: string };
  }>(
    '/stores/:storeId/users/:userId',
    {
      onRequest: [server.authenticate, authorize(['owner', 'manager']), requireStore()],
    },
    async (request: FastifyRequest, reply: FastifyReply) => {
      const params = request.params as { storeId: string; userId: string };

      // 1. Request validation
      const parseResult = updateUserSchema.safeParse(request.body);
      if (!parseResult.success) {
        return reply.status(400).send({
          statusCode: 400,
          error: 'Bad Request',
          message: parseResult.error.errors[0].message,
        });
      }

      const data = parseResult.data;

      // 2. User шинэчлэх
      const result = await updateUser(params.userId, params.storeId, data);

      if (!result.success) {
        return reply.status(400).send({
          statusCode: 400,
          error: 'Bad Request',
          message: result.error,
        });
      }

      return reply.status(200).send({
        success: true,
        user: result.user,
      });
    }
  );

  /**
   * DELETE /stores/:storeId/users/:userId
   * Хэрэглэгч устгах (owner only)
   */
  server.delete<{
    Params: { storeId: string; userId: string };
    Reply: { success: boolean; message: string } | { statusCode: number; error: string; message: string };
  }>(
    '/stores/:storeId/users/:userId',
    {
      onRequest: [server.authenticate, authorize(['owner']), requireStore()],
    },
    async (request: FastifyRequest, reply: FastifyReply) => {
      const params = request.params as { storeId: string; userId: string };

      const result = await deleteUser(params.userId, params.storeId);

      if (!result.success) {
        return reply.status(400).send({
          statusCode: 400,
          error: 'Bad Request',
          message: result.error,
        });
      }

      return reply.status(200).send({
        success: true,
        message: 'Хэрэглэгч амжилттай устгагдлаа',
      });
    }
  );

  /**
   * PUT /stores/:storeId/users/:userId/role
   * Role солих (owner only)
   */
  server.put<{
    Params: { storeId: string; userId: string };
    Body: { role: 'owner' | 'manager' | 'seller' };
    Reply: UserResponse | { statusCode: number; error: string; message: string };
  }>(
    '/stores/:storeId/users/:userId/role',
    {
      onRequest: [server.authenticate, authorize(['owner']), requireStore()],
    },
    async (request: FastifyRequest, reply: FastifyReply) => {
      const params = request.params as { storeId: string; userId: string };

      // 1. Request validation
      const parseResult = updateUserRoleSchema.safeParse(request.body);
      if (!parseResult.success) {
        return reply.status(400).send({
          statusCode: 400,
          error: 'Bad Request',
          message: parseResult.error.errors[0].message,
        });
      }

      const { role } = parseResult.data;

      // 2. Role шинэчлэх
      const result = await updateUserRole(params.userId, params.storeId, role);

      if (!result.success) {
        return reply.status(400).send({
          statusCode: 400,
          error: 'Bad Request',
          message: result.error,
        });
      }

      return reply.status(200).send({
        success: true,
        user: result.user,
      });
    }
  );

  server.log.info('✓ User routes registered');
}
