-- ============================================================================
-- Local Retail Control Platform - Supabase Postgres Schema (initial)
-- NOTE:
--  - Supabase 2026: use gen_random_uuid() from pgcrypto (NOT uuid_generate_v4()).
--  - Table order is important: `shifts` MUST exist before `inventory_events` (FK).
--  - Keep this file schema-only (no sample inserts). Use seed files for data.
-- ============================================================================

-- Extensions
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ============================================================================
-- 1) STORES
-- ============================================================================
CREATE TABLE IF NOT EXISTS public.stores (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  owner_id UUID NOT NULL,
  name VARCHAR(255) NOT NULL,
  location VARCHAR(500),
  timezone VARCHAR(100) DEFAULT 'Asia/Ulaanbaatar',
  created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_stores_owner_id ON public.stores(owner_id);

COMMENT ON TABLE public.stores IS 'Дэлгүүрийн мэдээлэл';
COMMENT ON COLUMN public.stores.timezone IS 'Цагийн бүс (Монголд Asia/Ulaanbaatar)';

-- ============================================================================
-- 2) USERS (Owner, Manager, Seller roles)
-- ============================================================================
CREATE TABLE IF NOT EXISTS public.users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  store_id UUID NOT NULL REFERENCES public.stores(id) ON DELETE CASCADE,
  name VARCHAR(255) NOT NULL,
  phone VARCHAR(20),
  role VARCHAR(50) NOT NULL CHECK (role IN ('owner', 'manager', 'seller')),
  password_hash VARCHAR(255),
  last_online TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_users_store_id ON public.users(store_id);
CREATE INDEX IF NOT EXISTS idx_users_phone ON public.users(phone);
CREATE INDEX IF NOT EXISTS idx_users_role ON public.users(role);

COMMENT ON TABLE public.users IS 'Хэрэглэгчид (эзэмшигч, менежер, худалдагч)';
COMMENT ON COLUMN public.users.role IS 'owner (эзэмшигч), manager (менежер), seller (худалдагч)';

-- ============================================================================
-- 3) SHIFTS (MUST be before inventory_events & sales due to FK references)
-- ============================================================================
CREATE TABLE IF NOT EXISTS public.shifts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  store_id UUID NOT NULL REFERENCES public.stores(id) ON DELETE CASCADE,
  seller_id UUID NOT NULL REFERENCES public.users(id),
  opened_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
  closed_at TIMESTAMPTZ,
  open_balance DECIMAL(15, 2),
  close_balance DECIMAL(15, 2),
  synced_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_shifts_store_id ON public.shifts(store_id);
CREATE INDEX IF NOT EXISTS idx_shifts_seller_id ON public.shifts(seller_id);
CREATE INDEX IF NOT EXISTS idx_shifts_opened_at ON public.shifts(opened_at DESC);
CREATE INDEX IF NOT EXISTS idx_shifts_seller_opened ON public.shifts(seller_id, opened_at DESC);

COMMENT ON TABLE public.shifts IS 'Худалдагчийн ээлжийн бүртгэл';
COMMENT ON COLUMN public.shifts.open_balance IS 'Ээлж эхлэхэд байсан мөнгө (optional)';
COMMENT ON COLUMN public.shifts.close_balance IS 'Ээлж дуусахад байгаа мөнгө';

-- ============================================================================
-- 4) PRODUCTS
-- ============================================================================
CREATE TABLE IF NOT EXISTS public.products (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  store_id UUID NOT NULL REFERENCES public.stores(id) ON DELETE CASCADE,
  name VARCHAR(255) NOT NULL,
  sku VARCHAR(100) NOT NULL,
  unit VARCHAR(50) NOT NULL,
  sell_price DECIMAL(15, 2) NOT NULL CHECK (sell_price >= 0),
  cost_price DECIMAL(15, 2) CHECK (cost_price >= 0),
  low_stock_threshold INTEGER DEFAULT 10 CHECK (low_stock_threshold >= 0),
  note TEXT,
  is_deleted BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
  UNIQUE(store_id, sku)
);

CREATE INDEX IF NOT EXISTS idx_products_store_id ON public.products(store_id);
CREATE INDEX IF NOT EXISTS idx_products_sku ON public.products(sku);
CREATE INDEX IF NOT EXISTS idx_products_is_deleted ON public.products(is_deleted);

