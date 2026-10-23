-- =============================================================================
-- Migration 013: Fix RLS policies for onboarding flow
-- Ensures approved users can create their school workspace
-- Run this after migrations 001-012
-- =============================================================================

-- ─── SCHOOLS INSERT: any authenticated user can create a school ──────────────
-- Rationale: the user must be authenticated AND have gone through
-- the approval flow (onboarding_status = pending_onboarding) to reach
-- this page. The application layer enforces approval; the DB policy
-- just needs to not block legitimate inserts.
DROP POLICY IF EXISTS "schools_insert" ON public.schools;

CREATE POLICY "schools_insert" ON public.schools
  FOR INSERT
  WITH CHECK (auth.uid() IS NOT NULL);

-- ─── SCHOOL MEMBERSHIPS INSERT: allow self-assignment as owner ────────────────
DROP POLICY IF EXISTS "memberships_insert" ON public.school_memberships;

CREATE POLICY "memberships_insert" ON public.school_memberships
  FOR INSERT
  WITH CHECK (
    auth.uid() IS NOT NULL
    AND (
      -- Adding yourself as school_owner
      user_id = auth.uid()
      OR
      -- School owner adding other staff
      public.user_has_role_in_school(school_id, ARRAY['school_owner'])
    )
  );

-- ─── SCHOOL MEMBERSHIPS SELECT: always see your own memberships ───────────────
DROP POLICY IF EXISTS "memberships_select" ON public.school_memberships;

CREATE POLICY "memberships_select" ON public.school_memberships
  FOR SELECT
  USING (
    user_id = auth.uid()
    OR school_id IN (SELECT public.get_user_school_ids())
    OR public.is_platform_admin()
  );

-- Verify policies
SELECT tablename, policyname, cmd, with_check
FROM pg_policies
WHERE tablename IN ('schools', 'school_memberships')
ORDER BY tablename, cmd;
