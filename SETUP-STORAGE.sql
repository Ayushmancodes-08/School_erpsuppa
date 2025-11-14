-- ============================================
-- SETUP SUPABASE STORAGE FOR PROFILE IMAGES
-- Run this in Supabase SQL Editor
-- ============================================

-- Note: Storage buckets are usually created via Supabase Dashboard
-- Go to: Storage → Create new bucket → Name: "avatars"
-- Set to Public bucket

-- After creating the bucket, run these policies:

-- Create policy to allow public read access
CREATE POLICY "Public Access"
ON storage.objects FOR SELECT
USING ( bucket_id = 'avatars' );

-- Create policy to allow authenticated users to upload
CREATE POLICY "Authenticated users can upload avatars"
ON storage.objects FOR INSERT
WITH CHECK (
  bucket_id = 'avatars' AND
  auth.role() = 'authenticated'
);

-- Create policy to allow users to update their own avatars
CREATE POLICY "Users can update avatars"
ON storage.objects FOR UPDATE
USING ( bucket_id = 'avatars' );

-- Create policy to allow users to delete avatars
CREATE POLICY "Users can delete avatars"
ON storage.objects FOR DELETE
USING ( bucket_id = 'avatars' );

-- ============================================
-- MANUAL STEPS IN SUPABASE DASHBOARD:
-- ============================================
-- 1. Go to Storage section
-- 2. Click "Create a new bucket"
-- 3. Name: avatars
-- 4. Set as "Public bucket" (check the box)
-- 5. Click "Create bucket"
-- 6. Then run the policies above
-- ============================================
