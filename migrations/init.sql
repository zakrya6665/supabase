-- migrations/init.sql
-- Run as superuser (postgres). This file attempts to create missing schemas and minimal tables.
SET client_min_messages = WARNING;

-- Extensions
CREATE EXTENSION IF NOT EXISTS "pgcrypto";
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Create anon role if missing (minimal)
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'anon') THEN
    CREATE ROLE anon NOINHERIT;
  END IF;
END
$$;

-- Public schema is default

-- Create storage schema and minimal tables
CREATE SCHEMA IF NOT EXISTS storage;

CREATE TABLE IF NOT EXISTS storage.buckets (
  id text PRIMARY KEY,
  name text UNIQUE NOT NULL,
  owner uuid,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  public boolean DEFAULT false
);

CREATE TABLE IF NOT EXISTS storage.objects (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  bucket_id text NOT NULL REFERENCES storage.buckets(id) ON DELETE CASCADE,
  name text NOT NULL,
  owner uuid,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  version text,
  metadata jsonb DEFAULT '{}'::jsonb,
  path_tokens text[]
);

-- Create graphql_public schema placeholder
CREATE SCHEMA IF NOT EXISTS graphql_public;

-- Minimal functions/placeholders used by studio / API
CREATE SCHEMA IF NOT EXISTS extensions;

-- Ensure public search_path usage
ALTER DATABASE current_database() SET search_path = public,storage,graphql_public;

-- Set up a minimal policy-friendly structure for anon (you should harden policies as needed)
GRANT USAGE ON SCHEMA storage TO anon;
GRANT SELECT ON ALL TABLES IN SCHEMA storage TO anon;

-- Make sure future tables are accessible
ALTER DEFAULT PRIVILEGES IN SCHEMA storage GRANT SELECT ON TABLES TO anon;

-- sanity
COMMENT ON SCHEMA storage IS 'Supabase storage schema (created by init migration)';

-- Done
