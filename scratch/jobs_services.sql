-- Jobs, applications, and service marketplace.
-- Run after scratch/secure_platform.sql.

-- ==========================================
-- Indexes
-- ==========================================

CREATE INDEX IF NOT EXISTS idx_jobs_active_created
  ON jobs (is_active, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_jobs_business
  ON jobs (business_id);
CREATE INDEX IF NOT EXISTS idx_jobs_type_active
  ON jobs (job_type)
  WHERE is_active = TRUE;

CREATE INDEX IF NOT EXISTS idx_job_applications_job_created
  ON job_applications (job_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_job_applications_applicant
  ON job_applications (applicant_id);

CREATE INDEX IF NOT EXISTS idx_service_providers_category
  ON service_providers (category_id);
CREATE INDEX IF NOT EXISTS idx_service_providers_user
  ON service_providers (user_id);

CREATE INDEX IF NOT EXISTS idx_service_requests_provider_created
  ON service_requests (provider_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_service_requests_user
  ON service_requests (user_id);
CREATE INDEX IF NOT EXISTS idx_service_requests_status
  ON service_requests (status);

-- ==========================================
-- RLS — jobs / applications
-- ==========================================

ALTER TABLE jobs ENABLE ROW LEVEL SECURITY;
ALTER TABLE job_applications ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Admins manage all jobs" ON jobs;
CREATE POLICY "Admins manage all jobs" ON jobs
  FOR ALL USING (is_admin()) WITH CHECK (is_admin());

DROP POLICY IF EXISTS "Public read active jobs" ON jobs;
CREATE POLICY "Public read active jobs" ON jobs
  FOR SELECT USING (is_active = TRUE);

DROP POLICY IF EXISTS "Owners read own jobs" ON jobs;
CREATE POLICY "Owners read own jobs" ON jobs
  FOR SELECT USING (
    poster_id = auth.uid()
    OR EXISTS (
      SELECT 1 FROM businesses
      WHERE businesses.id = jobs.business_id
        AND businesses.owner_id = auth.uid()
    )
  );

DROP POLICY IF EXISTS "Owners insert own jobs" ON jobs;
CREATE POLICY "Owners insert own jobs" ON jobs
  FOR INSERT WITH CHECK (
    poster_id = auth.uid()
    AND EXISTS (
      SELECT 1 FROM businesses
      WHERE businesses.id = jobs.business_id
        AND businesses.owner_id = auth.uid()
    )
  );

DROP POLICY IF EXISTS "Owners update own jobs" ON jobs;
CREATE POLICY "Owners update own jobs" ON jobs
  FOR UPDATE USING (
    poster_id = auth.uid()
    OR EXISTS (
      SELECT 1 FROM businesses
      WHERE businesses.id = jobs.business_id
        AND businesses.owner_id = auth.uid()
    )
  );

DROP POLICY IF EXISTS "Admins manage all job applications" ON job_applications;
CREATE POLICY "Admins manage all job applications" ON job_applications
  FOR ALL USING (is_admin()) WITH CHECK (is_admin());

DROP POLICY IF EXISTS "Applicants read own applications" ON job_applications;
CREATE POLICY "Applicants read own applications" ON job_applications
  FOR SELECT USING (applicant_id = auth.uid());

DROP POLICY IF EXISTS "Owners read job applications" ON job_applications;
CREATE POLICY "Owners read job applications" ON job_applications
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM jobs
      JOIN businesses ON businesses.id = jobs.business_id
      WHERE jobs.id = job_applications.job_id
        AND (jobs.poster_id = auth.uid() OR businesses.owner_id = auth.uid())
    )
  );

DROP POLICY IF EXISTS "Applicants insert own applications" ON job_applications;
CREATE POLICY "Applicants insert own applications" ON job_applications
  FOR INSERT WITH CHECK (applicant_id = auth.uid());

-- ==========================================
-- RLS — service providers / requests
-- ==========================================

DROP POLICY IF EXISTS "Public read service providers" ON service_providers;
CREATE POLICY "Public read service providers" ON service_providers
  FOR SELECT USING (true);

DROP POLICY IF EXISTS "Users manage own provider profile" ON service_providers;
CREATE POLICY "Users manage own provider profile" ON service_providers
  FOR ALL USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());

DROP POLICY IF EXISTS "Users read own service requests" ON service_requests;
CREATE POLICY "Users read own service requests" ON service_requests
  FOR SELECT USING (user_id = auth.uid());

DROP POLICY IF EXISTS "Providers read assigned requests" ON service_requests;
CREATE POLICY "Providers read assigned requests" ON service_requests
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM service_providers
      WHERE service_providers.id = service_requests.provider_id
        AND service_providers.user_id = auth.uid()
    )
  );

