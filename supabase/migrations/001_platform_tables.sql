-- =============================================================================
-- Migration 001: Core Platform Tables
-- EduTrack School Management System
-- Run this first. No dependencies on other migrations.
-- =============================================================================

-- Enable the pgcrypto extension for gen_random_uuid()
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- =============================================================================
-- SUBSCRIPTION PLANS
-- Defines the available tiers schools can subscribe to.
-- Managed by platform super admin only.
-- =============================================================================
CREATE TABLE IF NOT EXISTS public.subscription_plans (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name          TEXT NOT NULL,
  description   TEXT,
  max_students  INTEGER NOT NULL DEFAULT 500,
  max_staff     INTEGER NOT NULL DEFAULT 50,
  feature_flags JSONB NOT NULL DEFAULT '{}',
  price_ugx     NUMERIC(12,2),
  is_active     BOOLEAN NOT NULL DEFAULT TRUE,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at    TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Insert default plans
INSERT INTO public.subscription_plans (name, description, max_students, max_staff, price_ugx)
VALUES
  ('Trial',      'Free 30-day trial',          200,  20,  0),
  ('Starter',    'Up to 500 students',          500,  50,  150000),
  ('Standard',   'Up to 1500 students',         1500, 100, 350000),
  ('Premium',    'Unlimited students',          99999,500, 600000)
ON CONFLICT DO NOTHING;

-- =============================================================================
-- SCHOOLS
-- One row per school tenant. Every other school-specific table references this.
-- =============================================================================
CREATE TABLE IF NOT EXISTS public.schools (
  id                   UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name                 TEXT NOT NULL,
  slug                 TEXT NOT NULL UNIQUE,
  type                 TEXT NOT NULL DEFAULT 'secondary'
                         CHECK (type IN ('primary','secondary','combined')),
  address              TEXT,
  district             TEXT,
  phone                TEXT,
  email                TEXT,
  logo_url             TEXT,
  status               TEXT NOT NULL DEFAULT 'trial'
                         CHECK (status IN ('trial','active','suspended','cancelled')),
  subscription_plan_id UUID REFERENCES public.subscription_plans(id),
  subscription_start   DATE,
  subscription_end     DATE,
  is_trial             BOOLEAN NOT NULL DEFAULT TRUE,
  -- School-level settings stored as JSONB for flexibility
  settings             JSONB NOT NULL DEFAULT '{}',
  created_at           TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at           TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_schools_slug   ON public.schools(slug);
CREATE INDEX IF NOT EXISTS idx_schools_status ON public.schools(status);

-- =============================================================================
-- USER PROFILES
-- Extends auth.users with display name and contact info.
-- Created automatically when a user signs up (via trigger in migration 002).
-- =============================================================================
CREATE TABLE IF NOT EXISTS public.user_profiles (
  id          UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  full_name   TEXT NOT NULL DEFAULT '',
  phone       TEXT,
  avatar_url  TEXT,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Trigger: auto-create a user_profile row when a new auth user signs up
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  INSERT INTO public.user_profiles (id, full_name)
  VALUES (
    NEW.id,
    COALESCE(NEW.raw_user_meta_data->>'full_name', '')
  )
  ON CONFLICT (id) DO NOTHING;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- Trigger: auto-update updated_at timestamps
CREATE OR REPLACE FUNCTION public.set_updated_at()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$;

CREATE TRIGGER set_schools_updated_at
  BEFORE UPDATE ON public.schools
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

CREATE TRIGGER set_user_profiles_updated_at
  BEFORE UPDATE ON public.user_profiles
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

CREATE TRIGGER set_subscription_plans_updated_at
  BEFORE UPDATE ON public.subscription_plans
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
