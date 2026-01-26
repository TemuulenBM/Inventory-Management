-- ============================================================================
-- MULTI-STORE OWNER SUPPORT
-- Нэг owner олон дэлгүүр эзэмших архитектур
-- ============================================================================

-- ============================================================================
-- 1. STORE_MEMBERS JUNCTION TABLE ҮҮСГЭХ
-- Many-to-many user-store холбоос (owner олон дэлгүүр эзэмших)
-- ============================================================================

CREATE TABLE IF NOT EXISTS public.store_members (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  store_id UUID NOT NULL REFERENCES public.stores(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  role VARCHAR(50) NOT NULL CHECK (role IN ('owner', 'manager', 'seller')),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,

  -- Нэг хэрэглэгч нэг дэлгүүрт нэг удаа л харъяалагдах
  UNIQUE(store_id, user_id)
);

-- Indexes хурдан хандалтын төлөө
CREATE INDEX IF NOT EXISTS idx_store_members_store_id ON public.store_members(store_id);
CREATE INDEX IF NOT EXISTS idx_store_members_user_id ON public.store_members(user_id);
CREATE INDEX IF NOT EXISTS idx_store_members_role ON public.store_members(role);

COMMENT ON TABLE public.store_members IS 'Дэлгүүр-хэрэглэгчийн холбоос (many-to-many junction table). Owner олон дэлгүүр эзэмших, seller/manager нэг дэлгүүрт ажиллах.';
COMMENT ON COLUMN public.store_members.role IS 'Тухайн дэлгүүр дахь эрх (owner/manager/seller)';

-- Enable RLS
ALTER TABLE public.store_members ENABLE ROW LEVEL SECURITY;

-- ============================================================================
-- 2. ОДООГИЙН ӨГӨГДӨЛ MIGRATION
-- users -> store_members руу шилжүүлэх (existing single-store data)
-- ============================================================================

-- users.store_id-аас membership үүсгэх
INSERT INTO public.store_members (store_id, user_id, role)
SELECT
  u.store_id,
  u.id,
  u.role
FROM public.users u
WHERE u.store_id IS NOT NULL
  AND u.role != 'super_admin'
ON CONFLICT (store_id, user_id) DO NOTHING;

-- stores.owner_id-аас owner membership үүсгэх (давхардсан эсэхийг шалгах)
INSERT INTO public.store_members (store_id, user_id, role)
SELECT
  s.id AS store_id,
  s.owner_id AS user_id,
  'owner' AS role
FROM public.stores s
WHERE s.owner_id IS NOT NULL
ON CONFLICT (store_id, user_id) DO NOTHING;

-- ============================================================================
-- 3. RLS HELPER FUNCTION - user_has_store_access()
-- Хэрэглэгч тухайн дэлгүүрт хандах эрхтэй эсэхийг шалгах
-- ============================================================================

CREATE OR REPLACE FUNCTION public.user_has_store_access(check_store_id UUID)
RETURNS BOOLEAN
LANGUAGE SQL
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT EXISTS (
    SELECT 1
    FROM public.store_members sm
    WHERE sm.user_id = auth.uid()
      AND sm.store_id = check_store_id
  );
$$;

COMMENT ON FUNCTION public.user_has_store_access(UUID) IS 'Хэрэглэгч тухайн дэлгүүрт хандах эрхтэй эсэхийг store_members table дээр шалгана.';

-- Grant access
GRANT EXECUTE ON FUNCTION public.user_has_store_access(UUID) TO authenticated;

-- ============================================================================
-- 4. RLS POLICIES ШИНЭЧЛЭХ
-- user_store_id() хадгалах (backward compatibility), гэхдээ бүх policies
-- user_has_store_access() ашиглах
-- ============================================================================

-- ----------------------------------------------------------------------------
-- STORES TABLE POLICIES (шинэчлэгдсэн)
-- ----------------------------------------------------------------------------

-- Хэрэглэгч өөрийн дэлгүүрүүдийг харах (store_members-аар)
DROP POLICY IF EXISTS "Users can view their own stores" ON public.stores;
CREATE POLICY "Users can view their own stores"
  ON public.stores FOR SELECT
  USING (
    owner_id = auth.uid() OR  -- Backward compatibility (owner)
    public.user_has_store_access(id)  -- Multi-store дэмжлэг
  );

-- Owners can update their stores
DROP POLICY IF EXISTS "Owners can update their stores" ON public.stores;
CREATE POLICY "Owners can update their stores"
  ON public.stores FOR UPDATE
  USING (
    public.user_has_store_access(id) AND
    (SELECT sm.role FROM public.store_members sm
     WHERE sm.user_id = auth.uid() AND sm.store_id = id) = 'owner'
  );

-- Owners can create stores (onboarding эсвэл дэлгүүр нэмэх)
-- CREATE policy хэвээр (зөвхөн owner_id = auth.uid() шалгах)

-- ----------------------------------------------------------------------------
-- USERS TABLE POLICIES (шинэчлэгдсэн)
-- ----------------------------------------------------------------------------

-- Хэрэглэгч өөрийн дэлгүүрийн гишүүдийг харах
DROP POLICY IF EXISTS "Users can view store members" ON public.users;
CREATE POLICY "Users can view store members"
  ON public.users FOR SELECT
  USING (
    store_id = public.user_store_id() OR  -- Own store (backward compat)
    public.user_has_store_access(store_id)  -- Multi-store
  );

-- Owners/Managers can add users
DROP POLICY IF EXISTS "Owners/Managers can add users" ON public.users;
CREATE POLICY "Owners/Managers can add users"
  ON public.users FOR INSERT
  WITH CHECK (
    public.user_has_store_access(store_id) AND
    (SELECT sm.role FROM public.store_members sm
     WHERE sm.user_id = auth.uid() AND sm.store_id = store_id) IN ('owner', 'manager')
  );

-- Owners/Managers can update users
DROP POLICY IF EXISTS "Owners/Managers can update users" ON public.users;
CREATE POLICY "Owners/Managers can update users"
  ON public.users FOR UPDATE
  USING (
    public.user_has_store_access(store_id) AND
    (SELECT sm.role FROM public.store_members sm
     WHERE sm.user_id = auth.uid() AND sm.store_id = users.store_id) IN ('owner', 'manager')
  );

-- ----------------------------------------------------------------------------
-- PRODUCTS TABLE POLICIES (шинэчлэгдсэн)
-- ----------------------------------------------------------------------------

DROP POLICY IF EXISTS "Users can view store products" ON public.products;
CREATE POLICY "Users can view store products"
  ON public.products FOR SELECT
  USING (public.user_has_store_access(store_id));

DROP POLICY IF EXISTS "Users can create products" ON public.products;
CREATE POLICY "Users can create products"
  ON public.products FOR INSERT
  WITH CHECK (public.user_has_store_access(store_id));

DROP POLICY IF EXISTS "Users can update products" ON public.products;
CREATE POLICY "Users can update products"
  ON public.products FOR UPDATE
  USING (public.user_has_store_access(store_id));

-- ----------------------------------------------------------------------------
-- INVENTORY_EVENTS TABLE POLICIES (шинэчлэгдсэн)
-- ----------------------------------------------------------------------------

DROP POLICY IF EXISTS "Users can view inventory events" ON public.inventory_events;
CREATE POLICY "Users can view inventory events"
  ON public.inventory_events FOR SELECT
  USING (public.user_has_store_access(store_id));

DROP POLICY IF EXISTS "Users can create inventory events" ON public.inventory_events;
CREATE POLICY "Users can create inventory events"
  ON public.inventory_events FOR INSERT
  WITH CHECK (
    public.user_has_store_access(store_id) AND
    actor_id = auth.uid()
  );

-- ----------------------------------------------------------------------------
-- SALES TABLE POLICIES (шинэчлэгдсэн)
-- ----------------------------------------------------------------------------

DROP POLICY IF EXISTS "Users can view sales" ON public.sales;
CREATE POLICY "Users can view sales"
  ON public.sales FOR SELECT
  USING (public.user_has_store_access(store_id));

DROP POLICY IF EXISTS "Sellers can create sales" ON public.sales;
CREATE POLICY "Sellers can create sales"
  ON public.sales FOR INSERT
  WITH CHECK (
    public.user_has_store_access(store_id) AND
    seller_id = auth.uid()
  );

-- ----------------------------------------------------------------------------
-- SALE_ITEMS TABLE POLICIES (шинэчлэгдсэн)
-- ----------------------------------------------------------------------------

DROP POLICY IF EXISTS "Users can view sale items" ON public.sale_items;
CREATE POLICY "Users can view sale items"
  ON public.sale_items FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.sales
      WHERE sales.id = sale_items.sale_id
        AND public.user_has_store_access(sales.store_id)
    )
  );

