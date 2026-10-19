-- =============================================================================
-- EduTrack Seed Data — Fixed UUIDs (all valid hex, 8-4-4-4-12 format)
-- Run AFTER all migrations 001–010.
-- =============================================================================

-- ─── SCHOOL A: Secondary ─────────────────────────────────────────────────────
INSERT INTO public.schools (id, name, slug, type, address, district, phone, email, status, is_trial, settings)
VALUES (
  'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11',
  'St. Mary''s College Kampala', 'st-marys-kampala', 'secondary',
  'Plot 12, Nakasero Hill Road, Kampala', 'Kampala',
  '+256 700 100001', 'admin@stmarys-kampala.edu.ug', 'active', FALSE,
  '{"school_motto": "Excellence in All Things", "term_count": 3}'
) ON CONFLICT (slug) DO NOTHING;

-- ─── SCHOOL B: Primary ───────────────────────────────────────────────────────
INSERT INTO public.schools (id, name, slug, type, address, district, phone, email, status, is_trial, settings)
VALUES (
  'b0eebc99-9c0b-4ef8-bb6d-6bb9bd380b22',
  'Green Valley Primary School', 'green-valley-primary', 'primary',
  'Plot 45, Entebbe Road, Wakiso', 'Wakiso',
  '+256 700 200001', 'admin@greenvalley.edu.ug', 'active', TRUE,
  '{"school_motto": "Learning for Life", "term_count": 3}'
) ON CONFLICT (slug) DO NOTHING;

-- ─── ACADEMIC YEARS ──────────────────────────────────────────────────────────
INSERT INTO public.academic_years (id, school_id, name, start_date, end_date, is_current) VALUES
  ('aa000001-9c0b-4ef8-bb6d-6bb9bd380a11', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '2026', '2026-01-06', '2026-11-30', TRUE),
  ('bb000001-9c0b-4ef8-bb6d-6bb9bd380b22', 'b0eebc99-9c0b-4ef8-bb6d-6bb9bd380b22', '2026', '2026-01-06', '2026-11-30', TRUE)
ON CONFLICT DO NOTHING;

-- ─── ACADEMIC TERMS — School A ───────────────────────────────────────────────
INSERT INTO public.academic_terms (id, school_id, academic_year_id, name, start_date, end_date, is_current) VALUES
  ('a0000001-9c0b-4ef8-bb6d-6bb9bd380001', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'aa000001-9c0b-4ef8-bb6d-6bb9bd380a11', 'Term 1', '2026-01-06', '2026-04-10', FALSE),
  ('a0000002-9c0b-4ef8-bb6d-6bb9bd380001', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'aa000001-9c0b-4ef8-bb6d-6bb9bd380a11', 'Term 2', '2026-05-04', '2026-08-07', FALSE),
  ('a0000003-9c0b-4ef8-bb6d-6bb9bd380001', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'aa000001-9c0b-4ef8-bb6d-6bb9bd380a11', 'Term 3', '2026-09-01', '2026-11-30', TRUE)
ON CONFLICT DO NOTHING;

-- ─── ACADEMIC TERMS — School B ───────────────────────────────────────────────
INSERT INTO public.academic_terms (id, school_id, academic_year_id, name, start_date, end_date, is_current) VALUES
  ('b0000001-9c0b-4ef8-bb6d-6bb9bd380002', 'b0eebc99-9c0b-4ef8-bb6d-6bb9bd380b22', 'bb000001-9c0b-4ef8-bb6d-6bb9bd380b22', 'Term 1', '2026-01-06', '2026-04-10', FALSE),
  ('b0000002-9c0b-4ef8-bb6d-6bb9bd380002', 'b0eebc99-9c0b-4ef8-bb6d-6bb9bd380b22', 'bb000001-9c0b-4ef8-bb6d-6bb9bd380b22', 'Term 2', '2026-05-04', '2026-08-07', FALSE),
  ('b0000003-9c0b-4ef8-bb6d-6bb9bd380002', 'b0eebc99-9c0b-4ef8-bb6d-6bb9bd380b22', 'bb000001-9c0b-4ef8-bb6d-6bb9bd380b22', 'Term 3', '2026-09-01', '2026-11-30', TRUE)
