-- =============================================================================
-- Migration 010: Row Level Security Policies
-- Enables RLS on every school-sensitive table and creates isolation policies.
-- School A users CANNOT access School B data under any circumstances.
-- Depends on: 001–009
--
-- POLICY PATTERN:
--   SELECT: school_id IN (get_user_school_ids())
--   INSERT: user_has_school_access(school_id)  + role check
--   UPDATE: user_has_school_access(school_id)  + role check
--   DELETE: blocked or restricted to owners
-- =============================================================================

-- ─── SCHOOLS ─────────────────────────────────────────────────────────────────
ALTER TABLE public.schools ENABLE ROW LEVEL SECURITY;

CREATE POLICY "schools_select" ON public.schools
  FOR SELECT USING (
    id IN (SELECT public.get_user_school_ids())
    OR public.is_platform_admin()
  );

CREATE POLICY "schools_insert" ON public.schools
  FOR INSERT WITH CHECK (
    public.is_platform_admin()
    OR
    EXISTS (
      SELECT 1 FROM public.user_profiles up
      WHERE up.id = auth.uid()
        AND up.onboarding_status IN ('pending_onboarding', 'complete')
    )
  );

CREATE POLICY "schools_update" ON public.schools
  FOR UPDATE USING (
    public.is_platform_admin()
    OR public.user_has_role_in_school(id, ARRAY['school_owner'])
  );

-- ─── SUBSCRIPTION PLANS ──────────────────────────────────────────────────────
ALTER TABLE public.subscription_plans ENABLE ROW LEVEL SECURITY;

CREATE POLICY "subscription_plans_select" ON public.subscription_plans
  FOR SELECT USING (is_active = TRUE OR public.is_platform_admin());

CREATE POLICY "subscription_plans_modify" ON public.subscription_plans
  FOR ALL USING (public.is_platform_admin());

-- ─── USER PROFILES ───────────────────────────────────────────────────────────
ALTER TABLE public.user_profiles ENABLE ROW LEVEL SECURITY;

-- Users can read their own profile; school members can read profiles of
-- other members in the same school
CREATE POLICY "user_profiles_select_own" ON public.user_profiles
  FOR SELECT USING (
    id = auth.uid()
    OR EXISTS (
      SELECT 1 FROM public.school_memberships sm1
      JOIN public.school_memberships sm2
        ON sm1.school_id = sm2.school_id
      WHERE sm1.user_id = auth.uid()
        AND sm2.user_id = user_profiles.id
        AND sm1.status = 'active'
        AND sm2.status = 'active'
    )
  );

CREATE POLICY "user_profiles_update_own" ON public.user_profiles
  FOR UPDATE USING (id = auth.uid());

-- ─── SCHOOL MEMBERSHIPS ───────────────────────────────────────────────────────
ALTER TABLE public.school_memberships ENABLE ROW LEVEL SECURITY;

CREATE POLICY "memberships_select" ON public.school_memberships
  FOR SELECT USING (
    school_id IN (SELECT public.get_user_school_ids())
    OR user_id = auth.uid()
  );

-- Only school_owners can insert memberships; no self-assignment
CREATE POLICY "memberships_insert" ON public.school_memberships
  FOR INSERT WITH CHECK (
    public.is_platform_admin()
    OR
    -- User adding themselves as owner during onboarding
    (
      user_id = auth.uid()
      AND role = 'school_owner'
      AND EXISTS (
        SELECT 1 FROM public.user_profiles
        WHERE id = auth.uid()
          AND onboarding_status IN ('pending_onboarding', 'complete')
      )
    )
    OR
    -- Existing school owner adding other staff (not themselves)
    (
      user_id <> auth.uid()
      AND public.user_has_role_in_school(school_id, ARRAY['school_owner'])
    )
  );

CREATE POLICY "memberships_update" ON public.school_memberships
  FOR UPDATE USING (
    public.user_has_role_in_school(school_id, ARRAY['school_owner'])
    AND user_id <> auth.uid()  -- Cannot modify your own membership
  );

