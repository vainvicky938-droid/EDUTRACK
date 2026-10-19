-- =============================================================================
-- EduTrack Seed Data
-- Two synthetic schools for development and testing.
-- Run AFTER all migrations (001–010).
--
-- IMPORTANT: This seed creates school records and academic structure only.
-- User accounts (auth.users) must be created manually through Supabase Auth
-- or the application sign-up flow, then linked to schools via school_memberships.
--
-- TEST SCHOOLS:
--   School A: "St. Mary's College Kampala" (secondary)
--   School B: "Green Valley Primary School" (primary)
--
-- These are entirely synthetic. Any resemblance to real institutions is coincidental.
-- =============================================================================

-- ─── SUBSCRIPTION PLANS (already seeded in migration 001, just reference) ────
-- Use the existing plan IDs

-- ─── SCHOOL A: Secondary ─────────────────────────────────────────────────────
INSERT INTO public.schools (
  id, name, slug, type, address, district, phone, email, status, is_trial,
  settings
) VALUES (
  'a0000000-0000-0000-0000-000000000001',
  'St. Mary''s College Kampala',
  'st-marys-kampala',
  'secondary',
  'Plot 12, Nakasero Hill Road, Kampala',
  'Kampala',
  '+256 700 100001',
  'admin@stmarys-kampala.edu.ug',
  'active',
  FALSE,
  '{"school_motto": "Excellence in All Things", "term_count": 3}'
)
ON CONFLICT (slug) DO NOTHING;

-- ─── SCHOOL B: Primary ───────────────────────────────────────────────────────
INSERT INTO public.schools (
  id, name, slug, type, address, district, phone, email, status, is_trial,
  settings
) VALUES (
  'b0000000-0000-0000-0000-000000000002',
  'Green Valley Primary School',
  'green-valley-primary',
  'primary',
  'Plot 45, Entebbe Road, Wakiso',
  'Wakiso',
  '+256 700 200001',
  'admin@greenvalley.edu.ug',
  'active',
  TRUE,
  '{"school_motto": "Learning for Life", "term_count": 3}'
)
ON CONFLICT (slug) DO NOTHING;

-- ─── ACADEMIC YEARS ──────────────────────────────────────────────────────────

-- School A: 2026
INSERT INTO public.academic_years (id, school_id, name, start_date, end_date, is_current)
VALUES (
  'aa000001-0000-0000-0000-000000000001',
  'a0000000-0000-0000-0000-000000000001',
  '2026', '2026-01-06', '2026-11-30', TRUE
) ON CONFLICT DO NOTHING;

-- School B: 2026
INSERT INTO public.academic_years (id, school_id, name, start_date, end_date, is_current)
VALUES (
  'bb000001-0000-0000-0000-000000000002',
  'b0000000-0000-0000-0000-000000000002',
  '2026', '2026-01-06', '2026-11-30', TRUE
) ON CONFLICT DO NOTHING;

-- ─── ACADEMIC TERMS ───────────────────────────────────────────────────────────

-- School A Terms
INSERT INTO public.academic_terms (id, school_id, academic_year_id, name, start_date, end_date, is_current)
VALUES
  ('at000001-0000-0000-0000-000000000001', 'a0000000-0000-0000-0000-000000000001',
   'aa000001-0000-0000-0000-000000000001', 'Term 1', '2026-01-06', '2026-04-10', FALSE),
  ('at000002-0000-0000-0000-000000000001', 'a0000000-0000-0000-0000-000000000001',
   'aa000001-0000-0000-0000-000000000001', 'Term 2', '2026-05-04', '2026-08-07', FALSE),
  ('at000003-0000-0000-0000-000000000001', 'a0000000-0000-0000-0000-000000000001',
   'aa000001-0000-0000-0000-000000000001', 'Term 3', '2026-09-01', '2026-11-30', TRUE)
ON CONFLICT DO NOTHING;