ON CONFLICT DO NOTHING;

-- ─── CLASSES — School A (S1–S6) ──────────────────────────────────────────────
INSERT INTO public.classes (id, school_id, name, level_code, sort_order) VALUES
  ('a1000001-9c0b-4ef8-bb6d-6bb9bd380a11', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'S1', 'S1', 1),
  ('a1000002-9c0b-4ef8-bb6d-6bb9bd380a11', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'S2', 'S2', 2),
  ('a1000003-9c0b-4ef8-bb6d-6bb9bd380a11', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'S3', 'S3', 3),
  ('a1000004-9c0b-4ef8-bb6d-6bb9bd380a11', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'S4', 'S4', 4),
  ('a1000005-9c0b-4ef8-bb6d-6bb9bd380a11', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'S5', 'S5', 5),
  ('a1000006-9c0b-4ef8-bb6d-6bb9bd380a11', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'S6', 'S6', 6)
ON CONFLICT DO NOTHING;

-- ─── CLASSES — School B (P1–P7) ──────────────────────────────────────────────
INSERT INTO public.classes (id, school_id, name, level_code, sort_order) VALUES
  ('b1000001-9c0b-4ef8-bb6d-6bb9bd380b22', 'b0eebc99-9c0b-4ef8-bb6d-6bb9bd380b22', 'P1', 'P1', 1),
  ('b1000002-9c0b-4ef8-bb6d-6bb9bd380b22', 'b0eebc99-9c0b-4ef8-bb6d-6bb9bd380b22', 'P2', 'P2', 2),
  ('b1000003-9c0b-4ef8-bb6d-6bb9bd380b22', 'b0eebc99-9c0b-4ef8-bb6d-6bb9bd380b22', 'P3', 'P3', 3),
  ('b1000004-9c0b-4ef8-bb6d-6bb9bd380b22', 'b0eebc99-9c0b-4ef8-bb6d-6bb9bd380b22', 'P4', 'P4', 4),
  ('b1000005-9c0b-4ef8-bb6d-6bb9bd380b22', 'b0eebc99-9c0b-4ef8-bb6d-6bb9bd380b22', 'P5', 'P5', 5),
  ('b1000006-9c0b-4ef8-bb6d-6bb9bd380b22', 'b0eebc99-9c0b-4ef8-bb6d-6bb9bd380b22', 'P6', 'P6', 6),
  ('b1000007-9c0b-4ef8-bb6d-6bb9bd380b22', 'b0eebc99-9c0b-4ef8-bb6d-6bb9bd380b22', 'P7', 'P7', 7)
ON CONFLICT DO NOTHING;

-- ─── STREAMS — School A ───────────────────────────────────────────────────────
INSERT INTO public.streams (id, school_id, class_id, name) VALUES
  ('a2000001-9c0b-4ef8-bb6d-6bb9bd380a11', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'a1000001-9c0b-4ef8-bb6d-6bb9bd380a11', 'East'),
  ('a2000002-9c0b-4ef8-bb6d-6bb9bd380a11', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'a1000001-9c0b-4ef8-bb6d-6bb9bd380a11', 'West'),
  ('a2000003-9c0b-4ef8-bb6d-6bb9bd380a11', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'a1000002-9c0b-4ef8-bb6d-6bb9bd380a11', 'East'),
  ('a2000004-9c0b-4ef8-bb6d-6bb9bd380a11', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'a1000002-9c0b-4ef8-bb6d-6bb9bd380a11', 'West'),
  ('a2000005-9c0b-4ef8-bb6d-6bb9bd380a11', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'a1000003-9c0b-4ef8-bb6d-6bb9bd380a11', 'Arts'),
  ('a2000006-9c0b-4ef8-bb6d-6bb9bd380a11', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'a1000003-9c0b-4ef8-bb6d-6bb9bd380a11', 'Sciences')
ON CONFLICT DO NOTHING;

