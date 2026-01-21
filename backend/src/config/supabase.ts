/**
 * Supabase Client Configuration
 *
 * Type-safe Supabase client singleton-г үүсгэнэ.
 * Database types-г ашиглан бүх query type-safe болгоно.
 */

import 'dotenv/config';
import { createClient } from '@supabase/supabase-js';
import type { Database } from '../types/database.types.js';

// Environment variables шалгах
const supabaseUrl = process.env.SUPABASE_URL;
const supabaseServiceKey = process.env.SUPABASE_SERVICE_KEY; // Backend-д service key ашиглана

if (!supabaseUrl) {
  throw new Error('Missing SUPABASE_URL environment variable');
}

if (!supabaseServiceKey) {
  throw new Error('Missing SUPABASE_SERVICE_KEY environment variable');
}

/**
 * Type-safe Supabase client
 *
 * Backend дээр service role key ашигладаг - энэ нь:
 * - RLS (Row Level Security) bypass хийнэ
 * - Admin эрхтэй
 * - Auth logic backend code дээр бичигдэнэ
 *
 * АНХААРУУЛГА: Service key-г client-side code дээр хэзээ ч ашиглах хэрэггүй!
 */
export const supabase = createClient<Database>(supabaseUrl, supabaseServiceKey, {
  auth: {
    autoRefreshToken: false,
    persistSession: false,
  },
  db: {
    schema: 'public',
  },
});

/**
 * Database tables-ын type exports
 *
 * Хэрэглэх жишээ:
 * ```typescript
 * import type { Store, User, Product } from './config/supabase.js';
 *
 * const store: Store = { ... };
 * ```
 */
export type Tables = Database['public']['Tables'];
export type Store = Tables['stores']['Row'];
export type StoreInsert = Tables['stores']['Insert'];
export type StoreUpdate = Tables['stores']['Update'];

export type User = Tables['users']['Row'];
export type UserInsert = Tables['users']['Insert'];
export type UserUpdate = Tables['users']['Update'];

export type Product = Tables['products']['Row'];
export type ProductInsert = Tables['products']['Insert'];
export type ProductUpdate = Tables['products']['Update'];

export type InventoryEvent = Tables['inventory_events']['Row'];
export type InventoryEventInsert = Tables['inventory_events']['Insert'];
export type InventoryEventUpdate = Tables['inventory_events']['Update'];

export type Sale = Tables['sales']['Row'];
export type SaleInsert = Tables['sales']['Insert'];
export type SaleUpdate = Tables['sales']['Update'];

export type SaleItem = Tables['sale_items']['Row'];
export type SaleItemInsert = Tables['sale_items']['Insert'];
export type SaleItemUpdate = Tables['sale_items']['Update'];

export type Shift = Tables['shifts']['Row'];
export type ShiftInsert = Tables['shifts']['Insert'];
export type ShiftUpdate = Tables['shifts']['Update'];

export type Alert = Tables['alerts']['Row'];
export type AlertInsert = Tables['alerts']['Insert'];
export type AlertUpdate = Tables['alerts']['Update'];

export type OtpToken = Tables['otp_tokens']['Row'];
export type OtpTokenInsert = Tables['otp_tokens']['Insert'];
export type OtpTokenUpdate = Tables['otp_tokens']['Update'];

export type RefreshToken = Tables['refresh_tokens']['Row'];
export type RefreshTokenInsert = Tables['refresh_tokens']['Insert'];
export type RefreshTokenUpdate = Tables['refresh_tokens']['Update'];
