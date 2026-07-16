
CREATE TABLE public.kv_store (
  key TEXT PRIMARY KEY,
  value JSONB NOT NULL,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_by UUID
);
GRANT SELECT, INSERT, UPDATE, DELETE ON public.kv_store TO authenticated;
GRANT ALL ON public.kv_store TO service_role;
ALTER TABLE public.kv_store ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Authenticated users can read shared data" ON public.kv_store FOR SELECT TO authenticated USING (true);
CREATE POLICY "Authenticated users can insert shared data" ON public.kv_store FOR INSERT TO authenticated WITH CHECK (true);
CREATE POLICY "Authenticated users can update shared data" ON public.kv_store FOR UPDATE TO authenticated USING (true) WITH CHECK (true);
CREATE POLICY "Authenticated users can delete shared data" ON public.kv_store FOR DELETE TO authenticated USING (true);
