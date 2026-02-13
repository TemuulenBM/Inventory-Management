-- ============================================================================
-- Ээлж хаахад бараа тоолж тулгах (Shift Inventory Count Reconciliation)
-- Худалдагч ээлж хаахдаа бараа тоолж, системийн тоотой тулгана.
-- Зөрүүтэй бол alert автоматаар үүснэ.
-- ============================================================================

-- Ээлж бүрт тоолсон барааны тулгалтын мэдээлэл
CREATE TABLE shift_inventory_counts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    shift_id UUID NOT NULL REFERENCES shifts(id) ON DELETE CASCADE,
    store_id UUID NOT NULL REFERENCES stores(id) ON DELETE CASCADE,
    product_id UUID NOT NULL REFERENCES products(id) ON DELETE RESTRICT,
    -- Бодит тоолсон тоо
    physical_count INTEGER NOT NULL CHECK (physical_count >= 0),
    -- Системийн хүлээгдэж буй тоо (event sourcing-аас тулгах үед авсан)
    system_count INTEGER NOT NULL,
    -- Зөрүү = physical_count - system_count (автомат тооцоо)
    discrepancy INTEGER GENERATED ALWAYS AS (physical_count - system_count) STORED,
    -- Тоолсон хүн
    counted_by UUID NOT NULL REFERENCES users(id),
    -- Тоолсон огноо
    counted_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    -- Тайлбар (яагаад зөрүүтэй байгааг бичих)
    notes TEXT,

    -- Нэг ээлж дээр нэг бараа нэг л удаа тоологдоно
    UNIQUE(shift_id, product_id)
);

-- Хайлтын индексүүд
CREATE INDEX idx_shift_inv_counts_shift_id ON shift_inventory_counts(shift_id);
CREATE INDEX idx_shift_inv_counts_store_id ON shift_inventory_counts(store_id);
CREATE INDEX idx_shift_inv_counts_product_id ON shift_inventory_counts(product_id);
-- Зөрүүтэй мөрүүдийг хурдан олох
CREATE INDEX idx_shift_inv_counts_discrepancy ON shift_inventory_counts(discrepancy)
    WHERE discrepancy != 0;

-- RLS Policy
ALTER TABLE shift_inventory_counts ENABLE ROW LEVEL SECURITY;

-- Дэлгүүрийн гишүүд тоолгын мэдээллийг унших
CREATE POLICY "shift_inv_counts_select"
    ON shift_inventory_counts FOR SELECT
    USING (
        store_id IN (
            SELECT sm.store_id FROM store_members sm WHERE sm.user_id = auth.uid()
        )
        OR EXISTS (SELECT 1 FROM users u WHERE u.id = auth.uid() AND u.role = 'super_admin')
    );

-- Дэлгүүрийн гишүүд тоолгын мэдээлэл бичих
CREATE POLICY "shift_inv_counts_insert"
    ON shift_inventory_counts FOR INSERT
    WITH CHECK (
        store_id IN (
            SELECT sm.store_id FROM store_members sm WHERE sm.user_id = auth.uid()
        )
    );
