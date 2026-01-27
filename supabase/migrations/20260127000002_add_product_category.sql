-- Migration: Барааны ангилал (category) талбар нэмэх
-- Created: 2026-01-27
-- Description: Products table-д category талбар нэмж, барааг ангилал (Хүнс, Ундаа, Гэр ахуй гэх мэт) болгон ялгах боломжтой болгох

-- Category талбар нэмэх
ALTER TABLE public.products
ADD COLUMN category VARCHAR(100);

-- Performance-ийн тулд index үүсгэх
CREATE INDEX idx_products_category
ON public.products(category);

-- Талбарын тайлбар нэмэх
COMMENT ON COLUMN public.products.category
IS 'Барааны ангилал (жишээ нь: Хүнс, Ундаа, Гэр ахуй, Хувцас гэх мэт). Nullable - учир нь одоо байгаа бараанууд category байхгүй байж болно.';
