-- 08_functions_schema.sql
CREATE SCHEMA IF NOT EXISTS supabase_functions;

CREATE TABLE IF NOT EXISTS supabase_functions.invocations (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  function_name text,
  payload jsonb,
  status text,
  created_at timestamptz DEFAULT now()
);

CREATE OR REPLACE FUNCTION supabase_functions.log_invocation(fn text, payload jsonb)
RETURNS void LANGUAGE plpgsql AS $$
BEGIN
  INSERT INTO supabase_functions.invocations(function_name, payload, status) VALUES (fn, payload, 'queued');
END;
$$;
