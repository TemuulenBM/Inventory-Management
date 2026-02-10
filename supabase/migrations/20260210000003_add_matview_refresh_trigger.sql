-- ============================================================================
-- Materialized view auto-refresh trigger
-- Асуудал: product_stock_levels materialized view гараар refresh хийх шаардлагатай
-- Шийдэл: inventory_events INSERT бүрт auto-refresh хийх trigger
-- FOR EACH STATEMENT ашиглаж batch insert үед нэг л удаа refresh хийнэ
-- ============================================================================

-- Refresh функц
CREATE OR REPLACE FUNCTION public.trigger_refresh_stock_levels()
RETURNS TRIGGER AS $$
BEGIN
  REFRESH MATERIALIZED VIEW CONCURRENTLY public.product_stock_levels;
  RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- Trigger: inventory_events INSERT-ийн дараа ажиллана
CREATE TRIGGER trigger_refresh_stock_after_inventory
  AFTER INSERT ON public.inventory_events
  FOR EACH STATEMENT
  EXECUTE FUNCTION public.trigger_refresh_stock_levels();

COMMENT ON FUNCTION public.trigger_refresh_stock_levels IS 'product_stock_levels materialized view-г auto-refresh хийнэ (FOR EACH STATEMENT — batch insert-д хурдан)';
