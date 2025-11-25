-- 03_auth_schema.sql
CREATE SCHEMA IF NOT EXISTS auth;

-- users table
CREATE TABLE IF NOT EXISTS auth.users (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  email text,
  phone text,
  encrypted_password text,
  confirmation_sent_at timestamptz,
  confirmed_at timestamptz,
  recovery_sent_at timestamptz,
  email_change text,
  phone_change text,
  raw_user_meta jsonb DEFAULT '{}'::jsonb,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  last_sign_in_at timestamptz
);

-- sessions
CREATE TABLE IF NOT EXISTS auth.sessions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE,
  provider text,
  refresh_token text,
  expires_at timestamptz,
  created_at timestamptz DEFAULT now()
);

-- identities (for OAuth)
CREATE TABLE IF NOT EXISTS auth.identities (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE,
  provider text,
  provider_id text,
  created_at timestamptz DEFAULT now()
);

-- helper: auth.uid() -> uses JWT claim `sub`
CREATE OR REPLACE FUNCTION auth.uid()
RETURNS uuid
LANGUAGE sql
STABLE
AS $$
  SELECT (current_setting('jwt.claims.sub', true))::uuid;
$$;
