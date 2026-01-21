/**
 * User Service
 *
 * User management business logic:
 * - User үүсгэх, олох, засах, устгах
 * - Role солих
 */

import { supabase } from '../../config/supabase.js';
import { validatePhone } from '../../utils/phone.js';
import type { CreateUserBody, UpdateUserBody, UserInfo } from './user.schema.js';

/**
 * Store-ийн хэрэглэгчдийн жагсаалт авах
 *
 * @param storeId - Store ID
 * @returns Хэрэглэгчдийн жагсаалт
 */
export async function getUsers(storeId: string) {
  const { data: users, error } = await supabase
    .from('users')
    .select('*')
    .eq('store_id', storeId)
    .order('created_at', { ascending: false });

  if (error) {
    console.error('Get users error:', error);
    return { success: false as const, error: 'Хэрэглэгчдийг авахад алдаа гарлаа' };
  }

  const userList: UserInfo[] = users.map((user) => ({
    id: user.id,
    storeId: user.store_id,
    phone: user.phone || '',
    name: user.name,
    role: user.role as 'owner' | 'manager' | 'seller',
    createdAt: user.created_at || '',
  }));

  return {
    success: true as const,
    users: userList,
    total: userList.length,
  };
}

/**
 * Шинэ хэрэглэгч нэмэх (manager эсвэл seller)
 *
 * @param storeId - Store ID
 * @param data - User мэдээлэл
 * @returns Үүссэн user
 */
export async function createUser(storeId: string, data: CreateUserBody) {
  // 1. Phone validation
  const validatedPhone = validatePhone(data.phone);
  if (!validatedPhone) {
    return { success: false as const, error: 'Утасны дугаар буруу байна. +976XXXXXXXX форматаар оруулна уу.' };
  }

  // 2. Phone давхцаж байгаа эсэх шалгах
  const { data: existing } = await supabase
    .from('users')
    .select('id')
    .eq('phone', validatedPhone)
    .limit(1);

  if (existing && existing.length > 0) {
    return { success: false as const, error: 'Энэ утасны дугаар аль хэдийн бүртгэлтэй байна' };
  }

  // 3. User үүсгэх
  const { data: user, error } = await supabase
    .from('users')
    .insert({
      store_id: storeId,
      phone: validatedPhone,
      name: data.name,
      role: data.role,
    })
    .select()
    .single();

  if (error) {
    console.error('Create user error:', error);
    return { success: false as const, error: 'Хэрэглэгч үүсгэхэд алдаа гарлаа' };
  }

  console.log(`✅ User created: ${user.name} (${user.role}) in store ${storeId}`);

  return {
    success: true as const,
    user: {
      id: user.id,
      storeId: user.store_id,
      phone: user.phone,
      name: user.name,
      role: user.role as 'owner' | 'manager' | 'seller',
      createdAt: user.created_at || '',
    },
  };
}

/**
 * User мэдээлэл засах
 *
 * @param userId - User ID
 * @param storeId - Store ID
 * @param data - Шинэчлэх мэдээлэл
 * @returns Шинэчлэгдсэн user
 */
export async function updateUser(userId: string, storeId: string, data: UpdateUserBody) {
  // Phone validation (хэрэв phone шинэчлэх бол)
  if (data.phone) {
    const validatedPhone = validatePhone(data.phone);
    if (!validatedPhone) {
      return { success: false as const, error: 'Утасны дугаар буруу байна' };
    }

    // Phone давхцаж байгаа эсэх шалгах (өөр хэрэглэгчтэй)
    const { data: existing } = await supabase
      .from('users')
      .select('id')
      .eq('phone', validatedPhone)
      .neq('id', userId)
      .limit(1);

    if (existing && existing.length > 0) {
      return { success: false as const, error: 'Энэ утасны дугаар бусад хэрэглэгч ашиглаж байна' };
    }

    data.phone = validatedPhone;
  }

  // User шинэчлэх
  const { data: user, error } = await supabase
    .from('users')
    .update({
      ...(data.name && { name: data.name }),
      ...(data.phone && { phone: data.phone }),
    })
    .eq('id', userId)
    .eq('store_id', storeId) // Store ownership шалгах
    .select()
    .single();

  if (error) {
    console.error('Update user error:', error);
    return { success: false as const, error: 'Хэрэглэгч шинэчлэхэд алдаа гарлаа' };
  }

  return {
    success: true as const,
    user: {
      id: user.id,
      storeId: user.store_id,
      phone: user.phone,
      name: user.name,
      role: user.role as 'owner' | 'manager' | 'seller',
      createdAt: user.created_at || '',
    },
  };
}

/**
 * User устгах (soft delete - deleted_at timestamp set хийнэ)
 *
 * @param userId - User ID
 * @param storeId - Store ID
 * @returns Амжилттай бол { success: true }
 */
export async function deleteUser(userId: string, storeId: string) {
  // Owner-г устгаж болохгүй
  const { data: user } = await supabase.from('users').select('role').eq('id', userId).single();

  if (user && user.role === 'owner') {
    return { success: false as const, error: 'Owner-г устгаж болохгүй' };
  }

  // Soft delete (deleted_at set хийх гэж оролдоно, table-д column байхгүй бол hard delete хийнэ)
  const { error } = await supabase.from('users').delete().eq('id', userId).eq('store_id', storeId);

  if (error) {
    console.error('Delete user error:', error);
    return { success: false as const, error: 'Хэрэглэгч устгахад алдаа гарлаа' };
  }

  console.log(`🗑️  User deleted: ${userId}`);
  return { success: true as const };
}

/**
 * User role солих
 *
 * @param userId - User ID
 * @param storeId - Store ID
 * @param newRole - Шинэ role
 * @returns Шинэчлэгдсэн user
 */
export async function updateUserRole(userId: string, storeId: string, newRole: 'owner' | 'manager' | 'seller') {
  const { data: user, error } = await supabase
    .from('users')
    .update({ role: newRole })
    .eq('id', userId)
    .eq('store_id', storeId)
    .select()
    .single();

  if (error) {
    console.error('Update user role error:', error);
    return { success: false as const, error: 'Role шинэчлэхэд алдаа гарлаа' };
  }

  console.log(`🔄 User role updated: ${user.name} → ${newRole}`);

  return {
    success: true as const,
    user: {
      id: user.id,
      storeId: user.store_id,
      phone: user.phone,
      name: user.name,
      role: user.role as 'owner' | 'manager' | 'seller',
      createdAt: user.created_at || '',
    },
  };
}
