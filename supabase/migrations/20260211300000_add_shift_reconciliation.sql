-- ============================================================================
-- Ээлжийн мөнгөн тулгалт (Cash Reconciliation)
-- ============================================================================
-- Ээлж хаагдах үед:
--   expected_balance = open_balance + бэлэн мөнгөний борлуулалт
--   discrepancy = close_balance - expected_balance
-- Зөрүү > ₮5,000 бол CASH_DISCREPANCY alert автомат үүсгэнэ
-- ============================================================================

-- shifts хүснэгтэд тулгалтын баганууд нэмэх
ALTER TABLE shifts ADD COLUMN expected_balance DECIMAL(15, 2);
ALTER TABLE shifts ADD COLUMN discrepancy DECIMAL(15, 2);

-- alerts хүснэгтэд шинэ alert type-ууд дэмжих
-- (alert_type нь TEXT төрөлтэй, enum биш тул schema өөрчлөлт шаардлагагүй)
-- Шинэ alert type-ууд:
--   'cash_discrepancy'    — Мөнгөн тулгалт зөрүүтэй
--   'excessive_discount'  — Хэт их хөнгөлөлт
--   'high_void_rate'      — Олон борлуулалт цуцлагдсан

-- Индекс: shifts.discrepancy дээр шүүлт хурдасгах
CREATE INDEX idx_shifts_discrepancy ON shifts (discrepancy) WHERE discrepancy IS NOT NULL AND discrepancy != 0;

-- Индекс: alerts.alert_type дээр шүүлт хурдасгах (шинэ type-уудад)
CREATE INDEX IF NOT EXISTS idx_alerts_alert_type ON alerts (alert_type, resolved);
