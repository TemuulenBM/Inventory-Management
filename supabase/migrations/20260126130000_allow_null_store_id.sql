-- ============================================================================
-- Migration: Allow NULL store_id for super-admin users
-- Date: 2026-01-26
-- Description: Super-admin owner-ууд store-гүй байж болох (store_id = NULL)
-- ============================================================================

-- Одоогоор users.store_id нь NOT NULL constraint байгаа.
-- Super-admin owner үүсгэхийн тулд store_id-г nullable болгох хэрэгтэй.

-- ============================================================================
-- ALTER USERS TABLE
-- ============================================================================

-- 1. Drop existing foreign key constraint
ALTER TABLE public.users
  DROP CONSTRAINT IF EXISTS users_store_id_fkey;

-- 2. Make store_id nullable
ALTER TABLE public.users
  ALTER COLUMN store_id DROP NOT NULL;

-- 3. Re-add foreign key constraint with NULL support
ALTER TABLE public.users
  ADD CONSTRAINT users_store_id_fkey
  FOREIGN KEY (store_id)
  REFERENCES public.stores(id)
  ON DELETE CASCADE;

-- ============================================================================
-- COMMENTS
-- ============================================================================
COMMENT ON COLUMN public.users.store_id IS 'Дэлгүүрийн ID. Super-admin owner-ууд store_id = NULL байж болно.';

-- ============================================================================
-- VERIFICATION
-- ============================================================================
-- Migration амжилттай болсныг шалгах:
-- SELECT column_name, is_nullable FROM information_schema.columns
-- WHERE table_name = 'users' AND column_name = 'store_id';
-- -- is_nullable = 'YES' байх ёстой
