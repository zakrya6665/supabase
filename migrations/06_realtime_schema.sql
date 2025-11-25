-- 06_realtime_schema.sql
CREATE SCHEMA IF NOT EXISTS realtime;

-- minimal: metadata table for replication subscriptions
CREATE TABLE IF NOT EXISTS realtime.replication_events (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  table_name text,
  event jsonb,
  created_at timestamptz DEFAULT now()
);

-- function to push events (realtime service will read directly from WAL in full supabase; this is a lightweight placeholder)
CREATE OR REPLACE FUNCTION realtime.notify_event(tbl text, payload jsonb)
RETURNS void LANGUAGE plpgsql AS $$
BEGIN
  INSERT INTO realtime.replication_events(table_name, event) VALUES (tbl, payload);
END;
$$;
