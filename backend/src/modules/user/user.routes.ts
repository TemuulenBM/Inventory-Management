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
import { authorize, requireStore, type AuthRequest } from '../auth/auth.middleware.js';
import { supabase } from '../../config/supabase.js';

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

  // ============================================================================
  // MULTI-STORE ENDPOINTS
  // ============================================================================

  /**
   * GET /users/:userId/stores
   * Хэрэглэгчийн дэлгүүрүүдийн жагсаалт авах (multi-store support)
   *
   * Owner олон дэлгүүртэй байж болох тул энэ endpoint-р
   * хэрэглэгчийн бүх дэлгүүрүүдийг store_members-аар авна.
   */
  server.get<{
    Params: { userId: string };
    Reply: {
      success: boolean;
      stores: Array<{
        id: string;
        name: string;
        location: string | null;
        role: string;
      }>;
    };
  }>(
    '/users/:userId/stores',
    {
      onRequest: [server.authenticate],
    },
    async (request: FastifyRequest, reply: FastifyReply) => {
      const authRequest = request as AuthRequest;
      const params = request.params as { userId: string };

      // Зөвхөн өөрийн дэлгүүрүүдийг харах эсвэл super-admin
      if (
        authRequest.user.userId !== params.userId &&
        authRequest.user.role !== 'super_admin'
      ) {
        return reply.status(403).send({
          statusCode: 403,
          error: 'Forbidden',
          message: 'Та зөвхөн өөрийн дэлгүүрүүдийг харах эрхтэй',
        });
      }

      // store_members-аас хэрэглэгчийн дэлгүүрүүдийг авах
      const { data: memberships, error } = await supabase
        .from('store_members')
        .select('store_id, role, stores(id, name, location)')
        .eq('user_id', params.userId);

      if (error) {
        console.error('Get user stores error:', error);
        return reply.status(500).send({
          statusCode: 500,
          error: 'Internal Server Error',
          message: 'Дэлгүүрүүд авахад алдаа гарлаа',
        });
      }

      // Response format
      const stores = (memberships || []).map((m: any) => ({
        id: m.stores.id,
        name: m.stores.name,
        location: m.stores.location,
        role: m.role,
      }));

      return reply.status(200).send({
        success: true,
        stores,
      });
    }
  );

  /**
   * POST /users/:userId/stores/:storeId/select
   * Дэлгүүр сонгох (primary store шинэчлэх)
   *
   * Owner олон дэлгүүртэй үед одоо ажиллаж байгаа дэлгүүрийг
   * солих endpoint. users.store_id шинэчилнэ.
   */
  server.post<{
    Params: { userId: string; storeId: string };
    Reply: { success: boolean; message?: string };
  }>(
    '/users/:userId/stores/:storeId/select',
    {
      onRequest: [server.authenticate],
    },
    async (request: FastifyRequest, reply: FastifyReply) => {
      const authRequest = request as AuthRequest;
      const params = request.params as { userId: string; storeId: string };

      // Зөвхөн өөрөө store солих боломжтой
      if (authRequest.user.userId !== params.userId) {
        return reply.status(403).send({
          statusCode: 403,
          error: 'Forbidden',
          message: 'Та зөвхөн өөрийн дэлгүүрийг солих эрхтэй',
        });
      }

      // store_members дээр хэрэглэгч энэ дэлгүүрт хандах эрхтэй эсэхийг шалгах
      const { data: membership, error: checkError } = await supabase
        .from('store_members')
        .select('id, role')
        .eq('user_id', params.userId)
        .eq('store_id', params.storeId)
        .single();

      if (checkError || !membership) {
        return reply.status(403).send({
          statusCode: 403,
          error: 'Forbidden',
          message: 'Та энэ дэлгүүрт хандах эрхгүй байна',
        });
      }

      // users.store_id шинэчлэх (primary/selected store)
      const { error: updateError } = await supabase
        .from('users')
        .update({ store_id: params.storeId })
        .eq('id', params.userId);

      if (updateError) {
        console.error('Update user store_id error:', updateError);
        return reply.status(500).send({
          statusCode: 500,
          error: 'Internal Server Error',
          message: 'Дэлгүүр сонгоход алдаа гарлаа',
        });
      }

      console.log(`✅ User ${params.userId} selected store ${params.storeId}`);

      return reply.status(200).send({
        success: true,
        message: 'Дэлгүүр амжилттай сонгогдлоо',
      });
    }
  );

  server.log.info('✓ User routes registered (including multi-store endpoints)');
}
