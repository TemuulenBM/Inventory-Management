-- ============================================================================
-- Migration: Add invitations table for invite-only registration
-- Date: 2026-01-26
-- Description: Урилгаар хязгаарлагдсан бүртгэл - зөвхөн уригдсан хүмүүс owner болж чадна
-- NOTE: Uses gen_random_uuid() from pgcrypto (Supabase standard)
-- ============================================================================

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ============================================================================
-- INVITATIONS TABLE
-- Админ илгээсэн урилгууд
-- ============================================================================
CREATE TABLE IF NOT EXISTS public.invitations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    -- Урилга мэдээлэл
    phone VARCHAR(20) NOT NULL,                    -- Уригдаж буй утасны дугаар (+976XXXXXXXX)
    role VARCHAR(50) NOT NULL DEFAULT 'owner',     -- Урилгын эрх (owner, manager, seller)
    status VARCHAR(50) NOT NULL DEFAULT 'pending', -- pending, used, expired, revoked

    -- Invite metadata
    invited_by UUID REFERENCES users(id) ON DELETE SET NULL, -- Урилга илгээсэн админ/owner ID
    invited_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMP WITH TIME ZONE NOT NULL,  -- Урилга дуусах хугацаа (default: 7 days)

    -- Usage tracking
    used_at TIMESTAMP WITH TIME ZONE,              -- Урилга ашигласан цаг
    used_by UUID REFERENCES users(id) ON DELETE SET NULL, -- Үүссэн user ID

    -- Audit trail
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,

    -- Constraints
    CHECK (role IN ('owner', 'manager', 'seller')),
    CHECK (status IN ('pending', 'used', 'expired', 'revoked'))
);

-- Нэг дугаарт зөвхөн нэг идэвхитэй урилга
CREATE UNIQUE INDEX IF NOT EXISTS idx_invitations_phone_pending
    ON public.invitations(phone)
    WHERE status = 'pending';

-- Performance indexes
CREATE INDEX IF NOT EXISTS idx_invitations_phone ON public.invitations(phone);
CREATE INDEX IF NOT EXISTS idx_invitations_status ON public.invitations(status);
CREATE INDEX IF NOT EXISTS idx_invitations_expires_at ON public.invitations(expires_at);
CREATE INDEX IF NOT EXISTS idx_invitations_invited_by ON public.invitations(invited_by);

-- ============================================================================
-- TRIGGER: updated_at автоматаар шинэчлэх
-- ============================================================================
CREATE TRIGGER update_invitations_updated_at
    BEFORE UPDATE ON public.invitations
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- ============================================================================
-- FUNCTION: Хугацаа дууссан урилгуудыг expire болгох
-- ============================================================================
CREATE OR REPLACE FUNCTION public.expire_old_invitations()
RETURNS void AS $$
BEGIN
    UPDATE public.invitations
    SET
        status = 'expired',
        updated_at = CURRENT_TIMESTAMP
    WHERE status = 'pending'
      AND expires_at < CURRENT_TIMESTAMP;
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- COMMENTS
-- ============================================================================
COMMENT ON TABLE public.invitations IS 'Invite-only registration: урилгаар хязгаарлагдсан бүртгэл. Зөвхөн уригдсан хүмүүс owner болж чадна.';
COMMENT ON COLUMN public.invitations.phone IS 'Уригдаж буй утасны дугаар (+976XXXXXXXX формат)';
COMMENT ON COLUMN public.invitations.role IS 'owner (эзэмшигч), manager (менежер), seller (худалдагч)';
COMMENT ON COLUMN public.invitations.status IS 'pending (хүлээгдэж буй), used (ашигласан), expired (хугацаа дууссан), revoked (цуцалсан)';
COMMENT ON COLUMN public.invitations.invited_by IS 'Урилга илгээсэн админ/owner user ID';
COMMENT ON COLUMN public.invitations.expires_at IS 'Урилга дуусах хугацаа (default: 7 хоног)';
COMMENT ON COLUMN public.invitations.used_by IS 'Урилга ашиглаж үүссэн user ID';

-- ============================================================================
-- VERIFICATION
-- ============================================================================
-- Migration амжилттай болсныг шалгах:
-- SELECT * FROM invitations;
-- \d invitations
