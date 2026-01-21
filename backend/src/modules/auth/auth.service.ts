/**
 * Auth Service
 *
 * OTP-based authentication business logic:
 * - OTP үүсгэх, илгээх, verify хийх
 * - JWT token үүсгэх, refresh хийх
 * - User бүртгэх, олох
 */

import type { FastifyInstance } from 'fastify';
import { supabase } from '../../config/supabase.js';
import { validatePhone } from '../../utils/phone.js';
import { generateOTP, getOTPExpiry, isOTPValid, verifyOTP as verifyOTPCode, OTP_CONFIG } from '../../utils/otp.js';
import type { JWTPayload } from '../../plugins/jwt.js';
import { env } from '../../config/env.js';

/**
 * OTP хүсэлт - утасны дугаар руу OTP илгээх
 *
 * Rate limiting: 1 утасны дугаарт 3 OTP / 5 минут
 *
 * @param phone - Утасны дугаар
 * @returns Амжилттай бол { success: true, expiresIn }
 */
export async function requestOTP(phone: string): Promise<{ success: boolean; expiresIn?: number; error?: string }> {
  // 1. Phone validation
  const validatedPhone = validatePhone(phone);
  if (!validatedPhone) {
    return { success: false, error: 'Утасны дугаар буруу байна. +976XXXXXXXX форматаар оруулна уу.' };
  }

  // 2. Rate limiting check - сүүлийн 5 минутад хэдэн OTP хүссэн
  const fiveMinutesAgo = new Date(Date.now() - 5 * 60 * 1000);
  const { data: recentOTPs, error: countError } = await supabase
    .from('otp_tokens')
    .select('id')
    .eq('phone', validatedPhone)
    .gte('created_at', fiveMinutesAgo.toISOString());

  if (countError) {
    console.error('Rate limit check failed:', countError);
    return { success: false, error: 'Системийн алдаа гарлаа. Дахин оролдоно уу.' };
  }

  if (recentOTPs && recentOTPs.length >= 3) {
    return {
      success: false,
      error: '5 минутад 3 удаа OTP хүсэх боломжтой. Түр хүлээгээд дахин оролдоно уу.',
    };
  }

  // 3. OTP үүсгэх
  const otp = generateOTP();
  const expiresAt = getOTPExpiry();

  // 4. OTP database-д хадгалах
  const { error: insertError } = await supabase.from('otp_tokens').insert({
    phone: validatedPhone,
    otp_code: otp,
    expires_at: expiresAt.toISOString(),
  });

  if (insertError) {
    console.error('OTP insert failed:', insertError);
    return { success: false, error: 'OTP үүсгэхэд алдаа гарлаа. Дахин оролдоно уу.' };
  }

  // 5. SMS илгээх (Mock implementation - дараа нь Twilio/other SMS service ашиглана)
  await sendOTPSMS(validatedPhone, otp);

  console.log(`📱 OTP sent to ${validatedPhone}: ${otp} (expires in ${OTP_CONFIG.EXPIRY_MINUTES} minutes)`);

  return {
    success: true,
    expiresIn: OTP_CONFIG.EXPIRY_MINUTES * 60, // Секундээр
  };
}

/**
 * OTP verify - Хэрэглэгчийн оруулсан OTP шалгаж login хийх
 *
 * @param phone - Утасны дугаар
 * @param otpInput - Хэрэглэгчийн оруулсан OTP
 * @param server - Fastify instance (JWT үүсгэхэд хэрэгтэй)
 * @returns User болон tokens
 */
export async function verifyOTP(
  phone: string,
  otpInput: string,
  server: FastifyInstance
): Promise<{
  success: boolean;
  user?: any;
  tokens?: { accessToken: string; refreshToken: string; expiresIn: number };
  error?: string;
}> {
  // 1. Phone validation
  const validatedPhone = validatePhone(phone);
  if (!validatedPhone) {
    return { success: false, error: 'Утасны дугаар буруу байна.' };
  }

  // 2. OTP олох (сүүлийн, expire аагүй, attempt < 3)
  const { data: otpTokens, error: fetchError } = await supabase
    .from('otp_tokens')
    .select('*')
    .eq('phone', validatedPhone)
    .order('created_at', { ascending: false })
    .limit(1);

  if (fetchError || !otpTokens || otpTokens.length === 0) {
    return { success: false, error: 'OTP олдсонгүй. Дахин OTP хүсэх хэрэгтэй.' };
  }

  const otpToken = otpTokens[0];

  // 3. OTP хүчинтэй эсэх шалгах
  if (!isOTPValid(new Date(otpToken.expires_at))) {
    return { success: false, error: 'OTP хугацаа дууссан байна. Дахин OTP хүсэх хэрэгтэй.' };
  }

  // 4. OTP verify хийх
  const isValid = verifyOTPCode(otpInput, otpToken.otp_code);

  // 5. Буруу бол алдаа буцаах
  if (!isValid) {
    return {
      success: false,
      error: 'OTP буруу байна. Дахин оролдоно уу.',
    };
  }

  // 6. OTP зөв - OTP token устгах
  await supabase.from('otp_tokens').delete().eq('id', otpToken.id);

  // 7. User олох эсвэл үүсгэх
  const { data: existingUsers } = await supabase.from('users').select('*').eq('phone', validatedPhone).limit(1);

  let user;

  if (existingUsers && existingUsers.length > 0) {
    // Хэрэглэгч байна - login
    user = existingUsers[0];
  } else {
    // Шинэ хэрэглэгч - бүртгэх (phone-only registration)
    // NOTE: Энэ нь simplified version - production дээр store_id заавал шаардлагатай
    // Одоогоор phone-only registration зөвшөөрч байна
    return {
      success: false,
      error: 'Хэрэглэгч бүртгэгдээгүй байна. Эхлээд дэлгүүр үүсгэх хэрэгтэй.',
    };
  }

  // 8. JWT tokens үүсгэх
  const payload: JWTPayload = {
    userId: user.id,
    storeId: user.store_id,
    role: user.role as 'owner' | 'manager' | 'seller',
  };

  const accessToken = server.jwt.sign(payload, { expiresIn: env.JWT_ACCESS_EXPIRY });
  const refreshToken = server.jwt.sign(payload, { expiresIn: env.JWT_REFRESH_EXPIRY });

  // 9. Refresh token database-д хадгалах
  const refreshExpiresAt = new Date();
  refreshExpiresAt.setDate(refreshExpiresAt.getDate() + 30); // 30 days

  await supabase.from('refresh_tokens' as any).insert({
    user_id: user.id,
    token: refreshToken,
    expires_at: refreshExpiresAt.toISOString(),
  });

  console.log(`✅ User logged in: ${user.phone} (${user.role})`);

  return {
    success: true,
    user: {
      id: user.id,
      phone: user.phone,
      name: user.name,
      role: user.role,
      storeId: user.store_id,
    },
    tokens: {
      accessToken,
      refreshToken,
      expiresIn: parseInt(env.JWT_ACCESS_EXPIRY.replace('h', '')) * 3600, // Секундээр
    },
  };
}

