-- =============================================================================
-- Migration 003: Academic Structure
-- academic_years, academic_terms, classes, streams, subjects,
-- class_subjects, teacher_assignments
-- Depends on: 001, 002
-- =============================================================================

-- =============================================================================
-- ACADEMIC YEARS
-- e.g. "2026", "2027"
-- =============================================================================
CREATE TABLE IF NOT EXISTS public.academic_years (
  id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  school_id  UUID NOT NULL REFERENCES public.schools(id) ON DELETE CASCADE,
  name       TEXT NOT NULL,
  start_date DATE NOT NULL,
  end_date   DATE NOT NULL,
  is_current BOOLEAN NOT NULL DEFAULT FALSE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  CONSTRAINT academic_years_dates_check CHECK (end_date > start_date),
  UNIQUE (school_id, name)
);

CREATE INDEX IF NOT EXISTS idx_academic_years_school ON public.academic_years(school_id);

-- Only one current academic year per school
CREATE UNIQUE INDEX IF NOT EXISTS idx_academic_years_current
  ON public.academic_years(school_id)
  WHERE is_current = TRUE;

-- =============================================================================
-- ACADEMIC TERMS
-- e.g. "Term 1", "Term 2", "Term 3" within an academic year
-- =============================================================================
CREATE TABLE IF NOT EXISTS public.academic_terms (
  id               UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  school_id        UUID NOT NULL REFERENCES public.schools(id) ON DELETE CASCADE,
  academic_year_id UUID NOT NULL REFERENCES public.academic_years(id) ON DELETE CASCADE,
  name             TEXT NOT NULL,
  start_date       DATE NOT NULL,
  end_date         DATE NOT NULL,
  is_current       BOOLEAN NOT NULL DEFAULT FALSE,
  created_at       TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  CONSTRAINT academic_terms_dates_check CHECK (end_date > start_date),
  UNIQUE (academic_year_id, name)
);

CREATE INDEX IF NOT EXISTS idx_academic_terms_school ON public.academic_terms(school_id);
CREATE INDEX IF NOT EXISTS idx_academic_terms_year   ON public.academic_terms(academic_year_id);

-- Only one current term per school
CREATE UNIQUE INDEX IF NOT EXISTS idx_academic_terms_current
  ON public.academic_terms(school_id)
  WHERE is_current = TRUE;

-- =============================================================================
-- CLASSES
-- e.g. "S1", "S2", "S3", "S4", "S5", "S6" for secondary
-- School configures their own class names — no hardcoding
-- =============================================================================
CREATE TABLE IF NOT EXISTS public.classes (
  id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  school_id  UUID NOT NULL REFERENCES public.schools(id) ON DELETE CASCADE,
  name       TEXT NOT NULL,
  level_code TEXT,
  sort_order INTEGER NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (school_id, name)
);

CREATE INDEX IF NOT EXISTS idx_classes_school ON public.classes(school_id, sort_order);

-- =============================================================================
-- STREAMS
-- Subdivisions of a class, e.g. "S2 East", "S2 West"
-- =============================================================================
CREATE TABLE IF NOT EXISTS public.streams (
  id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  school_id  UUID NOT NULL REFERENCES public.schools(id) ON DELETE CASCADE,
  class_id   UUID NOT NULL REFERENCES public.classes(id) ON DELETE CASCADE,
  name       TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (class_id, name)
);

CREATE INDEX IF NOT EXISTS idx_streams_class  ON public.streams(class_id);
CREATE INDEX IF NOT EXISTS idx_streams_school ON public.streams(school_id);

-- =============================================================================
-- SUBJECTS
-- School-defined subjects, e.g. "Mathematics", "Biology", "History"
-- =============================================================================
CREATE TABLE IF NOT EXISTS public.subjects (
  id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  school_id  UUID NOT NULL REFERENCES public.schools(id) ON DELETE CASCADE,
  name       TEXT NOT NULL,
  code       TEXT,
  is_active  BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (school_id, name)
);

CREATE INDEX IF NOT EXISTS idx_subjects_school ON public.subjects(school_id);

-- =============================================================================
-- CLASS SUBJECTS
-- Which subjects are taught in which class during which academic year
-- =============================================================================
CREATE TABLE IF NOT EXISTS public.class_subjects (
  id               UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  school_id        UUID NOT NULL REFERENCES public.schools(id) ON DELETE CASCADE,
  class_id         UUID NOT NULL REFERENCES public.classes(id) ON DELETE CASCADE,
  subject_id       UUID NOT NULL REFERENCES public.subjects(id) ON DELETE CASCADE,
  academic_year_id UUID NOT NULL REFERENCES public.academic_years(id) ON DELETE CASCADE,
  is_active        BOOLEAN NOT NULL DEFAULT TRUE,
  created_at       TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (class_id, subject_id, academic_year_id)
);

CREATE INDEX IF NOT EXISTS idx_class_subjects_class  ON public.class_subjects(class_id);
CREATE INDEX IF NOT EXISTS idx_class_subjects_school ON public.class_subjects(school_id);

-- =============================================================================
-- TEACHER ASSIGNMENTS
-- Which teacher is responsible for which class-subject in which term
-- =============================================================================
CREATE TABLE IF NOT EXISTS public.teacher_assignments (
  id               UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  school_id        UUID NOT NULL REFERENCES public.schools(id) ON DELETE CASCADE,
  staff_id         UUID NOT NULL REFERENCES public.staff_profiles(id) ON DELETE CASCADE,
  class_subject_id UUID NOT NULL REFERENCES public.class_subjects(id) ON DELETE CASCADE,
  stream_id        UUID REFERENCES public.streams(id) ON DELETE SET NULL,
  academic_term_id UUID NOT NULL REFERENCES public.academic_terms(id) ON DELETE CASCADE,
  -- A teacher can be designated the class teacher for a stream
  is_class_teacher BOOLEAN NOT NULL DEFAULT FALSE,
  created_at       TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (staff_id, class_subject_id, academic_term_id)
);

CREATE INDEX IF NOT EXISTS idx_teacher_assignments_school ON public.teacher_assignments(school_id);
CREATE INDEX IF NOT EXISTS idx_teacher_assignments_staff  ON public.teacher_assignments(staff_id);
