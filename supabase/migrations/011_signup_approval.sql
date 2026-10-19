-- =============================================================================
-- Migration 011: Signup Approval Flow
-- Adds:
--   - is_platform_admin flag to user_profiles
--   - pending_registrations table for new school signup requests
-- Depends on: 001–010
-- =============================================================================

-- Add platform admin flag to user_profiles
ALTER TABLE public.user_profiles
  ADD COLUMN IF NOT EXISTS is_platform_admin BOOLEAN NOT NULL DEFAULT FALSE;

-- Add onboarding status so we know where a user is in the flow
ALTER TABLE public.user_profiles
  ADD COLUMN IF NOT EXISTS onboarding_status TEXT NOT NULL DEFAULT 'pending_approval'
    CHECK (onboarding_status IN (
      'pending_approval',   -- signed up, waiting for admin to approve
      'pending_onboarding', -- approved, needs to fill in school details
      'complete'            -- school created, can access dashboard
    ));

-- =============================================================================
-- PENDING REGISTRATIONS
-- Created when a new user signs up. Platform admin reviews and approves/rejects.
-- =============================================================================
CREATE TABLE IF NOT EXISTS public.pending_registrations (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id       UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  full_name     TEXT NOT NULL,
  email         TEXT NOT NULL,
  phone         TEXT,
  -- What type of school they intend to register
  intended_school_type TEXT CHECK (intended_school_type IN ('primary','secondary','combined')),
  -- A short message from the applicant (optional)
  message       TEXT,
  status        TEXT NOT NULL DEFAULT 'pending'
                  CHECK (status IN ('pending','approved','rejected')),
  rejection_reason TEXT,
  reviewed_by   UUID REFERENCES auth.users(id),
  reviewed_at   TIMESTAMPTZ,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (user_id)
);

CREATE INDEX IF NOT EXISTS idx_pending_reg_status ON public.pending_registrations(status, created_at DESC);

-- =============================================================================
-- RLS for pending_registrations
-- =============================================================================
ALTER TABLE public.pending_registrations ENABLE ROW LEVEL SECURITY;

-- Platform admin can see all
CREATE POLICY "pending_reg_admin_all" ON public.pending_registrations
  FOR ALL USING (public.is_platform_admin());

-- Users can see only their own registration
CREATE POLICY "pending_reg_own_select" ON public.pending_registrations
  FOR SELECT USING (user_id = auth.uid());

-- Any authenticated user can insert their own registration
CREATE POLICY "pending_reg_insert" ON public.pending_registrations
  FOR INSERT WITH CHECK (user_id = auth.uid());

-- =============================================================================
-- RLS update: existing users (from seed) should be marked complete
-- =============================================================================
UPDATE public.user_profiles
SET onboarding_status = 'complete'
WHERE id IN (
  SELECT DISTINCT user_id FROM public.school_memberships WHERE status = 'active'
);

-- =============================================================================
-- FUNCTION: approve_registration
-- Called by platform admin to approve a pending signup.
-- Sets onboarding_status to 'pending_onboarding' so the user sees the
-- school setup form on next login.
-- =============================================================================
CREATE OR REPLACE FUNCTION public.approve_registration(p_registration_id UUID)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_user_id UUID;
BEGIN
  -- Only platform admins can call this
  IF NOT public.is_platform_admin() THEN
    RAISE EXCEPTION 'Access denied: platform admin required';
  END IF;

  SELECT user_id INTO v_user_id
  FROM public.pending_registrations
  WHERE id = p_registration_id AND status = 'pending';

  IF v_user_id IS NULL THEN
    RAISE EXCEPTION 'Registration not found or already processed';
  END IF;

  -- Mark registration as approved
  UPDATE public.pending_registrations
  SET status = 'approved',
      reviewed_by = auth.uid(),
      reviewed_at = NOW()
  WHERE id = p_registration_id;

  -- Move user to onboarding step
  UPDATE public.user_profiles
  SET onboarding_status = 'pending_onboarding'
  WHERE id = v_user_id;
END;
$$;

-- =============================================================================
-- FUNCTION: reject_registration
-- =============================================================================
CREATE OR REPLACE FUNCTION public.reject_registration(
  p_registration_id UUID,
  p_reason TEXT DEFAULT NULL
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_user_id UUID;
BEGIN
  IF NOT public.is_platform_admin() THEN
    RAISE EXCEPTION 'Access denied: platform admin required';
  END IF;

  SELECT user_id INTO v_user_id
  FROM public.pending_registrations
  WHERE id = p_registration_id AND status = 'pending';

  IF v_user_id IS NULL THEN
    RAISE EXCEPTION 'Registration not found or already processed';
  END IF;

  UPDATE public.pending_registrations
  SET status = 'rejected',
      rejection_reason = p_reason,
      reviewed_by = auth.uid(),
      reviewed_at = NOW()
  WHERE id = p_registration_id;

  -- Keep user in pending_approval so they see the rejection message
  UPDATE public.user_profiles
  SET onboarding_status = 'pending_approval'
  WHERE id = v_user_id;
END;
$$;
