/**
 * JWT Plugin
 *
 * JSON Web Token authentication setup.
 * Access token болон refresh token-ийг verify хийх чадвартай.
 */

import fp from 'fastify-plugin';
import jwt from '@fastify/jwt';
import type { FastifyInstance } from 'fastify';
import { env } from '../config/env.js';

/**
 * JWT Payload interface
 */
export interface JWTPayload {
  userId: string;
  storeId: string;
  role: 'owner' | 'manager' | 'seller';
  iat?: number;
  exp?: number;
}

async function jwtPluginFn(server: FastifyInstance) {
  await server.register(jwt, {
    secret: env.JWT_SECRET,
    sign: {
      expiresIn: env.JWT_ACCESS_EXPIRY, // Default: 1h
    },
    verify: {
      maxAge: env.JWT_ACCESS_EXPIRY,
    },
    messages: {
      badRequestErrorMessage: 'Authorization header is malformed',
      noAuthorizationInHeaderMessage: 'Authorization header is missing',
      authorizationTokenExpiredMessage: 'Token expired',
      authorizationTokenInvalid: (err) => {
        return `Authorization token is invalid: ${err.message}`;
      },
    },
  });

  // Декоратор нэмэх - request.user = JWTPayload
  server.decorate(
    'authenticate',
    async function (request: any, reply: any) {
      try {
        await request.jwtVerify();
      } catch (error) {
        return reply.status(401).send({
          statusCode: 401,
          error: 'Unauthorized',
          message: 'Invalid or expired token',
        });
      }
    }
  );

  server.log.info('✓ JWT plugin registered');
}

export const jwtPlugin = fp(jwtPluginFn, {
  name: 'jwt-plugin',
});
