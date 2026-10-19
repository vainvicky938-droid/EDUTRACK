-- =============================================================================
-- Migration 012: Mark vainvicky938@gmail.com as platform admin
-- Run AFTER migration 011.
-- Replace the email below if your admin email is different.
-- =============================================================================

UPDATE public.user_profiles
SET
  is_platform_admin  = TRUE,
  onboarding_status  = 'complete'
WHERE id = (
  SELECT id FROM auth.users WHERE email = 'vainvicky938@gmail.com'
);

-- Verify
SELECT id, full_name, is_platform_admin, onboarding_status
FROM public.user_profiles
WHERE is_platform_admin = TRUE;
