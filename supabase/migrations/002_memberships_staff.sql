-- =============================================================================
-- Migration 002: School Memberships and Staff Profiles
-- Depends on: 001_platform_tables.sql
-- =============================================================================

-- =============================================================================
-- SCHOOL MEMBERSHIPS
-- Links a user to a school with a specific role.
-- This is the central tenancy enforcement table — RLS on every other table
-- checks this table to confirm the user belongs to that school.
-- A user can belong to multiple schools with different roles.
-- =============================================================================
CREATE TABLE IF NOT EXISTS public.school_memberships (
  id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  school_id         UUID NOT NULL REFERENCES public.schools(id) ON DELETE CASCADE,
  user_id           UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  role              TEXT NOT NULL
                      CHECK (role IN (
                        'school_owner',
                        'headteacher',
                        'registrar',
                        'bursar',
                        'teacher',
                        'support_staff'
                      )),
  -- Extra permissions granted beyond the base role
  -- e.g. {"view_financial_reports": true, "approve_marks": true}
  extra_permissions JSONB NOT NULL DEFAULT '{}',
  status            TEXT NOT NULL DEFAULT 'active'
                      CHECK (status IN ('active','suspended','removed')),
  joined_at         TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at        TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  -- One active membership per user per school
  UNIQUE (school_id, user_id)
);

CREATE INDEX IF NOT EXISTS idx_memberships_school   ON public.school_memberships(school_id);
CREATE INDEX IF NOT EXISTS idx_memberships_user     ON public.school_memberships(user_id);
CREATE INDEX IF NOT EXISTS idx_memberships_role     ON public.school_memberships(school_id, role);

CREATE TRIGGER set_memberships_updated_at
  BEFORE UPDATE ON public.school_memberships
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

-- =============================================================================
-- STAFF PROFILES
-- Additional employment details for users who are staff at a school.
-- Separate from school_memberships so a user can have one membership
-- row (for access control) and one staff_profile row (for HR details).
-- =============================================================================
CREATE TABLE IF NOT EXISTS public.staff_profiles (
  id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  school_id         UUID NOT NULL REFERENCES public.schools(id) ON DELETE CASCADE,
  user_id           UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  employee_number   TEXT,
  job_title         TEXT,
  employment_status TEXT NOT NULL DEFAULT 'active'
                      CHECK (employment_status IN ('active','on_leave','terminated')),
  joined_date       DATE,
  notes             TEXT,
  created_at        TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at        TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (school_id, user_id)
);

CREATE INDEX IF NOT EXISTS idx_staff_school ON public.staff_profiles(school_id);
CREATE INDEX IF NOT EXISTS idx_staff_user   ON public.staff_profiles(user_id);

CREATE TRIGGER set_staff_profiles_updated_at
  BEFORE UPDATE ON public.staff_profiles
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
