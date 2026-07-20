
-- Allowlist of approved app users
CREATE TABLE public.authorized_users (
  user_id uuid PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email text,
  added_at timestamptz NOT NULL DEFAULT now()
);

GRANT SELECT ON public.authorized_users TO authenticated;
GRANT ALL ON public.authorized_users TO service_role;

ALTER TABLE public.authorized_users ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can see their own authorization row"
  ON public.authorized_users FOR SELECT
  TO authenticated
  USING (user_id = auth.uid());

-- Seed with the two existing partner accounts
INSERT INTO public.authorized_users (user_id, email) VALUES
  ('de179a48-cd2a-495d-b33b-9a467ed33ffb', 'info@crestpointmanagement.co.uk'),
  ('202bf5ee-59d4-4ffc-ad35-f6bdf98143da', 'hunzlashh@gmail.com')
ON CONFLICT (user_id) DO NOTHING;

-- Security definer helper to avoid recursion / expose to policies
CREATE OR REPLACE FUNCTION public.is_authorized_user(_uid uuid)
RETURNS boolean
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT EXISTS (
    SELECT 1 FROM public.authorized_users WHERE user_id = _uid
  );
$$;

-- Replace overly-permissive kv_store policies with allowlist-gated ones
DROP POLICY IF EXISTS "Authenticated users can delete shared data" ON public.kv_store;
DROP POLICY IF EXISTS "Authenticated users can insert shared data" ON public.kv_store;
DROP POLICY IF EXISTS "Authenticated users can read shared data"  ON public.kv_store;
DROP POLICY IF EXISTS "Authenticated users can update shared data" ON public.kv_store;

CREATE POLICY "Approved users can read shared data"
  ON public.kv_store FOR SELECT
  TO authenticated
  USING (public.is_authorized_user(auth.uid()));

CREATE POLICY "Approved users can insert shared data"
  ON public.kv_store FOR INSERT
  TO authenticated
  WITH CHECK (public.is_authorized_user(auth.uid()));

CREATE POLICY "Approved users can update shared data"
  ON public.kv_store FOR UPDATE
  TO authenticated
  USING (public.is_authorized_user(auth.uid()))
  WITH CHECK (public.is_authorized_user(auth.uid()));

CREATE POLICY "Approved users can delete shared data"
  ON public.kv_store FOR DELETE
  TO authenticated
  USING (public.is_authorized_user(auth.uid()));