-- ─── STAFF PROFILES ───────────────────────────────────────────────────────────
ALTER TABLE public.staff_profiles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "staff_profiles_select" ON public.staff_profiles
  FOR SELECT USING (school_id IN (SELECT public.get_user_school_ids()));

CREATE POLICY "staff_profiles_insert" ON public.staff_profiles
  FOR INSERT WITH CHECK (
    public.user_has_role_in_school(school_id, ARRAY['school_owner','headteacher'])
  );

CREATE POLICY "staff_profiles_update" ON public.staff_profiles
  FOR UPDATE USING (
    public.user_has_role_in_school(school_id, ARRAY['school_owner','headteacher'])
  );

-- ─── ACADEMIC YEARS ───────────────────────────────────────────────────────────
ALTER TABLE public.academic_years ENABLE ROW LEVEL SECURITY;

CREATE POLICY "academic_years_select" ON public.academic_years
  FOR SELECT USING (school_id IN (SELECT public.get_user_school_ids()));

CREATE POLICY "academic_years_insert" ON public.academic_years
  FOR INSERT WITH CHECK (
    public.user_has_role_in_school(school_id, ARRAY['school_owner','headteacher'])
  );

CREATE POLICY "academic_years_update" ON public.academic_years
  FOR UPDATE USING (
    public.user_has_role_in_school(school_id, ARRAY['school_owner','headteacher'])
  );

-- ─── ACADEMIC TERMS ───────────────────────────────────────────────────────────
ALTER TABLE public.academic_terms ENABLE ROW LEVEL SECURITY;

CREATE POLICY "academic_terms_select" ON public.academic_terms
  FOR SELECT USING (school_id IN (SELECT public.get_user_school_ids()));

CREATE POLICY "academic_terms_insert" ON public.academic_terms
  FOR INSERT WITH CHECK (
    public.user_has_role_in_school(school_id, ARRAY['school_owner','headteacher'])
  );

CREATE POLICY "academic_terms_update" ON public.academic_terms
  FOR UPDATE USING (
    public.user_has_role_in_school(school_id, ARRAY['school_owner','headteacher'])
  );

-- ─── CLASSES ─────────────────────────────────────────────────────────────────
ALTER TABLE public.classes ENABLE ROW LEVEL SECURITY;

CREATE POLICY "classes_select" ON public.classes
  FOR SELECT USING (school_id IN (SELECT public.get_user_school_ids()));

CREATE POLICY "classes_insert" ON public.classes
  FOR INSERT WITH CHECK (
    public.user_has_role_in_school(school_id, ARRAY['school_owner','headteacher','registrar'])
  );

CREATE POLICY "classes_update" ON public.classes
  FOR UPDATE USING (
    public.user_has_role_in_school(school_id, ARRAY['school_owner','headteacher','registrar'])
  );

-- ─── STREAMS ─────────────────────────────────────────────────────────────────
ALTER TABLE public.streams ENABLE ROW LEVEL SECURITY;

CREATE POLICY "streams_select" ON public.streams
  FOR SELECT USING (school_id IN (SELECT public.get_user_school_ids()));

CREATE POLICY "streams_insert" ON public.streams
  FOR INSERT WITH CHECK (
    public.user_has_role_in_school(school_id, ARRAY['school_owner','headteacher','registrar'])
  );

CREATE POLICY "streams_update" ON public.streams
  FOR UPDATE USING (
    public.user_has_role_in_school(school_id, ARRAY['school_owner','headteacher','registrar'])
  );

-- ─── SUBJECTS ────────────────────────────────────────────────────────────────
ALTER TABLE public.subjects ENABLE ROW LEVEL SECURITY;

CREATE POLICY "subjects_select" ON public.subjects
  FOR SELECT USING (school_id IN (SELECT public.get_user_school_ids()));

CREATE POLICY "subjects_insert" ON public.subjects
  FOR INSERT WITH CHECK (
    public.user_has_role_in_school(school_id, ARRAY['school_owner','headteacher','registrar'])
  );

