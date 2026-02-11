-- ============================================================================
-- Super-Admin RLS: Бүрэн засвар
-- Огноо: 2026-02-11
-- Асуудал: stores UPDATE, users INSERT/UPDATE, store_members CRUD,
--          alerts UPDATE дээр super-admin блоклогддог.
--          Учир: super-admin-д store_members хүснэгтэд мөр байхгүй тул
--          role шалгалт бүтэлгүйтдэг.
-- Шийдэл: is_super_admin() helper function + policy бүр дээр OR bypass нэмэх
-- ============================================================================

-- ============================================================================
-- 1. is_super_admin() HELPER FUNCTION
-- Давтагдсан super-admin шалгалтыг нэг газар төвлөрүүлэх
-- STABLE — нэг transaction дотор утга өөрчлөгдөхгүй (кэшлэх боломжтой)
-- SECURITY DEFINER — users хүснэгтэд шууд хандана
-- ============================================================================

CREATE OR REPLACE FUNCTION public.is_super_admin()
RETURNS BOOLEAN
LANGUAGE SQL
SECURITY DEFINER
STABLE
SET search_path = public
AS $$
  SELECT EXISTS (
    SELECT 1 FROM public.users
    WHERE id = auth.uid()
      AND role = 'super_admin'
  );
$$;

COMMENT ON FUNCTION public.is_super_admin() IS 'Одоогийн хэрэглэгч super_admin эсэхийг шалгана. RLS policy-уудад ашиглана.';
GRANT EXECUTE ON FUNCTION public.is_super_admin() TO authenticated;

-- ============================================================================
-- 2. STORES — UPDATE policy
-- Өмнө нь: Зөвхөн store_members → owner role шалгадаг
-- Одоо: Super-admin ямар ч store-г засварлаж болно
-- ============================================================================

DROP POLICY IF EXISTS "Owners can update their stores" ON public.stores;
CREATE POLICY "Owners can update their stores"
  ON public.stores FOR UPDATE
  USING (
    public.is_super_admin()
    OR (
      public.user_has_store_access(id) AND
      (SELECT sm.role FROM public.store_members sm
       WHERE sm.user_id = auth.uid() AND sm.store_id = id) = 'owner'
    )
  );

-- ============================================================================
-- 3. USERS — INSERT policy
-- Өмнө нь: store_members → owner/manager role шалгадаг
-- Одоо: Super-admin ямар ч store-д хэрэглэгч нэмж болно
-- ============================================================================

DROP POLICY IF EXISTS "Owners/Managers can add users" ON public.users;
CREATE POLICY "Owners/Managers can add users"
  ON public.users FOR INSERT
  WITH CHECK (
    public.is_super_admin()
    OR (
      public.user_has_store_access(store_id) AND
      (SELECT sm.role FROM public.store_members sm
       WHERE sm.user_id = auth.uid() AND sm.store_id = store_id) IN ('owner', 'manager')
    )
  );

-- ============================================================================
-- 4. USERS — UPDATE policy
-- Өмнө нь: store_members → owner/manager role шалгадаг
-- Одоо: Super-admin ямар ч хэрэглэгчийг засварлаж болно
-- ============================================================================

DROP POLICY IF EXISTS "Owners/Managers can update users" ON public.users;
CREATE POLICY "Owners/Managers can update users"
  ON public.users FOR UPDATE
  USING (
    public.is_super_admin()
    OR (
      public.user_has_store_access(store_id) AND
      (SELECT sm.role FROM public.store_members sm
       WHERE sm.user_id = auth.uid() AND sm.store_id = users.store_id) IN ('owner', 'manager')
    )
  );

-- ============================================================================
-- 5. STORE_MEMBERS — SELECT policy
-- Өмнө нь: Зөвхөн user_id = auth.uid() (өөрийн membership)
-- Одоо: Super-admin бүх membership харах боломжтой
-- ============================================================================

DROP POLICY IF EXISTS "Users can view their memberships" ON public.store_members;
CREATE POLICY "Users can view their memberships"
  ON public.store_members FOR SELECT
  USING (
    user_id = auth.uid()
    OR public.is_super_admin()
  );

-- ============================================================================
-- 6. STORE_MEMBERS — INSERT policy
-- Өмнө нь: store_members → owner role шалгадаг (super-admin мөр байхгүй)
-- Одоо: Super-admin ямар ч store-д гишүүн нэмж болно
-- ============================================================================

DROP POLICY IF EXISTS "Owners can add store members" ON public.store_members;
CREATE POLICY "Owners can add store members"
  ON public.store_members FOR INSERT
  WITH CHECK (
    public.is_super_admin()
    OR (
      (SELECT sm.role FROM public.store_members sm
       WHERE sm.user_id = auth.uid() AND sm.store_id = store_id) = 'owner'
    )
  );

-- ============================================================================
-- 7. STORE_MEMBERS — DELETE policy
-- Өмнө нь: store_members → owner role шалгадаг
-- Одоо: Super-admin ямар ч гишүүнийг устгаж болно
-- ============================================================================

DROP POLICY IF EXISTS "Owners can remove store members" ON public.store_members;
CREATE POLICY "Owners can remove store members"
  ON public.store_members FOR DELETE
  USING (
    public.is_super_admin()
    OR (
      (SELECT sm.role FROM public.store_members sm
       WHERE sm.user_id = auth.uid() AND sm.store_id = store_members.store_id) = 'owner'
    )
  );

-- ============================================================================
-- 8. ALERTS — UPDATE policy
-- Өмнө нь: store_members → owner role шалгадаг
-- Одоо: Super-admin ямар ч alert-г шийдвэрлэж болно
-- ============================================================================

DROP POLICY IF EXISTS "Owners can resolve alerts" ON public.alerts;
CREATE POLICY "Owners can resolve alerts"
  ON public.alerts FOR UPDATE
  USING (
    public.is_super_admin()
    OR (
      public.user_has_store_access(store_id) AND
      (SELECT sm.role FROM public.store_members sm
       WHERE sm.user_id = auth.uid() AND sm.store_id = alerts.store_id) = 'owner'
    )
  );

-- ============================================================================
-- ШАЛГАЛТ (Verification)
-- ============================================================================
-- Суурь шалгалтууд:
-- 1. Super-admin → SELECT * FROM stores; → Бүгдийг харна ✓ (өмнөх засвараар)
-- 2. Super-admin → UPDATE stores SET name='X' WHERE id='...'; → Ажиллана ✓ (шинэ)
-- 3. Super-admin → SELECT * FROM store_members; → Бүгдийг харна ✓ (шинэ)
-- 4. Super-admin → INSERT INTO store_members (...); → Ажиллана ✓ (шинэ)
-- 5. Super-admin → UPDATE alerts SET resolved=true WHERE id='...'; → Ажиллана ✓ (шинэ)
-- 6. Seller → UPDATE stores; → DENIED (аюулгүй байдал хэвээр) ✓
-- 7. Seller → DELETE FROM store_members; → DENIED ✓
