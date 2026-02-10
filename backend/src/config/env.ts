/**
 * Environment Configuration
 *
 * Environment variables-г load хийж, validate хийнэ.
 */

import 'dotenv/config';

interface EnvConfig {
  // Server
  NODE_ENV: 'development' | 'staging' | 'production';
  PORT: number;
  HOST: string;

  // Supabase
  SUPABASE_URL: string;
  SUPABASE_ANON_KEY: string;
  SUPABASE_SERVICE_KEY: string;

  // JWT
  JWT_SECRET: string;
  JWT_ACCESS_EXPIRY: string;
  JWT_REFRESH_EXPIRY: string;

  // CORS
  CORS_ORIGIN: string;

  // Rate limiting
  RATE_LIMIT_MAX: number;

  // SMS (future)
  SMS_PROVIDER?: string;
  SMS_API_KEY?: string;
}

function validateEnv(): EnvConfig {
  const requiredVars = [
    'SUPABASE_URL',
    'SUPABASE_ANON_KEY',
    'SUPABASE_SERVICE_KEY',
    'JWT_SECRET',
  ];

  const missing = requiredVars.filter((key) => !process.env[key]);

  if (missing.length > 0) {
    throw new Error(
      `Missing required environment variables: ${missing.join(', ')}\n` +
      'Please check your .env file.'
    );
  }

  return {
    // Server
    NODE_ENV: (process.env.ENVIRONMENT || 'development') as EnvConfig['NODE_ENV'],
    PORT: parseInt(process.env.PORT || '3000', 10),
    HOST: process.env.HOST || '0.0.0.0',

    // Supabase
    SUPABASE_URL: process.env.SUPABASE_URL!,
    SUPABASE_ANON_KEY: process.env.SUPABASE_ANON_KEY!,
    SUPABASE_SERVICE_KEY: process.env.SUPABASE_SERVICE_KEY!,

    // JWT (токен генерэйт хийхэд ашиглана, Supabase Auth-тай хамт ажиллана)
    JWT_SECRET: process.env.JWT_SECRET!,
    JWT_ACCESS_EXPIRY: process.env.JWT_ACCESS_EXPIRY || '1h',
    JWT_REFRESH_EXPIRY: process.env.JWT_REFRESH_EXPIRY || '30d',

    // CORS
    CORS_ORIGIN: process.env.CORS_ORIGIN || '*',

    // Rate limiting
    RATE_LIMIT_MAX: parseInt(process.env.RATE_LIMIT_MAX || '100', 10),

    // SMS
    SMS_PROVIDER: process.env.SMS_PROVIDER,
    SMS_API_KEY: process.env.SMS_API_KEY,
  };
}

export const env = validateEnv();

// Log configuration (development only)
if (env.NODE_ENV === 'development') {
  console.log('🔧 Environment Configuration:');
  console.log(`  - NODE_ENV: ${env.NODE_ENV}`);
  console.log(`  - PORT: ${env.PORT}`);
  console.log(`  - SUPABASE_URL: ${env.SUPABASE_URL}`);
  console.log(`  - JWT_SECRET: ${env.JWT_SECRET.substring(0, 10)}...`);
}
