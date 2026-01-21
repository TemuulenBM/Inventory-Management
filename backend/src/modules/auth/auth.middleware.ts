/**
 * Auth Middleware
 *
 * Request validation middleware-үүд:
 * - authenticate: JWT token verify (jwt.ts plugin-д байна)
 * - authorize: Role-based access control
 * - requireStore: Store ownership validation
 */

import type { FastifyRequest, FastifyReply } from 'fastify';
import type { JWTPayload } from '../../plugins/jwt.js';

/**
 * Extended FastifyRequest with user info
 */
export interface AuthRequest extends FastifyRequest {
  user: JWTPayload;
}

/**
 * Role-based access control middleware
 *
 * Зөвхөн зөвшөөрөгдсөн role-тэй хэрэглэгчдэд хандалт олгоно.
 *
 * @param allowedRoles - Зөвшөөрөгдсөн role-ууд
 * @returns Middleware function
 *
 * @example
 * // Зөвхөн owner болон manager
 * server.get('/admin/stats', {
 *   onRequest: [
 *     (server as any).authenticate,
 *     authorize(['owner', 'manager'])
 *   ]
 * }, handler)
 *
 * // Зөвхөн owner
 * server.delete('/stores/:id', {
 *   onRequest: [
 *     (server as any).authenticate,
 *     authorize(['owner'])
 *   ]
 * }, handler)
 */
export function authorize(allowedRoles: Array<'owner' | 'manager' | 'seller'>) {
  return async (request: FastifyRequest, reply: FastifyReply) => {
    const authRequest = request as AuthRequest;

    // User JWT-аас ирсэн эсэхийг шалгах
    if (!authRequest.user) {
      return reply.status(401).send({
        statusCode: 401,
        error: 'Unauthorized',
        message: 'Нэвтрэх шаардлагатай',
      });
    }

    // Role шалгах
    const userRole = authRequest.user.role;
    if (!allowedRoles.includes(userRole)) {
      return reply.status(403).send({
        statusCode: 403,
        error: 'Forbidden',
        message: `Энэ үйлдлийг зөвхөн ${allowedRoles.join(', ')} хийх эрхтэй`,
      });
    }

    // Зөвшөөрөгдсөн - дараагийн handler руу шилжих
  };
}

/**
 * Store ownership validation middleware
 *
 * Request-ийн :storeId parameter хэрэглэгчийн store-тэй таарч байгаа эсэхийг шалгана.
 * Хэрэглэгч зөвхөн өөрийн store-ийн өгөгдөлд хандах эрхтэй.
 *
 * @returns Middleware function
 *
 * @example
 * // Store-specific endpoint
 * server.get('/stores/:storeId/products', {
 *   onRequest: [
 *     (server as any).authenticate,
 *     requireStore()
 *   ]
 * }, handler)
 */
export function requireStore() {
  return async (request: FastifyRequest, reply: FastifyReply) => {
    const authRequest = request as AuthRequest;
    const params = request.params as { storeId?: string; id?: string };

    // User JWT-аас ирсэн эсэхийг шалгах
    if (!authRequest.user) {
      return reply.status(401).send({
        statusCode: 401,
        error: 'Unauthorized',
        message: 'Нэвтрэх шаардлагатай',
      });
    }

    // storeId эсвэл id parameter-ийг авах (routes-үүд :storeId эсвэл :id ашигладаг)
    const storeIdFromParams = params.storeId || params.id;

    // storeId parameter байгаа эсэхийг шалгах
    if (!storeIdFromParams) {
      return reply.status(400).send({
        statusCode: 400,
        error: 'Bad Request',
        message: 'storeId parameter шаардлагатай',
      });
    }

    // User-ийн store ID-тэй таарч байгаа эсэхийг шалгах
    if (authRequest.user.storeId !== storeIdFromParams) {
      return reply.status(403).send({
        statusCode: 403,
        error: 'Forbidden',
        message: 'Та зөвхөн өөрийн дэлгүүрийн өгөгдөлд хандах эрхтэй',
      });
    }

    // Зөвшөөрөгдсөн - дараагийн handler руу шилжих
  };
}

/**
 * Combined middleware helper
 *
 * authenticate + authorize + requireStore-г нэгтгэсэн helper function.
 *
 * @param allowedRoles - Зөвшөөрөгдсөн role-ууд
 * @param checkStore - Store validation хийх эсэх (default: true)
 * @returns Array of middleware functions
 *
 * @example
 * // Owner болон manager, store validation хийнэ
 * server.get('/stores/:storeId/users', {
 *   onRequest: requireAuth(['owner', 'manager'])
 * }, handler)
 *
 * // Бүх role, store validation үгүй
 * server.get('/auth/me', {
 *   onRequest: requireAuth(['owner', 'manager', 'seller'], false)
 * }, handler)
 */
export function requireAuth(
  allowedRoles: Array<'owner' | 'manager' | 'seller'>,
  checkStore: boolean = true
) {
  const middlewares: any[] = [authorize(allowedRoles)];

  if (checkStore) {
    middlewares.push(requireStore());
  }

  return middlewares;
}

/**
 * Optional authentication middleware
 *
 * JWT байвал verify хийж user мэдээлэл нэмнэ, байхгүй бол үргэлжлүүлнэ.
 * Public endpoints-д хэрэглэгч нэвтэрсэн эсэхээс хамааран өөр өөр мэдээлэл харуулахад ашиглана.
 *
 * @param server - Fastify instance
 * @returns Middleware function
 *
 * @example
 * // Public endpoint, optional auth
 * server.get('/products', {
 *   onRequest: [optionalAuth(server)]
 * }, async (request: any) => {
 *   if (request.user) {
 *     // Нэвтэрсэн хэрэглэгч - бүх мэдээлэл
 *     return { products: [...], user: request.user }
 *   } else {
 *     // Нэвтрээгүй - зөвхөн нийтийн мэдээлэл
 *     return { products: [...] }
 *   }
 * })
 */
export function optionalAuth(_server: any) {
  return async (request: any, _reply: FastifyReply) => {
    try {
      // Authorization header байгаа бол verify хийх
      const authHeader = request.headers.authorization;
      if (authHeader && authHeader.startsWith('Bearer ')) {
        await request.jwtVerify();
      }
      // Header байхгүй бол алгасах - user undefined байна
    } catch (error) {
      // Token буруу эсвэл хугацаа дууссан - алгасах
      request.log.debug('Optional auth failed, continuing without user');
    }

    // Дараагийн handler руу шилжих (user байж болно, байхгүй ч болно)
  };
}