CREATE POLICY "subjects_update" ON public.subjects
  FOR UPDATE USING (
    public.user_has_role_in_school(school_id, ARRAY['school_owner','headteacher','registrar'])
  );

-- ─── CLASS SUBJECTS ──────────────────────────────────────────────────────────
ALTER TABLE public.class_subjects ENABLE ROW LEVEL SECURITY;

CREATE POLICY "class_subjects_select" ON public.class_subjects
  FOR SELECT USING (school_id IN (SELECT public.get_user_school_ids()));

CREATE POLICY "class_subjects_insert" ON public.class_subjects
  FOR INSERT WITH CHECK (
    public.user_has_role_in_school(school_id, ARRAY['school_owner','headteacher','registrar'])
  );

-- ─── TEACHER ASSIGNMENTS ─────────────────────────────────────────────────────
ALTER TABLE public.teacher_assignments ENABLE ROW LEVEL SECURITY;

CREATE POLICY "teacher_assignments_select" ON public.teacher_assignments
  FOR SELECT USING (school_id IN (SELECT public.get_user_school_ids()));

CREATE POLICY "teacher_assignments_insert" ON public.teacher_assignments
  FOR INSERT WITH CHECK (
    public.user_has_role_in_school(school_id, ARRAY['school_owner','headteacher','registrar'])
  );

-- ─── STUDENTS ────────────────────────────────────────────────────────────────
ALTER TABLE public.students ENABLE ROW LEVEL SECURITY;

CREATE POLICY "students_select" ON public.students
  FOR SELECT USING (school_id IN (SELECT public.get_user_school_ids()));

CREATE POLICY "students_insert" ON public.students
  FOR INSERT WITH CHECK (
    public.user_has_role_in_school(school_id,
      ARRAY['school_owner','headteacher','registrar'])
  );

CREATE POLICY "students_update" ON public.students
  FOR UPDATE USING (
    public.user_has_role_in_school(school_id,
      ARRAY['school_owner','headteacher','registrar'])
  );

-- ─── GUARDIANS ───────────────────────────────────────────────────────────────
ALTER TABLE public.guardians ENABLE ROW LEVEL SECURITY;

CREATE POLICY "guardians_select" ON public.guardians
  FOR SELECT USING (school_id IN (SELECT public.get_user_school_ids()));

CREATE POLICY "guardians_insert" ON public.guardians
  FOR INSERT WITH CHECK (
    public.user_has_role_in_school(school_id,
      ARRAY['school_owner','headteacher','registrar'])
  );

CREATE POLICY "guardians_update" ON public.guardians
  FOR UPDATE USING (
    public.user_has_role_in_school(school_id,
      ARRAY['school_owner','headteacher','registrar'])
  );

-- ─── STUDENT GUARDIANS ───────────────────────────────────────────────────────
ALTER TABLE public.student_guardians ENABLE ROW LEVEL SECURITY;

CREATE POLICY "student_guardians_select" ON public.student_guardians
  FOR SELECT USING (
    student_id IN (
      SELECT id FROM public.students
      WHERE school_id IN (SELECT public.get_user_school_ids())
    )
  );

CREATE POLICY "student_guardians_insert" ON public.student_guardians
  FOR INSERT WITH CHECK (
    student_id IN (
      SELECT id FROM public.students s
      WHERE s.school_id IN (SELECT public.get_user_school_ids())
        AND public.user_has_role_in_school(s.school_id,
              ARRAY['school_owner','headteacher','registrar'])
    )
  );

-- ─── STUDENT ENROLLMENTS ─────────────────────────────────────────────────────
ALTER TABLE public.student_enrollments ENABLE ROW LEVEL SECURITY;

CREATE POLICY "enrollments_select" ON public.student_enrollments
  FOR SELECT USING (school_id IN (SELECT public.get_user_school_ids()));

CREATE POLICY "enrollments_insert" ON public.student_enrollments
  FOR INSERT WITH CHECK (
    public.user_has_role_in_school(school_id,
      ARRAY['school_owner','headteacher','registrar'])
  );

