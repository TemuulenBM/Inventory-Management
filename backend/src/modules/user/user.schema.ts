/**
 * User Module - Zod Validation Schemas
 *
 * User management validation schemas.
 */

import { z } from 'zod';

/**
 * Create User Schema
 * POST /stores/:storeId/users body validation
 */
export const createUserSchema = z.object({
  phone: z.string().min(8).max(20).describe('Утасны дугаар'),
  name: z.string().min(1).max(100).describe('Нэр'),
  role: z.enum(['manager', 'seller']).describe('Role (owner байж болохгүй)'),
});

export type CreateUserBody = z.infer<typeof createUserSchema>;

/**
 * Update User Schema
 * PUT /stores/:storeId/users/:userId body validation
 */
export const updateUserSchema = z.object({
  name: z.string().min(1).max(100).optional().describe('Нэр'),
  phone: z.string().min(8).max(20).optional().describe('Утасны дугаар'),
});

export type UpdateUserBody = z.infer<typeof updateUserSchema>;

/**
 * Update User Role Schema
 * PUT /stores/:storeId/users/:userId/role body validation
 */
export const updateUserRoleSchema = z.object({
  role: z.enum(['owner', 'manager', 'seller']).describe('Шинэ role'),
});

export type UpdateUserRoleBody = z.infer<typeof updateUserRoleSchema>;

/**
 * User Response Types
 */

// User мэдээлэл
export interface UserInfo {
  id: string;
  storeId: string | null; // Super-admin owner үед null байж болно
  phone: string;
  name: string | null;
  role: 'owner' | 'manager' | 'seller';
  createdAt: string;
}

// User list response
export interface UsersListResponse {
  success: true;
  users: UserInfo[];
  total: number;
}

// Single user response
export interface UserResponse {
  success: true;
  user: UserInfo;
}
