-- ============================================================================
-- stores.owner_id FK constraint нэмэх
-- Асуудал: owner_id UUID NOT NULL боловч REFERENCES байхгүй → orphan data үүсч болно
-- ============================================================================

ALTER TABLE public.stores
  ADD CONSTRAINT fk_stores_owner_id
  FOREIGN KEY (owner_id) REFERENCES public.users(id)
  ON DELETE RESTRICT;

COMMENT ON CONSTRAINT fk_stores_owner_id ON public.stores IS 'Owner устгахын өмнө stores-оос хасах шаардлагатай (referential integrity)';
