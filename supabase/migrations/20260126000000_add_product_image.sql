-- ============================================================================
-- Барааны зураг нэмэх (Product Image Support)
-- Products table-д image_url column + Supabase Storage bucket
-- ============================================================================

-- 1. Products table-д image_url column нэмэх
ALTER TABLE products ADD COLUMN IF NOT EXISTS image_url TEXT;
COMMENT ON COLUMN products.image_url IS 'Барааны зургийн URL (Supabase Storage)';

-- 2. Storage bucket үүсгэх
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'product-images',
  'product-images',
  true,
  5242880,  -- 5MB
  ARRAY['image/jpeg', 'image/png', 'image/webp']
)
ON CONFLICT (id) DO NOTHING;

-- 3. Storage RLS policies

-- Хэн ч зураг харах боломжтой (public bucket)
CREATE POLICY "Public can view product images"
  ON storage.objects FOR SELECT
  TO public
  USING (bucket_id = 'product-images');

-- Нэвтэрсэн хэрэглэгч зураг оруулах
CREATE POLICY "Authenticated users can upload product images"
  ON storage.objects FOR INSERT
  TO authenticated
  WITH CHECK (bucket_id = 'product-images');

-- Нэвтэрсэн хэрэглэгч зураг шинэчлэх
CREATE POLICY "Authenticated users can update product images"
  ON storage.objects FOR UPDATE
  TO authenticated
  USING (bucket_id = 'product-images');

-- Нэвтэрсэн хэрэглэгч зураг устгах
CREATE POLICY "Authenticated users can delete product images"
  ON storage.objects FOR DELETE
  TO authenticated
  USING (bucket_id = 'product-images');