-- School B Terms
INSERT INTO public.academic_terms (id, school_id, academic_year_id, name, start_date, end_date, is_current)
VALUES
  ('bt000001-0000-0000-0000-000000000002', 'b0000000-0000-0000-0000-000000000002',
   'bb000001-0000-0000-0000-000000000002', 'Term 1', '2026-01-06', '2026-04-10', FALSE),
  ('bt000002-0000-0000-0000-000000000002', 'b0000000-0000-0000-0000-000000000002',
   'bb000001-0000-0000-0000-000000000002', 'Term 2', '2026-05-04', '2026-08-07', FALSE),
  ('bt000003-0000-0000-0000-000000000002', 'b0000000-0000-0000-0000-000000000002',
   'bb000001-0000-0000-0000-000000000002', 'Term 3', '2026-09-01', '2026-11-30', TRUE)
ON CONFLICT DO NOTHING;

-- ─── CLASSES — School A (Secondary: S1–S6) ────────────────────────────────────
INSERT INTO public.classes (id, school_id, name, level_code, sort_order)
VALUES
  ('ac000001-0000-0000-0000-000000000001', 'a0000000-0000-0000-0000-000000000001', 'S1', 'S1', 1),
  ('ac000002-0000-0000-0000-000000000001', 'a0000000-0000-0000-0000-000000000001', 'S2', 'S2', 2),
  ('ac000003-0000-0000-0000-000000000001', 'a0000000-0000-0000-0000-000000000001', 'S3', 'S3', 3),
  ('ac000004-0000-0000-0000-000000000001', 'a0000000-0000-0000-0000-000000000001', 'S4', 'S4', 4),
  ('ac000005-0000-0000-0000-000000000001', 'a0000000-0000-0000-0000-000000000001', 'S5', 'S5', 5),
  ('ac000006-0000-0000-0000-000000000001', 'a0000000-0000-0000-0000-000000000001', 'S6', 'S6', 6)
ON CONFLICT DO NOTHING;

-- ─── CLASSES — School B (Primary: P1–P7) ─────────────────────────────────────
INSERT INTO public.classes (id, school_id, name, level_code, sort_order)
VALUES
  ('bc000001-0000-0000-0000-000000000002', 'b0000000-0000-0000-0000-000000000002', 'P1', 'P1', 1),
  ('bc000002-0000-0000-0000-000000000002', 'b0000000-0000-0000-0000-000000000002', 'P2', 'P2', 2),
  ('bc000003-0000-0000-0000-000000000002', 'b0000000-0000-0000-0000-000000000002', 'P3', 'P3', 3),
  ('bc000004-0000-0000-0000-000000000002', 'b0000000-0000-0000-0000-000000000002', 'P4', 'P4', 4),
  ('bc000005-0000-0000-0000-000000000002', 'b0000000-0000-0000-0000-000000000002', 'P5', 'P5', 5),
  ('bc000006-0000-0000-0000-000000000002', 'b0000000-0000-0000-0000-000000000002', 'P6', 'P6', 6),
  ('bc000007-0000-0000-0000-000000000002', 'b0000000-0000-0000-0000-000000000002', 'P7', 'P7', 7)
ON CONFLICT DO NOTHING;

-- ─── STREAMS — School A ───────────────────────────────────────────────────────
INSERT INTO public.streams (id, school_id, class_id, name)
VALUES
  ('as000001-0000-0000-0000-000000000001', 'a0000000-0000-0000-0000-000000000001', 'ac000001-0000-0000-0000-000000000001', 'East'),
  ('as000002-0000-0000-0000-000000000001', 'a0000000-0000-0000-0000-000000000001', 'ac000001-0000-0000-0000-000000000001', 'West'),
  ('as000003-0000-0000-0000-000000000001', 'a0000000-0000-0000-0000-000000000001', 'ac000002-0000-0000-0000-000000000001', 'East'),
  ('as000004-0000-0000-0000-000000000001', 'a0000000-0000-0000-0000-000000000001', 'ac000002-0000-0000-0000-000000000001', 'West'),
  ('as000005-0000-0000-0000-000000000001', 'a0000000-0000-0000-0000-000000000001', 'ac000003-0000-0000-0000-000000000001', 'Arts'),
  ('as000006-0000-0000-0000-000000000001', 'a0000000-0000-0000-0000-000000000001', 'ac000003-0000-0000-0000-000000000001', 'Sciences')
