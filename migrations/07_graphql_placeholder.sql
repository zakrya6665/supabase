-- 07_graphql_placeholder.sql
CREATE SCHEMA IF NOT EXISTS graphql_public;

-- placeholder table exposing basic metadata (Supabase's real pg_graphql is more involved)
CREATE TABLE IF NOT EXISTS graphql_public.schemas (
  id serial PRIMARY KEY,
  name text,
  created_at timestamptz DEFAULT now()
);
