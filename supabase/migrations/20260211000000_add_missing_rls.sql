-- ============================================================================
-- Migration: otp_tokens болон invitations хүснэгтүүдэд RLS дүрэм нэмэх
-- Date: 2026-02-11
-- Асуудал: Эдгээр хүснэгтүүдэд RLS идэвхжүүлээгүй тул аль ч нэвтэрсэн
--          хэрэглэгч бусдын OTP код, урилгуудыг унших боломжтой байсан
-- ============================================================================

-- ============================================================================
-- 1. OTP_TOKENS - Зөвхөн service_role (backend) хандах эрхтэй
-- Хэрэглэгч шууд otp_tokens уншиж/бичиж чадахгүй (backend-ээр дамжуулна)
-- ============================================================================

ALTER TABLE IF EXISTS public.otp_tokens ENABLE ROW LEVEL SECURITY;

-- Бүх хандалтыг хориглох (service_role RLS-г алгасдаг тул backend ажиллана)
-- Ямар ч authenticated user шууд хандаж чадахгүй
CREATE POLICY "otp_tokens_no_direct_access"
  ON public.otp_tokens
  FOR ALL
  USING (false)
  WITH CHECK (false);

-- ============================================================================
-- 2. INVITATIONS - Super-admin/owner бүрэн эрх, бусад хязгаарлагдмал
-- ============================================================================

ALTER TABLE IF EXISTS public.invitations ENABLE ROW LEVEL SECURITY;

-- Super-admin бүх урилга удирдах (CRUD)
CREATE POLICY "invitations_super_admin_all"
  ON public.invitations
  FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM public.users
      WHERE id = auth.uid()
        AND role = 'super_admin'
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.users
      WHERE id = auth.uid()
        AND role = 'super_admin'
    )
  );

-- Owner өөрийн илгээсэн урилгуудыг харах
CREATE POLICY "invitations_owner_view_own"
  ON public.invitations
  FOR SELECT
  USING (invited_by = auth.uid());

-- Owner шинэ урилга илгээх
CREATE POLICY "invitations_owner_create"
  ON public.invitations
  FOR INSERT
  WITH CHECK (invited_by = auth.uid());

-- Owner өөрийн урилгыг цуцлах (revoke)
CREATE POLICY "invitations_owner_update_own"
  ON public.invitations
  FOR UPDATE
  USING (invited_by = auth.uid());

-- ============================================================================
-- VERIFICATION
-- ============================================================================
-- Шалгах:
-- 1. Seller/manager → SELECT * FROM otp_tokens; → 0 мөр (RLS хориглоно)
-- 2. Owner → SELECT * FROM invitations; → Зөвхөн өөрийн илгээсэн
-- 3. Super-admin → SELECT * FROM invitations; → Бүгдийг харна
-- 4. Backend (service_role) → otp_tokens CRUD ажиллана