ON CONFLICT DO NOTHING;

-- ─── SUBJECTS — School A (Secondary) ─────────────────────────────────────────
INSERT INTO public.subjects (id, school_id, name, code)
VALUES
  ('subj0001-0000-0000-0000-000000000001', 'a0000000-0000-0000-0000-000000000001', 'Mathematics', 'MATH'),
  ('subj0002-0000-0000-0000-000000000001', 'a0000000-0000-0000-0000-000000000001', 'English Language', 'ENG'),
  ('subj0003-0000-0000-0000-000000000001', 'a0000000-0000-0000-0000-000000000001', 'Physics', 'PHY'),
  ('subj0004-0000-0000-0000-000000000001', 'a0000000-0000-0000-0000-000000000001', 'Chemistry', 'CHEM'),
  ('subj0005-0000-0000-0000-000000000001', 'a0000000-0000-0000-0000-000000000001', 'Biology', 'BIO'),
  ('subj0006-0000-0000-0000-000000000001', 'a0000000-0000-0000-0000-000000000001', 'History', 'HIST'),
  ('subj0007-0000-0000-0000-000000000001', 'a0000000-0000-0000-0000-000000000001', 'Geography', 'GEO'),
  ('subj0008-0000-0000-0000-000000000001', 'a0000000-0000-0000-0000-000000000001', 'Christian Religious Education', 'CRE'),
  ('subj0009-0000-0000-0000-000000000001', 'a0000000-0000-0000-0000-000000000001', 'Computer Studies', 'COMP'),
  ('subj0010-0000-0000-0000-000000000001', 'a0000000-0000-0000-0000-000000000001', 'Luganda', 'LUG')
ON CONFLICT DO NOTHING;

-- ─── SUBJECTS — School B (Primary) ───────────────────────────────────────────
INSERT INTO public.subjects (id, school_id, name, code)
VALUES
  ('subj0001-0000-0000-0000-000000000002', 'b0000000-0000-0000-0000-000000000002', 'Mathematics', 'MATH'),
  ('subj0002-0000-0000-0000-000000000002', 'b0000000-0000-0000-0000-000000000002', 'English Language', 'ENG'),
  ('subj0003-0000-0000-0000-000000000002', 'b0000000-0000-0000-0000-000000000002', 'Science', 'SCI'),
  ('subj0004-0000-0000-0000-000000000002', 'b0000000-0000-0000-0000-000000000002', 'Social Studies', 'SST'),
  ('subj0005-0000-0000-0000-000000000002', 'b0000000-0000-0000-0000-000000000002', 'Religious Education', 'RE'),
  ('subj0006-0000-0000-0000-000000000002', 'b0000000-0000-0000-0000-000000000002', 'Luganda', 'LUG')
ON CONFLICT DO NOTHING;

-- ─── GRADING SCALES ───────────────────────────────────────────────────────────

-- School A default grading scale (secondary)
INSERT INTO public.grading_scales (id, school_id, name, is_default)
VALUES (
  'gs000001-0000-0000-0000-000000000001',
  'a0000000-0000-0000-0000-000000000001',
  'Standard Secondary Scale', TRUE
) ON CONFLICT DO NOTHING;

INSERT INTO public.grade_bands (grading_scale_id, letter_grade, min_percent, max_percent, interpretation, points, sort_order)
VALUES
  ('gs000001-0000-0000-0000-000000000001', 'D1', 80, 100, 'Distinction 1', 1, 1),
  ('gs000001-0000-0000-0000-000000000001', 'D2', 75, 79,  'Distinction 2', 2, 2),
  ('gs000001-0000-0000-0000-000000000001', 'C3', 70, 74,  'Credit 3',      3, 3),
  ('gs000001-0000-0000-0000-000000000001', 'C4', 65, 69,  'Credit 4',      4, 4),
  ('gs000001-0000-0000-0000-000000000001', 'C5', 60, 64,  'Credit 5',      5, 5),
  ('gs000001-0000-0000-0000-000000000001', 'C6', 55, 59,  'Credit 6',      6, 6),
  ('gs000001-0000-0000-0000-000000000001', 'P7', 45, 54,  'Pass 7',        7, 7),
  ('gs000001-0000-0000-0000-000000000001', 'P8', 40, 44,  'Pass 8',        8, 8),
  ('gs000001-0000-0000-0000-000000000001', 'F9', 0,  39,  'Fail',          9, 9)
