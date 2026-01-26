/**
 * Invitation Routes
 *
 * Admin/Owner урилга илгээх, жагсаалт авах endpoints
 */

import type { FastifyInstance, FastifyRequest, FastifyReply } from 'fastify';
import {
  createInvitationSchema,
  listInvitationsQuerySchema,
  type InvitationResponse,
  type InvitationsListResponse,
} from './invitation.schema.js';
import {
  createInvitation,
  listInvitations,
  revokeInvitation,
} from './invitation.service.js';
import type { AuthRequest } from '../auth/auth.middleware.js';
import { authorize } from '../auth/auth.middleware.js';

/**
 * Invitation routes register
 */
export async function invitationRoutes(server: FastifyInstance) {
  /**
   * POST /invitations
   * Урилга үүсгэх (Admin/Super-admin only)
   *
   * АНХААРАХ: Одоогоор аливаа owner урилга илгээх боломжтой.
   * Production дээр super-admin role нэмэх хэрэгтэй (зөвхөл тэд owner урилга илгээх эрхтэй).
   */
  server.post<{
    Body: { phone: string; role?: 'owner' | 'manager' | 'seller'; expiresInDays?: number };
    Reply: InvitationResponse;
  }>(
    '/invitations',
    {
      onRequest: [server.authenticate, authorize(['super_admin', 'owner'])], // Super-admin болон owner урилга илгээнэ
    },
    async (request: FastifyRequest, reply: FastifyReply) => {
      const authRequest = request as AuthRequest;

      // 1. Validation
      const parseResult = createInvitationSchema.safeParse(request.body);
      if (!parseResult.success) {
        return reply.status(400).send({
          success: false,
          error: parseResult.error.errors[0].message,
        });
      }

      const { phone, role, expiresInDays } = parseResult.data;

      // 2. Create invitation
      const result = await createInvitation(
        phone,
        role || 'owner',
        authRequest.user.userId,
        expiresInDays || 7
      );

      if (!result.success) {
        return reply.status(400).send({
          success: false,
          error: result.error,
        });
      }

      return reply.status(201).send({
        success: true,
        invitation: result.invitation,
      });
    }
  );

  /**
   * GET /invitations
   * Урилгын жагсаалт авах (Admin only)
   */
  server.get<{
    Querystring: { status?: string; phone?: string; limit?: number; offset?: number };
    Reply: InvitationsListResponse;
  }>(
    '/invitations',
    {
      onRequest: [server.authenticate, authorize(['super_admin', 'owner'])], // Super-admin болон owner жагсаалт харна
    },
    async (request: FastifyRequest, reply: FastifyReply) => {
      // 1. Validation
      const parseResult = listInvitationsQuerySchema.safeParse(request.query);
      if (!parseResult.success) {
        return reply.status(400).send({
          success: false,
          invitations: [],
          total: 0,
        });
      }

      const filters = parseResult.data;

      // 2. List invitations
      const result = await listInvitations(filters);

      if (!result.success) {
        return reply.status(500).send({
          success: false,
          invitations: [],
          total: 0,
        });
      }

      return reply.status(200).send({
        success: true,
        invitations: result.invitations,
        total: result.total,
      });
    }
  );

  /**
   * DELETE /invitations/:id
   * Урилга цуцлах (Admin only)
   */
  server.delete<{
    Params: { id: string };
    Reply: { success: boolean; error?: string };
  }>(
    '/invitations/:id',
    {
      onRequest: [server.authenticate, authorize(['super_admin', 'owner'])], // Super-admin болон owner урилга цуцлана
    },
    async (request: FastifyRequest, reply: FastifyReply) => {
      const authRequest = request as AuthRequest;
      const params = request.params as { id: string };

      const result = await revokeInvitation(params.id, authRequest.user.userId);

      if (!result.success) {
        return reply.status(400).send({
          success: false,
          error: result.error,
        });
      }

      return reply.status(200).send({
        success: true,
      });
    }
  );

  server.log.info('✓ Invitation routes registered');
}
