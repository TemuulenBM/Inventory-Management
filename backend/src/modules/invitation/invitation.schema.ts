/**
 * Invitation Schemas
 *
 * Урилга үүсгэх, жагсаалт авах, цуцлах validation
 */

import { z } from 'zod';

/**
 * Урилга үүсгэх request schema
 */
export const createInvitationSchema = z.object({
  phone: z.string().regex(/^\+976\d{8}$/, 'Утасны дугаар буруу байна (+976XXXXXXXX)'),
  role: z.enum(['owner', 'manager', 'seller']).default('owner'),
  expiresInDays: z.number().int().min(1).max(30).default(7), // 1-30 хоног
});

export type CreateInvitationBody = z.infer<typeof createInvitationSchema>;

/**
 * Урилгын жагсаалт авах query schema
 */
export const listInvitationsQuerySchema = z.object({
  status: z.enum(['pending', 'used', 'expired', 'revoked']).optional(),
  phone: z.string().optional(),
  limit: z.number().int().min(1).max(100).default(50),
  offset: z.number().int().min(0).default(0),
});

export type ListInvitationsQuery = z.infer<typeof listInvitationsQuerySchema>;

/**
 * Урилга response type
 */
export interface InvitationResponse {
  success: boolean;
  invitation?: {
    id: string;
    phone: string;
    role: string;
    status: string;
    invitedBy: string | null;
    invitedAt: string;
    expiresAt: string;
    usedAt?: string | null;
    usedBy?: string | null;
  };
  error?: string;
}

/**
 * Урилгын жагсаалт response type
 */
export interface InvitationsListResponse {
  success: boolean;
  invitations: Array<{
    id: string;
    phone: string;
    role: string;
    status: string;
    invitedBy: string | null;
    invitedAt: string;
    expiresAt: string;
    usedAt?: string | null;
  }>;
  total: number;
}
