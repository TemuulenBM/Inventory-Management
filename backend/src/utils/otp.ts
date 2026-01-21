/**
 * OTP (One-Time Password) Generator
 *
 * 6 оронтой санамсаргүй код үүсгэх utility.
 * Ашиглалт: SMS authentication, 2FA verification
 */

import crypto from 'crypto';

/**
 * OTP Configuration
 */
export const OTP_CONFIG = {
  LENGTH: 6, // 6 оронтой код
  EXPIRY_MINUTES: 5, // 5 минутын дараа хүчингүй болно
  MAX_ATTEMPTS: 3, // Максимум 3 удаа оролдох эрхтэй
} as const;

/**
 * 6 оронтой OTP код үүсгэх
 *
 * Cryptographically secure random number generation ашиглана.
 * Example: "123456", "998877", "000123"
 *
 * @returns 6 оронтой string (leading zeros хадгална)
 */
export function generateOTP(): string {
  // Crypto.randomInt ашиглан аюулгүй random number үүсгэх
  const min = 0;
  const max = 999999;
  const otp = crypto.randomInt(min, max + 1);

  // Leading zeros хадгалж string болгох
  return otp.toString().padStart(OTP_CONFIG.LENGTH, '0');
}

/**
 * OTP expiry timestamp тооцоолох
 *
 * @param minutes - Хэдэн минутын дараа дуусах (default: 5)
 * @returns ISO timestamp string
 */
export function getOTPExpiry(minutes: number = OTP_CONFIG.EXPIRY_MINUTES): Date {
  const now = new Date();
  now.setMinutes(now.getMinutes() + minutes);
  return now;
}

/**
 * OTP хүчинтэй эсэхийг шалгах
 *
 * @param expiresAt - OTP дуусах timestamp
 * @returns Хүчинтэй бол true
 */
export function isOTPValid(expiresAt: Date): boolean {
  return new Date() < new Date(expiresAt);
}

/**
 * OTP оролдлого хязгаарлалт шалгах
 *
 * @param attempts - Одоогийн оролдлогын тоо
 * @returns Зөвшөөрөгдсөн бол true
 */
export function canAttemptOTP(attempts: number): boolean {
  return attempts < OTP_CONFIG.MAX_ATTEMPTS;
}

/**
 * Test хэрэгцээнд OTP үүсгэх (development only)
 *
 * PRODUCTION дээр энийг ашиглахгүй!
 *
 * @returns Fixed OTP code "111111"
 */
export function generateTestOTP(): string {
  return '111111';
}

/**
 * OTP verify - хоёр код ижил эсэхийг шалгах
 *
 * Constant-time comparison ашиглан timing attack-ээс хамгаална
 *
 * @param input - Хэрэглэгчийн оруулсан код
 * @param stored - Database-д хадгалсан код
 * @returns Ижил бол true
 */
export function verifyOTP(input: string, stored: string): boolean {
  // String-үүдийг buffer болгож constant-time compare хийх
  const inputBuffer = Buffer.from(input);
  const storedBuffer = Buffer.from(stored);

  // Length check
  if (inputBuffer.length !== storedBuffer.length) {
    return false;
  }

  // Constant-time comparison (timing attack prevention)
  return crypto.timingSafeEqual(inputBuffer, storedBuffer);
}
