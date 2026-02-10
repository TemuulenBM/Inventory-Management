-- ============================================================================
-- RLS Policies: Super-admin bypass засвар
-- Асуудал: user_has_store_access() → super-admin (store_id = NULL) юу ч харж чадахгүй
-- Шийдэл: user_has_store_access() функцэд super-admin шалгалт нэмэх
-- ============================================================================

-- 1. user_has_store_access() функцыг super-admin bypass-тай болгох
CREATE OR REPLACE FUNCTION public.user_has_store_access(check_store_id UUID)
RETURNS BOOLEAN
LANGUAGE SQL
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT EXISTS (
    SELECT 1 FROM public.store_members sm
    WHERE sm.user_id = auth.uid()
      AND sm.store_id = check_store_id
  )
  OR EXISTS (
    SELECT 1 FROM public.users u
    WHERE u.id = auth.uid()
      AND u.role = 'super_admin'
  );
$$;

-- 2. Users table SELECT policy: super-admin өөрийгөө харах боломж нэмэх
DROP POLICY IF EXISTS "Users can view store members" ON public.users;
CREATE POLICY "Users can view store members"
  ON public.users FOR SELECT
  USING (
    id = auth.uid() OR
    public.user_has_store_access(store_id)
  );
