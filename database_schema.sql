-- ============================================================================
-- Local Retail Control Platform - PostgreSQL Database Schema
-- Backend API Database
-- ============================================================================

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================================================
-- 1. STORES TABLE
-- ============================================================================
CREATE TABLE stores (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    owner_id UUID NOT NULL,
    name VARCHAR(255) NOT NULL,
    location VARCHAR(500),
    timezone VARCHAR(100) DEFAULT 'Asia/Ulaanbaatar',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_stores_owner_id ON stores(owner_id);

COMMENT ON TABLE stores IS 'Дэлгүүрийн мэдээлэл';
COMMENT ON COLUMN stores.timezone IS 'Цагийн бүс (Монголд Asia/Ulaanbaatar)';

-- ============================================================================
-- 2. USERS TABLE (Owner, Manager, Seller roles)
-- ============================================================================
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    store_id UUID NOT NULL REFERENCES stores(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    phone VARCHAR(20),
    role VARCHAR(50) NOT NULL CHECK (role IN ('owner', 'manager', 'seller')),
    password_hash VARCHAR(255),
    last_online TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_users_store_id ON users(store_id);
CREATE INDEX idx_users_phone ON users(phone);
CREATE INDEX idx_users_role ON users(role);

COMMENT ON TABLE users IS 'Хэрэглэгчид (эзэмшигч, менежер, худалдагч)';
COMMENT ON COLUMN users.role IS 'owner (эзэмшигч), manager (менежер), seller (худалдагч)';

-- ============================================================================
-- 3. PRODUCTS TABLE
-- ============================================================================
CREATE TABLE products (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    store_id UUID NOT NULL REFERENCES stores(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    sku VARCHAR(100) NOT NULL,
    unit VARCHAR(50) NOT NULL,
    sell_price DECIMAL(15, 2) NOT NULL CHECK (sell_price >= 0),
    cost_price DECIMAL(15, 2) CHECK (cost_price >= 0),
    low_stock_threshold INTEGER DEFAULT 10 CHECK (low_stock_threshold >= 0),
    note TEXT,
    image_url TEXT,  -- Барааны зургийн URL (Supabase Storage)
    is_deleted BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(store_id, sku)
);

-- Одоо байгаа database-д image_url нэмэх (migration):
-- ALTER TABLE products ADD COLUMN image_url TEXT;

CREATE INDEX idx_products_store_id ON products(store_id);
CREATE INDEX idx_products_sku ON products(sku);
CREATE INDEX idx_products_is_deleted ON products(is_deleted);

COMMENT ON TABLE products IS 'Бараа бүтээгдэхүүн';
COMMENT ON COLUMN products.sku IS 'Stock Keeping Unit - барааны код';
COMMENT ON COLUMN products.unit IS 'Хэмжих нэгж: pcs (ширхэг), kg (кг), liter (литр)';
COMMENT ON COLUMN products.low_stock_threshold IS 'Бага үлдэгдлийн босго';

-- ============================================================================
-- 4. INVENTORY_EVENTS TABLE (Event Sourcing Pattern)
-- Үлдэгдлийн бүх өөрчлөлтийг event хэлбэрээр хадгална
-- ============================================================================
CREATE TABLE inventory_events (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    store_id UUID NOT NULL REFERENCES stores(id) ON DELETE CASCADE,
    product_id UUID NOT NULL REFERENCES products(id) ON DELETE RESTRICT,
    event_type VARCHAR(50) NOT NULL CHECK (event_type IN ('INITIAL', 'SALE', 'ADJUST', 'RETURN')),
    qty_change INTEGER NOT NULL,
    actor_id UUID NOT NULL REFERENCES users(id),
    shift_id UUID REFERENCES shifts(id),
    reason TEXT,
    timestamp TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    synced_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_inventory_events_store_id ON inventory_events(store_id);
CREATE INDEX idx_inventory_events_product_id ON inventory_events(product_id);
CREATE INDEX idx_inventory_events_timestamp ON inventory_events(timestamp DESC);
CREATE INDEX idx_inventory_events_type ON inventory_events(event_type);

COMMENT ON TABLE inventory_events IS 'Үлдэгдлийн өөрчлөлтийн түүх (Event Sourcing)';
COMMENT ON COLUMN inventory_events.event_type IS 'INITIAL (эхлэх), SALE (борлуулалт), ADJUST (засвар), RETURN (буцаалт)';
COMMENT ON COLUMN inventory_events.qty_change IS 'Тоо ширхэгийн өөрчлөлт (+10 нэмэх, -5 хасах)';
COMMENT ON COLUMN inventory_events.reason IS 'Гар засвар хийсэн шалтгаан';

-- ============================================================================
-- 5. SALES TABLE
-- ============================================================================
CREATE TABLE sales (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    store_id UUID NOT NULL REFERENCES stores(id) ON DELETE CASCADE,
    seller_id UUID NOT NULL REFERENCES users(id),
    shift_id UUID REFERENCES shifts(id),
    total_amount DECIMAL(15, 2) NOT NULL CHECK (total_amount >= 0),
    payment_method VARCHAR(50) DEFAULT 'cash' CHECK (payment_method IN ('cash', 'card', 'qr', 'transfer')),
    timestamp TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    synced_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_sales_store_id ON sales(store_id);
CREATE INDEX idx_sales_seller_id ON sales(seller_id);
CREATE INDEX idx_sales_shift_id ON sales(shift_id);
CREATE INDEX idx_sales_timestamp ON sales(timestamp DESC);

COMMENT ON TABLE sales IS 'Борлуулалтын бүртгэл';
COMMENT ON COLUMN sales.payment_method IS 'Төлбөрийн хэлбэр: cash (бэлэн), card (карт), qr (QR), transfer (шилжүүлэг)';

-- ============================================================================
-- 6. SALE_ITEMS TABLE
-- Нэг борлуулалтад олон бараа багтана (One-to-Many)
-- ============================================================================
CREATE TABLE sale_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    sale_id UUID NOT NULL REFERENCES sales(id) ON DELETE CASCADE,
    product_id UUID NOT NULL REFERENCES products(id) ON DELETE RESTRICT,
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    unit_price DECIMAL(15, 2) NOT NULL CHECK (unit_price >= 0),
    subtotal DECIMAL(15, 2) NOT NULL CHECK (subtotal >= 0)
);

CREATE INDEX idx_sale_items_sale_id ON sale_items(sale_id);
CREATE INDEX idx_sale_items_product_id ON sale_items(product_id);

COMMENT ON TABLE sale_items IS 'Борлуулалтын бараанууд';
COMMENT ON COLUMN sale_items.unit_price IS 'Тухайн үеийн нэгж үнэ (price snapshot)';
COMMENT ON COLUMN sale_items.subtotal IS 'Нийт: quantity * unit_price';

-- ============================================================================
-- 7. SHIFTS TABLE
-- Худалдагчийн ээлж
-- ============================================================================
CREATE TABLE shifts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    store_id UUID NOT NULL REFERENCES stores(id) ON DELETE CASCADE,
    seller_id UUID NOT NULL REFERENCES users(id),
    opened_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    closed_at TIMESTAMP WITH TIME ZONE,
    open_balance DECIMAL(15, 2),
    close_balance DECIMAL(15, 2),
    synced_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_shifts_store_id ON shifts(store_id);
CREATE INDEX idx_shifts_seller_id ON shifts(seller_id);
CREATE INDEX idx_shifts_opened_at ON shifts(opened_at DESC);

COMMENT ON TABLE shifts IS 'Худалдагчийн ээлжийн бүртгэл';
COMMENT ON COLUMN shifts.open_balance IS 'Ээлж эхлэхэд байсан мөнгө (optional)';
COMMENT ON COLUMN shifts.close_balance IS 'Ээлж дуусахад байгаа мөнгө';

-- ============================================================================
-- 8. ALERTS TABLE
-- Системийн сэрэмжлүүлэг
-- ============================================================================
CREATE TABLE alerts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    store_id UUID NOT NULL REFERENCES stores(id) ON DELETE CASCADE,
    alert_type VARCHAR(100) NOT NULL CHECK (alert_type IN ('low_stock', 'negative_inventory', 'suspicious_activity', 'system')),
    product_id UUID REFERENCES products(id) ON DELETE SET NULL,
    message TEXT NOT NULL,
    level VARCHAR(50) DEFAULT 'info' CHECK (level IN ('info', 'warning', 'error', 'critical')),
    resolved BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    resolved_at TIMESTAMP WITH TIME ZONE
);

CREATE INDEX idx_alerts_store_id ON alerts(store_id);
CREATE INDEX idx_alerts_type ON alerts(alert_type);
CREATE INDEX idx_alerts_resolved ON alerts(resolved);
CREATE INDEX idx_alerts_created_at ON alerts(created_at DESC);

COMMENT ON TABLE alerts IS 'Систем сэрэмжлүүлэг';
COMMENT ON COLUMN alerts.alert_type IS 'low_stock (бага үлдэгдэл), negative_inventory (сөрөг), suspicious_activity (сэжигтэй үйлдэл)';

-- ============================================================================
-- 9. SYNC_LOG TABLE (Backend sync tracking)
-- Mobile app-аас ирсэн sync operation-ы log
-- ============================================================================
CREATE TABLE sync_log (
    id BIGSERIAL PRIMARY KEY,
    store_id UUID NOT NULL REFERENCES stores(id) ON DELETE CASCADE,
    device_id VARCHAR(255),
    entity_type VARCHAR(100) NOT NULL,
    operation VARCHAR(50) NOT NULL CHECK (operation IN ('create', 'update', 'delete')),
    entity_id UUID,
    payload JSONB NOT NULL,
    sync_timestamp TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    conflict_resolved BOOLEAN DEFAULT FALSE,
    error_message TEXT
);

CREATE INDEX idx_sync_log_store_id ON sync_log(store_id);
CREATE INDEX idx_sync_log_device_id ON sync_log(device_id);
CREATE INDEX idx_sync_log_timestamp ON sync_log(sync_timestamp DESC);
CREATE INDEX idx_sync_log_entity_type ON sync_log(entity_type);

COMMENT ON TABLE sync_log IS 'Mobile sync үйлдлийн log (backend tracking)';
COMMENT ON COLUMN sync_log.payload IS 'JSON өгөгдөл (full entity snapshot)';

-- ============================================================================
-- 10. OTP_TOKENS TABLE (Authentication)
-- Утасны дугаараар нэвтрэх OTP code хадгалах
-- ============================================================================
CREATE TABLE otp_tokens (
    id BIGSERIAL PRIMARY KEY,
    phone VARCHAR(20) NOT NULL,
    otp_code VARCHAR(6) NOT NULL,
    expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
    verified BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_otp_tokens_phone ON otp_tokens(phone);
CREATE INDEX idx_otp_tokens_expires_at ON otp_tokens(expires_at);

COMMENT ON TABLE otp_tokens IS 'OTP нэвтрэх кодын хадгалалт';
COMMENT ON COLUMN otp_tokens.expires_at IS 'OTP code-н хүчинтэй хугацаа (5 минут)';

-- ============================================================================
-- FUNCTIONS & TRIGGERS
-- ============================================================================

-- 1. Auto-update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply to relevant tables
CREATE TRIGGER update_stores_updated_at BEFORE UPDATE ON stores
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_products_updated_at BEFORE UPDATE ON products
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- 2. Calculate current stock from inventory events (Materialized View)
CREATE MATERIALIZED VIEW product_stock_levels AS
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
    MAX(ie.timestamp) AS last_updated
FROM products p
LEFT JOIN inventory_events ie ON p.id = ie.product_id
WHERE p.is_deleted = FALSE
GROUP BY p.id, p.store_id, p.name, p.sku, p.low_stock_threshold;

CREATE UNIQUE INDEX idx_product_stock_levels_product_id ON product_stock_levels(product_id);
CREATE INDEX idx_product_stock_levels_store_id ON product_stock_levels(store_id);
CREATE INDEX idx_product_stock_levels_is_low_stock ON product_stock_levels(is_low_stock);

COMMENT ON MATERIALIZED VIEW product_stock_levels IS 'Бараа бүрийн одоогийн үлдэгдэл (materialized view for performance)';

-- Refresh materialized view function
CREATE OR REPLACE FUNCTION refresh_product_stock_levels()
RETURNS void AS $$
BEGIN
    REFRESH MATERIALIZED VIEW CONCURRENTLY product_stock_levels;
END;
$$ LANGUAGE plpgsql;

-- 3. Auto-create low stock alerts
CREATE OR REPLACE FUNCTION check_low_stock_alert()
RETURNS TRIGGER AS $$
DECLARE
    current_stock INTEGER;
    threshold INTEGER;
BEGIN
    -- Calculate current stock for this product
    SELECT COALESCE(SUM(qty_change), 0) INTO current_stock
    FROM inventory_events
    WHERE product_id = NEW.product_id;

    -- Get threshold
    SELECT low_stock_threshold INTO threshold
    FROM products
    WHERE id = NEW.product_id;

    -- Create alert if stock is low
    IF current_stock <= threshold THEN
        INSERT INTO alerts (store_id, alert_type, product_id, message, level)
        VALUES (
            NEW.store_id,
            'low_stock',
            NEW.product_id,
            'Бага үлдэгдэл: ' || (SELECT name FROM products WHERE id = NEW.product_id),
            'warning'
        )
        ON CONFLICT DO NOTHING;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_check_low_stock AFTER INSERT ON inventory_events
    FOR EACH ROW EXECUTE FUNCTION check_low_stock_alert();

-- 4. Validate sale items subtotal
CREATE OR REPLACE FUNCTION validate_sale_item_subtotal()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.subtotal != (NEW.quantity * NEW.unit_price) THEN
        RAISE EXCEPTION 'Subtotal буруу: % ≠ % × %', NEW.subtotal, NEW.quantity, NEW.unit_price;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_validate_subtotal BEFORE INSERT OR UPDATE ON sale_items
    FOR EACH ROW EXECUTE FUNCTION validate_sale_item_subtotal();

-- ============================================================================
-- INDEXES FOR PERFORMANCE
-- ============================================================================

-- Composite indexes for common queries
CREATE INDEX idx_sales_store_timestamp ON sales(store_id, timestamp DESC);
CREATE INDEX idx_inventory_events_product_timestamp ON inventory_events(product_id, timestamp DESC);
CREATE INDEX idx_shifts_seller_opened ON shifts(seller_id, opened_at DESC);

-- GIN index for JSONB sync_log payload search
CREATE INDEX idx_sync_log_payload_gin ON sync_log USING GIN (payload);

-- ============================================================================
-- SAMPLE DATA SEEDING (for development)
-- ============================================================================

-- Create sample store
INSERT INTO stores (id, owner_id, name, location) VALUES
('550e8400-e29b-41d4-a716-446655440000', '550e8400-e29b-41d4-a716-446655440099', 'Гэр бүлийн хүүхдийн дэлгүүр', 'Улаанбаатар, Баянгол дүүрэг');

-- Create sample owner user
INSERT INTO users (id, store_id, name, phone, role) VALUES
('550e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440000', 'Болд', '+97699887766', 'owner');

-- Create sample seller
INSERT INTO users (id, store_id, name, phone, role) VALUES
('550e8400-e29b-41d4-a716-446655440002', '550e8400-e29b-41d4-a716-446655440000', 'Сарнай', '+97699887755', 'seller');

-- Create sample products
INSERT INTO products (id, store_id, name, sku, unit, sell_price, cost_price, low_stock_threshold) VALUES
('650e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440000', 'Сүү 1л', 'MILK-001', 'pcs', 2500.00, 2000.00, 10),
('650e8400-e29b-41d4-a716-446655440002', '550e8400-e29b-41d4-a716-446655440000', 'Талх', 'BREAD-001', 'pcs', 1800.00, 1400.00, 15),
('650e8400-e29b-41d4-a716-446655440003', '550e8400-e29b-41d4-a716-446655440000', 'Өндөг', 'EGG-001', 'pcs', 500.00, 350.00, 20);

-- Create initial inventory events
INSERT INTO inventory_events (store_id, product_id, event_type, qty_change, actor_id) VALUES
('550e8400-e29b-41d4-a716-446655440000', '650e8400-e29b-41d4-a716-446655440001', 'INITIAL', 50, '550e8400-e29b-41d4-a716-446655440001'),
('550e8400-e29b-41d4-a716-446655440000', '650e8400-e29b-41d4-a716-446655440002', 'INITIAL', 100, '550e8400-e29b-41d4-a716-446655440001'),
('550e8400-e29b-41d4-a716-446655440000', '650e8400-e29b-41d4-a716-446655440003', 'INITIAL', 200, '550e8400-e29b-41d4-a716-446655440001');

-- Refresh materialized view
SELECT refresh_product_stock_levels();

-- ============================================================================
-- USEFUL QUERIES (for API development)
-- ============================================================================

-- Query 1: Get current stock for all products in a store
-- SELECT * FROM product_stock_levels WHERE store_id = '550e8400-e29b-41d4-a716-446655440000';

-- Query 2: Get today's sales total
-- SELECT SUM(total_amount) AS today_sales
-- FROM sales
-- WHERE store_id = '550e8400-e29b-41d4-a716-446655440000'
--   AND timestamp >= CURRENT_DATE;

-- Query 3: Top selling products (today)
-- SELECT
--     p.name,
--     SUM(si.quantity) AS total_quantity,
--     SUM(si.subtotal) AS total_revenue
-- FROM sale_items si
-- JOIN sales s ON si.sale_id = s.id
-- JOIN products p ON si.product_id = p.id
-- WHERE s.store_id = '550e8400-e29b-41d4-a716-446655440000'
--   AND s.timestamp >= CURRENT_DATE
-- GROUP BY p.id, p.name
-- ORDER BY total_quantity DESC
-- LIMIT 5;

-- Query 4: Get unresolved alerts
-- SELECT * FROM alerts
-- WHERE store_id = '550e8400-e29b-41d4-a716-446655440000'
--   AND resolved = FALSE
-- ORDER BY created_at DESC;

-- ============================================================================
-- GRANT PERMISSIONS (adjust as needed for your backend user)
-- ============================================================================

-- GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO retail_backend_user;
-- GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO retail_backend_user;
-- GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA public TO retail_backend_user;

-- ============================================================================
-- END OF SCHEMA
-- ============================================================================
