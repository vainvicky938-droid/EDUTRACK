-- =============================================================================
-- Migration 007: Academic Assessment
-- assessment_definitions, assessment_results, result_corrections,
-- grading_scales, grade_bands
-- Depends on: 001, 002, 003, 004
-- =============================================================================

-- =============================================================================
-- GRADING SCALES
-- School-configurable grading rules. No hardcoded UNEB grades.
-- e.g. "UCE Scale", "Internal Scale", "Custom 2026"
-- =============================================================================
CREATE TABLE IF NOT EXISTS public.grading_scales (
  id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  school_id  UUID NOT NULL REFERENCES public.schools(id) ON DELETE CASCADE,
  name       TEXT NOT NULL,
  is_default BOOLEAN NOT NULL DEFAULT FALSE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (school_id, name)
);

CREATE INDEX IF NOT EXISTS idx_grading_scales_school ON public.grading_scales(school_id);

-- Only one default grading scale per school
CREATE UNIQUE INDEX IF NOT EXISTS idx_grading_scales_default
  ON public.grading_scales(school_id)
  WHERE is_default = TRUE;

-- =============================================================================
-- GRADE BANDS
-- The individual ranges within a grading scale.
-- e.g. 80-100 → A, 70-79 → B, etc.
-- =============================================================================
CREATE TABLE IF NOT EXISTS public.grade_bands (
  id               UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  grading_scale_id UUID NOT NULL REFERENCES public.grading_scales(id) ON DELETE CASCADE,
  letter_grade     TEXT NOT NULL,
  min_percent      NUMERIC(5,2) NOT NULL CHECK (min_percent >= 0 AND min_percent <= 100),
  max_percent      NUMERIC(5,2) NOT NULL CHECK (max_percent >= 0 AND max_percent <= 100),
  interpretation   TEXT,        -- e.g. "Distinction", "Credit", "Pass", "Fail"
  points           INTEGER,     -- e.g. for GPA or aggregate calculations
  sort_order       INTEGER NOT NULL DEFAULT 0,
  CONSTRAINT grade_bands_range_check CHECK (max_percent >= min_percent)
);

CREATE INDEX IF NOT EXISTS idx_grade_bands_scale ON public.grade_bands(grading_scale_id);

-- =============================================================================
-- ASSESSMENT DEFINITIONS
-- Defines the individual assessable components for a subject in a term.
-- e.g. "BOT Test" (20%), "Mid-term Exam" (30%), "End-of-Term Exam" (50%)
-- Weights across all components for a class_subject+term must sum to 100
-- (validated in application logic, not enforced by DB constraint).
-- =============================================================================
CREATE TABLE IF NOT EXISTS public.assessment_definitions (
  id               UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  school_id        UUID NOT NULL REFERENCES public.schools(id) ON DELETE CASCADE,
  class_subject_id UUID NOT NULL REFERENCES public.class_subjects(id) ON DELETE CASCADE,
  academic_term_id UUID NOT NULL REFERENCES public.academic_terms(id) ON DELETE CASCADE,
  name             TEXT NOT NULL,     -- e.g. "BOT", "MOT", "EOT"
  code             TEXT,              -- Short code e.g. "BOT"
  max_mark         NUMERIC(6,2) NOT NULL CHECK (max_mark > 0),
  weight_percent   NUMERIC(5,2) NOT NULL CHECK (weight_percent > 0 AND weight_percent <= 100),
  sort_order       INTEGER NOT NULL DEFAULT 0,
  created_at       TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (class_subject_id, academic_term_id, name)
);

CREATE INDEX IF NOT EXISTS idx_assessment_defs_school   ON public.assessment_definitions(school_id);
CREATE INDEX IF NOT EXISTS idx_assessment_defs_subject  ON public.assessment_definitions(class_subject_id);
CREATE INDEX IF NOT EXISTS idx_assessment_defs_term     ON public.assessment_definitions(academic_term_id);

-- =============================================================================
-- ASSESSMENT RESULTS
-- The mark a student received for a specific assessment component.
-- Status workflow: draft → submitted → approved
-- Approved marks cannot be changed without creating a result_correction row.
-- =============================================================================
CREATE TABLE IF NOT EXISTS public.assessment_results (
  id                      UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  school_id               UUID NOT NULL REFERENCES public.schools(id) ON DELETE CASCADE,
  student_id              UUID NOT NULL REFERENCES public.students(id) ON DELETE CASCADE,
  assessment_definition_id UUID NOT NULL REFERENCES public.assessment_definitions(id) ON DELETE CASCADE,
  raw_mark                NUMERIC(6,2) NOT NULL CHECK (raw_mark >= 0),
  status                  TEXT NOT NULL DEFAULT 'draft'
                            CHECK (status IN ('draft','submitted','approved','rejected')),
  entered_by              UUID NOT NULL REFERENCES auth.users(id),
  approved_by             UUID REFERENCES auth.users(id),
  entered_at              TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  approved_at             TIMESTAMPTZ,
  updated_at              TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  -- One result per student per assessment component
  UNIQUE (student_id, assessment_definition_id)
);

CREATE INDEX IF NOT EXISTS idx_assessment_results_school   ON public.assessment_results(school_id);
CREATE INDEX IF NOT EXISTS idx_assessment_results_student  ON public.assessment_results(student_id);
CREATE INDEX IF NOT EXISTS idx_assessment_results_def      ON public.assessment_results(assessment_definition_id);

CREATE TRIGGER set_assessment_results_updated_at
  BEFORE UPDATE ON public.assessment_results
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

-- =============================================================================
-- RESULT CORRECTIONS
-- Audit trail for any change to an approved assessment result.
-- The original row in assessment_results is updated but the old value
-- is preserved here permanently.
-- =============================================================================
CREATE TABLE IF NOT EXISTS public.result_corrections (
  id                   UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  school_id            UUID NOT NULL REFERENCES public.schools(id) ON DELETE CASCADE,
  assessment_result_id UUID NOT NULL REFERENCES public.assessment_results(id) ON DELETE CASCADE,
  old_mark             NUMERIC(6,2) NOT NULL,
  new_mark             NUMERIC(6,2) NOT NULL,
  reason               TEXT NOT NULL,
  corrected_by         UUID NOT NULL REFERENCES auth.users(id),
  created_at           TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_result_corrections_school ON public.result_corrections(school_id);
CREATE INDEX IF NOT EXISTS idx_result_corrections_result ON public.result_corrections(assessment_result_id);
