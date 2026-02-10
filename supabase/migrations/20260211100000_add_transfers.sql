-- ============================================================================
-- Migration: Салбар хоорондын бараа шилжүүлэг
-- Date: 2026-02-11
-- Асуудал: Sunday Plaza → Алтжин Бөмбөгөр бараа шилжүүлэхэд бүртгэл байхгүй
-- Шийдэл: transfers + transfer_items хүснэгтүүд, inventory_events-д TRANSFER_OUT/TRANSFER_IN
-- ============================================================================

-- ============================================================================
-- 1. INVENTORY_EVENTS event_type-д TRANSFER нэмэх
-- ============================================================================

-- Хуучин CHECK constraint устгах
ALTER TABLE public.inventory_events DROP CONSTRAINT IF EXISTS inventory_events_event_type_check;

-- Шинэ CHECK constraint: TRANSFER_OUT, TRANSFER_IN нэмэгдсэн
ALTER TABLE public.inventory_events
  ADD CONSTRAINT inventory_events_event_type_check
  CHECK (event_type IN ('INITIAL', 'SALE', 'ADJUST', 'RETURN', 'TRANSFER_OUT', 'TRANSFER_IN'));

COMMENT ON COLUMN public.inventory_events.event_type IS
  'INITIAL (эхлэх), SALE (борлуулалт), ADJUST (засвар), RETURN (буцаалт), TRANSFER_OUT (шилжүүлсэн), TRANSFER_IN (хүлээн авсан)';

-- ============================================================================
-- 2. TRANSFERS хүснэгт — Шилжүүлгийн үндсэн мэдээлэл
-- ============================================================================

CREATE TABLE IF NOT EXISTS public.transfers (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

  -- Салбарууд
  source_store_id UUID NOT NULL REFERENCES public.stores(id) ON DELETE RESTRICT,
  destination_store_id UUID NOT NULL REFERENCES public.stores(id) ON DELETE RESTRICT,

  -- Хэн эхлүүлсэн
  initiated_by UUID NOT NULL REFERENCES public.users(id),

  -- Статус
  status VARCHAR(20) NOT NULL DEFAULT 'pending'
    CHECK (status IN ('pending', 'completed', 'cancelled')),

  -- Тэмдэглэл
  notes TEXT,

  -- Цаг
  created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
  completed_at TIMESTAMPTZ,

  -- Нэг store дотроо шилжүүлэхгүй
  CHECK (source_store_id != destination_store_id)
);

-- ============================================================================
-- 3. TRANSFER_ITEMS хүснэгт — Шилжүүлж буй бараанууд
-- ============================================================================

CREATE TABLE IF NOT EXISTS public.transfer_items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  transfer_id UUID NOT NULL REFERENCES public.transfers(id) ON DELETE CASCADE,
  product_id UUID NOT NULL REFERENCES public.products(id) ON DELETE RESTRICT,
  quantity INTEGER NOT NULL CHECK (quantity > 0),

  -- Нэг transfer-д нэг бараа давхардахгүй
  UNIQUE (transfer_id, product_id)
);

-- ============================================================================
-- 4. INDEXES
-- ============================================================================

CREATE INDEX IF NOT EXISTS idx_transfers_source_store ON public.transfers(source_store_id);
CREATE INDEX IF NOT EXISTS idx_transfers_destination_store ON public.transfers(destination_store_id);
CREATE INDEX IF NOT EXISTS idx_transfers_initiated_by ON public.transfers(initiated_by);
CREATE INDEX IF NOT EXISTS idx_transfers_status ON public.transfers(status);
CREATE INDEX IF NOT EXISTS idx_transfers_created_at ON public.transfers(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_transfer_items_transfer ON public.transfer_items(transfer_id);
CREATE INDEX IF NOT EXISTS idx_transfer_items_product ON public.transfer_items(product_id);

-- ============================================================================
-- 5. RLS POLICIES
-- ============================================================================

ALTER TABLE public.transfers ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.transfer_items ENABLE ROW LEVEL SECURITY;

-- Owner: өөрийн store-уудтай холбоотой transfer-уудыг харах/удирдах
CREATE POLICY "transfers_owner_access"
  ON public.transfers
  FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM public.stores s
      WHERE s.owner_id = auth.uid()
        AND (s.id = source_store_id OR s.id = destination_store_id)
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.stores s
      WHERE s.owner_id = auth.uid()
        AND s.id = source_store_id
    )
  );

-- Super-admin бүх transfer харах
CREATE POLICY "transfers_super_admin_access"
  ON public.transfers
  FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM public.users
      WHERE id = auth.uid() AND role = 'super_admin'
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.users
      WHERE id = auth.uid() AND role = 'super_admin'
    )
  );

-- Transfer items: transfer-тэй ижил эрх
CREATE POLICY "transfer_items_via_transfer"
  ON public.transfer_items
  FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM public.transfers t
      JOIN public.stores s ON (s.id = t.source_store_id OR s.id = t.destination_store_id)
      WHERE t.id = transfer_id
        AND s.owner_id = auth.uid()
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.transfers t
      JOIN public.stores s ON s.id = t.source_store_id
      WHERE t.id = transfer_id
        AND s.owner_id = auth.uid()
    )
  );

-- Transfer items: super-admin
CREATE POLICY "transfer_items_super_admin"
  ON public.transfer_items
  FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM public.users
      WHERE id = auth.uid() AND role = 'super_admin'
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.users
      WHERE id = auth.uid() AND role = 'super_admin'
    )
  );

-- ============================================================================
-- 6. COMMENTS
-- ============================================================================

COMMENT ON TABLE public.transfers IS 'Салбар хоорондын бараа шилжүүлэг. Sunday Plaza → Алтжин Бөмбөгөр гэх мэт.';
COMMENT ON COLUMN public.transfers.source_store_id IS 'Бараа илгээж буй салбар';
COMMENT ON COLUMN public.transfers.destination_store_id IS 'Бараа хүлээн авч буй салбар';
COMMENT ON COLUMN public.transfers.status IS 'pending (хүлээгдэж буй), completed (дууссан), cancelled (цуцалсан)';
COMMENT ON TABLE public.transfer_items IS 'Шилжүүлгийн бараанууд (тоо ширхэгтэй)';

-- ============================================================================
-- VERIFICATION
-- ============================================================================
-- Шалгах:
-- 1. SELECT * FROM transfers; → Хоосон хүснэгт
-- 2. INSERT INTO inventory_events (..., event_type) VALUES (..., 'TRANSFER_OUT'); → OK
-- 3. INSERT INTO inventory_events (..., event_type) VALUES (..., 'INVALID'); → CHECK fail
