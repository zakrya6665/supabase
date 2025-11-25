-- 04_storage_schema.sql
CREATE SCHEMA IF NOT EXISTS storage;

-- buckets
CREATE TABLE IF NOT EXISTS storage.buckets (
  id text PRIMARY KEY,
  name text UNIQUE NOT NULL,
  owner uuid,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  public boolean DEFAULT false,
  metadata jsonb DEFAULT '{}'::jsonb
);

-- objects
CREATE TABLE IF NOT EXISTS storage.objects (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  bucket_id text NOT NULL REFERENCES storage.buckets(id) ON DELETE CASCADE,
  name text NOT NULL,
  owner uuid,
  metadata jsonb DEFAULT '{}'::jsonb,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  version text,
  path_tokens text[]
);

-- simple helper to normalize path_tokens on insert/update
CREATE OR REPLACE FUNCTION storage.path_tokens_trigger()
RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  NEW.path_tokens := regexp_split_to_array(NEW.name, E'/+');
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_objects_path_tokens ON storage.objects;
CREATE TRIGGER trg_objects_path_tokens
BEFORE INSERT OR UPDATE ON storage.objects
FOR EACH ROW EXECUTE FUNCTION storage.path_tokens_trigger();