/**
 * Refresh token ашиглан шинэ access token авах
 *
 * @param refreshToken - Refresh token
 * @param server - Fastify instance
 * @returns Шинэ tokens
 */
export async function refreshAccessToken(
  refreshToken: string,
  server: FastifyInstance
): Promise<{
  success: boolean;
  tokens?: { accessToken: string; refreshToken: string; expiresIn: number };
  error?: string;
}> {
  try {
    // 1. Refresh token verify хийх
    const decoded = server.jwt.verify<JWTPayload>(refreshToken);

    // 2. Refresh token database-д байгаа эсэх шалгах
    const { data: storedTokens, error: fetchError } = await supabase
      .from('refresh_tokens' as any)
      .select('*')
      .eq('token', refreshToken)
      .eq('user_id', decoded.userId)
      .limit(1);

    if (fetchError || !storedTokens || storedTokens.length === 0) {
      return { success: false, error: 'Refresh token олдсонгүй эсвэл хүчингүй байна.' };
    }

    const storedToken = storedTokens[0] as any;

    // 3. Хугацаа дууссан эсэх шалгах
    if (new Date(storedToken.expires_at) < new Date()) {
      // Хуучин token устгах
      await supabase.from('refresh_tokens' as any).delete().eq('id', storedToken.id);
      return { success: false, error: 'Refresh token хугацаа дууссан. Дахин нэвтэрнэ үү.' };
    }

    // 4. Шинэ tokens үүсгэх
    const payload: JWTPayload = {
      userId: decoded.userId,
      storeId: decoded.storeId,
      role: decoded.role,
    };

    const newAccessToken = server.jwt.sign(payload, { expiresIn: env.JWT_ACCESS_EXPIRY });
    const newRefreshToken = server.jwt.sign(payload, { expiresIn: env.JWT_REFRESH_EXPIRY });

    // 5. Хуучин refresh token устгаж, шинэ refresh token хадгалах
    await supabase.from('refresh_tokens' as any).delete().eq('id', storedToken.id);

    const newRefreshExpiresAt = new Date();
    newRefreshExpiresAt.setDate(newRefreshExpiresAt.getDate() + 30);

    await supabase.from('refresh_tokens' as any).insert({
      user_id: decoded.userId,
      token: newRefreshToken,
      expires_at: newRefreshExpiresAt.toISOString(),
    });

    console.log(`🔄 Token refreshed for user: ${decoded.userId}`);

    return {
      success: true,
      tokens: {
        accessToken: newAccessToken,
        refreshToken: newRefreshToken,
        expiresIn: parseInt(env.JWT_ACCESS_EXPIRY.replace('h', '')) * 3600,
      },
    };
  } catch (error: any) {
    console.error('Token refresh error:', error);
    return { success: false, error: 'Refresh token буруу эсвэл хүчингүй байна.' };
  }
}

/**
 * Logout - Refresh token устгах
 *
 * @param userId - Хэрэглэгчийн ID
 * @param refreshToken - Устгах refresh token
 * @returns Амжилттай бол { success: true }
 */
export async function logout(userId: string, refreshToken: string): Promise<{ success: boolean; error?: string }> {
  const { error } = await supabase
    .from('refresh_tokens' as any)
    .delete()
    .eq('user_id', userId)
    .eq('token', refreshToken);

  if (error) {
    console.error('Logout error:', error);
    return { success: false, error: 'Logout хийхэд алдаа гарлаа.' };
  }

  console.log(`👋 User logged out: ${userId}`);
  return { success: true };
}

/**
 * SMS илгээх (Mock implementation)
 *
 * Production дээр Twilio, MessageBird гэх мэт SMS service ашиглана.
 *
 * @param phone - Утасны дугаар
 * @param otp - OTP код
 */
async function sendOTPSMS(phone: string, otp: string): Promise<void> {
  // Mock implementation - console-д хэвлэх
  console.log(`\n📨 SMS Mock Send:`);
  console.log(`   To: ${phone}`);
  console.log(`   Message: Таны нэвтрэх код: ${otp} (${OTP_CONFIG.EXPIRY_MINUTES} минут хүчинтэй)`);
  console.log('');

  // TODO: Production дээр:
  // - Twilio API call
  // - MessageBird API call
  // - SMS gateway integration
}
