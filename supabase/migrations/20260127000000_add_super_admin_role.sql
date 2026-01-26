-- Migration: Add super_admin role
-- Description: Super-admin роль нэмэж, одоо байгаа super-admin user-ийг шинэчлэх
-- Date: 2026-01-27

BEGIN;

-- 1. Хуучин CHECK constraint устгах
ALTER TABLE public.users DROP CONSTRAINT IF EXISTS users_role_check;

-- 2. Шинэ CHECK constraint нэмэх ('super_admin' нэмэгдэнэ)
ALTER TABLE public.users
  ADD CONSTRAINT users_role_check
  CHECK (role IN ('super_admin', 'owner', 'manager', 'seller'));

-- 3. Одоо байгаа super-admin user-ийг шинэчлэх (role = 'owner' → 'super_admin')
UPDATE public.users
SET role = 'super_admin'
WHERE phone = '+97694393494' AND role = 'owner' AND store_id IS NULL;

-- 4. Comment шинэчлэх
COMMENT ON COLUMN public.users.role IS 'super_admin (системийн админ), owner (эзэмшигч), manager (менежер), seller (худалдагч)';

COMMIT;

-- Verification queries (manual execution only)
-- SELECT constraint_name, check_clause
-- FROM information_schema.check_constraints
-- WHERE constraint_name = 'users_role_check';
--
-- SELECT id, phone, name, role, store_id
-- FROM users
-- WHERE role = 'super_admin';
