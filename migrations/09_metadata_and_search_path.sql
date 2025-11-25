-- 09_metadata_and_search_path.sql
-- Ensure database search path includes the schemas used by services
ALTER DATABASE current_database() SET search_path = public, auth, storage, graphql_public, realtime, extensions, supabase_functions;

-- create a lightweight metadata table used by studio/dashboard
CREATE TABLE IF NOT EXISTS public.supabase_meta (
  id serial PRIMARY KEY,
  key text UNIQUE,
  value jsonb,
  created_at timestamptz DEFAULT now()
);
