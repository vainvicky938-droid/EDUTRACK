-- =============================================================================
-- Migration 005: Attendance
-- attendance_sessions, attendance_records
-- Depends on: 001, 002, 003, 004
-- =============================================================================

-- =============================================================================
-- ATTENDANCE SESSIONS
-- Represents one attendance-taking event for a class on a given date.
-- The UNIQUE constraint prevents duplicate sessions for the same
-- class + stream + date + session_type combination.
-- =============================================================================
CREATE TABLE IF NOT EXISTS public.attendance_sessions (
  id               UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  school_id        UUID NOT NULL REFERENCES public.schools(id) ON DELETE CASCADE,
  class_id         UUID NOT NULL REFERENCES public.classes(id),
  stream_id        UUID REFERENCES public.streams(id),
  academic_term_id UUID NOT NULL REFERENCES public.academic_terms(id),
  session_date     DATE NOT NULL,
  session_type     TEXT NOT NULL DEFAULT 'morning'
                     CHECK (session_type IN ('morning','afternoon','full_day')),
  -- Status allows for correction workflows
  status           TEXT NOT NULL DEFAULT 'open'
                     CHECK (status IN ('open','closed','corrected')),
  recorded_by      UUID NOT NULL REFERENCES auth.users(id),
  closed_at        TIMESTAMPTZ,
  created_at       TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  -- Prevent duplicate sessions: same class, stream, date, type
  UNIQUE (school_id, class_id, stream_id, session_date, session_type)
);

CREATE INDEX IF NOT EXISTS idx_attendance_sessions_school ON public.attendance_sessions(school_id, session_date);
CREATE INDEX IF NOT EXISTS idx_attendance_sessions_class  ON public.attendance_sessions(class_id, session_date);
CREATE INDEX IF NOT EXISTS idx_attendance_sessions_term   ON public.attendance_sessions(academic_term_id);

-- =============================================================================
-- ATTENDANCE RECORDS
-- One record per student per session.
-- UNIQUE constraint prevents recording a student twice in the same session.
-- Corrections are tracked via corrected_by + corrected_at + correction_reason.
-- The original status is preserved in original_status for audit purposes.
-- =============================================================================
CREATE TABLE IF NOT EXISTS public.attendance_records (
  id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  session_id        UUID NOT NULL REFERENCES public.attendance_sessions(id) ON DELETE CASCADE,
  student_id        UUID NOT NULL REFERENCES public.students(id) ON DELETE CASCADE,
  school_id         UUID NOT NULL REFERENCES public.schools(id) ON DELETE CASCADE,
  status            TEXT NOT NULL
                      CHECK (status IN ('present','absent','late','excused')),
  notes             TEXT,
  -- Correction audit trail
  original_status   TEXT CHECK (original_status IN ('present','absent','late','excused')),
  corrected_by      UUID REFERENCES auth.users(id),
  corrected_at      TIMESTAMPTZ,
  correction_reason TEXT,
  created_at        TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  -- One record per student per session
  UNIQUE (session_id, student_id)
);

CREATE INDEX IF NOT EXISTS idx_attendance_records_session ON public.attendance_records(session_id);
CREATE INDEX IF NOT EXISTS idx_attendance_records_student ON public.attendance_records(student_id);
CREATE INDEX IF NOT EXISTS idx_attendance_records_school  ON public.attendance_records(school_id);
CREATE INDEX IF NOT EXISTS idx_attendance_records_date    ON public.attendance_records(school_id, student_id);