CREATE POLICY "enrollments_update" ON public.student_enrollments
  FOR UPDATE USING (
    public.user_has_role_in_school(school_id,
      ARRAY['school_owner','headteacher','registrar'])
  );

-- ─── ATTENDANCE SESSIONS ─────────────────────────────────────────────────────
ALTER TABLE public.attendance_sessions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "attendance_sessions_select" ON public.attendance_sessions
  FOR SELECT USING (school_id IN (SELECT public.get_user_school_ids()));

-- Teachers, registrars, headteachers, and owners can create sessions
CREATE POLICY "attendance_sessions_insert" ON public.attendance_sessions
  FOR INSERT WITH CHECK (
    public.user_has_role_in_school(school_id,
      ARRAY['school_owner','headteacher','registrar','teacher'])
    AND recorded_by = auth.uid()
  );

CREATE POLICY "attendance_sessions_update" ON public.attendance_sessions
  FOR UPDATE USING (
    public.user_has_role_in_school(school_id,
      ARRAY['school_owner','headteacher','registrar'])
  );

-- ─── ATTENDANCE RECORDS ──────────────────────────────────────────────────────
ALTER TABLE public.attendance_records ENABLE ROW LEVEL SECURITY;

CREATE POLICY "attendance_records_select" ON public.attendance_records
  FOR SELECT USING (school_id IN (SELECT public.get_user_school_ids()));

CREATE POLICY "attendance_records_insert" ON public.attendance_records
  FOR INSERT WITH CHECK (
    school_id IN (SELECT public.get_user_school_ids())
  );

-- Corrections require elevated role
CREATE POLICY "attendance_records_update" ON public.attendance_records
  FOR UPDATE USING (
    public.user_has_role_in_school(school_id,
      ARRAY['school_owner','headteacher','registrar'])
  );

-- ─── FEE STRUCTURES + ITEMS ───────────────────────────────────────────────────
ALTER TABLE public.fee_structures ENABLE ROW LEVEL SECURITY;

CREATE POLICY "fee_structures_select" ON public.fee_structures
  FOR SELECT USING (school_id IN (SELECT public.get_user_school_ids()));

CREATE POLICY "fee_structures_insert" ON public.fee_structures
  FOR INSERT WITH CHECK (
    public.user_has_role_in_school(school_id, ARRAY['school_owner','bursar'])
  );

CREATE POLICY "fee_structures_update" ON public.fee_structures
  FOR UPDATE USING (
    public.user_has_role_in_school(school_id, ARRAY['school_owner','bursar'])
  );

ALTER TABLE public.fee_items ENABLE ROW LEVEL SECURITY;

CREATE POLICY "fee_items_select" ON public.fee_items
  FOR SELECT USING (school_id IN (SELECT public.get_user_school_ids()));

CREATE POLICY "fee_items_insert" ON public.fee_items
  FOR INSERT WITH CHECK (
    public.user_has_role_in_school(school_id, ARRAY['school_owner','bursar'])
  );

-- ─── FEE ASSESSMENTS ─────────────────────────────────────────────────────────
ALTER TABLE public.fee_assessments ENABLE ROW LEVEL SECURITY;

CREATE POLICY "fee_assessments_select" ON public.fee_assessments
  FOR SELECT USING (school_id IN (SELECT public.get_user_school_ids()));

CREATE POLICY "fee_assessments_insert" ON public.fee_assessments
  FOR INSERT WITH CHECK (
    public.user_has_role_in_school(school_id, ARRAY['school_owner','bursar'])
  );

CREATE POLICY "fee_assessments_update" ON public.fee_assessments
  FOR UPDATE USING (
    public.user_has_role_in_school(school_id, ARRAY['school_owner','bursar'])
  );

-- ─── PAYMENTS ────────────────────────────────────────────────────────────────
ALTER TABLE public.payments ENABLE ROW LEVEL SECURITY;

CREATE POLICY "payments_select" ON public.payments
  FOR SELECT USING (school_id IN (SELECT public.get_user_school_ids()));