DROP POLICY IF EXISTS "Users can create sale items" ON public.sale_items;
CREATE POLICY "Users can create sale items"
  ON public.sale_items FOR INSERT
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.sales
      WHERE sales.id = sale_items.sale_id
        AND public.user_has_store_access(sales.store_id)
        AND sales.seller_id = auth.uid()
    )
  );

-- ----------------------------------------------------------------------------
-- SHIFTS TABLE POLICIES (шинэчлэгдсэн)
-- ----------------------------------------------------------------------------

DROP POLICY IF EXISTS "Users can view shifts" ON public.shifts;
CREATE POLICY "Users can view shifts"
  ON public.shifts FOR SELECT
  USING (public.user_has_store_access(store_id));

DROP POLICY IF EXISTS "Sellers can create shifts" ON public.shifts;
CREATE POLICY "Sellers can create shifts"
  ON public.shifts FOR INSERT
  WITH CHECK (
    public.user_has_store_access(store_id) AND
    seller_id = auth.uid()
  );

DROP POLICY IF EXISTS "Sellers can close their shifts" ON public.shifts;
CREATE POLICY "Sellers can close their shifts"
  ON public.shifts FOR UPDATE
  USING (
    public.user_has_store_access(store_id) AND
    seller_id = auth.uid() AND
    closed_at IS NULL
  );