-- ─── SUBJECTS — School A ─────────────────────────────────────────────────────
INSERT INTO public.subjects (id, school_id, name, code) VALUES
  ('a3000001-9c0b-4ef8-bb6d-6bb9bd380a11', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Mathematics',                  'MATH'),
  ('a3000002-9c0b-4ef8-bb6d-6bb9bd380a11', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'English Language',             'ENG'),
  ('a3000003-9c0b-4ef8-bb6d-6bb9bd380a11', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Physics',                      'PHY'),
  ('a3000004-9c0b-4ef8-bb6d-6bb9bd380a11', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Chemistry',                    'CHEM'),
  ('a3000005-9c0b-4ef8-bb6d-6bb9bd380a11', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Biology',                      'BIO'),
  ('a3000006-9c0b-4ef8-bb6d-6bb9bd380a11', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'History',                      'HIST'),
  ('a3000007-9c0b-4ef8-bb6d-6bb9bd380a11', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Geography',                    'GEO'),
  ('a3000008-9c0b-4ef8-bb6d-6bb9bd380a11', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Christian Religious Education', 'CRE'),
  ('a3000009-9c0b-4ef8-bb6d-6bb9bd380a11', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Computer Studies',             'COMP'),
  ('a300000a-9c0b-4ef8-bb6d-6bb9bd380a11', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Luganda',                      'LUG')
ON CONFLICT DO NOTHING;

-- ─── SUBJECTS — School B ─────────────────────────────────────────────────────
INSERT INTO public.subjects (id, school_id, name, code) VALUES
  ('b3000001-9c0b-4ef8-bb6d-6bb9bd380b22', 'b0eebc99-9c0b-4ef8-bb6d-6bb9bd380b22', 'Mathematics',       'MATH'),
  ('b3000002-9c0b-4ef8-bb6d-6bb9bd380b22', 'b0eebc99-9c0b-4ef8-bb6d-6bb9bd380b22', 'English Language',  'ENG'),
  ('b3000003-9c0b-4ef8-bb6d-6bb9bd380b22', 'b0eebc99-9c0b-4ef8-bb6d-6bb9bd380b22', 'Science',           'SCI'),
  ('b3000004-9c0b-4ef8-bb6d-6bb9bd380b22', 'b0eebc99-9c0b-4ef8-bb6d-6bb9bd380b22', 'Social Studies',    'SST'),
  ('b3000005-9c0b-4ef8-bb6d-6bb9bd380b22', 'b0eebc99-9c0b-4ef8-bb6d-6bb9bd380b22', 'Religious Education','RE'),
  ('b3000006-9c0b-4ef8-bb6d-6bb9bd380b22', 'b0eebc99-9c0b-4ef8-bb6d-6bb9bd380b22', 'Luganda',           'LUG')
ON CONFLICT DO NOTHING;

-- ─── GRADING SCALES ───────────────────────────────────────────────────────────
INSERT INTO public.grading_scales (id, school_id, name, is_default) VALUES
  ('a4000001-9c0b-4ef8-bb6d-6bb9bd380a11', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Standard Secondary Scale', TRUE),
  ('b4000001-9c0b-4ef8-bb6d-6bb9bd380b22', 'b0eebc99-9c0b-4ef8-bb6d-6bb9bd380b22', 'Standard Primary Scale',   TRUE)
ON CONFLICT DO NOTHING;

INSERT INTO public.grade_bands (grading_scale_id, letter_grade, min_percent, max_percent, interpretation, points, sort_order) VALUES
  ('a4000001-9c0b-4ef8-bb6d-6bb9bd380a11', 'D1', 80, 100, 'Distinction 1', 1, 1),
  ('a4000001-9c0b-4ef8-bb6d-6bb9bd380a11', 'D2', 75,  79, 'Distinction 2', 2, 2),
  ('a4000001-9c0b-4ef8-bb6d-6bb9bd380a11', 'C3', 70,  74, 'Credit 3',      3, 3),
  ('a4000001-9c0b-4ef8-bb6d-6bb9bd380a11', 'C4', 65,  69, 'Credit 4',      4, 4),
  ('a4000001-9c0b-4ef8-bb6d-6bb9bd380a11', 'C5', 60,  64, 'Credit 5',      5, 5),
  ('a4000001-9c0b-4ef8-bb6d-6bb9bd380a11', 'C6', 55,  59, 'Credit 6',      6, 6),
  ('a4000001-9c0b-4ef8-bb6d-6bb9bd380a11', 'P7', 45,  54, 'Pass 7',        7, 7),
  ('a4000001-9c0b-4ef8-bb6d-6bb9bd380a11', 'P8', 40,  44, 'Pass 8',        8, 8),
  ('a4000001-9c0b-4ef8-bb6d-6bb9bd380a11', 'F9',  0,  39, 'Fail',          9, 9)
ON CONFLICT DO NOTHING;

INSERT INTO public.grade_bands (grading_scale_id, letter_grade, min_percent, max_percent, interpretation, sort_order) VALUES
  ('b4000001-9c0b-4ef8-bb6d-6bb9bd380b22', 'A', 75, 100, 'Excellent',      1),
  ('b4000001-9c0b-4ef8-bb6d-6bb9bd380b22', 'B', 65,  74, 'Very Good',      2),
  ('b4000001-9c0b-4ef8-bb6d-6bb9bd380b22', 'C', 50,  64, 'Good',           3),
  ('b4000001-9c0b-4ef8-bb6d-6bb9bd380b22', 'D', 40,  49, 'Satisfactory',   4),
  ('b4000001-9c0b-4ef8-bb6d-6bb9bd380b22', 'E', 30,  39, 'Needs Work',     5),
  ('b4000001-9c0b-4ef8-bb6d-6bb9bd380b22', 'U',  0,  29, 'Unsatisfactory', 6)
ON CONFLICT DO NOTHING;

-- ─── REPORT CARD TEMPLATES ────────────────────────────────────────────────────
INSERT INTO public.report_card_templates (id, school_id, name, is_default) VALUES
  ('a5000001-9c0b-4ef8-bb6d-6bb9bd380a11', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Standard Report Card', TRUE),
  ('b5000001-9c0b-4ef8-bb6d-6bb9bd380b22', 'b0eebc99-9c0b-4ef8-bb6d-6bb9bd380b22', 'Standard Report Card', TRUE)
ON CONFLICT DO NOTHING;

-- ─── STUDENTS — School A ─────────────────────────────────────────────────────
INSERT INTO public.students (id, school_id, admission_number, full_name, date_of_birth, gender, admission_date, status) VALUES
  ('a6000001-9c0b-4ef8-bb6d-6bb9bd380a11', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'SMA/2024/001', 'Akello Diana',   '2010-03-15', 'female', '2024-01-08', 'active'),
  ('a6000002-9c0b-4ef8-bb6d-6bb9bd380a11', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'SMA/2024/002', 'Okello Brian',   '2010-07-22', 'male',   '2024-01-08', 'active'),
  ('a6000003-9c0b-4ef8-bb6d-6bb9bd380a11', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'SMA/2024/003', 'Nakato Sarah',   '2009-11-05', 'female', '2024-01-08', 'active'),
  ('a6000004-9c0b-4ef8-bb6d-6bb9bd380a11', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'SMA/2025/001', 'Mugisha Peter',  '2011-01-18', 'male',   '2025-01-06', 'active'),
  ('a6000005-9c0b-4ef8-bb6d-6bb9bd380a11', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'SMA/2025/002', 'Namusoke Grace', '2010-08-30', 'female', '2025-01-06', 'active')
ON CONFLICT DO NOTHING;

-- ─── STUDENTS — School B ─────────────────────────────────────────────────────
INSERT INTO public.students (id, school_id, admission_number, full_name, date_of_birth, gender, admission_date, status) VALUES
  ('b6000001-9c0b-4ef8-bb6d-6bb9bd380b22', 'b0eebc99-9c0b-4ef8-bb6d-6bb9bd380b22', 'GVP/2024/001', 'Tendo James',      '2016-04-10', 'male',   '2024-01-08', 'active'),
  ('b6000002-9c0b-4ef8-bb6d-6bb9bd380b22', 'b0eebc99-9c0b-4ef8-bb6d-6bb9bd380b22', 'GVP/2024/002', 'Namukasa Irene',   '2016-09-14', 'female', '2024-01-08', 'active'),
  ('b6000003-9c0b-4ef8-bb6d-6bb9bd380b22', 'b0eebc99-9c0b-4ef8-bb6d-6bb9bd380b22', 'GVP/2025/001', 'Ssemwogerere Max', '2015-06-20', 'male',   '2025-01-06', 'active')
ON CONFLICT DO NOTHING;

-- ─── ENROLLMENTS — School A ───────────────────────────────────────────────────
INSERT INTO public.student_enrollments (school_id, student_id, academic_year_id, class_id, stream_id, status, enrolled_date) VALUES
  ('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11','a6000001-9c0b-4ef8-bb6d-6bb9bd380a11','aa000001-9c0b-4ef8-bb6d-6bb9bd380a11','a1000003-9c0b-4ef8-bb6d-6bb9bd380a11','a2000005-9c0b-4ef8-bb6d-6bb9bd380a11','active','2026-01-06'),
  ('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11','a6000002-9c0b-4ef8-bb6d-6bb9bd380a11','aa000001-9c0b-4ef8-bb6d-6bb9bd380a11','a1000003-9c0b-4ef8-bb6d-6bb9bd380a11','a2000005-9c0b-4ef8-bb6d-6bb9bd380a11','active','2026-01-06'),
  ('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11','a6000003-9c0b-4ef8-bb6d-6bb9bd380a11','aa000001-9c0b-4ef8-bb6d-6bb9bd380a11','a1000004-9c0b-4ef8-bb6d-6bb9bd380a11', NULL,                                   'active','2026-01-06'),
  ('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11','a6000004-9c0b-4ef8-bb6d-6bb9bd380a11','aa000001-9c0b-4ef8-bb6d-6bb9bd380a11','a1000001-9c0b-4ef8-bb6d-6bb9bd380a11','a2000001-9c0b-4ef8-bb6d-6bb9bd380a11','active','2026-01-06'),
  ('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11','a6000005-9c0b-4ef8-bb6d-6bb9bd380a11','aa000001-9c0b-4ef8-bb6d-6bb9bd380a11','a1000001-9c0b-4ef8-bb6d-6bb9bd380a11','a2000002-9c0b-4ef8-bb6d-6bb9bd380a11','active','2026-01-06')
ON CONFLICT DO NOTHING;

-- ─── ENROLLMENTS — School B ───────────────────────────────────────────────────
INSERT INTO public.student_enrollments (school_id, student_id, academic_year_id, class_id, status, enrolled_date) VALUES
  ('b0eebc99-9c0b-4ef8-bb6d-6bb9bd380b22','b6000001-9c0b-4ef8-bb6d-6bb9bd380b22','bb000001-9c0b-4ef8-bb6d-6bb9bd380b22','b1000003-9c0b-4ef8-bb6d-6bb9bd380b22','active','2026-01-06'),
  ('b0eebc99-9c0b-4ef8-bb6d-6bb9bd380b22','b6000002-9c0b-4ef8-bb6d-6bb9bd380b22','bb000001-9c0b-4ef8-bb6d-6bb9bd380b22','b1000003-9c0b-4ef8-bb6d-6bb9bd380b22','active','2026-01-06'),
  ('b0eebc99-9c0b-4ef8-bb6d-6bb9bd380b22','b6000003-9c0b-4ef8-bb6d-6bb9bd380b22','bb000001-9c0b-4ef8-bb6d-6bb9bd380b22','b1000004-9c0b-4ef8-bb6d-6bb9bd380b22','active','2026-01-06')
ON CONFLICT DO NOTHING;

-- =============================================================================
-- AFTER THIS RUNS SUCCESSFULLY:
--
-- 1. Go to Authentication → Users → Add user → Create new user
--    Email: vainvicky938@gmail.com | Auto Confirm: ON
--
-- 2. Copy the UUID of the new user, then run:
--    INSERT INTO public.school_memberships (school_id, user_id, role)
--    VALUES ('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'PASTE-UUID-HERE', 'school_owner');
--
-- 3. Sign in at your Vercel URL — dashboard will load.
-- =============================================================================
