CREATE OR REPLACE FUNCTION public.is_authorized_user(_uid uuid)
RETURNS boolean
LANGUAGE sql
STABLE
SECURITY INVOKER
SET search_path = public
AS $$
  SELECT EXISTS (
    SELECT 1
    FROM public.authorized_users
    WHERE user_id = _uid
  )
$$;

REVOKE EXECUTE ON FUNCTION public.is_authorized_user(uuid) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.is_authorized_user(uuid) TO authenticated, service_role;