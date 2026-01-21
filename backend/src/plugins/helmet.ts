/**
 * Helmet Plugin
 *
 * Security headers тохируулга.
 * XSS, clickjacking, гэх мэт халдлагаас хамгаална.
 */

import fp from 'fastify-plugin';
import helmet from '@fastify/helmet';
import type { FastifyInstance } from 'fastify';

async function helmetPluginFn(server: FastifyInstance) {
  await server.register(helmet, {
    // Content Security Policy
    contentSecurityPolicy: {
      directives: {
        defaultSrc: ["'self'"],
        styleSrc: ["'self'", "'unsafe-inline'"],
        scriptSrc: ["'self'"],
        imgSrc: ["'self'", 'data:', 'https:'],
      },
    },

    // Prevent browsers from detecting MIME types
    noSniff: true,

    // Prevent clickjacking
    frameguard: {
      action: 'deny',
    },

    // XSS Protection (legacy browsers)
    xssFilter: true,

    // HSTS (HTTPS only)
    hsts: {
      maxAge: 31536000, // 1 жил
      includeSubDomains: true,
    },
  });

  server.log.info('✓ Helmet plugin registered');
}

export const helmetPlugin = fp(helmetPluginFn, {
  name: 'helmet-plugin',
});
