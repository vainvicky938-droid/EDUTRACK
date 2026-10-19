-- =============================================================================
-- Migration 006: Fees and Financial Management
-- fee_structures, fee_items, fee_assessments, payments,
-- student_account_transactions, payment_allocations
-- Depends on: 001, 002, 003, 004
--
-- FINANCIAL INTEGRITY RULES (enforced here and in application logic):
-- 1. Payments are NEVER deleted. Reversals create new rows.
-- 2. Balances are ALWAYS calculated from student_account_transactions SUM.
-- 3. All financial mutations must be wrapped in a database transaction.
-- 4. Duplicate payment prevention via application + unique reference checks.
-- =============================================================================

-- =============================================================================
-- FEE STRUCTURES
-- A named grouping of fees applicable to a class/term combination.
-- e.g. "S2 Term 1 2026 Fees"
-- =============================================================================
CREATE TABLE IF NOT EXISTS public.fee_structures (
  id               UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  school_id        UUID NOT NULL REFERENCES public.schools(id) ON DELETE CASCADE,
  academic_year_id UUID NOT NULL REFERENCES public.academic_years(id),
  academic_term_id UUID REFERENCES public.academic_terms(id),
  -- NULL class_id means this structure applies to all classes
  class_id         UUID REFERENCES public.classes(id),
  name             TEXT NOT NULL,
  description      TEXT,
  is_active        BOOLEAN NOT NULL DEFAULT TRUE,
  created_by       UUID REFERENCES auth.users(id),
  created_at       TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at       TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_fee_structures_school ON public.fee_structures(school_id);
CREATE INDEX IF NOT EXISTS idx_fee_structures_year   ON public.fee_structures(academic_year_id);

CREATE TRIGGER set_fee_structures_updated_at
  BEFORE UPDATE ON public.fee_structures
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

-- =============================================================================
-- FEE ITEMS
-- Individual line items within a fee structure.
-- e.g. "Tuition", "Development Fee", "Lunch", "Boarding"
-- =============================================================================
CREATE TABLE IF NOT EXISTS public.fee_items (
  id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  school_id         UUID NOT NULL REFERENCES public.schools(id) ON DELETE CASCADE,
  fee_structure_id  UUID NOT NULL REFERENCES public.fee_structures(id) ON DELETE CASCADE,
  name              TEXT NOT NULL,
  description       TEXT,
  amount            NUMERIC(12,2) NOT NULL CHECK (amount >= 0),
  category          TEXT NOT NULL DEFAULT 'tuition'
                      CHECK (category IN (
                        'tuition','boarding','meals','uniform',
                        'development','activity','exam','other'
                      )),
  is_mandatory      BOOLEAN NOT NULL DEFAULT TRUE,
  created_at        TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_fee_items_structure ON public.fee_items(fee_structure_id);
CREATE INDEX IF NOT EXISTS idx_fee_items_school    ON public.fee_items(school_id);

-- =============================================================================
-- FEE ASSESSMENTS
-- What a specific student is charged for a specific fee item in a term.
-- A student may receive a discount (scholarship/bursary).
-- =============================================================================
CREATE TABLE IF NOT EXISTS public.fee_assessments (
  id               UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  school_id        UUID NOT NULL REFERENCES public.schools(id) ON DELETE CASCADE,
  student_id       UUID NOT NULL REFERENCES public.students(id) ON DELETE CASCADE,
  fee_item_id      UUID NOT NULL REFERENCES public.fee_items(id),
  academic_term_id UUID NOT NULL REFERENCES public.academic_terms(id),
  assessed_amount  NUMERIC(12,2) NOT NULL CHECK (assessed_amount >= 0),
  discount_amount  NUMERIC(12,2) NOT NULL DEFAULT 0 CHECK (discount_amount >= 0),
  discount_reason  TEXT,
  -- net_amount = assessed_amount - discount_amount (calculated in queries)
  status           TEXT NOT NULL DEFAULT 'active'
                     CHECK (status IN ('active','waived','reversed')),
  assessed_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  assessed_by      UUID NOT NULL REFERENCES auth.users(id),
  -- Prevent double-charging same student for same item in same term
  UNIQUE (student_id, fee_item_id, academic_term_id)
);

CREATE INDEX IF NOT EXISTS idx_fee_assessments_school   ON public.fee_assessments(school_id);
CREATE INDEX IF NOT EXISTS idx_fee_assessments_student  ON public.fee_assessments(student_id);
CREATE INDEX IF NOT EXISTS idx_fee_assessments_term     ON public.fee_assessments(academic_term_id);

-- =============================================================================
-- PAYMENTS
-- Records a payment made by or for a student.
-- NEVER deleted. Reversals create a new payment row with status='reversed'
-- and a corresponding reversal transaction in student_account_transactions.
-- =============================================================================
CREATE TABLE IF NOT EXISTS public.payments (
  id                    UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  school_id             UUID NOT NULL REFERENCES public.schools(id) ON DELETE CASCADE,
  student_id            UUID NOT NULL REFERENCES public.students(id) ON DELETE CASCADE,
  amount_paid           NUMERIC(12,2) NOT NULL CHECK (amount_paid > 0),
  payment_date          DATE NOT NULL DEFAULT CURRENT_DATE,
  payment_method        TEXT NOT NULL DEFAULT 'cash'
                          CHECK (payment_method IN (
                            'cash','bank_transfer','mobile_money','cheque','other'
                          )),
  -- External transaction reference (bank slip, mobile money ID, etc.)
  transaction_reference TEXT,
  -- Internal receipt number — unique within a school
  receipt_number        TEXT NOT NULL,
  status                TEXT NOT NULL DEFAULT 'confirmed'
                          CHECK (status IN ('confirmed','reversed','pending')),
  notes                 TEXT,
  recorded_by           UUID NOT NULL REFERENCES auth.users(id),
  -- If this is a reversal, link to the original payment
  reversal_of           UUID REFERENCES public.payments(id),
  created_at            TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (school_id, receipt_number)
);

CREATE INDEX IF NOT EXISTS idx_payments_school   ON public.payments(school_id);
CREATE INDEX IF NOT EXISTS idx_payments_student  ON public.payments(student_id);
CREATE INDEX IF NOT EXISTS idx_payments_date     ON public.payments(school_id, payment_date);
CREATE INDEX IF NOT EXISTS idx_payments_receipt  ON public.payments(school_id, receipt_number);

-- =============================================================================
-- STUDENT ACCOUNT TRANSACTIONS
-- The immutable financial ledger for each student.
-- Balance = SUM(amount) for a student — NEVER stored as a column.
-- Every charge, payment, discount, and reversal creates a row here.
-- Positive amount = credit (money in). Negative amount = debit (charge).
-- =============================================================================
CREATE TABLE IF NOT EXISTS public.student_account_transactions (
  id                    UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  school_id             UUID NOT NULL REFERENCES public.schools(id) ON DELETE CASCADE,
  student_id            UUID NOT NULL REFERENCES public.students(id) ON DELETE CASCADE,
  -- charge=-amount, payment=+amount, discount=+amount, reversal=+/-amount
  type                  TEXT NOT NULL
                          CHECK (type IN (
                            'charge','payment','discount','reversal','adjustment'
                          )),
  amount                NUMERIC(12,2) NOT NULL,
  reference             TEXT,
  description           TEXT NOT NULL,
  related_assessment_id UUID REFERENCES public.fee_assessments(id),
  related_payment_id    UUID REFERENCES public.payments(id),
  created_by            UUID NOT NULL REFERENCES auth.users(id),
  created_at            TIMESTAMPTZ NOT NULL DEFAULT NOW()
  -- NOTE: No UPDATE or DELETE permitted on this table (enforced by RLS)
);

CREATE INDEX IF NOT EXISTS idx_transactions_school   ON public.student_account_transactions(school_id);
CREATE INDEX IF NOT EXISTS idx_transactions_student  ON public.student_account_transactions(student_id, school_id);
CREATE INDEX IF NOT EXISTS idx_transactions_date     ON public.student_account_transactions(school_id, created_at DESC);

-- =============================================================================
-- PAYMENT ALLOCATIONS
-- Links a payment to the specific fee assessments it covers.
-- A single payment can partially cover multiple assessments.
-- =============================================================================
CREATE TABLE IF NOT EXISTS public.payment_allocations (
  id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  payment_id        UUID NOT NULL REFERENCES public.payments(id) ON DELETE CASCADE,
  fee_assessment_id UUID NOT NULL REFERENCES public.fee_assessments(id),
  allocated_amount  NUMERIC(12,2) NOT NULL CHECK (allocated_amount > 0),
  created_at        TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (payment_id, fee_assessment_id)
);

CREATE INDEX IF NOT EXISTS idx_payment_allocations_payment    ON public.payment_allocations(payment_id);
CREATE INDEX IF NOT EXISTS idx_payment_allocations_assessment ON public.payment_allocations(fee_assessment_id);

-- =============================================================================
-- RECEIPT SEQUENCE
-- Generates sequential receipt numbers per school: SCH-2026-000001
-- =============================================================================
CREATE TABLE IF NOT EXISTS public.receipt_sequences (
  school_id    UUID PRIMARY KEY REFERENCES public.schools(id) ON DELETE CASCADE,
  last_number  INTEGER NOT NULL DEFAULT 0,
  updated_at   TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Function to get next receipt number for a school
CREATE OR REPLACE FUNCTION public.next_receipt_number(p_school_id UUID)
RETURNS TEXT
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_next INTEGER;
  v_year TEXT;
BEGIN
  v_year := TO_CHAR(NOW(), 'YYYY');

  INSERT INTO public.receipt_sequences (school_id, last_number)
  VALUES (p_school_id, 1)
  ON CONFLICT (school_id) DO UPDATE
    SET last_number = receipt_sequences.last_number + 1,
        updated_at  = NOW()
  RETURNING last_number INTO v_next;

  RETURN 'RCP-' || v_year || '-' || LPAD(v_next::TEXT, 6, '0');
END;
$$;
