/**
 * Swagger Plugin
 *
 * OpenAPI documentation with Swagger UI.
 * API documentation-г автоматаар үүсгэж, /docs endpoint дээр UI-тай харуулна.
 */

import type { FastifyInstance } from 'fastify';
import fastifySwagger from '@fastify/swagger';
import fastifySwaggerUI from '@fastify/swagger-ui';
import { env } from '../config/env.js';

export async function registerSwagger(server: FastifyInstance) {
  // Register @fastify/swagger
  await server.register(fastifySwagger, {
    openapi: {
      openapi: '3.0.0',
      info: {
        title: 'Local Retail Control Platform API',
        description: 'Offline-first retail inventory and sales management system API',
        version: '1.0.0',
        contact: {
          name: 'API Support',
          email: 'support@retailcontrol.mn',
        },
        license: {
          name: 'MIT',
        },
      },
      servers: [
        {
          url: `http://localhost:${env.PORT}`,
          description: 'Development server',
        },
        {
          url: 'https://api.retailcontrol.mn',
          description: 'Production server',
        },
      ],
      tags: [
        { name: 'health', description: 'Health check endpoints' },
        { name: 'auth', description: 'Authentication endpoints' },
        { name: 'stores', description: 'Store management' },
        { name: 'users', description: 'User management' },
        { name: 'products', description: 'Product management' },
        { name: 'inventory', description: 'Inventory events (event sourcing)' },
        { name: 'sales', description: 'Sales management' },
        { name: 'shifts', description: 'Shift management' },
        { name: 'reports', description: 'Reports and analytics' },
        { name: 'alerts', description: 'Alerts and notifications' },
        { name: 'sync', description: 'Offline-first synchronization' },
      ],
      components: {
        securitySchemes: {
          bearerAuth: {
            type: 'http',
            scheme: 'bearer',
            bearerFormat: 'JWT',
            description: 'JWT access token (expires in 1 hour)',
          },
        },
      },
      security: [
        {
          bearerAuth: [],
        },
      ],
    },
  });

  // Register @fastify/swagger-ui
  await server.register(fastifySwaggerUI, {
    routePrefix: '/docs',
    uiConfig: {
      docExpansion: 'list',
      deepLinking: true,
      displayRequestDuration: true,
      filter: true,
      tryItOutEnabled: true,
    },
    staticCSP: true,
    transformStaticCSP: (header) => header,
  });

  server.log.info('✓ Swagger documentation registered at /docs');
}
