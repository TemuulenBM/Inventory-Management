/**
 * Fastify Type Extensions
 *
 * Custom декораторууд болон plugins-ийн type definitions.
 */

import 'fastify';
import type { JWTPayload } from '../plugins/jwt.js';

declare module 'fastify' {
  interface FastifyInstance {
    /**
     * JWT authentication decorator
     *
     * Request-ийн Authorization header-аас JWT token verify хийнэ.
     * Token зөв бол request.user-д payload хадгална.
     *
     * @example
     * server.get('/protected', {
     *   onRequest: [server.authenticate]
     * }, async (request) => {
     *   const user = request.user // JWTPayload type
     *   return { user }
     * })
     */
    authenticate(request: FastifyRequest, reply: FastifyReply): Promise<void>;
  }

  interface FastifyRequest {
    /**
     * JWT payload - authenticate middleware-ээр нэмэгдэнэ
     */
    user?: JWTPayload;
  }
}
