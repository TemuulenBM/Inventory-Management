-- ============================================================================
-- ROW LEVEL SECURITY (RLS) POLICIES
-- Multi-tenant data isolation - Хэрэглэгч зөвхөн өөрийн дэлгүүрийн өгөгдөлд хандана
-- ============================================================================

-- Enable RLS on all tables
ALTER TABLE stores ENABLE ROW LEVEL SECURITY;
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE products ENABLE ROW LEVEL SECURITY;
ALTER TABLE inventory_events ENABLE ROW LEVEL SECURITY;
ALTER TABLE sales ENABLE ROW LEVEL SECURITY;
ALTER TABLE sale_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE shifts ENABLE ROW LEVEL SECURITY;
ALTER TABLE alerts ENABLE ROW LEVEL SECURITY;
ALTER TABLE sync_log ENABLE ROW LEVEL SECURITY;

-- ============================================================================
-- HELPER FUNCTION: Get user's store_id from users table
-- NOTE: Can't create functions in `auth` schema from migrations (permission denied).
--       Keep helper in `public` schema and reference it from policies.
-- ============================================================================
CREATE OR REPLACE FUNCTION public.user_store_id()
RETURNS UUID
LANGUAGE SQL
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT store_id
  FROM public.users
  WHERE id = auth.uid()
  LIMIT 1;
$$;

-- ============================================================================
-- STORES TABLE POLICIES
-- ============================================================================

-- Owners can read their own stores
CREATE POLICY "Users can view their own stores"
  ON stores FOR SELECT
  USING (owner_id = auth.uid());

-- Owners can update their own stores
CREATE POLICY "Owners can update their stores"
  ON stores FOR UPDATE
  USING (owner_id = auth.uid());

-- Owners can insert stores (for onboarding)
CREATE POLICY "Users can create stores"
  ON stores FOR INSERT
  WITH CHECK (owner_id = auth.uid());

-- ============================================================================
-- USERS TABLE POLICIES
-- ============================================================================

-- Users can view users in their store
CREATE POLICY "Users can view store members"
  ON users FOR SELECT
  USING (store_id = public.user_store_id());

-- Owners and managers can insert users (adding sellers)
CREATE POLICY "Owners/Managers can add users"
  ON users FOR INSERT
  WITH CHECK (
    store_id = public.user_store_id() AND
    (SELECT role FROM users WHERE id = auth.uid()) IN ('owner', 'manager')
  );

-- Owners and managers can update users
CREATE POLICY "Owners/Managers can update users"
  ON users FOR UPDATE
  USING (
    store_id = public.user_store_id() AND
    (SELECT role FROM users WHERE id = auth.uid()) IN ('owner', 'manager')
  );

-- ============================================================================
-- PRODUCTS TABLE POLICIES
-- ============================================================================

-- Users can view products in their store
CREATE POLICY "Users can view store products"
  ON products FOR SELECT
  USING (store_id = public.user_store_id());

-- Authenticated users can insert products
CREATE POLICY "Users can create products"
  ON products FOR INSERT
  WITH CHECK (store_id = public.user_store_id());

-- Users can update products in their store
CREATE POLICY "Users can update products"
  ON products FOR UPDATE
  USING (store_id = public.user_store_id());

-- ============================================================================
-- INVENTORY_EVENTS TABLE POLICIES
-- ============================================================================

-- Users can view inventory events in their store
CREATE POLICY "Users can view inventory events"
  ON inventory_events FOR SELECT
  USING (store_id = public.user_store_id());

-- Users can insert inventory events
CREATE POLICY "Users can create inventory events"
  ON inventory_events FOR INSERT
  WITH CHECK (
    store_id = public.user_store_id() AND
    actor_id = auth.uid()
  );

-- ============================================================================
-- SALES TABLE POLICIES
-- ============================================================================

-- Users can view sales in their store
CREATE POLICY "Users can view sales"
  ON sales FOR SELECT
  USING (store_id = public.user_store_id());

-- Sellers can create sales
CREATE POLICY "Sellers can create sales"
  ON sales FOR INSERT
  WITH CHECK (
    store_id = public.user_store_id() AND
    seller_id = auth.uid()
  );

-- ============================================================================
-- SALE_ITEMS TABLE POLICIES
-- ============================================================================

-- Users can view sale items in their store
CREATE POLICY "Users can view sale items"
  ON sale_items FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM sales
      WHERE sales.id = sale_items.sale_id
      AND sales.store_id = public.user_store_id()
    )
  );

-- Users can insert sale items (via sales)
CREATE POLICY "Users can create sale items"
  ON sale_items FOR INSERT
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM sales
      WHERE sales.id = sale_items.sale_id
      AND sales.store_id = public.user_store_id()
      AND sales.seller_id = auth.uid()
    )
  );

-- ============================================================================
-- SHIFTS TABLE POLICIES
-- ============================================================================

-- Users can view shifts in their store
CREATE POLICY "Users can view shifts"
  ON shifts FOR SELECT
  USING (store_id = public.user_store_id());

-- Sellers can create their own shifts
CREATE POLICY "Sellers can create shifts"
  ON shifts FOR INSERT
  WITH CHECK (
    store_id = public.user_store_id() AND
    seller_id = auth.uid()
  );

-- Sellers can update their own open shifts
CREATE POLICY "Sellers can close their shifts"
  ON shifts FOR UPDATE
  USING (
    store_id = public.user_store_id() AND
    seller_id = auth.uid() AND
    closed_at IS NULL
  );

-- ============================================================================
-- ALERTS TABLE POLICIES
-- ============================================================================

-- Users can view alerts in their store
CREATE POLICY "Users can view alerts"
  ON alerts FOR SELECT
  USING (store_id = public.user_store_id());

-- System can insert alerts (via triggers or Edge Functions)
CREATE POLICY "System can create alerts"
  ON alerts FOR INSERT
  WITH CHECK (store_id = public.user_store_id());

-- Owners can mark alerts as resolved
CREATE POLICY "Owners can resolve alerts"
  ON alerts FOR UPDATE
  USING (
    store_id = public.user_store_id() AND
    (SELECT role FROM users WHERE id = auth.uid()) = 'owner'
  );

-- ============================================================================
-- SYNC_LOG TABLE POLICIES
-- ============================================================================

-- Users can view sync logs in their store
CREATE POLICY "Users can view sync logs"
  ON sync_log FOR SELECT
  USING (store_id = public.user_store_id());

-- Edge Functions can insert sync logs
CREATE POLICY "System can create sync logs"
  ON sync_log FOR INSERT
  WITH CHECK (store_id = public.user_store_id());

-- ============================================================================
-- GRANT ACCESS TO public.user_store_id() function
-- ============================================================================
GRANT EXECUTE ON FUNCTION public.user_store_id() TO authenticated;

