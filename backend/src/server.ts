/**
 * Fastify Server Entry Point
 *
 * Backend API server-ийн гол entry point.
 * Plugins, routes, error handlers бүгдийг энд load хийнэ.
 */

import Fastify from 'fastify';
import { env } from './config/env.js';
import { registerPlugins } from './plugins/index.js';
import { authRoutes } from './modules/auth/auth.routes.js';
import { storeRoutes } from './modules/store/store.routes.js';
import { userRoutes } from './modules/user/user.routes.js';
import { productRoutes } from './modules/product/product.routes.js';
import { inventoryRoutes } from './modules/inventory/inventory.routes.js';
import { shiftRoutes } from './modules/shift/shift.routes.js';
import { salesRoutes } from './modules/sales/sales.routes.js';
import { reportsRoutes } from './modules/reports/reports.routes.js';
import { alertsRoutes } from './modules/alerts/alerts.routes.js';
import { syncRoutes } from './modules/sync/sync.routes.js';

// Fastify instance үүсгэх
const server = Fastify({
  logger: {
    transport:
      env.NODE_ENV === 'development'
        ? {
            target: 'pino-pretty',
            options: {
              colorize: true,
              translateTime: 'HH:MM:ss',
              ignore: 'pid,hostname',
            },
          }
        : undefined,
  },
  disableRequestLogging: false,
  requestIdHeader: 'x-request-id',
});

/**
 * Server startup
 */
async function start() {
  try {
    server.log.info('🚀 Starting Retail Control Backend...');

    // Register plugins
    await registerPlugins(server);

    // Health check endpoint (register before routes)
    server.get('/health', async () => {
      return {
        status: 'ok',
        timestamp: new Date().toISOString(),
        environment: env.NODE_ENV,
        version: '1.0.0',
      };
    });

    // Register routes
    await server.register(authRoutes);
    await server.register(storeRoutes);
    await server.register(userRoutes);
    await server.register(productRoutes);
    await server.register(inventoryRoutes);
    await server.register(shiftRoutes);
    await server.register(salesRoutes);
    await server.register(reportsRoutes);
    await server.register(alertsRoutes);
    await server.register(syncRoutes);

    // Start listening
    await server.listen({
      port: env.PORT,
      host: env.HOST,
    });

    server.log.info(`✅ Server listening on ${env.HOST}:${env.PORT}`);
    server.log.info(`📚 Environment: ${env.NODE_ENV}`);
  } catch (error) {
    server.log.error(error);
    process.exit(1);
  }
}

/**
 * Graceful shutdown
 */
async function shutdown() {
  server.log.info('🛑 Shutting down server...');
  await server.close();
  process.exit(0);
}

// Signal handlers
process.on('SIGTERM', shutdown);
process.on('SIGINT', shutdown);

// Start server
start();