COMMENT ON TABLE public.products IS 'Бараа бүтээгдэхүүн';
COMMENT ON COLUMN public.products.sku IS 'Stock Keeping Unit - барааны код';
COMMENT ON COLUMN public.products.unit IS 'Хэмжих нэгж: pcs (ширхэг), kg (кг), liter (литр)';
COMMENT ON COLUMN public.products.low_stock_threshold IS 'Бага үлдэгдлийн босго';

-- ============================================================================
-- 5) SALES
-- ============================================================================
CREATE TABLE IF NOT EXISTS public.sales (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  store_id UUID NOT NULL REFERENCES public.stores(id) ON DELETE CASCADE,
  seller_id UUID NOT NULL REFERENCES public.users(id),
  shift_id UUID REFERENCES public.shifts(id),
  total_amount DECIMAL(15, 2) NOT NULL CHECK (total_amount >= 0),
  payment_method VARCHAR(50) DEFAULT 'cash' CHECK (payment_method IN ('cash', 'card', 'qr', 'transfer')),
  "timestamp" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
  synced_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_sales_store_id ON public.sales(store_id);
CREATE INDEX IF NOT EXISTS idx_sales_seller_id ON public.sales(seller_id);
CREATE INDEX IF NOT EXISTS idx_sales_shift_id ON public.sales(shift_id);
CREATE INDEX IF NOT EXISTS idx_sales_timestamp ON public.sales("timestamp" DESC);
CREATE INDEX IF NOT EXISTS idx_sales_store_timestamp ON public.sales(store_id, "timestamp" DESC);

COMMENT ON TABLE public.sales IS 'Борлуулалтын бүртгэл';
COMMENT ON COLUMN public.sales.payment_method IS 'Төлбөрийн хэлбэр: cash (бэлэн), card (карт), qr (QR), transfer (шилжүүлэг)';

-- ============================================================================
-- 6) SALE_ITEMS
-- ============================================================================
CREATE TABLE IF NOT EXISTS public.sale_items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  sale_id UUID NOT NULL REFERENCES public.sales(id) ON DELETE CASCADE,
  product_id UUID NOT NULL REFERENCES public.products(id) ON DELETE RESTRICT,
  quantity INTEGER NOT NULL CHECK (quantity > 0),
  unit_price DECIMAL(15, 2) NOT NULL CHECK (unit_price >= 0),
  subtotal DECIMAL(15, 2) NOT NULL CHECK (subtotal >= 0)
);

CREATE INDEX IF NOT EXISTS idx_sale_items_sale_id ON public.sale_items(sale_id);
CREATE INDEX IF NOT EXISTS idx_sale_items_product_id ON public.sale_items(product_id);

COMMENT ON TABLE public.sale_items IS 'Борлуулалтын бараанууд';
COMMENT ON COLUMN public.sale_items.unit_price IS 'Тухайн үеийн нэгж үнэ (price snapshot)';
COMMENT ON COLUMN public.sale_items.subtotal IS 'Нийт: quantity * unit_price';

