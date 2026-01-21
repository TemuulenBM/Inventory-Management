/**
 * Rate Limiting Plugin
 *
 * API rate limiting - DDoS халдлага, abuse-аас хамгаална.
 */

import fp from 'fastify-plugin';
import rateLimit from '@fastify/rate-limit';
import type { FastifyInstance } from 'fastify';
import { env } from '../config/env.js';

async function rateLimitPluginFn(server: FastifyInstance) {
  await server.register(rateLimit, {
    // Maximum хүсэлтийн тоо
    max: env.RATE_LIMIT_MAX,

    // Хугацаа (milliseconds)
    timeWindow: 60 * 1000, // 1 минут

    // Cache size
    cache: 10000,

    // Error response
    errorResponseBuilder: (_request: any, context: any) => {
      return {
        statusCode: 429,
        error: 'Too Many Requests',
        message: `Rate limit exceeded. Try again in ${Math.ceil(context.ttl / 1000)} seconds.`,
        retryAfter: Math.ceil(context.ttl / 1000),
      };
    },

    // Key generator (IP address-аар)
    keyGenerator: (request: any) => {
      return request.ip || 'unknown';
    },
  });

  // Health check endpoint-д rate limiting хэрэггүй
  server.addHook('onRequest', async (request: any, reply: any) => {
    if (request.url === '/health') {
      reply.hijack();
      return;
    }
  });

  server.log.info(`✓ Rate limit plugin registered (${env.RATE_LIMIT_MAX} req/min)`);
}

export const rateLimitPlugin = fp(rateLimitPluginFn, {
  name: 'rate-limit-plugin',
});
