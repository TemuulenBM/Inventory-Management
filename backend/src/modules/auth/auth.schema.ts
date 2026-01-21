/**
 * Auth Module - Zod Validation Schemas
 *
 * Request/Response validation-д ашиглах Zod schemas.
 */

import { z } from 'zod';

/**
 * OTP Request Schema
 * POST /auth/otp/request body validation
 */
export const otpRequestSchema = z.object({
  phone: z.string().min(8).max(20).describe('Утасны дугаар (+976XXXXXXXX)'),
});

export type OTPRequestBody = z.infer<typeof otpRequestSchema>;

/**
 * OTP Verify Schema
 * POST /auth/otp/verify body validation
 */
export const otpVerifySchema = z.object({
  phone: z.string().min(8).max(20).describe('Утасны дугаар'),
  otp: z.string().length(6).regex(/^\d{6}$/).describe('6 оронтой OTP код'),
});

export type OTPVerifyBody = z.infer<typeof otpVerifySchema>;

/**
 * Refresh Token Schema
 * POST /auth/refresh body validation
 */
export const refreshTokenSchema = z.object({
  refreshToken: z.string().min(1).describe('Refresh token'),
});

export type RefreshTokenBody = z.infer<typeof refreshTokenSchema>;

/**
 * Auth Response Types
 */

// OTP Request успех response
export interface OTPRequestResponse {
  success: true;
  message: string;
  expiresIn: number; // Секундээр
}

// OTP Verify успех response
export interface OTPVerifyResponse {
  success: true;
  user: {
    id: string;
    phone: string;
    name: string | null;
    role: 'owner' | 'manager' | 'seller';
    storeId: string;
  };
  tokens: {
    accessToken: string;
    refreshToken: string;
    expiresIn: number; // Секундээр
  };
}

// Token refresh успех response
export interface RefreshTokenResponse {
  success: true;
  tokens: {
    accessToken: string;
    refreshToken: string;
    expiresIn: number;
  };
}

// User info response (GET /auth/me)
export interface UserInfoResponse {
  success: true;
  user: {
    id: string;
    phone: string;
    name: string | null;
    role: 'owner' | 'manager' | 'seller';
    storeId: string;
    createdAt: string;
  };
}
