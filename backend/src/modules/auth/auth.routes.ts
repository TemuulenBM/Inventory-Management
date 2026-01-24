/**
 * Auth Routes
 *
 * Authentication endpoints:
 * - POST /auth/otp/request - OTP хүсэх
 * - POST /auth/otp/verify - OTP баталгаажуулж login хийх
 * - POST /auth/refresh - Access token шинэчлэх
 * - POST /auth/logout - Logout хийх
 * - GET /auth/me - Одоогийн хэрэглэгчийн мэдээлэл
 */

import type { FastifyInstance, FastifyRequest, FastifyReply } from 'fastify';
import {
  otpRequestSchema,
  otpVerifySchema,
  refreshTokenSchema,
  deviceLoginSchema,
  type OTPRequestResponse,
  type OTPVerifyResponse,
  type RefreshTokenResponse,
  type UserInfoResponse,
} from './auth.schema.js';
import { requestOTP, verifyOTP, refreshAccessToken, logout, deviceLogin, getTrustedDevices, removeTrustedDevice } from './auth.service.js';
import type { JWTPayload } from '../../plugins/jwt.js';

/**
 * Auth routes register
 */
export async function authRoutes(server: FastifyInstance) {
  /**
   * POST /auth/otp/request
   * OTP хүсэх endpoint
   */
  server.post<{
    Body: { phone: string };
    Reply: OTPRequestResponse | { statusCode: number; error: string; message: string };
  }>('/auth/otp/request', async (request: FastifyRequest, reply: FastifyReply) => {
    // 1. Request validation
    const parseResult = otpRequestSchema.safeParse(request.body);
    if (!parseResult.success) {
      return reply.status(400).send({
        statusCode: 400,
        error: 'Bad Request',
        message: parseResult.error.errors[0].message,
      });
    }

    const { phone } = parseResult.data;

    // 2. OTP үүсгэж илгээх
    const result = await requestOTP(phone);

    if (!result.success) {
      return reply.status(400).send({
        statusCode: 400,
        error: 'Bad Request',
        message: result.error || 'OTP хүсэлт амжилтгүй боллоо',
      });
    }

    // 3. Амжилттай
    return reply.status(200).send({
      success: true,
      message: 'OTP амжилттай илгээгдлээ',
      expiresIn: result.expiresIn!,
    });
  });

  /**
   * POST /auth/otp/verify
   * OTP баталгаажуулах endpoint
   */
  server.post<{
    Body: { phone: string; otp: string; deviceId?: string; trustDevice?: boolean };
    Reply: OTPVerifyResponse | { statusCode: number; error: string; message: string };
  }>('/auth/otp/verify', async (request: FastifyRequest, reply: FastifyReply) => {
    // 1. Request validation
    const parseResult = otpVerifySchema.safeParse(request.body);
    if (!parseResult.success) {
      return reply.status(400).send({
        statusCode: 400,
        error: 'Bad Request',
        message: parseResult.error.errors[0].message,
      });
    }

    const { phone, otp, deviceId, trustDevice } = parseResult.data;

    // 2. OTP verify болон login (device trust дэмжсэн)
    const result = await verifyOTP(phone, otp, server, deviceId, trustDevice);

    if (!result.success) {
      return reply.status(401).send({
        statusCode: 401,
        error: 'Unauthorized',
        message: result.error || 'OTP баталгаажуулалт амжилтгүй боллоо',
      });
    }

    // 3. Амжилттай - user болон tokens буцаах
    return reply.status(200).send({
      success: true,
      user: result.user!,
      tokens: result.tokens!,
    });
  });

  /**
   * POST /auth/refresh
   * Access token шинэчлэх endpoint
   */
  server.post<{
    Body: { refreshToken: string };
    Reply: RefreshTokenResponse | { statusCode: number; error: string; message: string };
  }>('/auth/refresh', async (request: FastifyRequest, reply: FastifyReply) => {
    // 1. Request validation
    const parseResult = refreshTokenSchema.safeParse(request.body);
    if (!parseResult.success) {
      return reply.status(400).send({
        statusCode: 400,
        error: 'Bad Request',
        message: parseResult.error.errors[0].message,
      });
    }

    const { refreshToken } = parseResult.data;

    // 2. Token refresh
    const result = await refreshAccessToken(refreshToken, server);

    if (!result.success) {
      return reply.status(401).send({
        statusCode: 401,
        error: 'Unauthorized',
        message: result.error || 'Token шинэчлэх амжилтгүй боллоо',
      });
    }

    // 3. Амжилттай - шинэ tokens буцаах
    return reply.status(200).send({
      success: true,
      tokens: result.tokens!,
    });
  });

  /**
   * POST /auth/logout
   * Logout хийх endpoint
   */
  server.post<{
    Body: { refreshToken: string };
    Reply: { success: boolean; message: string } | { statusCode: number; error: string; message: string };
  }>(
    '/auth/logout',
    {
      onRequest: [server.authenticate], // JWT required
    },
    async (request: any, reply: FastifyReply) => {
      // 1. Request validation
      const parseResult = refreshTokenSchema.safeParse(request.body);
      if (!parseResult.success) {
        return reply.status(400).send({
          statusCode: 400,
          error: 'Bad Request',
          message: parseResult.error.errors[0].message,
        });
      }

      const { refreshToken } = parseResult.data;
      const user = request.user as JWTPayload;

      // 2. Logout
      const result = await logout(user.userId, refreshToken);

      if (!result.success) {
        return reply.status(500).send({
          statusCode: 500,
          error: 'Internal Server Error',
          message: result.error || 'Logout хийхэд алдаа гарлаа',
        });
      }

      // 3. Амжилттай
      return reply.status(200).send({
        success: true,
        message: 'Амжилттай гарлаа',
      });
    }
  );

  /**
   * GET /auth/me
   * Одоогийн хэрэглэгчийн мэдээлэл авах endpoint
   */
  server.get<{
    Reply: UserInfoResponse | { statusCode: number; error: string; message: string };
  }>(
    '/auth/me',
    {
      onRequest: [server.authenticate], // JWT required
    },
    async (request: any, reply: FastifyReply) => {
      const user = request.user as JWTPayload;

      // User мэдээлэл database-аас авах
      const { data: userData, error } = await (await import('../../config/supabase.js')).supabase
        .from('users')
        .select('*')
        .eq('id', user.userId)
        .single();

      if (error || !userData) {
        return reply.status(404).send({
          statusCode: 404,
          error: 'Not Found',
          message: 'Хэрэглэгч олдсонгүй',
        });
      }

      return reply.status(200).send({
        success: true,
        user: {
          id: userData.id,
          phone: userData.phone,
          name: userData.name,
          role: userData.role,
          storeId: userData.store_id,
          createdAt: userData.created_at,
        },
      });
    }
  );

  // ============================================================================
  // DEVICE TRUST ENDPOINTS
  // ============================================================================

  /**
   * POST /auth/device-login
   * Итгэмжлэгдсэн төхөөрөмжөөр OTP-гүй нэвтрэх
   */
  server.post<{
    Body: { phone: string; deviceId: string };
    Reply: OTPVerifyResponse | { statusCode: number; error: string; message: string };
  }>('/auth/device-login', async (request: FastifyRequest, reply: FastifyReply) => {
    // 1. Request validation
    const parseResult = deviceLoginSchema.safeParse(request.body);
    if (!parseResult.success) {
      return reply.status(400).send({
        statusCode: 400,
        error: 'Bad Request',
        message: parseResult.error.errors[0].message,
      });
    }

    const { phone, deviceId } = parseResult.data;

    // 2. Device login
    const result = await deviceLogin(phone, deviceId, server);

    if (!result.success) {
      // 403 = device not trusted, client should fall back to OTP
      return reply.status(403).send({
        statusCode: 403,
        error: 'Forbidden',
        message: result.error || 'Төхөөрөмж итгэмжлэгдээгүй байна',
      });
    }

    // 3. Амжилттай
    return reply.status(200).send({
      success: true,
      user: result.user!,
      tokens: result.tokens!,
    });
  });

  /**
   * GET /auth/trusted-devices
   * Одоогийн хэрэглэгчийн итгэмжлэгдсэн төхөөрөмжүүдийг авах
   */
  server.get<{
    Reply:
      | { success: boolean; devices: any[] }
      | { statusCode: number; error: string; message: string };
  }>(
    '/auth/trusted-devices',
    {
      onRequest: [server.authenticate],
    },
    async (request: any, reply: FastifyReply) => {
      const user = request.user as JWTPayload;
      const devices = await getTrustedDevices(user.userId);

      return reply.status(200).send({
        success: true,
        devices,
      });
    }
  );

  /**
   * DELETE /auth/trusted-devices/:deviceId
   * Итгэмжлэгдсэн төхөөрөмжийг устгах
   */
  server.delete<{
    Params: { deviceId: string };
    Reply: { success: boolean; message: string } | { statusCode: number; error: string; message: string };
  }>(
    '/auth/trusted-devices/:deviceId',
    {
      onRequest: [server.authenticate],
    },
    async (request: any, reply: FastifyReply) => {
      const user = request.user as JWTPayload;
      const { deviceId } = request.params;

      const result = await removeTrustedDevice(user.userId, deviceId);

      if (!result.success) {
        return reply.status(500).send({
          statusCode: 500,
          error: 'Internal Server Error',
          message: result.error || 'Төхөөрөмж устгахад алдаа гарлаа',
        });
      }

      return reply.status(200).send({
        success: true,
        message: 'Төхөөрөмж амжилттай устгагдлаа',
      });
    }
  );

  server.log.info('✓ Auth routes registered');
}