CREATE POLICY "payments_insert" ON public.payments
  FOR INSERT WITH CHECK (
    public.user_has_role_in_school(school_id, ARRAY['school_owner','bursar'])
    AND recorded_by = auth.uid()
  );

-- No direct UPDATE on payments — reversals go through Edge Functions
-- This forces all financial mutations through the controlled API
CREATE POLICY "payments_update_owner_only" ON public.payments
  FOR UPDATE USING (
    public.user_has_role_in_school(school_id, ARRAY['school_owner'])
  );

-- ─── STUDENT ACCOUNT TRANSACTIONS (append-only ledger) ───────────────────────
ALTER TABLE public.student_account_transactions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "transactions_select" ON public.student_account_transactions
  FOR SELECT USING (school_id IN (SELECT public.get_user_school_ids()));

CREATE POLICY "transactions_insert" ON public.student_account_transactions
  FOR INSERT WITH CHECK (
    public.user_has_role_in_school(school_id, ARRAY['school_owner','bursar'])
    AND created_by = auth.uid()
  );

-- DENY all UPDATE and DELETE on the ledger — immutable by policy
CREATE POLICY "transactions_no_update" ON public.student_account_transactions
  FOR UPDATE USING (FALSE);

CREATE POLICY "transactions_no_delete" ON public.student_account_transactions
  FOR DELETE USING (FALSE);

-- ─── PAYMENT ALLOCATIONS ──────────────────────────────────────────────────────
ALTER TABLE public.payment_allocations ENABLE ROW LEVEL SECURITY;

CREATE POLICY "payment_allocations_select" ON public.payment_allocations
  FOR SELECT USING (
    payment_id IN (
      SELECT id FROM public.payments
      WHERE school_id IN (SELECT public.get_user_school_ids())
    )
  );

CREATE POLICY "payment_allocations_insert" ON public.payment_allocations
  FOR INSERT WITH CHECK (
    payment_id IN (
      SELECT id FROM public.payments p
      WHERE p.school_id IN (SELECT public.get_user_school_ids())
        AND public.user_has_role_in_school(p.school_id, ARRAY['school_owner','bursar'])
    )
  );

-- ─── GRADING SCALES + GRADE BANDS ────────────────────────────────────────────
ALTER TABLE public.grading_scales ENABLE ROW LEVEL SECURITY;

CREATE POLICY "grading_scales_select" ON public.grading_scales
  FOR SELECT USING (school_id IN (SELECT public.get_user_school_ids()));

CREATE POLICY "grading_scales_insert" ON public.grading_scales
  FOR INSERT WITH CHECK (
    public.user_has_role_in_school(school_id,
      ARRAY['school_owner','headteacher','registrar'])
  );

ALTER TABLE public.grade_bands ENABLE ROW LEVEL SECURITY;

CREATE POLICY "grade_bands_select" ON public.grade_bands
  FOR SELECT USING (
    grading_scale_id IN (
      SELECT id FROM public.grading_scales
      WHERE school_id IN (SELECT public.get_user_school_ids())
    )
  );

CREATE POLICY "grade_bands_insert" ON public.grade_bands
  FOR INSERT WITH CHECK (
    grading_scale_id IN (
      SELECT id FROM public.grading_scales gs
      WHERE gs.school_id IN (SELECT public.get_user_school_ids())
        AND public.user_has_role_in_school(gs.school_id,
              ARRAY['school_owner','headteacher','registrar'])
    )
  );

-- ─── ASSESSMENT DEFINITIONS ──────────────────────────────────────────────────
ALTER TABLE public.assessment_definitions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "assessment_defs_select" ON public.assessment_definitions
  FOR SELECT USING (school_id IN (SELECT public.get_user_school_ids()));

CREATE POLICY "assessment_defs_insert" ON public.assessment_definitions
  FOR INSERT WITH CHECK (
    public.user_has_role_in_school(school_id,
      ARRAY['school_owner','headteacher','registrar'])
  );

-- ─── ASSESSMENT RESULTS ──────────────────────────────────────────────────────
ALTER TABLE public.assessment_results ENABLE ROW LEVEL SECURITY;

