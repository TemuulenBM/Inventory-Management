-- ============================================================================
-- Migration: Add Unique Constraint to Shifts Table
-- Date: 2026-01-29
-- Purpose: Нэг seller нэг store-д зөвхөн 1 идэвхтэй ээлж байх constraint нэмэх
-- ============================================================================

-- STEP 1: Dirty Data Цэвэрлэх
-- Хэрэв олон идэвхтэй ээлж байвал, хамгийн сүүлд нээсэнийг үлдээж бусдыг хаана
WITH duplicates AS (
  SELECT
    id,
    store_id,
    seller_id,
    opened_at,
    ROW_NUMBER() OVER (
      PARTITION BY store_id, seller_id
      ORDER BY opened_at DESC
    ) as rn
  FROM shifts
  WHERE closed_at IS NULL
)
UPDATE shifts
SET closed_at = CURRENT_TIMESTAMP,
    close_balance = NULL,
    synced_at = CURRENT_TIMESTAMP
WHERE id IN (
  SELECT id FROM duplicates WHERE rn > 1
);

-- Log: Хэдэн мөр засварласан
DO $$
DECLARE
  affected_count INTEGER;
BEGIN
  GET DIAGNOSTICS affected_count = ROW_COUNT;
  RAISE NOTICE 'Cleaned up % duplicate active shifts', affected_count;
END $$;

-- STEP 2: Partial UNIQUE Constraint Нэмэх
-- PostgreSQL partial unique index (WHERE closed_at IS NULL)
CREATE UNIQUE INDEX IF NOT EXISTS idx_shifts_active_unique
ON shifts(store_id, seller_id)
WHERE closed_at IS NULL;

-- Index comment
COMMENT ON INDEX idx_shifts_active_unique IS
'Нэг seller нэг store-д зөвхөн 1 идэвхтэй ээлж (closed_at IS NULL). Энэ constraint нь duplicate shift-ийг шинээр үүсэхээс сэргийлнэ.';

-- STEP 3: Verification Query (optional, for manual testing)
-- Дараах query-г ажиллуулж duplicate shifts байхгүй эсэхийг шалгана:
-- SELECT store_id, seller_id, COUNT(*) as active_count
-- FROM shifts
-- WHERE closed_at IS NULL
-- GROUP BY store_id, seller_id
-- HAVING COUNT(*) > 1;

-- ============================================================================
-- ROLLBACK SCRIPT (emergency only)
-- ============================================================================
-- DROP INDEX IF EXISTS idx_shifts_active_unique;
