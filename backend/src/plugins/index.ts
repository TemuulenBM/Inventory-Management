/**
 * Fastify Plugins Index
 *
 * Бүх plugins-ийг энд import хийж, export хийнэ.
 */

import type { FastifyInstance } from 'fastify';
import { corsPlugin } from './cors.js';
import { helmetPlugin } from './helmet.js';
import { rateLimitPlugin } from './rate-limit.js';
import { jwtPlugin } from './jwt.js';
import { errorHandlerPlugin } from './error-handler.js';
import { registerSwagger } from './swagger.js';

/**
 * Register бүх core plugins
 */
export async function registerPlugins(server: FastifyInstance) {
  // 1. Security plugins
  await server.register(corsPlugin);
  await server.register(helmetPlugin);

  // 2. Rate limiting
  await server.register(rateLimitPlugin);

  // 3. JWT authentication
  await server.register(jwtPlugin);

  // 4. Swagger documentation (routes-аас өмнө)
  await registerSwagger(server);

  // 5. Error handler (сүүлд register хийх)
  await server.register(errorHandlerPlugin);

  server.log.info('✅ All plugins registered');
}