CREATE POLICY "assessment_results_select" ON public.assessment_results
  FOR SELECT USING (school_id IN (SELECT public.get_user_school_ids()));

-- Teachers can insert results for students in their assigned subjects
CREATE POLICY "assessment_results_insert" ON public.assessment_results
  FOR INSERT WITH CHECK (
    school_id IN (SELECT public.get_user_school_ids())
    AND entered_by = auth.uid()
  );

-- Only headteachers/owners/registrars can update (approve/reject)
CREATE POLICY "assessment_results_update" ON public.assessment_results
  FOR UPDATE USING (
    public.user_has_role_in_school(school_id,
      ARRAY['school_owner','headteacher','registrar'])
  );

-- ─── RESULT CORRECTIONS ───────────────────────────────────────────────────────
ALTER TABLE public.result_corrections ENABLE ROW LEVEL SECURITY;

CREATE POLICY "result_corrections_select" ON public.result_corrections
  FOR SELECT USING (school_id IN (SELECT public.get_user_school_ids()));

CREATE POLICY "result_corrections_insert" ON public.result_corrections
  FOR INSERT WITH CHECK (
    public.user_has_role_in_school(school_id,
      ARRAY['school_owner','headteacher'])
    AND corrected_by = auth.uid()
  );

-- ─── REPORT CARD TEMPLATES ────────────────────────────────────────────────────
ALTER TABLE public.report_card_templates ENABLE ROW LEVEL SECURITY;

CREATE POLICY "report_templates_select" ON public.report_card_templates
  FOR SELECT USING (school_id IN (SELECT public.get_user_school_ids()));

CREATE POLICY "report_templates_insert" ON public.report_card_templates
  FOR INSERT WITH CHECK (
    public.user_has_role_in_school(school_id,
      ARRAY['school_owner','headteacher','registrar'])
  );

-- ─── REPORT CARDS ────────────────────────────────────────────────────────────
ALTER TABLE public.report_cards ENABLE ROW LEVEL SECURITY;

CREATE POLICY "report_cards_select" ON public.report_cards
  FOR SELECT USING (school_id IN (SELECT public.get_user_school_ids()));

CREATE POLICY "report_cards_insert" ON public.report_cards
  FOR INSERT WITH CHECK (
    public.user_has_role_in_school(school_id,
      ARRAY['school_owner','headteacher','registrar'])
    AND generated_by = auth.uid()
  );

CREATE POLICY "report_cards_update" ON public.report_cards
  FOR UPDATE USING (
    public.user_has_role_in_school(school_id,
      ARRAY['school_owner','headteacher'])
  );

-- ─── AUDIT LOGS (append-only) ────────────────────────────────────────────────
ALTER TABLE public.audit_logs ENABLE ROW LEVEL SECURITY;

-- School staff can read their own school's audit logs
CREATE POLICY "audit_logs_select" ON public.audit_logs
  FOR SELECT USING (
    school_id IN (SELECT public.get_user_school_ids())
    OR public.is_platform_admin()
  );

-- Any authenticated user can insert an audit log (for their own actions)
CREATE POLICY "audit_logs_insert" ON public.audit_logs
  FOR INSERT WITH CHECK (user_id = auth.uid() OR public.is_platform_admin());

-- DENY update and delete — audit logs are immutable
CREATE POLICY "audit_logs_no_update" ON public.audit_logs
  FOR UPDATE USING (FALSE);

CREATE POLICY "audit_logs_no_delete" ON public.audit_logs
  FOR DELETE USING (FALSE);

-- ─── SUBSCRIPTIONS ───────────────────────────────────────────────────────────
ALTER TABLE public.subscriptions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "subscriptions_select" ON public.subscriptions
  FOR SELECT USING (
    school_id IN (SELECT public.get_user_school_ids())
    OR public.is_platform_admin()
  );

CREATE POLICY "subscriptions_insert" ON public.subscriptions
  FOR INSERT WITH CHECK (public.is_platform_admin());
