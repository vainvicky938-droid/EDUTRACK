import { createBrowserRouter, Navigate } from 'react-router-dom'
import { AppShell } from '@/components/layout/AppShell'
import { AuthLayout } from '@/components/layout/AuthLayout'
import { AdminShell } from '@/components/layout/AdminShell'
import { ProtectedRoute, PublicOnlyRoute } from './ProtectedRoute'

// Auth pages
import { LoginPage }            from '@/pages/auth/LoginPage'
import { SignUpPage }            from '@/pages/auth/SignUpPage'
import { SelectSchoolPage }      from '@/pages/auth/SelectSchoolPage'
import { PendingApprovalPage }   from '@/pages/auth/PendingApprovalPage'
import { SchoolOnboardingPage }  from '@/pages/auth/SchoolOnboardingPage'
import { UnauthorizedPage }      from '@/pages/auth/UnauthorizedPage'
import { NotFoundPage }          from '@/pages/auth/NotFoundPage'

// School app pages
import { DashboardPage }    from '@/pages/dashboard/DashboardPage'
import { StudentsPage }     from '@/pages/students/StudentsPage'
import { StaffPage }        from '@/pages/staff/StaffPage'
import { ClassesPage }      from '@/pages/classes/ClassesPage'
import { AttendancePage }   from '@/pages/attendance/AttendancePage'
import { FeesPage }         from '@/pages/fees/FeesPage'
import { AcademicPage }     from '@/pages/academic/AcademicPage'
import { ReportsPage }      from '@/pages/reports/ReportsPage'
import { ReportCardsPage }  from '@/pages/reports/ReportCardsPage'
import { SettingsPage }     from '@/pages/settings/SettingsPage'

// Platform admin pages
import { AdminDashboardPage } from '@/pages/platform/AdminDashboardPage'
import { AdminSchoolsPage }   from '@/pages/platform/AdminSchoolsPage'
import { AdminUsersPage }     from '@/pages/platform/AdminUsersPage'
import { AdminSettingsPage }  from '@/pages/platform/AdminSettingsPage'

export const router = createBrowserRouter([

  // ─── Public routes (unauthenticated only) ──────────────────────────────────
  {
    element: <PublicOnlyRoute />,
    children: [
      {
        element: <AuthLayout />,
        children: [
          { path: '/login',  element: <LoginPage /> },
          { path: '/signup', element: <SignUpPage /> },
        ],
      },
    ],
  },

  // ─── Pending approval (authenticated, no school yet) ───────────────────────
  { path: '/pending-approval', element: <PendingApprovalPage /> },

  // ─── School onboarding (authenticated, approved but no school) ────────────
  {
    element: <ProtectedRoute requireSchool={false} />,
    children: [
      { path: '/onboarding', element: <SchoolOnboardingPage /> },
    ],
  },

  // ─── School selection (authenticated, onboarding complete) ────────────────
  {
    element: <ProtectedRoute requireSchool={false} />,
    children: [
      { path: '/select-school', element: <SelectSchoolPage /> },
    ],
  },

  // ─── Platform admin routes ─────────────────────────────────────────────────
  {
    element: <ProtectedRoute requirePlatformAdmin requireSchool={false} />,
    children: [
      {
        element: <AdminShell />,
        children: [
          { path: '/admin',           element: <AdminDashboardPage /> },
          { path: '/admin/schools',   element: <AdminSchoolsPage /> },
          { path: '/admin/users',     element: <AdminUsersPage /> },
          { path: '/admin/settings',  element: <AdminSettingsPage /> },
        ],
      },
    ],
  },

  // ─── School app (authenticated + active school) ────────────────────────────
  {
    element: <ProtectedRoute />,
    children: [
      {
        element: <AppShell />,
        children: [
          { path: '/dashboard',    element: <DashboardPage /> },
          { path: '/students',     element: <StudentsPage /> },
          { path: '/staff',        element: <StaffPage /> },
          { path: '/classes',      element: <ClassesPage /> },
          { path: '/attendance',   element: <AttendancePage /> },
          { path: '/fees',         element: <FeesPage /> },
          { path: '/academic',     element: <AcademicPage /> },
          { path: '/reports',      element: <ReportsPage /> },
          { path: '/report-cards', element: <ReportCardsPage /> },
          { path: '/settings',     element: <SettingsPage /> },
        ],
      },
    ],
  },

  // ─── Utility routes ────────────────────────────────────────────────────────
  { path: '/unauthorized', element: <UnauthorizedPage /> },
  { path: '/',             element: <Navigate to="/dashboard" replace /> },
  { path: '*',             element: <NotFoundPage /> },
])
