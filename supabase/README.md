# EduTrack Database Setup

## How to run migrations

Open your **Supabase project** → **SQL Editor** and run each file in order:

| Order | File | Description |
|---|---|---|
| 1 | `migrations/001_platform_tables.sql` | subscription_plans, schools, user_profiles, triggers |
| 2 | `migrations/002_memberships_staff.sql` | school_memberships, staff_profiles |
| 3 | `migrations/003_academic_structure.sql` | academic_years, terms, classes, streams, subjects, class_subjects, teacher_assignments |
| 4 | `migrations/004_students.sql` | students, guardians, student_guardians, student_enrollments |
| 5 | `migrations/005_attendance.sql` | attendance_sessions, attendance_records |
| 6 | `migrations/006_fees_finance.sql` | fee_structures, fee_items, fee_assessments, payments, transactions, allocations |
| 7 | `migrations/007_academic_assessment.sql` | grading_scales, grade_bands, assessment_definitions, results, corrections |
| 8 | `migrations/008_report_cards_audit.sql` | report_card_templates, report_cards, subscriptions, audit_logs |
| 9 | `migrations/009_helper_functions.sql` | RLS helper functions |
| 10 | `migrations/010_rls_policies.sql` | All Row Level Security policies |

After all migrations, run `seed.sql` to load the two synthetic test schools.

## Step-by-step in Supabase SQL Editor

1. Go to https://supabase.com → your project → **SQL Editor**
2. Click **New query**
3. Paste the contents of `001_platform_tables.sql` → click **Run**
4. Repeat for each file in order
5. After file 010, paste and run `seed.sql`

## Creating test users

After the seed runs, create test accounts in **Authentication → Users → Add user**:

| Email | Password | Role | School |
|---|---|---|---|
| admin.stmarys@edutrack.test | TestPass2026! | school_owner | St. Mary's College Kampala |
| teacher.stmarys@edutrack.test | TestPass2026! | teacher | St. Mary's College Kampala |
| admin.greenvalley@edutrack.test | TestPass2026! | school_owner | Green Valley Primary School |

Then link each user to their school by running:
```sql
INSERT INTO public.school_memberships (school_id, user_id, role)
VALUES ('<school-id>', '<user-uuid-from-auth>', 'school_owner');
```

## Security verification

After setup, verify cross-school isolation:
1. Log in as `admin.stmarys` → navigate to Students → should see 5 students
2. Log in as `admin.greenvalley` → navigate to Students → should see 3 different students
3. Directly query: `SELECT * FROM students WHERE school_id = '<school-b-id>'` while authenticated as School A user → should return 0 rows