ON CONFLICT DO NOTHING;

-- School B default grading scale (primary)
INSERT INTO public.grading_scales (id, school_id, name, is_default)
VALUES (
  'gs000001-0000-0000-0000-000000000002',
  'b0000000-0000-0000-0000-000000000002',
  'Standard Primary Scale', TRUE
) ON CONFLICT DO NOTHING;

INSERT INTO public.grade_bands (grading_scale_id, letter_grade, min_percent, max_percent, interpretation, sort_order)
VALUES
  ('gs000001-0000-0000-0000-000000000002', 'A',  75, 100, 'Excellent',    1),
  ('gs000001-0000-0000-0000-000000000002', 'B',  65, 74,  'Very Good',    2),
  ('gs000001-0000-0000-0000-000000000002', 'C',  50, 64,  'Good',         3),
  ('gs000001-0000-0000-0000-000000000002', 'D',  40, 49,  'Satisfactory', 4),
  ('gs000001-0000-0000-0000-000000000002', 'E',  30, 39,  'Needs Work',   5),
  ('gs000001-0000-0000-0000-000000000002', 'U',  0,  29,  'Unsatisfactory',6)
ON CONFLICT DO NOTHING;

-- ─── REPORT CARD TEMPLATES ────────────────────────────────────────────────────
INSERT INTO public.report_card_templates (id, school_id, name, is_default)
VALUES
  ('rct00001-0000-0000-0000-000000000001',
   'a0000000-0000-0000-0000-000000000001',
   'Standard Report Card', TRUE),
  ('rct00001-0000-0000-0000-000000000002',
   'b0000000-0000-0000-0000-000000000002',
   'Standard Report Card', TRUE)
ON CONFLICT DO NOTHING;

-- ─── SAMPLE STUDENTS — School A ───────────────────────────────────────────────
INSERT INTO public.students (id, school_id, admission_number, full_name, date_of_birth, gender, admission_date, status)
VALUES
  ('st000001-0000-0000-0000-000000000001', 'a0000000-0000-0000-0000-000000000001', 'SMA/2024/001', 'Akello Diana',     '2010-03-15', 'female', '2024-01-08', 'active'),
  ('st000002-0000-0000-0000-000000000001', 'a0000000-0000-0000-0000-000000000001', 'SMA/2024/002', 'Okello Brian',     '2010-07-22', 'male',   '2024-01-08', 'active'),
  ('st000003-0000-0000-0000-000000000001', 'a0000000-0000-0000-0000-000000000001', 'SMA/2024/003', 'Nakato Sarah',     '2009-11-05', 'female', '2024-01-08', 'active'),
  ('st000004-0000-0000-0000-000000000001', 'a0000000-0000-0000-0000-000000000001', 'SMA/2025/001', 'Mugisha Peter',    '2011-01-18', 'male',   '2025-01-06', 'active'),
  ('st000005-0000-0000-0000-000000000001', 'a0000000-0000-0000-0000-000000000001', 'SMA/2025/002', 'Namusoke Grace',   '2010-08-30', 'female', '2025-01-06', 'active')
ON CONFLICT DO NOTHING;

-- ─── SAMPLE STUDENTS — School B ───────────────────────────────────────────────
INSERT INTO public.students (id, school_id, admission_number, full_name, date_of_birth, gender, admission_date, status)
VALUES
  ('st000001-0000-0000-0000-000000000002', 'b0000000-0000-0000-0000-000000000002', 'GVP/2024/001', 'Tendo James',      '2016-04-10', 'male',   '2024-01-08', 'active'),
  ('st000002-0000-0000-0000-000000000002', 'b0000000-0000-0000-0000-000000000002', 'GVP/2024/002', 'Namukasa Irene',   '2016-09-14', 'female', '2024-01-08', 'active'),
  ('st000003-0000-0000-0000-000000000002', 'b0000000-0000-0000-0000-000000000002', 'GVP/2025/001', 'Ssemwogerere Max', '2015-06-20', 'male',   '2025-01-06', 'active')
