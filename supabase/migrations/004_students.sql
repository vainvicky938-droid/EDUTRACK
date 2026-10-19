-- =============================================================================
-- Migration 004: Students, Guardians, and Enrollments
-- Depends on: 001, 002, 003
-- =============================================================================

-- =============================================================================
-- STUDENTS
-- Core student record. Never hard-deleted — status tracks lifecycle.
-- =============================================================================
CREATE TABLE IF NOT EXISTS public.students (
  id               UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  school_id        UUID NOT NULL REFERENCES public.schools(id) ON DELETE CASCADE,
  admission_number TEXT NOT NULL,
  full_name        TEXT NOT NULL,
  date_of_birth    DATE,
  gender           TEXT CHECK (gender IN ('male','female','other','not_stated')),
  admission_date   DATE NOT NULL DEFAULT CURRENT_DATE,
  status           TEXT NOT NULL DEFAULT 'active'
                     CHECK (status IN (
                       'active','transferred','withdrawn','graduated','deceased'
                     )),
  photo_url        TEXT,
  -- Additional fields relevant for Ugandan schools
  nationality      TEXT DEFAULT 'Ugandan',
  religion         TEXT,
  previous_school  TEXT,
  notes            TEXT,
  created_at       TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at       TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (school_id, admission_number)
);

CREATE INDEX IF NOT EXISTS idx_students_school        ON public.students(school_id);
CREATE INDEX IF NOT EXISTS idx_students_status        ON public.students(school_id, status);
CREATE INDEX IF NOT EXISTS idx_students_name          ON public.students(school_id, full_name);
CREATE INDEX IF NOT EXISTS idx_students_admission     ON public.students(school_id, admission_number);

CREATE TRIGGER set_students_updated_at
  BEFORE UPDATE ON public.students
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

-- =============================================================================
-- GUARDIANS
-- Parent or guardian contact records.
-- One guardian can be linked to multiple students.
-- =============================================================================
CREATE TABLE IF NOT EXISTS public.guardians (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  school_id       UUID NOT NULL REFERENCES public.schools(id) ON DELETE CASCADE,
  full_name       TEXT NOT NULL,
  relationship    TEXT NOT NULL, -- e.g. "Father", "Mother", "Uncle", "Guardian"
  phone_primary   TEXT NOT NULL,
  phone_secondary TEXT,
  email           TEXT,
  address         TEXT,
  occupation      TEXT,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_guardians_school ON public.guardians(school_id);

CREATE TRIGGER set_guardians_updated_at
  BEFORE UPDATE ON public.guardians
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

-- =============================================================================
-- STUDENT GUARDIANS
-- Junction table linking students to their guardians
-- =============================================================================
CREATE TABLE IF NOT EXISTS public.student_guardians (
  id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  student_id          UUID NOT NULL REFERENCES public.students(id) ON DELETE CASCADE,
  guardian_id         UUID NOT NULL REFERENCES public.guardians(id) ON DELETE CASCADE,
  is_primary          BOOLEAN NOT NULL DEFAULT FALSE,
  receives_reports    BOOLEAN NOT NULL DEFAULT TRUE,
  receives_statements BOOLEAN NOT NULL DEFAULT TRUE,
  created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (student_id, guardian_id)
);

CREATE INDEX IF NOT EXISTS idx_student_guardians_student  ON public.student_guardians(student_id);
CREATE INDEX IF NOT EXISTS idx_student_guardians_guardian ON public.student_guardians(guardian_id);

-- =============================================================================
-- STUDENT ENROLLMENTS
-- Tracks which class a student is in for each academic year.
-- Historical records are preserved — status changes instead of deletion.
-- One enrollment per student per academic year (enforced by unique constraint).
-- =============================================================================
CREATE TABLE IF NOT EXISTS public.student_enrollments (
  id               UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  school_id        UUID NOT NULL REFERENCES public.schools(id) ON DELETE CASCADE,
  student_id       UUID NOT NULL REFERENCES public.students(id) ON DELETE CASCADE,
  academic_year_id UUID NOT NULL REFERENCES public.academic_years(id) ON DELETE CASCADE,
  class_id         UUID NOT NULL REFERENCES public.classes(id),
  stream_id        UUID REFERENCES public.streams(id),
  status           TEXT NOT NULL DEFAULT 'active'
                     CHECK (status IN (
                       'active','promoted','transferred','withdrawn','completed'
                     )),
  enrolled_date    DATE NOT NULL DEFAULT CURRENT_DATE,
  -- Who enrolled the student
  enrolled_by      UUID REFERENCES auth.users(id),
  notes            TEXT,
  created_at       TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  -- One enrollment per student per academic year
  UNIQUE (student_id, academic_year_id)
);

CREATE INDEX IF NOT EXISTS idx_enrollments_school       ON public.student_enrollments(school_id);
CREATE INDEX IF NOT EXISTS idx_enrollments_student      ON public.student_enrollments(student_id);
CREATE INDEX IF NOT EXISTS idx_enrollments_class        ON public.student_enrollments(class_id, academic_year_id);
CREATE INDEX IF NOT EXISTS idx_enrollments_year         ON public.student_enrollments(school_id, academic_year_id);