-- ============================================================================
-- 7) INVENTORY_EVENTS (Event Sourcing Pattern)
-- ============================================================================
CREATE TABLE IF NOT EXISTS public.inventory_events (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  store_id UUID NOT NULL REFERENCES public.stores(id) ON DELETE CASCADE,
  product_id UUID NOT NULL REFERENCES public.products(id) ON DELETE RESTRICT,
  event_type VARCHAR(50) NOT NULL CHECK (event_type IN ('INITIAL', 'SALE', 'ADJUST', 'RETURN')),
  qty_change INTEGER NOT NULL,
  actor_id UUID NOT NULL REFERENCES public.users(id),
  shift_id UUID REFERENCES public.shifts(id),
  reason TEXT,
  "timestamp" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
  synced_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_inventory_events_store_id ON public.inventory_events(store_id);
CREATE INDEX IF NOT EXISTS idx_inventory_events_product_id ON public.inventory_events(product_id);
CREATE INDEX IF NOT EXISTS idx_inventory_events_timestamp ON public.inventory_events("timestamp" DESC);
CREATE INDEX IF NOT EXISTS idx_inventory_events_type ON public.inventory_events(event_type);
CREATE INDEX IF NOT EXISTS idx_inventory_events_product_timestamp ON public.inventory_events(product_id, "timestamp" DESC);

COMMENT ON TABLE public.inventory_events IS 'Үлдэгдлийн өөрчлөлтийн түүх (Event Sourcing)';
COMMENT ON COLUMN public.inventory_events.event_type IS 'INITIAL (эхлэх), SALE (борлуулалт), ADJUST (засвар), RETURN (буцаалт)';
COMMENT ON COLUMN public.inventory_events.qty_change IS 'Тоо ширхэгийн өөрчлөлт (+10 нэмэх, -5 хасах)';
COMMENT ON COLUMN public.inventory_events.reason IS 'Гар засвар хийсэн шалтгаан';

-- ============================================================================
-- 8) ALERTS
-- ============================================================================
CREATE TABLE IF NOT EXISTS public.alerts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  store_id UUID NOT NULL REFERENCES public.stores(id) ON DELETE CASCADE,
  alert_type VARCHAR(100) NOT NULL CHECK (alert_type IN ('low_stock', 'negative_inventory', 'suspicious_activity', 'system')),
  product_id UUID REFERENCES public.products(id) ON DELETE SET NULL,
  message TEXT NOT NULL,
  level VARCHAR(50) DEFAULT 'info' CHECK (level IN ('info', 'warning', 'error', 'critical')),
  resolved BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
  resolved_at TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS idx_alerts_store_id ON public.alerts(store_id);
CREATE INDEX IF NOT EXISTS idx_alerts_type ON public.alerts(alert_type);
CREATE INDEX IF NOT EXISTS idx_alerts_resolved ON public.alerts(resolved);
CREATE INDEX IF NOT EXISTS idx_alerts_created_at ON public.alerts(created_at DESC);

COMMENT ON TABLE public.alerts IS 'Систем сэрэмжлүүлэг';
COMMENT ON COLUMN public.alerts.alert_type IS 'low_stock (бага үлдэгдэл), negative_inventory (сөрөг), suspicious_activity (сэжигтэй үйлдэл)';

-- ============================================================================
-- 9) SYNC_LOG (Backend sync tracking)
-- ============================================================================
CREATE TABLE IF NOT EXISTS public.sync_log (
  id BIGSERIAL PRIMARY KEY,
  store_id UUID NOT NULL REFERENCES public.stores(id) ON DELETE CASCADE,
  device_id VARCHAR(255),
  entity_type VARCHAR(100) NOT NULL,
  operation VARCHAR(50) NOT NULL CHECK (operation IN ('create', 'update', 'delete')),
  entity_id UUID,
  payload JSONB NOT NULL,
  sync_timestamp TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
  conflict_resolved BOOLEAN DEFAULT FALSE,
  error_message TEXT
);

CREATE INDEX IF NOT EXISTS idx_sync_log_store_id ON public.sync_log(store_id);
CREATE INDEX IF NOT EXISTS idx_sync_log_device_id ON public.sync_log(device_id);
CREATE INDEX IF NOT EXISTS idx_sync_log_timestamp ON public.sync_log(sync_timestamp DESC);
CREATE INDEX IF NOT EXISTS idx_sync_log_entity_type ON public.sync_log(entity_type);
CREATE INDEX IF NOT EXISTS idx_sync_log_payload_gin ON public.sync_log USING GIN (payload);

COMMENT ON TABLE public.sync_log IS 'Mobile sync үйлдлийн log (backend tracking)';
COMMENT ON COLUMN public.sync_log.payload IS 'JSON өгөгдөл (full entity snapshot)';

-- ============================================================================
-- 10) OTP_TOKENS (Legacy OTP storage; Supabase Auth can replace this)
-- ============================================================================
CREATE TABLE IF NOT EXISTS public.otp_tokens (
  id BIGSERIAL PRIMARY KEY,
  phone VARCHAR(20) NOT NULL,
  otp_code VARCHAR(6) NOT NULL,
  expires_at TIMESTAMPTZ NOT NULL,
  verified BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_otp_tokens_phone ON public.otp_tokens(phone);
CREATE INDEX IF NOT EXISTS idx_otp_tokens_expires_at ON public.otp_tokens(expires_at);

COMMENT ON TABLE public.otp_tokens IS 'OTP нэвтрэх кодын хадгалалт';
COMMENT ON COLUMN public.otp_tokens.expires_at IS 'OTP code-н хүчинтэй хугацаа (5 минут)';

-- ============================================================================
-- FUNCTIONS & TRIGGERS
-- ============================================================================

-- 1) Auto-update updated_at timestamp
CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = CURRENT_TIMESTAMP;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS update_stores_updated_at ON public.stores;
CREATE TRIGGER update_stores_updated_at
BEFORE UPDATE ON public.stores
FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

