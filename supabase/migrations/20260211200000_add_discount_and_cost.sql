-- ============================================================================
-- Фаза 3: Хөнгөлөлт + Ашиг/Орлогын Тооцоо
-- sale_items дээр original_price, discount_amount, cost_price нэмэх
-- sales дээр total_discount нэмэх
-- stores дээр хөнгөлөлтийн хязгаар тохиргоо нэмэх
-- ============================================================================

-- 1. sale_items-д шинэ баганууд нэмэх
ALTER TABLE sale_items ADD COLUMN original_price INTEGER NOT NULL DEFAULT 0;
ALTER TABLE sale_items ADD COLUMN discount_amount INTEGER NOT NULL DEFAULT 0;
ALTER TABLE sale_items ADD COLUMN cost_price INTEGER DEFAULT 0;

-- 2. Одоо байгаа бичлэгүүдэд original_price = unit_price гэж тавих
-- (хуучин бичлэгт хөнгөлөлт байхгүй)
UPDATE sale_items SET original_price = unit_price WHERE original_price = 0 AND unit_price > 0;

-- 3. sales-д нийт хөнгөлөлт нэмэх
ALTER TABLE sales ADD COLUMN total_discount INTEGER NOT NULL DEFAULT 0;

-- 4. stores-д хөнгөлөлтийн хязгаар тохиргоо нэмэх
ALTER TABLE stores ADD COLUMN max_seller_discount_pct INTEGER NOT NULL DEFAULT 10;
ALTER TABLE stores ADD COLUMN max_manager_discount_pct INTEGER NOT NULL DEFAULT 20;

-- Тайлбарууд
COMMENT ON COLUMN sale_items.original_price IS 'Анхны зарах үнэ (хөнгөлөлтийн өмнөх)';
COMMENT ON COLUMN sale_items.discount_amount IS 'Хөнгөлөлтийн дүн (₮)';
COMMENT ON COLUMN sale_items.cost_price IS 'Бүтээгдэхүүний өртөг (ашиг тооцоход)';
COMMENT ON COLUMN sales.total_discount IS 'Нийт хөнгөлөлтийн дүн (бүх items-ийн discount нийлбэр)';
COMMENT ON COLUMN stores.max_seller_discount_pct IS 'Худалдагчийн хамгийн их хөнгөлөлтийн хувь (default 10%)';
COMMENT ON COLUMN stores.max_manager_discount_pct IS 'Менежерийн хамгийн их хөнгөлөлтийн хувь (default 20%)';