-- ----------------------------------------------------------------------------
-- ALERTS TABLE POLICIES (шинэчлэгдсэн)
-- ----------------------------------------------------------------------------

DROP POLICY IF EXISTS "Users can view alerts" ON public.alerts;
CREATE POLICY "Users can view alerts"
  ON public.alerts FOR SELECT
  USING (public.user_has_store_access(store_id));

DROP POLICY IF EXISTS "System can create alerts" ON public.alerts;
CREATE POLICY "System can create alerts"
  ON public.alerts FOR INSERT
  WITH CHECK (public.user_has_store_access(store_id));

DROP POLICY IF EXISTS "Owners can resolve alerts" ON public.alerts;
CREATE POLICY "Owners can resolve alerts"
  ON public.alerts FOR UPDATE
  USING (
    public.user_has_store_access(store_id) AND
    (SELECT sm.role FROM public.store_members sm
     WHERE sm.user_id = auth.uid() AND sm.store_id = alerts.store_id) = 'owner'
  );

-- ----------------------------------------------------------------------------
-- SYNC_LOG TABLE POLICIES (шинэчлэгдсэн)
-- ----------------------------------------------------------------------------

DROP POLICY IF EXISTS "Users can view sync logs" ON public.sync_log;
CREATE POLICY "Users can view sync logs"
  ON public.sync_log FOR SELECT
  USING (public.user_has_store_access(store_id));

DROP POLICY IF EXISTS "System can create sync logs" ON public.sync_log;
CREATE POLICY "System can create sync logs"
  ON public.sync_log FOR INSERT
  WITH CHECK (public.user_has_store_access(store_id));

-- ----------------------------------------------------------------------------
-- STORE_MEMBERS TABLE POLICIES (шинэ)
-- ----------------------------------------------------------------------------

-- Хэрэглэгч өөрийн store memberships харах
CREATE POLICY "Users can view their memberships"
  ON public.store_members FOR SELECT
  USING (user_id = auth.uid());

-- Owners can add members to their stores
CREATE POLICY "Owners can add store members"
  ON public.store_members FOR INSERT
  WITH CHECK (
    (SELECT sm.role FROM public.store_members sm
     WHERE sm.user_id = auth.uid() AND sm.store_id = store_id) = 'owner'
  );

-- Owners can remove members from their stores
CREATE POLICY "Owners can remove store members"
  ON public.store_members FOR DELETE
  USING (
    (SELECT sm.role FROM public.store_members sm
     WHERE sm.user_id = auth.uid() AND sm.store_id = store_members.store_id) = 'owner'
  );

-- ============================================================================
-- 5. TABLE COMMENTS ШИНЭЧЛЭХ
-- ============================================================================

COMMENT ON COLUMN public.users.store_id IS 'Анхдагч дэлгүүр (primary/selected store). Owner үед сүүлд сонгосон store, seller/manager үед цорын ганц дэлгүүр. NULL байж болно (onboarding үед эсвэл super-admin).';
COMMENT ON COLUMN public.stores.owner_id IS 'Дэлгүүрийг үүсгэсэн анхны owner (creator). store_members table дээр үнэн эрх байна.';

-- ============================================================================
-- Migration бүрэн дууслаа
-- ============================================================================