DROP POLICY IF EXISTS "Users insert own service requests" ON service_requests;
CREATE POLICY "Users insert own service requests" ON service_requests
  FOR INSERT WITH CHECK (user_id = auth.uid());

-- ==========================================
-- RPCs
-- ==========================================

CREATE OR REPLACE FUNCTION apply_to_job(
    p_job_id UUID,
    p_experience TEXT
)
RETURNS job_applications
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_job jobs%ROWTYPE;
    v_app job_applications%ROWTYPE;
    v_owner UUID;
BEGIN
    IF auth.uid() IS NULL THEN
        RAISE EXCEPTION 'Please sign in to apply';
    END IF;
    IF p_experience IS NULL OR btrim(p_experience) = '' THEN
        RAISE EXCEPTION 'Please enter your experience summary';
    END IF;

    SELECT * INTO v_job FROM jobs WHERE id = p_job_id;
    IF NOT FOUND OR v_job.is_active IS NOT TRUE THEN
        RAISE EXCEPTION 'Job is not available';
    END IF;

    INSERT INTO job_applications (job_id, applicant_id, experience_summary, status)
    VALUES (p_job_id, auth.uid(), btrim(p_experience), 'applied')
    RETURNING * INTO v_app;

    SELECT owner_id INTO v_owner FROM businesses WHERE id = v_job.business_id;
    PERFORM notify_user(
        COALESCE(v_job.poster_id, v_owner),
        'New job application',
        'Someone applied for ' || v_job.title || '.',
        'job_application'
    );
    RETURN v_app;
END;
$$;

CREATE OR REPLACE FUNCTION create_service_request(
    p_provider_id UUID,
    p_description TEXT,
    p_scheduled_at TIMESTAMPTZ
)
RETURNS service_requests
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_req service_requests%ROWTYPE;
    v_provider_user UUID;
BEGIN
    IF auth.uid() IS NULL THEN
        RAISE EXCEPTION 'Please sign in to request a service';
    END IF;
    IF p_description IS NULL OR btrim(p_description) = '' THEN
        RAISE EXCEPTION 'Please enter a description';
    END IF;
    IF p_scheduled_at IS NULL THEN
        RAISE EXCEPTION 'Please select a schedule date';
    END IF;

    SELECT user_id INTO v_provider_user
    FROM service_providers
    WHERE id = p_provider_id;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Service provider not found';
    END IF;

    INSERT INTO service_requests (
        user_id, provider_id, description, scheduled_at, status
    )
    VALUES (
        auth.uid(), p_provider_id, btrim(p_description), p_scheduled_at, 'pending'
    )
    RETURNING * INTO v_req;

    PERFORM notify_user(
        v_provider_user,
        'New service request',
        'Someone requested your service in Degloor.',
        'service_request'
    );
    RETURN v_req;
END;
$$;

CREATE OR REPLACE FUNCTION update_service_request_status(
    p_request_id UUID,
    p_status TEXT
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_req service_requests%ROWTYPE;
    v_next TEXT;
    v_current TEXT;
BEGIN
    v_next := lower(btrim(COALESCE(p_status, '')));
    IF v_next NOT IN ('accepted', 'declined', 'completed') THEN
        RAISE EXCEPTION 'Invalid service request status';
    END IF;

    SELECT * INTO v_req FROM service_requests WHERE id = p_request_id FOR UPDATE;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Service request not found';
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM service_providers
        WHERE id = v_req.provider_id AND user_id = auth.uid()
    ) AND NOT is_admin() THEN
        RAISE EXCEPTION 'Not allowed to update this request';
    END IF;

    v_current := lower(COALESCE(v_req.status, 'pending'));
    IF v_current = 'pending' AND v_next NOT IN ('accepted', 'declined') THEN
        RAISE EXCEPTION 'Pending requests can only be accepted or declined';
    END IF;
    IF v_current = 'accepted' AND v_next <> 'completed' THEN
        RAISE EXCEPTION 'Accepted requests can only be completed';
    END IF;
    IF v_current NOT IN ('pending', 'accepted') THEN
        RAISE EXCEPTION 'Request can no longer be updated';
    END IF;

    UPDATE service_requests SET status = v_next WHERE id = p_request_id;

    PERFORM notify_user(
        v_req.user_id,
        'Service Request Update',
        'Your service request is now ' || v_next || '.',
        'service_request'
    );
END;
$$;

GRANT EXECUTE ON FUNCTION apply_to_job(UUID, TEXT) TO authenticated;
GRANT EXECUTE ON FUNCTION create_service_request(UUID, TEXT, TIMESTAMPTZ) TO authenticated;
GRANT EXECUTE ON FUNCTION update_service_request_status(UUID, TEXT) TO authenticated;
