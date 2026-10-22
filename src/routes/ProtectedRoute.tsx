import { Navigate, Outlet, useLocation } from 'react-router-dom'
import { useAuth } from '@/stores/authStore'
import { PageSpinner } from '@/components/ui'
import type { SchoolContext } from '@/types'
import type { ExtendedProfile } from '@/stores/AuthProvider'

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

  // Wait for session restore
  if (!auth.initialized) return <PageSpinner />

  // Not authenticated
  if (!auth.user) {
    return <Navigate to="/login" state={{ from: location }} replace />
  }

  // Wait for profile to load
  if (!auth.profile) return <PageSpinner />

  const profile = auth.profile as ExtendedProfile

  // ── Platform admin ──────────────────────────────────────────────────────────
  if (requirePlatformAdmin) {
    if (!profile.is_platform_admin) {
      return <Navigate to="/dashboard" replace />
    }
    return <Outlet />
  }

  // Redirect platform admin away from school routes
  if (profile.is_platform_admin) {
    if (!location.pathname.startsWith('/admin')) {
      return <Navigate to="/admin" replace />
    }
    return <Outlet />
  }

  // ── Onboarding state machine ────────────────────────────────────────────────
  const status = profile.onboarding_status ?? 'pending_approval'

  // User is complete — allow all school routes
  if (status === 'complete') {
    if (requireSchool && !auth.currentSchool) {
      return <Navigate to="/select-school" state={{ from: location }} replace />
    }
    if (
      allowedRoles.length > 0 &&
      auth.currentSchool &&
      !allowedRoles.includes(auth.currentSchool.role)
    ) {
      return <Navigate to="/unauthorized" replace />
    }
    return <Outlet />
  }

  // User needs onboarding — only allow /onboarding
  if (status === 'pending_onboarding') {
    if (location.pathname === '/onboarding') return <Outlet />
    return <Navigate to="/onboarding" replace />
  }

  // User is pending approval — only allow /pending-approval
  if (location.pathname === '/pending-approval') return <Outlet />
  return <Navigate to="/pending-approval" replace />
}

export function PublicOnlyRoute() {
  const auth = useAuth()
  const location = useLocation()

  if (!auth.initialized) return <PageSpinner />

  if (auth.user) {
    // Don't redirect until profile is loaded
    if (!auth.profile) return <PageSpinner />

    const profile = auth.profile as ExtendedProfile

    if (profile.is_platform_admin) return <Navigate to="/admin" replace />

    const status = profile.onboarding_status ?? 'pending_approval'
    if (status === 'pending_onboarding') return <Navigate to="/onboarding" replace />
    if (status === 'pending_approval')   return <Navigate to="/pending-approval" replace />

    // complete
    const from = (location.state as { from?: { pathname: string } })?.from?.pathname ?? '/dashboard'
    return <Navigate to={from} replace />
  }

  return <Outlet />
}
