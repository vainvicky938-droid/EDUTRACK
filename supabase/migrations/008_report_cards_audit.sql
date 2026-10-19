-- =============================================================================
-- Migration 008: Report Cards, Audit Logs, and Subscriptions
-- Depends on: 001–007
-- =============================================================================

-- =============================================================================
-- REPORT CARD TEMPLATES
-- School-configurable template settings for how report cards look.
-- =============================================================================
CREATE TABLE IF NOT EXISTS public.report_card_templates (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  school_id     UUID NOT NULL REFERENCES public.schools(id) ON DELETE CASCADE,
  name          TEXT NOT NULL,
  -- Layout configuration stored as JSONB for flexibility
  -- e.g. {"show_attendance": true, "show_position": true, "show_teacher_comment": true}
  layout_config JSONB NOT NULL DEFAULT '{
    "show_attendance": true,
    "show_position": true,
    "show_class_average": true,
    "show_teacher_comment": true,
    "show_headteacher_comment": true,
    "show_grading_scale": true
  }',
  is_default    BOOLEAN NOT NULL DEFAULT FALSE,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (school_id, name)
);

CREATE INDEX IF NOT EXISTS idx_report_templates_school ON public.report_card_templates(school_id);

CREATE UNIQUE INDEX IF NOT EXISTS idx_report_templates_default
  ON public.report_card_templates(school_id)
  WHERE is_default = TRUE;

-- =============================================================================
-- REPORT CARDS
-- Generated report card records per student per term.
-- computed_data stores the calculated marks/grades at generation time
-- so historical cards remain accurate even if data changes later.
-- =============================================================================
CREATE TABLE IF NOT EXISTS public.report_cards (
  id                   UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  school_id            UUID NOT NULL REFERENCES public.schools(id) ON DELETE CASCADE,
  student_id           UUID NOT NULL REFERENCES public.students(id) ON DELETE CASCADE,
  academic_term_id     UUID NOT NULL REFERENCES public.academic_terms(id),
  template_id          UUID REFERENCES public.report_card_templates(id),
  status               TEXT NOT NULL DEFAULT 'draft'
                         CHECK (status IN ('draft','published')),
  -- Snapshot of calculated results at time of generation
  computed_data        JSONB NOT NULL DEFAULT '{}',
  -- Comments
  teacher_comment      TEXT,
  headteacher_comment  TEXT,
  -- Publication
  generated_at         TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  published_at         TIMESTAMPTZ,
  generated_by         UUID NOT NULL REFERENCES auth.users(id),
  published_by         UUID REFERENCES auth.users(id),
  -- One report card per student per term
  UNIQUE (student_id, academic_term_id)
);

CREATE INDEX IF NOT EXISTS idx_report_cards_school  ON public.report_cards(school_id);
CREATE INDEX IF NOT EXISTS idx_report_cards_student ON public.report_cards(student_id);
CREATE INDEX IF NOT EXISTS idx_report_cards_term    ON public.report_cards(academic_term_id);

-- =============================================================================
-- SUBSCRIPTIONS
-- Billing history for each school. Manual billing for MVP.
-- =============================================================================
CREATE TABLE IF NOT EXISTS public.subscriptions (
  id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  school_id         UUID NOT NULL REFERENCES public.schools(id) ON DELETE CASCADE,
  plan_id           UUID NOT NULL REFERENCES public.subscription_plans(id),
  status            TEXT NOT NULL DEFAULT 'active'
                      CHECK (status IN ('active','expired','cancelled','pending')),
  start_date        DATE NOT NULL,
  end_date          DATE NOT NULL,
  billing_reference TEXT,
  amount_paid_ugx   NUMERIC(12,2),
  notes             TEXT,
  created_by        UUID REFERENCES auth.users(id),
  created_at        TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_subscriptions_school ON public.subscriptions(school_id);

-- =============================================================================
-- AUDIT LOGS
-- Append-only record of sensitive actions across the system.
-- RLS policy permits INSERT but denies UPDATE and DELETE for ALL users.
-- Platform admin can read all logs; school staff can only read their school's.
-- =============================================================================
CREATE TABLE IF NOT EXISTS public.audit_logs (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  school_id   UUID REFERENCES public.schools(id),  -- NULL = platform-level action
  user_id     UUID REFERENCES auth.users(id),
  action      TEXT NOT NULL,       -- e.g. 'payment.reverse', 'marks.approve'
  entity_type TEXT NOT NULL,       -- e.g. 'payments', 'assessment_results'
  entity_id   UUID,
  old_values  JSONB,
  new_values  JSONB,
  ip_address  TEXT,
  user_agent  TEXT,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_audit_logs_school ON public.audit_logs(school_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_audit_logs_user   ON public.audit_logs(user_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_audit_logs_action ON public.audit_logs(action);
