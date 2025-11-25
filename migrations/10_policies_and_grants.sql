-- 10_policies_and_grants.sql
-- Grants for schemas and tables to roles
GRANT USAGE ON SCHEMA auth TO anon, authenticated;
GRANT SELECT ON ALL TABLES IN SCHEMA auth TO authenticated;
GRANT SELECT ON ALL TABLES IN SCHEMA auth TO anon;

GRANT USAGE ON SCHEMA graphql_public TO anon, authenticated;
GRANT USAGE ON SCHEMA realtime TO anon, authenticated;
GRANT USAGE ON SCHEMA supabase_functions TO authenticated;

-- Make future tables accessible to appropriate roles
ALTER DEFAULT PRIVILEGES IN SCHEMA auth GRANT SELECT ON TABLES TO authenticated;
ALTER DEFAULT PRIVILEGES IN SCHEMA auth GRANT SELECT ON TABLES TO anon;

-- Basic policy for auth.users - users can see only their row
ALTER TABLE auth.users ENABLE ROW LEVEL SECURITY;
CREATE POLICY "users_is_owner" ON auth.users
  USING (id = auth.uid())
  WITH CHECK (id = auth.uid());

-- allow authenticated role to insert into sessions
GRANT INSERT ON auth.sessions TO authenticated;