DROP TRIGGER IF EXISTS update_users_updated_at ON public.users;
CREATE TRIGGER update_users_updated_at
BEFORE UPDATE ON public.users
FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

DROP TRIGGER IF EXISTS update_products_updated_at ON public.products;
CREATE TRIGGER update_products_updated_at
BEFORE UPDATE ON public.products
FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

-- 2) Stock levels materialized view
CREATE MATERIALIZED VIEW IF NOT EXISTS public.product_stock_levels AS
SELECT
  p.id AS product_id,
  p.store_id,
  p.name AS product_name,
  p.sku,
  COALESCE(SUM(ie.qty_change), 0) AS current_stock,
  p.low_stock_threshold,
  CASE
    WHEN COALESCE(SUM(ie.qty_change), 0) <= p.low_stock_threshold THEN TRUE
    ELSE FALSE
  END AS is_low_stock,
  MAX(ie."timestamp") AS last_updated
FROM public.products p
LEFT JOIN public.inventory_events ie ON p.id = ie.product_id
WHERE p.is_deleted = FALSE
GROUP BY p.id, p.store_id, p.name, p.sku, p.low_stock_threshold;

CREATE UNIQUE INDEX IF NOT EXISTS idx_product_stock_levels_product_id
  ON public.product_stock_levels(product_id);
CREATE INDEX IF NOT EXISTS idx_product_stock_levels_store_id
  ON public.product_stock_levels(store_id);
CREATE INDEX IF NOT EXISTS idx_product_stock_levels_is_low_stock
  ON public.product_stock_levels(is_low_stock);

COMMENT ON MATERIALIZED VIEW public.product_stock_levels IS 'Бараа бүрийн одоогийн үлдэгдэл (materialized view for performance)';

-- Refresh materialized view function
CREATE OR REPLACE FUNCTION public.refresh_product_stock_levels()
RETURNS void AS $$
BEGIN
  -- CONCURRENTLY requires a unique index (we created one above).
  REFRESH MATERIALIZED VIEW CONCURRENTLY public.product_stock_levels;
END;
$$ LANGUAGE plpgsql;

-- 3) Auto-create low stock alerts
CREATE OR REPLACE FUNCTION public.check_low_stock_alert()
RETURNS TRIGGER AS $$
DECLARE
  current_stock INTEGER;
  threshold INTEGER;
BEGIN
  SELECT COALESCE(SUM(qty_change), 0)
    INTO current_stock
  FROM public.inventory_events
  WHERE product_id = NEW.product_id;

  SELECT low_stock_threshold
    INTO threshold
  FROM public.products
  WHERE id = NEW.product_id;

  IF current_stock <= threshold THEN
    INSERT INTO public.alerts (store_id, alert_type, product_id, message, level)
    VALUES (
      NEW.store_id,
      'low_stock',
      NEW.product_id,
      'Бага үлдэгдэл: ' || (SELECT name FROM public.products WHERE id = NEW.product_id),
      'warning'
    );
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_check_low_stock ON public.inventory_events;
CREATE TRIGGER trigger_check_low_stock
AFTER INSERT ON public.inventory_events
FOR EACH ROW EXECUTE FUNCTION public.check_low_stock_alert();

-- 4) Validate sale items subtotal
CREATE OR REPLACE FUNCTION public.validate_sale_item_subtotal()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.subtotal != (NEW.quantity * NEW.unit_price) THEN
    RAISE EXCEPTION 'Subtotal буруу: % ≠ % × %', NEW.subtotal, NEW.quantity, NEW.unit_price;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_validate_subtotal ON public.sale_items;
CREATE TRIGGER trigger_validate_subtotal
BEFORE INSERT OR UPDATE ON public.sale_items
FOR EACH ROW EXECUTE FUNCTION public.validate_sale_item_subtotal();

