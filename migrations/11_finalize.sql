-- 11_finalize.sql
-- Minimal sanity checks and comments
COMMENT ON SCHEMA storage IS 'Storage schema for Supabase (minimal migration pack)';
COMMENT ON SCHEMA auth IS 'Auth schema for Supabase (minimal migration pack)';

-- Add sample bucket to avoid empty-state bugs (optional)
INSERT INTO storage.buckets (id, name, owner, public)
SELECT 'public-bucket', 'public', NULL, true
WHERE NOT EXISTS (SELECT 1 FROM storage.buckets WHERE id = 'public-bucket');
