-- ============================================================================
-- Manual Super-Admin Setup (Production)
-- Date: 2026-01-26
-- Description: Анхны super-admin owner үүсгэх
-- ============================================================================

-- АНХААРАХ: Жинхэнэ админ утасны дугаараа оруулна уу!

BEGIN;

-- Super-admin owner үүсгэх (store_id = NULL)
INSERT INTO users (id, phone, name, role, store_id, password_hash)
VALUES (
  uuid_generate_v4(),
  '+97694393494', -- Temuulen - Super Admin
  'Temuulen (Admin)',
  'owner',
  NULL, -- Store-гүй super-admin
  NULL
)
ON CONFLICT (phone) DO NOTHING;

COMMIT;

-- ============================================================================
-- VERIFICATION
-- ============================================================================

-- Super-admin үүссэн эсэхийг шалгах
SELECT id, phone, name, role, store_id, created_at
FROM users
WHERE phone = '+97694393494' AND role = 'owner' AND store_id IS NULL;

-- Хүлээгдэж буй үр дүн:
-- 1 мөр олдох ёстой, store_id = NULL байх ёстой
