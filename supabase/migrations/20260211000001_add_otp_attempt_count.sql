-- ============================================================================
-- Migration: OTP brute-force хамгаалалт
-- Date: 2026-02-11
-- Асуудал: OTP verify хийхэд оролдлогын тоо хязгаарлагдаагүй (6 оронтоо = 1 сая хослол)
-- Шийдэл: attempt_count нэмж, 3 удаа буруу оруулбал хүчингүй болгох
-- ============================================================================

-- OTP оролдлогын тоо хянах багана нэмэх
ALTER TABLE public.otp_tokens
  ADD COLUMN IF NOT EXISTS attempt_count INTEGER NOT NULL DEFAULT 0;

COMMENT ON COLUMN public.otp_tokens.attempt_count IS 'Буруу OTP оруулсан тоо. 3 удаа буруу бол хүчингүй болно.';
