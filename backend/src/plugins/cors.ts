/**
 * CORS Plugin
 *
 * Cross-Origin Resource Sharing тохируулга.
 * Flutter app болон бусад client-үүдээс API-руу хандах боломжтой болгоно.
 */

import fp from 'fastify-plugin';
import cors from '@fastify/cors';
import type { FastifyInstance } from 'fastify';
import { env } from '../config/env.js';

async function corsPluginFn(server: FastifyInstance) {
  await server.register(cors, {
    // Allowed origins
    origin:
      env.NODE_ENV === 'production'
        ? ['https://yourapp.com'] // Production domain
        : true, // Development - allow all origins

    // Allowed HTTP methods
    methods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH', 'OPTIONS'],

    // Allowed headers
    allowedHeaders: [
      'Content-Type',
      'Authorization',
      'X-Request-ID',
      'X-Device-ID',
    ],

    // Exposed headers
    exposedHeaders: ['X-Request-ID'],

    // Allow credentials (cookies, auth headers)
    credentials: true,

    // Preflight cache time (seconds)
    maxAge: 86400, // 24 цаг
  });

  server.log.info('✓ CORS plugin registered');
}

export const corsPlugin = fp(corsPluginFn, {
  name: 'cors-plugin',
});
