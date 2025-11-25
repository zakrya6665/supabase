-- 05_storage_functions_and_policies.sql
-- Minimal storage functions (presigned URL & search placeholders)
CREATE OR REPLACE FUNCTION storage.generate_signed_url(bucket_id text, object_name text, expires_in int)
RETURNS text LANGUAGE sql STABLE AS $$
  SELECT '/' || $1 || '/' || $2 || '?expires=' || ($3::text);
$$;

CREATE OR REPLACE FUNCTION storage.search(bucket_id text, prefix text DEFAULT '')
RETURNS TABLE(id uuid, name text, metadata jsonb)
LANGUAGE sql STABLE AS $$
  SELECT id, name, metadata FROM storage.objects
   WHERE bucket_id = bucket_id AND name LIKE prefix || '%';
$$;

-- Policies: allow anon read for public buckets, owner write
ALTER DEFAULT PRIVILEGES IN SCHEMA storage GRANT SELECT ON TABLES TO anon;
GRANT USAGE ON SCHEMA storage TO anon, authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA storage TO authenticated;
GRANT SELECT ON ALL TABLES IN SCHEMA storage TO anon;

-- Row-level policy examples (you can harden later)
-- Enable RLS for storage.objects and storage.buckets
ALTER TABLE storage.objects ENABLE ROW LEVEL SECURITY;
ALTER TABLE storage.buckets ENABLE ROW LEVEL SECURITY;

-- Policy: owners can full control
CREATE POLICY "storage_objects_owner_full_access" ON storage.objects
  USING (owner = auth.uid())
  WITH CHECK (owner = auth.uid());

-- Policy: public buckets - allow select for anon
CREATE POLICY "storage_objects_public_read" ON storage.objects
  USING (
    EXISTS (
      SELECT 1 FROM storage.buckets b WHERE b.id = bucket_id AND b.public = true
    )
  );
