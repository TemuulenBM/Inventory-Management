/**
 * Auth Module Exports
 *
 * Auth-тэй холбоотой бүх exports-г нэгтгэсэн файл.
 */

// Routes
export { authRoutes } from './auth.routes.js';

// Middleware
export { authorize, requireStore, requireAuth, optionalAuth } from './auth.middleware.js';
export type { AuthRequest } from './auth.middleware.js';

// Schemas
export type {
  OTPRequestBody,
  OTPVerifyBody,
  RefreshTokenBody,
  OTPRequestResponse,
  OTPVerifyResponse,
  RefreshTokenResponse,
  UserInfoResponse,
} from './auth.schema.js';

// Service (internal use only - эдгээрийг routes-с ашиглана)
// export { requestOTP, verifyOTP, refreshAccessToken, logout } from './auth.service.js';
