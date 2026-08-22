-- Admin notify RPC. Run after scratch/jobs_services.sql.
-- notify_user() stays revoked from clients; admins call this wrapper.

CREATE OR REPLACE FUNCTION admin_notify_user(
    p_user_id UUID,
    p_title TEXT,
    p_message TEXT,
    p_type TEXT DEFAULT 'general'
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  IF NOT is_admin() THEN
    RAISE EXCEPTION 'Not allowed to send notifications';
  END IF;
  IF p_user_id IS NULL THEN
    RETURN;
  END IF;
  PERFORM notify_user(
    p_user_id,
    COALESCE(NULLIF(btrim(p_title), ''), 'Notification'),
    COALESCE(NULLIF(btrim(p_message), ''), 'You have a new update.'),
    COALESCE(NULLIF(btrim(p_type), ''), 'general')
  );
END;
$$;

GRANT EXECUTE ON FUNCTION admin_notify_user(UUID, TEXT, TEXT, TEXT) TO authenticated;
