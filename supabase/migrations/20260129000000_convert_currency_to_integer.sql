-- Үнийн бүх талбаруудыг DECIMAL → INTEGER өөрчлөх
-- Монгол төгрөг: ₮2,500 = 2500 (бүтэн тоо, таслалгүй)
-- Created: 2026-01-29
-- Description: Convert all currency fields from DECIMAL(15,2) to INTEGER for Mongolian Tugrug

BEGIN;

-- 1. Products table
-- АНХААР: Монгол төгрөг бүтэн тоо, × 100 хэрэггүй!
ALTER TABLE public.products
  ALTER COLUMN sell_price TYPE INTEGER USING ROUND(sell_price)::INTEGER,
  ALTER COLUMN cost_price TYPE INTEGER USING ROUND(COALESCE(cost_price, 0))::INTEGER;

-- 2. Sales table
ALTER TABLE public.sales
  ALTER COLUMN total_amount TYPE INTEGER USING ROUND(total_amount)::INTEGER;

-- 3. Sale items table
ALTER TABLE public.sale_items
  ALTER COLUMN unit_price TYPE INTEGER USING ROUND(unit_price)::INTEGER,
  ALTER COLUMN subtotal TYPE INTEGER USING ROUND(subtotal)::INTEGER;

-- 4. Shifts table
ALTER TABLE public.shifts
  ALTER COLUMN open_balance TYPE INTEGER USING ROUND(COALESCE(open_balance, 0))::INTEGER,
  ALTER COLUMN close_balance TYPE INTEGER USING ROUND(COALESCE(close_balance, 0))::INTEGER;

-- 5. Update subtotal validation trigger
-- Өмнөх trigger устгаад, шинэ INTEGER version үүсгэх
DROP TRIGGER IF EXISTS trigger_validate_subtotal ON public.sale_items;

CREATE OR REPLACE FUNCTION public.validate_sale_item_subtotal()
RETURNS TRIGGER AS $$
BEGIN
    -- Subtotal = quantity × unit_price (INTEGER arithmetic)
    IF NEW.subtotal != (NEW.quantity * NEW.unit_price) THEN
        RAISE EXCEPTION 'Subtotal буруу: % ≠ % × %', NEW.subtotal, NEW.quantity, NEW.unit_price;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_validate_subtotal
BEFORE INSERT OR UPDATE ON public.sale_items
FOR EACH ROW
EXECUTE FUNCTION public.validate_sale_item_subtotal();

-- 6. Update column comments
COMMENT ON COLUMN public.products.sell_price IS 'Борлуулалтын үнэ (төгрөг, бүтэн тоо: ₮2,500 = 2500)';
COMMENT ON COLUMN public.products.cost_price IS 'Өртөг үнэ (төгрөг, бүтэн тоо)';
COMMENT ON COLUMN public.sales.total_amount IS 'Нийт дүн (төгрөг, бүтэн тоо)';
COMMENT ON COLUMN public.sale_items.unit_price IS 'Нэгжийн үнэ (төгрөг, бүтэн тоо)';
COMMENT ON COLUMN public.sale_items.subtotal IS 'Дэд нийлбэр (төгрөг, бүтэн тоо)';
COMMENT ON COLUMN public.shifts.open_balance IS 'Эхлэх мөнгө (төгрөг, бүтэн тоо)';
COMMENT ON COLUMN public.shifts.close_balance IS 'Хаах мөнгө (төгрөг, бүтэн тоо)';

COMMIT;

-- ============================================================================
-- VERIFICATION QUERIES
-- ============================================================================

-- Дараах query-ууд ашиглан type өөрчлөлтийг шалгах:
--
-- SELECT column_name, data_type
-- FROM information_schema.columns
-- WHERE table_name = 'products'
--   AND column_name IN ('sell_price', 'cost_price');
--
-- Expected result: data_type = 'integer'
