-- =============================================================================
-- Migration 009: Database Helper Functions
-- These functions are used by RLS policies to check membership and roles.
-- They use SECURITY DEFINER so they can query school_memberships safely
-- without causing infinite RLS recursion.
-- Depends on: 001, 002
-- =============================================================================

-- =============================================================================
-- get_user_school_ids()
-- Returns all school IDs where the current user has an active membership.
-- Used by RLS SELECT policies across all school-sensitive tables.
-- =============================================================================
CREATE OR REPLACE FUNCTION public.get_user_school_ids()
RETURNS SETOF UUID
LANGUAGE sql
SECURITY DEFINER
STABLE
SET search_path = public
AS $$
  SELECT school_id
  FROM public.school_memberships
  WHERE user_id = auth.uid()
    AND status = 'active';
$$;

-- =============================================================================
-- get_user_role_in_school(school_id)
-- Returns the role of the current user in a specific school.
-- Returns NULL if the user has no active membership in that school.
-- =============================================================================
CREATE OR REPLACE FUNCTION public.get_user_role_in_school(p_school_id UUID)
RETURNS TEXT
LANGUAGE sql
SECURITY DEFINER
STABLE
SET search_path = public
AS $$
  SELECT role
  FROM public.school_memberships
  WHERE user_id = auth.uid()
    AND school_id = p_school_id
    AND status = 'active'
  LIMIT 1;
$$;

-- =============================================================================
-- user_has_school_access(school_id)
-- Returns TRUE if the current user has any active membership in the school.
-- Used in INSERT/UPDATE WITH CHECK clauses.
-- =============================================================================
CREATE OR REPLACE FUNCTION public.user_has_school_access(p_school_id UUID)
RETURNS BOOLEAN
LANGUAGE sql
SECURITY DEFINER
STABLE
SET search_path = public
AS $$
  SELECT EXISTS (
    SELECT 1
    FROM public.school_memberships
    WHERE user_id = auth.uid()
      AND school_id = p_school_id
      AND status = 'active'
  );
$$;

-- =============================================================================
-- user_has_role_in_school(school_id, roles[])
-- Returns TRUE if the current user holds one of the specified roles
-- in the given school.
-- =============================================================================
CREATE OR REPLACE FUNCTION public.user_has_role_in_school(
  p_school_id UUID,
  p_roles     TEXT[]
)
RETURNS BOOLEAN
LANGUAGE sql
SECURITY DEFINER
STABLE
SET search_path = public
AS $$
  SELECT EXISTS (
    SELECT 1
    FROM public.school_memberships
    WHERE user_id = auth.uid()
      AND school_id = p_school_id
      AND status = 'active'
      AND role = ANY(p_roles)
  );
$$;

-- =============================================================================
-- is_platform_admin()
-- Returns TRUE if the current user is a platform super admin.
-- Checks the is_platform_admin flag in user_profiles.
-- =============================================================================
CREATE OR REPLACE FUNCTION public.is_platform_admin()
RETURNS BOOLEAN
LANGUAGE sql
SECURITY DEFINER
STABLE
SET search_path = public
AS $$
  SELECT COALESCE(
    (SELECT is_platform_admin FROM public.user_profiles WHERE id = auth.uid()),
    FALSE
  );
$$;
