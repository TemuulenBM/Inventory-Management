/**
 * Invitation Service
 *
 * Урилга үүсгэх, шалгах, жагсаалт авах логик
 */

import { supabase } from '../../config/supabase.js';
import { validatePhone } from '../../utils/phone.js';

/**
 * Урилга үүсгэх
 *
 * @param phone - Утасны дугаар
 * @param role - Эрхийн түвшин
 * @param invitedBy - Урилга илгээсэн админ/owner ID
 * @param expiresInDays - Хэдэн хоногийн дараа expire болох (default: 7)
 */
export async function createInvitation(
  phone: string,
  role: 'owner' | 'manager' | 'seller',
  invitedBy: string | null,
  expiresInDays: number = 7
) {
  const validatedPhone = validatePhone(phone);
  if (!validatedPhone) {
    return { success: false as const, error: 'Утасны дугаар буруу байна' };
  }

  // 1. Шалгах: тухайн дугаартай хэрэглэгч бүртгэлтэй эсэх
  const { data: existingUser } = await supabase
    .from('users')
    .select('id')
    .eq('phone', validatedPhone)
    .single();

  if (existingUser) {
    return { success: false as const, error: 'Энэ дугаар аль хэдийн бүртгэлтэй байна' };
  }

  // 2. Шалгах: идэвхитэй урилга байгаа эсэх
  const { data: pendingInvitation } = await supabase
    .from('invitations')
    .select('id')
    .eq('phone', validatedPhone)
    .eq('status', 'pending')
    .maybeSingle();

  if (pendingInvitation) {
    return { success: false as const, error: 'Энэ дугаарт идэвхитэй урилга байна' };
  }

  // 3. Урилга үүсгэх
  const expiresAt = new Date();
  expiresAt.setDate(expiresAt.getDate() + expiresInDays);

  const { data: invitation, error } = await supabase
    .from('invitations')
    .insert({
      phone: validatedPhone,
      role,
      invited_by: invitedBy,
      expires_at: expiresAt.toISOString(),
      status: 'pending',
    })
    .select()
    .single();

  if (error) {
    console.error('Create invitation error:', error);
    return { success: false as const, error: 'Урилга үүсгэхэд алдаа гарлаа' };
  }

  console.log(`✉️  Invitation created: ${validatedPhone} (${role}) - expires ${expiresInDays} days`);

  return {
    success: true as const,
    invitation: {
      id: invitation.id,
      phone: invitation.phone,
      role: invitation.role,
      status: invitation.status,
      invitedBy: invitation.invited_by,
      invitedAt: invitation.invited_at,
      expiresAt: invitation.expires_at,
    },
  };
}

/**
 * Урилга идэвхитэй эсэхийг шалгах
 *
 * OTP verify хийхийн өмнө дуудагдана.
 *
 * @param phone - Утасны дугаар
 * @returns Урилга байвал { valid: true, invitation }, байхгүй бол { valid: false }
 */
export async function checkInvitation(phone: string) {
  const validatedPhone = validatePhone(phone);
  if (!validatedPhone) {
    return { valid: false as const, error: 'Утасны дугаар буруу байна' };
  }

  // Expire болсон урилгуудыг шинэчлэх
  await expireOldInvitations();

  // Идэвхитэй урилга олох
  const { data: invitation, error } = await supabase
    .from('invitations')
    .select('*')
    .eq('phone', validatedPhone)
    .eq('status', 'pending')
    .maybeSingle();

  if (error || !invitation) {
    return { valid: false as const, error: 'Урилга олдсонгүй эсвэл хүчингүй байна' };
  }

  // Хугацаа дууссан эсэхийг дахин шалгах
  if (new Date(invitation.expires_at) < new Date()) {
    await supabase
      .from('invitations')
      .update({ status: 'expired' })
      .eq('id', invitation.id);

    return { valid: false as const, error: 'Урилгын хугацаа дууссан байна' };
  }

  return {
    valid: true as const,
    invitation: {
      id: invitation.id,
      phone: invitation.phone,
      role: invitation.role,
      expiresAt: invitation.expires_at,
    },
  };
}

/**
 * Урилга ашигласан гэж тэмдэглэх
 *
 * User амжилттай үүсснээр дуудагдана.
 *
 * @param invitationId - Урилгын ID
 * @param userId - Үүссэн user-ийн ID
 */
export async function markInvitationAsUsed(invitationId: string, userId: string) {
  const { error } = await supabase
    .from('invitations')
    .update({
      status: 'used',
      used_at: new Date().toISOString(),
      used_by: userId,
    })
    .eq('id', invitationId);

  if (error) {
    console.error('Mark invitation as used error:', error);
  } else {
    console.log(`✅ Invitation ${invitationId} marked as used by ${userId}`);
  }
}

/**
 * Урилга цуцлах (admin action)
 *
 * @param invitationId - Урилгын ID
 * @param adminId - Админ ID (authorization шалгах)
 */
export async function revokeInvitation(invitationId: string, adminId: string) {
  // 1. Урилга олох (update хийхээс өмнө authorization шалгах)
  const { data: invitation, error: findError } = await supabase
    .from('invitations')
    .select('id, invited_by, status')
    .eq('id', invitationId)
    .eq('status', 'pending')
    .single();

  if (findError || !invitation) {
    return { success: false as const, error: 'Урилга олдсонгүй эсвэл аль хэдийн ашигласан байна' };
  }

  // 2. Authorization шалгалт: зөвхөн урилга илгээсэн хүн эсвэл super-admin
  const { data: admin } = await supabase
    .from('users')
    .select('role')
    .eq('id', adminId)
    .single();

  if (invitation.invited_by !== adminId && admin?.role !== 'super_admin') {
    return { success: false as const, error: 'Энэ урилгыг цуцлах эрх байхгүй' };
  }

  // 3. Урилга цуцлах
  const { error } = await supabase
    .from('invitations')
    .update({ status: 'revoked' })
    .eq('id', invitationId);

  if (error) {
    return { success: false as const, error: 'Урилга цуцлахад алдаа гарлаа' };
  }

  return { success: true as const };
}

/**
 * Урилгын жагсаалт авах (admin only)
 *
 * @param filters - Шүүлтүүр (status, phone, pagination)
 */
export async function listInvitations(filters: {
  status?: string;
  phone?: string;
  limit?: number;
  offset?: number;
}) {
  let query = supabase
    .from('invitations')
    .select('*', { count: 'exact' })
    .order('created_at', { ascending: false });

  if (filters.status) {
    query = query.eq('status', filters.status);
  }

  if (filters.phone) {
    query = query.eq('phone', filters.phone);
  }

  query = query.range(filters.offset || 0, (filters.offset || 0) + (filters.limit || 50) - 1);

  const { data: invitations, error, count } = await query;

  if (error) {
    console.error('List invitations error:', error);
    return { success: false as const, error: 'Урилгын жагсаалт авахад алдаа гарлаа' };
  }

  return {
    success: true as const,
    invitations: invitations || [],
    total: count || 0,
  };
}

/**
 * Хугацаа дууссан урилгуудыг expire болгох
 *
 * Cron job эсвэл checkInvitation() дуудах үед ажиллана
 */
export async function expireOldInvitations() {
  const { error } = await supabase
    .from('invitations')
    .update({ status: 'expired' })
    .eq('status', 'pending')
    .lt('expires_at', new Date().toISOString());

  if (error) {
    console.error('Expire old invitations error:', error);
  }
}