ON CONFLICT DO NOTHING;

-- ─── ENROLLMENTS — School A (S1 East, 2026) ──────────────────────────────────
INSERT INTO public.student_enrollments (school_id, student_id, academic_year_id, class_id, stream_id, status, enrolled_date)
VALUES
  ('a0000000-0000-0000-0000-000000000001', 'st000001-0000-0000-0000-000000000001',
   'aa000001-0000-0000-0000-000000000001', 'ac000003-0000-0000-0000-000000000001',
   'as000005-0000-0000-0000-000000000001', 'active', '2026-01-06'),
  ('a0000000-0000-0000-0000-000000000001', 'st000002-0000-0000-0000-000000000001',
   'aa000001-0000-0000-0000-000000000001', 'ac000003-0000-0000-0000-000000000001',
   'as000005-0000-0000-0000-000000000001', 'active', '2026-01-06'),
  ('a0000000-0000-0000-0000-000000000001', 'st000003-0000-0000-0000-000000000001',
   'aa000001-0000-0000-0000-000000000001', 'ac000004-0000-0000-0000-000000000001',
   NULL, 'active', '2026-01-06'),
  ('a0000000-0000-0000-0000-000000000001', 'st000004-0000-0000-0000-000000000001',
   'aa000001-0000-0000-0000-000000000001', 'ac000001-0000-0000-0000-000000000001',
   'as000001-0000-0000-0000-000000000001', 'active', '2026-01-06'),
  ('a0000000-0000-0000-0000-000000000001', 'st000005-0000-0000-0000-000000000001',
   'aa000001-0000-0000-0000-000000000001', 'ac000001-0000-0000-0000-000000000001',
   'as000002-0000-0000-0000-000000000001', 'active', '2026-01-06')
ON CONFLICT DO NOTHING;

-- ─── ENROLLMENTS — School B ────────────────────────────────────────────────────
INSERT INTO public.student_enrollments (school_id, student_id, academic_year_id, class_id, status, enrolled_date)
VALUES
  ('b0000000-0000-0000-0000-000000000002', 'st000001-0000-0000-0000-000000000002',
   'bb000001-0000-0000-0000-000000000002', 'bc000003-0000-0000-0000-000000000002', 'active', '2026-01-06'),
  ('b0000000-0000-0000-0000-000000000002', 'st000002-0000-0000-0000-000000000002',
   'bb000001-0000-0000-0000-000000000002', 'bc000003-0000-0000-0000-000000000002', 'active', '2026-01-06'),
  ('b0000000-0000-0000-0000-000000000002', 'st000003-0000-0000-0000-000000000002',
   'bb000001-0000-0000-0000-000000000002', 'bc000004-0000-0000-0000-000000000002', 'active', '2026-01-06')
ON CONFLICT DO NOTHING;

-- =============================================================================
-- HOW TO CREATE TEST USERS (cannot be done via SQL — requires Supabase Auth)
-- =============================================================================
-- After running this seed, create the following test accounts in Supabase:
--
-- 1. Go to Supabase Dashboard → Authentication → Users → "Add user"
--
-- School A Admin:
--   Email: admin.stmarys@edutrack.test
--   Password: TestPass2026!
--   → Then run: INSERT INTO school_memberships (school_id, user_id, role)
--               VALUES ('a0000000-...', '<new-user-uuid>', 'school_owner');
--
-- School A Teacher:
--   Email: teacher.stmarys@edutrack.test
--   Password: TestPass2026!
--   → Then run: INSERT INTO school_memberships ... role = 'teacher'
--
-- School B Admin:
--   Email: admin.greenvalley@edutrack.test
--   Password: TestPass2026!
--   → Then run: INSERT INTO school_memberships (school_id, user_id, role)
--               VALUES ('b0000000-...', '<new-user-uuid>', 'school_owner');
--
-- ISOLATION TEST:
--   Log in as School A admin → confirm cannot see School B students
--   Log in as School B admin → confirm cannot see School A students
-- =============================================================================
