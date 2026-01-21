/**
 * Error Handler Plugin
 *
 * Global error handler - бүх алдааг catch хийж, consistent format-аар буцаана.
 */

import fp from 'fastify-plugin';
import type { FastifyInstance, FastifyError, FastifyRequest, FastifyReply } from 'fastify';
import { env } from '../config/env.js';

/**
 * Standard error response format
 */
interface ErrorResponse {
  statusCode: number;
  error: string;
  message: string;
  details?: any;
  stack?: string;
}

async function errorHandlerPluginFn(server: FastifyInstance) {
  server.setErrorHandler(
    (error: FastifyError, request: FastifyRequest, reply: FastifyReply) => {
      // Log алдааг server log-д бичих
      request.log.error({
        err: error,
        request: {
          method: request.method,
          url: request.url,
          params: request.params,
          query: request.query,
        },
      });

      // Status code тодорхойлох
      const statusCode = error.statusCode || 500;

      // Error response үүсгэх
      const errorResponse: ErrorResponse = {
        statusCode,
        error: error.name || 'Internal Server Error',
        message: error.message || 'Something went wrong',
      };

      // Development mode-д stack trace нэмэх
      if (env.NODE_ENV === 'development') {
        errorResponse.stack = error.stack;
        errorResponse.details = error.validation || (error as any).details;
      }

      // Validation errors (Zod, Fastify)
      if (error.validation) {
        errorResponse.error = 'Validation Error';
        errorResponse.details = error.validation;
      }

      // Supabase errors
      if ((error as any).code?.startsWith('PGRST')) {
        errorResponse.error = 'Database Error';
        errorResponse.message = 'Failed to process database request';
      }

      // JWT errors
      if (error.message?.includes('token')) {
        errorResponse.error = 'Authentication Error';
      }

      // Response буцаах
      reply.status(statusCode).send(errorResponse);
    }
  );

  server.log.info('✓ Error handler registered');
}

export const errorHandlerPlugin = fp(errorHandlerPluginFn, {
  name: 'error-handler-plugin',
});
