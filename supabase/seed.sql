-- =============================================================================
-- EduTrack Seed Data
-- Two synthetic schools for development and testing.
-- Run AFTER all migrations (001–010).
-- =============================================================================

-- ─── SCHOOL A: Secondary ─────────────────────────────────────────────────────
INSERT INTO public.schools (
  id, name, slug, type, address, district, phone, email, status, is_trial, settings
) VALUES (
  'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11',
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
  id, name, slug, type, address, district, phone, email, status, is_trial, settings
) VALUES (
  'b0eebc99-9c0b-4ef8-bb6d-6bb9bd380a22',
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

INSERT INTO public.academic_years (id, school_id, name, start_date, end_date, is_current)
VALUES (
  'aa000001-9c0b-4ef8-bb6d-6bb9bd380a11',
  'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11',
  '2026', '2026-01-06', '2026-11-30', TRUE
) ON CONFLICT DO NOTHING;

INSERT INTO public.academic_years (id, school_id, name, start_date, end_date, is_current)
VALUES (
  'bb000001-9c0b-4ef8-bb6d-6bb9bd380a22',
  'b0eebc99-9c0b-4ef8-bb6d-6bb9bd380a22',
  '2026', '2026-01-06', '2026-11-30', TRUE
) ON CONFLICT DO NOTHING;

-- ─── ACADEMIC TERMS — School A ───────────────────────────────────────────────

INSERT INTO public.academic_terms (id, school_id, academic_year_id, name, start_date, end_date, is_current)
VALUES
  ('at000001-9c0b-4ef8-bb6d-6bb9bd380a11', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11',
   'aa000001-9c0b-4ef8-bb6d-6bb9bd380a11', 'Term 1', '2026-01-06', '2026-04-10', FALSE),
  ('at000002-9c0b-4ef8-bb6d-6bb9bd380a11', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11',
   'aa000001-9c0b-4ef8-bb6d-6bb9bd380a11', 'Term 2', '2026-05-04', '2026-08-07', FALSE),
  ('at000003-9c0b-4ef8-bb6d-6bb9bd380a11', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11',
   'aa000001-9c0b-4ef8-bb6d-6bb9bd380a11', 'Term 3', '2026-09-01', '2026-11-30', TRUE)
ON CONFLICT DO NOTHING;

-- ─── ACADEMIC TERMS — School B ───────────────────────────────────────────────

INSERT INTO public.academic_terms (id, school_id, academic_year_id, name, start_date, end_date, is_current)
VALUES
  ('bt000001-9c0b-4ef8-bb6d-6bb9bd380a22', 'b0eebc99-9c0b-4ef8-bb6d-6bb9bd380a22',
   'bb000001-9c0b-4ef8-bb6d-6bb9bd380a22', 'Term 1', '2026-01-06', '2026-04-10', FALSE),
  ('bt000002-9c0b-4ef8-bb6d-6bb9bd380a22', 'b0eebc99-9c0b-4ef8-bb6d-6bb9bd380a22',
   'bb000001-9c0b-4ef8-bb6d-6bb9bd380a22', 'Term 2', '2026-05-04', '2026-08-07', FALSE),
  ('bt000003-9c0b-4ef8-bb6d-6bb9bd380a22', 'b0eebc99-9c0b-4ef8-bb6d-6bb9bd380a22',
   'bb000001-9c0b-4ef8-bb6d-6bb9bd380a22', 'Term 3', '2026-09-01', '2026-11-30', TRUE)
ON CONFLICT DO NOTHING;

-- ─── CLASSES — School A (Secondary S1–S6) ────────────────────────────────────

INSERT INTO public.classes (id, school_id, name, level_code, sort_order)
VALUES
  ('ac000001-9c0b-4ef8-bb6d-6bb9bd380a11', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'S1', 'S1', 1),
  ('ac000002-9c0b-4ef8-bb6d-6bb9bd380a11', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'S2', 'S2', 2),
  ('ac000003-9c0b-4ef8-bb6d-6bb9bd380a11', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'S3', 'S3', 3),
  ('ac000004-9c0b-4ef8-bb6d-6bb9bd380a11', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'S4', 'S4', 4),
  ('ac000005-9c0b-4ef8-bb6d-6bb9bd380a11', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'S5', 'S5', 5),
  ('ac000006-9c0b-4ef8-bb6d-6bb9bd380a11', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'S6', 'S6', 6)
ON CONFLICT DO NOTHING;

-- ─── CLASSES — School B (Primary P1–P7) ──────────────────────────────────────

INSERT INTO public.classes (id, school_id, name, level_code, sort_order)
VALUES
  ('bc000001-9c0b-4ef8-bb6d-6bb9bd380a22', 'b0eebc99-9c0b-4ef8-bb6d-6bb9bd380a22', 'P1', 'P1', 1),
  ('bc000002-9c0b-4ef8-bb6d-6bb9bd380a22', 'b0eebc99-9c0b-4ef8-bb6d-6bb9bd380a22', 'P2', 'P2', 2),
  ('bc000003-9c0b-4ef8-bb6d-6bb9bd380a22', 'b0eebc99-9c0b-4ef8-bb6d-6bb9bd380a22', 'P3', 'P3', 3),
  ('bc000004-9c0b-4ef8-bb6d-6bb9bd380a22', 'b0eebc99-9c0b-4ef8-bb6d-6bb9bd380a22', 'P4', 'P4', 4),
  ('bc000005-9c0b-4ef8-bb6d-6bb9bd380a22', 'b0eebc99-9c0b-4ef8-bb6d-6bb9bd380a22', 'P5', 'P5', 5),
  ('bc000006-9c0b-4ef8-bb6d-6bb9bd380a22', 'b0eebc99-9c0b-4ef8-bb6d-6bb9bd380a22', 'P6', 'P6', 6),
  ('bc000007-9c0b-4ef8-bb6d-6bb9bd380a22', 'b0eebc99-9c0b-4ef8-bb6d-6bb9bd380a22', 'P7', 'P7', 7)
ON CONFLICT DO NOTHING;

-- ─── STREAMS — School A ───────────────────────────────────────────────────────

INSERT INTO public.streams (id, school_id, class_id, name)
VALUES
  ('as000001-9c0b-4ef8-bb6d-6bb9bd380a11', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'ac000001-9c0b-4ef8-bb6d-6bb9bd380a11', 'East'),
  ('as000002-9c0b-4ef8-bb6d-6bb9bd380a11', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'ac000001-9c0b-4ef8-bb6d-6bb9bd380a11', 'West'),
  ('as000003-9c0b-4ef8-bb6d-6bb9bd380a11', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'ac000002-9c0b-4ef8-bb6d-6bb9bd380a11', 'East'),
  ('as000004-9c0b-4ef8-bb6d-6bb9bd380a11', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'ac000002-9c0b-4ef8-bb6d-6bb9bd380a11', 'West'),
  ('as000005-9c0b-4ef8-bb6d-6bb9bd380a11', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'ac000003-9c0b-4ef8-bb6d-6bb9bd380a11', 'Arts'),
  ('as000006-9c0b-4ef8-bb6d-6bb9bd380a11', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'ac000003-9c0b-4ef8-bb6d-6bb9bd380a11', 'Sciences')
ON CONFLICT DO NOTHING;

-- ─── SUBJECTS — School A (Secondary) ─────────────────────────────────────────

INSERT INTO public.subjects (id, school_id, name, code)
VALUES
  ('subja001-9c0b-4ef8-bb6d-6bb9bd380a11', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Mathematics',                 'MATH'),
  ('subja002-9c0b-4ef8-bb6d-6bb9bd380a11', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'English Language',            'ENG'),
  ('subja003-9c0b-4ef8-bb6d-6bb9bd380a11', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Physics',                     'PHY'),
  ('subja004-9c0b-4ef8-bb6d-6bb9bd380a11', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Chemistry',                   'CHEM'),
  ('subja005-9c0b-4ef8-bb6d-6bb9bd380a11', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Biology',                     'BIO'),
  ('subja006-9c0b-4ef8-bb6d-6bb9bd380a11', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'History',                     'HIST'),
  ('subja007-9c0b-4ef8-bb6d-6bb9bd380a11', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Geography',                   'GEO'),
  ('subja008-9c0b-4ef8-bb6d-6bb9bd380a11', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Christian Religious Education','CRE'),
  ('subja009-9c0b-4ef8-bb6d-6bb9bd380a11', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Computer Studies',            'COMP'),
  ('subja010-9c0b-4ef8-bb6d-6bb9bd380a11', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Luganda',                     'LUG')
ON CONFLICT DO NOTHING;

-- ─── SUBJECTS — School B (Primary) ───────────────────────────────────────────

INSERT INTO public.subjects (id, school_id, name, code)
VALUES
  ('subjb001-9c0b-4ef8-bb6d-6bb9bd380a22', 'b0eebc99-9c0b-4ef8-bb6d-6bb9bd380a22', 'Mathematics',      'MATH'),
  ('subjb002-9c0b-4ef8-bb6d-6bb9bd380a22', 'b0eebc99-9c0b-4ef8-bb6d-6bb9bd380a22', 'English Language', 'ENG'),
  ('subjb003-9c0b-4ef8-bb6d-6bb9bd380a22', 'b0eebc99-9c0b-4ef8-bb6d-6bb9bd380a22', 'Science',          'SCI'),
  ('subjb004-9c0b-4ef8-bb6d-6bb9bd380a22', 'b0eebc99-9c0b-4ef8-bb6d-6bb9bd380a22', 'Social Studies',   'SST'),
  ('subjb005-9c0b-4ef8-bb6d-6bb9bd380a22', 'b0eebc99-9c0b-4ef8-bb6d-6bb9bd380a22', 'Religious Education','RE'),
  ('subjb006-9c0b-4ef8-bb6d-6bb9bd380a22', 'b0eebc99-9c0b-4ef8-bb6d-6bb9bd380a22', 'Luganda',          'LUG')
ON CONFLICT DO NOTHING;

-- ─── GRADING SCALES ───────────────────────────────────────────────────────────

INSERT INTO public.grading_scales (id, school_id, name, is_default)
VALUES (
  'gsa00001-9c0b-4ef8-bb6d-6bb9bd380a11',
  'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11',
  'Standard Secondary Scale', TRUE
) ON CONFLICT DO NOTHING;

INSERT INTO public.grade_bands (grading_scale_id, letter_grade, min_percent, max_percent, interpretation, points, sort_order)
VALUES
  ('gsa00001-9c0b-4ef8-bb6d-6bb9bd380a11', 'D1', 80, 100, 'Distinction 1',  1, 1),
  ('gsa00001-9c0b-4ef8-bb6d-6bb9bd380a11', 'D2', 75,  79, 'Distinction 2',  2, 2),
  ('gsa00001-9c0b-4ef8-bb6d-6bb9bd380a11', 'C3', 70,  74, 'Credit 3',       3, 3),
  ('gsa00001-9c0b-4ef8-bb6d-6bb9bd380a11', 'C4', 65,  69, 'Credit 4',       4, 4),
  ('gsa00001-9c0b-4ef8-bb6d-6bb9bd380a11', 'C5', 60,  64, 'Credit 5',       5, 5),
  ('gsa00001-9c0b-4ef8-bb6d-6bb9bd380a11', 'C6', 55,  59, 'Credit 6',       6, 6),
  ('gsa00001-9c0b-4ef8-bb6d-6bb9bd380a11', 'P7', 45,  54, 'Pass 7',         7, 7),
  ('gsa00001-9c0b-4ef8-bb6d-6bb9bd380a11', 'P8', 40,  44, 'Pass 8',         8, 8),
  ('gsa00001-9c0b-4ef8-bb6d-6bb9bd380a11', 'F9',  0,  39, 'Fail',           9, 9)
ON CONFLICT DO NOTHING;

INSERT INTO public.grading_scales (id, school_id, name, is_default)
VALUES (
  'gsb00001-9c0b-4ef8-bb6d-6bb9bd380a22',
  'b0eebc99-9c0b-4ef8-bb6d-6bb9bd380a22',
  'Standard Primary Scale', TRUE
) ON CONFLICT DO NOTHING;

INSERT INTO public.grade_bands (grading_scale_id, letter_grade, min_percent, max_percent, interpretation, sort_order)
VALUES
  ('gsb00001-9c0b-4ef8-bb6d-6bb9bd380a22', 'A', 75, 100, 'Excellent',       1),
  ('gsb00001-9c0b-4ef8-bb6d-6bb9bd380a22', 'B', 65,  74, 'Very Good',       2),
  ('gsb00001-9c0b-4ef8-bb6d-6bb9bd380a22', 'C', 50,  64, 'Good',            3),
  ('gsb00001-9c0b-4ef8-bb6d-6bb9bd380a22', 'D', 40,  49, 'Satisfactory',    4),
  ('gsb00001-9c0b-4ef8-bb6d-6bb9bd380a22', 'E', 30,  39, 'Needs Work',      5),
  ('gsb00001-9c0b-4ef8-bb6d-6bb9bd380a22', 'U',  0,  29, 'Unsatisfactory',  6)
ON CONFLICT DO NOTHING;

-- ─── REPORT CARD TEMPLATES ────────────────────────────────────────────────────

INSERT INTO public.report_card_templates (id, school_id, name, is_default)
VALUES
  ('rcta0001-9c0b-4ef8-bb6d-6bb9bd380a11', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Standard Report Card', TRUE),
  ('rctb0001-9c0b-4ef8-bb6d-6bb9bd380a22', 'b0eebc99-9c0b-4ef8-bb6d-6bb9bd380a22', 'Standard Report Card', TRUE)
ON CONFLICT DO NOTHING;

-- ─── SAMPLE STUDENTS — School A ───────────────────────────────────────────────

INSERT INTO public.students (id, school_id, admission_number, full_name, date_of_birth, gender, admission_date, status)
VALUES
  ('sta00001-9c0b-4ef8-bb6d-6bb9bd380a11', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'SMA/2024/001', 'Akello Diana',   '2010-03-15', 'female', '2024-01-08', 'active'),
  ('sta00002-9c0b-4ef8-bb6d-6bb9bd380a11', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'SMA/2024/002', 'Okello Brian',   '2010-07-22', 'male',   '2024-01-08', 'active'),
  ('sta00003-9c0b-4ef8-bb6d-6bb9bd380a11', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'SMA/2024/003', 'Nakato Sarah',   '2009-11-05', 'female', '2024-01-08', 'active'),
  ('sta00004-9c0b-4ef8-bb6d-6bb9bd380a11', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'SMA/2025/001', 'Mugisha Peter',  '2011-01-18', 'male',   '2025-01-06', 'active'),
  ('sta00005-9c0b-4ef8-bb6d-6bb9bd380a11', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'SMA/2025/002', 'Namusoke Grace', '2010-08-30', 'female', '2025-01-06', 'active')
ON CONFLICT DO NOTHING;

-- ─── SAMPLE STUDENTS — School B ───────────────────────────────────────────────

INSERT INTO public.students (id, school_id, admission_number, full_name, date_of_birth, gender, admission_date, status)
VALUES
  ('stb00001-9c0b-4ef8-bb6d-6bb9bd380a22', 'b0eebc99-9c0b-4ef8-bb6d-6bb9bd380a22', 'GVP/2024/001', 'Tendo James',       '2016-04-10', 'male',   '2024-01-08', 'active'),
  ('stb00002-9c0b-4ef8-bb6d-6bb9bd380a22', 'b0eebc99-9c0b-4ef8-bb6d-6bb9bd380a22', 'GVP/2024/002', 'Namukasa Irene',    '2016-09-14', 'female', '2024-01-08', 'active'),
  ('stb00003-9c0b-4ef8-bb6d-6bb9bd380a22', 'b0eebc99-9c0b-4ef8-bb6d-6bb9bd380a22', 'GVP/2025/001', 'Ssemwogerere Max',  '2015-06-20', 'male',   '2025-01-06', 'active')
ON CONFLICT DO NOTHING;

-- ─── ENROLLMENTS — School A ───────────────────────────────────────────────────

INSERT INTO public.student_enrollments (school_id, student_id, academic_year_id, class_id, stream_id, status, enrolled_date)
VALUES
  ('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'sta00001-9c0b-4ef8-bb6d-6bb9bd380a11',
   'aa000001-9c0b-4ef8-bb6d-6bb9bd380a11', 'ac000003-9c0b-4ef8-bb6d-6bb9bd380a11',
   'as000005-9c0b-4ef8-bb6d-6bb9bd380a11', 'active', '2026-01-06'),
  ('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'sta00002-9c0b-4ef8-bb6d-6bb9bd380a11',
   'aa000001-9c0b-4ef8-bb6d-6bb9bd380a11', 'ac000003-9c0b-4ef8-bb6d-6bb9bd380a11',
   'as000005-9c0b-4ef8-bb6d-6bb9bd380a11', 'active', '2026-01-06'),
  ('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'sta00003-9c0b-4ef8-bb6d-6bb9bd380a11',
   'aa000001-9c0b-4ef8-bb6d-6bb9bd380a11', 'ac000004-9c0b-4ef8-bb6d-6bb9bd380a11',
   NULL, 'active', '2026-01-06'),
  ('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'sta00004-9c0b-4ef8-bb6d-6bb9bd380a11',
   'aa000001-9c0b-4ef8-bb6d-6bb9bd380a11', 'ac000001-9c0b-4ef8-bb6d-6bb9bd380a11',
   'as000001-9c0b-4ef8-bb6d-6bb9bd380a11', 'active', '2026-01-06'),
  ('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'sta00005-9c0b-4ef8-bb6d-6bb9bd380a11',
   'aa000001-9c0b-4ef8-bb6d-6bb9bd380a11', 'ac000001-9c0b-4ef8-bb6d-6bb9bd380a11',
   'as000002-9c0b-4ef8-bb6d-6bb9bd380a11', 'active', '2026-01-06')
ON CONFLICT DO NOTHING;

-- ─── ENROLLMENTS — School B ───────────────────────────────────────────────────

INSERT INTO public.student_enrollments (school_id, student_id, academic_year_id, class_id, status, enrolled_date)
VALUES
  ('b0eebc99-9c0b-4ef8-bb6d-6bb9bd380a22', 'stb00001-9c0b-4ef8-bb6d-6bb9bd380a22',
   'bb000001-9c0b-4ef8-bb6d-6bb9bd380a22', 'bc000003-9c0b-4ef8-bb6d-6bb9bd380a22', 'active', '2026-01-06'),
  ('b0eebc99-9c0b-4ef8-bb6d-6bb9bd380a22', 'stb00002-9c0b-4ef8-bb6d-6bb9bd380a22',
   'bb000001-9c0b-4ef8-bb6d-6bb9bd380a22', 'bc000003-9c0b-4ef8-bb6d-6bb9bd380a22', 'active', '2026-01-06'),
  ('b0eebc99-9c0b-4ef8-bb6d-6bb9bd380a22', 'stb00003-9c0b-4ef8-bb6d-6bb9bd380a22',
   'bb000001-9c0b-4ef8-bb6d-6bb9bd380a22', 'bc000004-9c0b-4ef8-bb6d-6bb9bd380a22', 'active', '2026-01-06')
ON CONFLICT DO NOTHING;

-- =============================================================================
-- NEXT STEP: Create your user account
-- =============================================================================
-- 1. Go to Supabase Dashboard → Authentication → Users → Add user
-- 2. Email: vainvicky938@gmail.com  |  Password: (your choice)  |  Auto-confirm: ON
-- 3. Copy the UUID shown for your new user
-- 4. Run this query (replace YOUR-UUID-HERE with the actual UUID):
--
-- INSERT INTO public.school_memberships (school_id, user_id, role)
-- VALUES ('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'YOUR-UUID-HERE', 'school_owner');
--
-- Then sign in at your Vercel URL — you will land on the dashboard.
-- =============================================================================
