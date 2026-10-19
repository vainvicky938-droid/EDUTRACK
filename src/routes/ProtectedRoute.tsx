import { Navigate, Outlet, useLocation } from 'react-router-dom'
import { useAuth } from '@/stores/authStore'
import { PageSpinner } from '@/components/ui'
import type { SchoolContext } from '@/types'

interface ProtectedRouteProps {
  allowedRoles?: SchoolContext['role'][]
  requireSchool?: boolean
  requirePlatformAdmin?: boolean
}

export function ProtectedRoute({
  allowedRoles = [],
  requireSchool = true,
  requirePlatformAdmin = false,
}: ProtectedRouteProps) {
  const auth = useAuth()
  const location = useLocation()

  if (!auth.initialized) return <PageSpinner />

  // Not authenticated
  if (!auth.user) {
    return <Navigate to="/login" state={{ from: location }} replace />
  }

  const profile = auth.profile as (typeof auth.profile & {
    is_platform_admin?: boolean
    onboarding_status?: string
  }) | null

  // Platform admin routes
  if (requirePlatformAdmin) {
    if (!profile?.is_platform_admin) {
      return <Navigate to="/dashboard" replace />
    }
    return <Outlet />
  }

  // If profile not loaded yet, wait
  if (!profile) return <PageSpinner />

  // Platform admin goes straight to admin dashboard
  if (profile.is_platform_admin) {
    if (!location.pathname.startsWith('/admin')) {
      return <Navigate to="/admin" replace />
    }
    return <Outlet />
  }

  // Non-admin users: check onboarding state
  const onboardingStatus = profile.onboarding_status ?? 'pending_approval'

  if (onboardingStatus === 'pending_approval' || onboardingStatus === 'pending_onboarding') {
    if (onboardingStatus === 'pending_onboarding' && location.pathname === '/onboarding') {
      return <Outlet />
    }
    if (onboardingStatus === 'pending_approval' && location.pathname === '/pending-approval') {
      return <Outlet />
    }
    if (onboardingStatus === 'pending_onboarding') {
      return <Navigate to="/onboarding" replace />
    }
    return <Navigate to="/pending-approval" replace />
  }

  // Onboarding complete — needs school context
  if (requireSchool && !auth.currentSchool) {
    return <Navigate to="/select-school" state={{ from: location }} replace />
  }

  // Role check
  if (
    allowedRoles.length > 0 &&
    auth.currentSchool &&
    !allowedRoles.includes(auth.currentSchool.role)
  ) {
    return <Navigate to="/unauthorized" replace />
  }

  return <Outlet />
}

export function PublicOnlyRoute() {
  const auth = useAuth()
  const location = useLocation()

  if (!auth.initialized) return <PageSpinner />

  if (auth.user) {
    const profile = auth.profile as (typeof auth.profile & {
      is_platform_admin?: boolean
      onboarding_status?: string
    }) | null

    if (profile?.is_platform_admin) return <Navigate to="/admin" replace />

    const status = profile?.onboarding_status
    if (status === 'pending_onboarding') return <Navigate to="/onboarding" replace />
    if (status === 'pending_approval')   return <Navigate to="/pending-approval" replace />

    const from = (location.state as { from?: Location })?.from?.pathname ?? '/dashboard'
    return <Navigate to={from} replace />
  }

  return <Outlet />
}
