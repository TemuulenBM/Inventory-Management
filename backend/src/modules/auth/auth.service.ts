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
 * @param deviceId - Төхөөрөмжийн UUID (optional)
 * @param trustDeviceFlag - Төхөөрөмжийг итгэмжлэх эсэх (optional)
 * @returns User болон tokens
 */
export async function verifyOTP(
  phone: string,
  otpInput: string,
  server: FastifyInstance,
  deviceId?: string,
  trustDeviceFlag?: boolean
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

  // 2. OTP олох (сүүлийн, expire аагүй, verified=false)
  const { data: otpTokens, error: fetchError } = await supabase
    .from('otp_tokens')
    .select('*')
    .eq('phone', validatedPhone)
    .eq('verified', false)
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

  // 6. OTP зөв - verified=true болгож тэмдэглэх (устгахгүй - audit trail)
  await supabase
    .from('otp_tokens')
    .update({ verified: true })
    .eq('id', otpToken.id);

  // 7. User олох эсвэл үүсгэх
  const { data: existingUsers } = await supabase.from('users').select('*').eq('phone', validatedPhone).limit(1);

  let user;

  if (existingUsers && existingUsers.length > 0) {
    // Хэрэглэгч байна - login
    user = existingUsers[0];
  } else {
    // ═══ Шинэ хэрэглэгч - Урилга шалгах (Invite-only registration) ═══
    const { checkInvitation, markInvitationAsUsed } = await import('../invitation/invitation.service.js');

    const invitationCheck = await checkInvitation(validatedPhone);

    if (!invitationCheck.valid) {
      return {
        success: false,
        error: invitationCheck.error || 'Та урилга авах хэрэгтэй. Администратортай холбогдоно уу.',
      };
    }

    // ═══ Урилга идэвхитэй - Шинэ owner user үүсгэх ═══
    const { data: newUser, error: createError } = await supabase
      .from('users')
      .insert({
        phone: validatedPhone,
        name: validatedPhone, // Temporary name, user updates later via onboarding
        role: invitationCheck.invitation.role,
        store_id: null, // Will be set after store creation in onboarding
      })
      .select()
      .single();

    if (createError || !newUser) {
      console.error('User creation error:', createError);
      return {
        success: false,
        error: 'Хэрэглэгч үүсгэхэд алдаа гарлаа. Дахин оролдоно уу.',
      };
    }

    // Урилга ашигласан гэж тэмдэглэх
    await markInvitationAsUsed(invitationCheck.invitation.id, newUser.id);

    user = newUser;
    console.log(`👤 New user created via invitation: ${user.phone} (${user.role})`);
  }

  // 8. JWT tokens үүсгэх (multi-store: storeId JWT-д хадгалахгүй)
  const payload: JWTPayload = {
    userId: user.id,
    role: user.role as 'super_admin' | 'owner' | 'manager' | 'seller',
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

  // 10. Device trust хийх (хэрэв хүсвэл)
  if (trustDeviceFlag && deviceId) {
    await supabase.from('trusted_devices' as any).upsert(
      {
        user_id: user.id,
        device_id: deviceId,
        last_used_at: new Date().toISOString(),
      },
      {
        onConflict: 'user_id,device_id',
      }
    );
    console.log(`🔐 Device trusted: ${deviceId.substring(0, 8)}... for ${user.phone}`);
  }

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

/**
 * Хуучин OTP tokens устгах (cleanup)
 *
 * 24+ цагийн өмнөх verified эсвэл expired OTP-г устгана.
 * Энэ функц периодоор ажиллах ёстой (cron job, scheduled task).
 */
export async function cleanupOldOTPs(): Promise<void> {
  const twentyFourHoursAgo = new Date(Date.now() - 24 * 60 * 60 * 1000);

  const { error } = await supabase
    .from('otp_tokens')
    .delete()
    .lt('created_at', twentyFourHoursAgo.toISOString());

  if (error) {
    console.error('OTP cleanup error:', error);
  } else {
    console.log('✓ Old OTP tokens cleaned up (24h+)');
  }
}

// ============================================================================
// DEVICE TRUST FUNCTIONS
// Итгэмжлэгдсэн төхөөрөмжөөр OTP-гүй нэвтрэх боломж
// ============================================================================

/**
 * Төхөөрөмж итгэмжлэгдсэн эсэхийг шалгах
 *
 * @param userId - Хэрэглэгчийн ID
 * @param deviceId - Төхөөрөмжийн UUID
 * @returns Итгэмжлэгдсэн бол true
 */
export async function isDeviceTrusted(userId: string, deviceId: string): Promise<boolean> {
  const { data, error } = await supabase
    .from('trusted_devices' as any)
    .select('id')
    .eq('user_id', userId)
    .eq('device_id', deviceId)
    .single();

  if (error || !data) {
    return false;
  }

  // last_used_at шинэчлэх
  await supabase
    .from('trusted_devices' as any)
    .update({ last_used_at: new Date().toISOString() })
    .eq('user_id', userId)
    .eq('device_id', deviceId);

  return true;
}

/**
 * Төхөөрөмжийг итгэмжлэх
 *
 * @param userId - Хэрэглэгчийн ID
 * @param deviceId - Төхөөрөмжийн UUID
 * @param deviceName - Төхөөрөмжийн нэр (optional, e.g., "iPhone 15")
 * @param deviceInfo - Төхөөрөмжийн metadata (platform, model, osVersion)
 */
export async function trustDevice(
  userId: string,
  deviceId: string,
  deviceName?: string,
  deviceInfo?: { platform?: string; model?: string; osVersion?: string }
): Promise<{ success: boolean; error?: string }> {
  const { error } = await supabase.from('trusted_devices' as any).upsert(
    {
      user_id: userId,
      device_id: deviceId,
      device_name: deviceName,
      device_info: deviceInfo ?? {},
      last_used_at: new Date().toISOString(),
    },
    {
      onConflict: 'user_id,device_id',
    }
  );

  if (error) {
    console.error('Trust device error:', error);
    return { success: false, error: 'Төхөөрөмж итгэмжлэхэд алдаа гарлаа.' };
  }

  console.log(`🔐 Device trusted: ${deviceId} for user ${userId}`);
  return { success: true };
}

/**
 * Утасны дугаараар хэрэглэгч олох
 *
 * @param phone - Утасны дугаар
 * @returns User объект эсвэл null
 */
export async function findUserByPhone(phone: string): Promise<any | null> {
  const validatedPhone = validatePhone(phone);
  if (!validatedPhone) {
    return null;
  }

  const { data: users, error } = await supabase
    .from('users')
    .select('*')
    .eq('phone', validatedPhone)
    .limit(1);

  if (error || !users || users.length === 0) {
    return null;
  }

  return users[0];
}

/**
 * JWT tokens үүсгэх
 *
 * @param user - User объект
 * @param server - Fastify instance
 * @returns Access token, refresh token, expiresIn
 */
export async function generateTokens(
  user: any,
  server: FastifyInstance
): Promise<{ accessToken: string; refreshToken: string; expiresIn: number }> {
  const payload: JWTPayload = {
    userId: user.id,
    role: user.role as 'super_admin' | 'owner' | 'manager' | 'seller',
  };

  const accessToken = server.jwt.sign(payload, { expiresIn: env.JWT_ACCESS_EXPIRY });
  const refreshToken = server.jwt.sign(payload, { expiresIn: env.JWT_REFRESH_EXPIRY });

  // Refresh token database-д хадгалах
  const refreshExpiresAt = new Date();
  refreshExpiresAt.setDate(refreshExpiresAt.getDate() + 30);

  await supabase.from('refresh_tokens' as any).insert({
    user_id: user.id,
    token: refreshToken,
    expires_at: refreshExpiresAt.toISOString(),
  });

  return {
    accessToken,
    refreshToken,
    expiresIn: parseInt(env.JWT_ACCESS_EXPIRY.replace('h', '')) * 3600,
  };
}

/**
 * Итгэмжлэгдсэн төхөөрөмжөөр нэвтрэх (OTP шаардахгүй)
 *
 * @param phone - Утасны дугаар
 * @param deviceId - Төхөөрөмжийн UUID
 * @param server - Fastify instance
 * @param currentDeviceInfo - Одоогийн төхөөрөмжийн мэдээлэл (platform шалгахад ашиглана)
 * @returns User болон tokens
 */
export async function deviceLogin(
  phone: string,
  deviceId: string,
  server: FastifyInstance,
  currentDeviceInfo?: { platform?: string; model?: string; osVersion?: string }
): Promise<{
  success: boolean;
  user?: any;
  tokens?: { accessToken: string; refreshToken: string; expiresIn: number };
  error?: string;
}> {
  // 1. User олох
  const user = await findUserByPhone(phone);
  if (!user) {
    return { success: false, error: 'Хэрэглэгч олдсонгүй.' };
  }

  // 2. Device trusted эсэх шалгах
  const trusted = await isDeviceTrusted(user.id, deviceId);
  if (!trusted) {
    return { success: false, error: 'Төхөөрөмж итгэмжлэгдээгүй байна. OTP ашиглан нэвтэрнэ үү.' };
  }

  // 3. Platform шалгалт — хулгайлагдсан device_id-г өөр platform-аас ашиглахаас сэргийлэх
  if (currentDeviceInfo?.platform) {
    const { data: deviceRecord } = await supabase
      .from('trusted_devices' as any)
      .select('device_info')
      .eq('user_id', user.id)
      .eq('device_id', deviceId)
      .single();

    const record = deviceRecord as { device_info?: { platform?: string } } | null;
    const storedInfo = record?.device_info;
    if (storedInfo?.platform && storedInfo.platform !== currentDeviceInfo.platform) {
      // Platform таарахгүй — warning log, гэхдээ login зөвшөөрөх (UX-д сөрөг нөлөөгүй)
      console.warn(
        `⚠️ Platform mismatch for device ${deviceId.substring(0, 8)}...: ` +
        `stored=${storedInfo.platform}, current=${currentDeviceInfo.platform}`
      );
    }
  }

  // 4. Tokens үүсгэх
  const tokens = await generateTokens(user, server);

  console.log(`✅ Device login: ${user.phone} via trusted device ${deviceId.substring(0, 8)}...`);

  return {
    success: true,
    user: {
      id: user.id,
      phone: user.phone,
      name: user.name,
      role: user.role,
      storeId: user.store_id,
    },
    tokens,
  };
}

/**
 * Хэрэглэгчийн итгэмжлэгдсэн төхөөрөмжүүдийг авах
 *
 * @param userId - Хэрэглэгчийн ID
 * @returns Төхөөрөмжүүдийн жагсаалт
 */
export async function getTrustedDevices(
  userId: string
): Promise<{ id: string; deviceId: string; deviceName?: string; trustedAt: string; lastUsedAt: string }[]> {
  const { data, error } = await supabase
    .from('trusted_devices' as any)
    .select('*')
    .eq('user_id', userId)
    .order('last_used_at', { ascending: false });

  if (error || !data) {
    return [];
  }

  return data.map((d: any) => ({
    id: d.id,
    deviceId: d.device_id,
    deviceName: d.device_name,
    trustedAt: d.trusted_at,
    lastUsedAt: d.last_used_at,
  }));
}

/**
 * Итгэмжлэгдсэн төхөөрөмж устгах
 *
 * @param userId - Хэрэглэгчийн ID
 * @param deviceId - Төхөөрөмжийн UUID
 */
export async function removeTrustedDevice(
  userId: string,
  deviceId: string
): Promise<{ success: boolean; error?: string }> {
  const { error } = await supabase
    .from('trusted_devices' as any)
    .delete()
    .eq('user_id', userId)
    .eq('device_id', deviceId);

  if (error) {
    console.error('Remove trusted device error:', error);
    return { success: false, error: 'Төхөөрөмж устгахад алдаа гарлаа.' };
  }

  console.log(`🗑️ Trusted device removed: ${deviceId} for user ${userId}`);
  return { success: true };
}
