import { useEffect, useState } from 'react'
import { useNavigate } from 'react-router-dom'
import { supabase } from '@/lib/supabase'
import { useAuth } from '@/stores/authStore'
import { Clock, CheckCircle2, XCircle, LogOut } from 'lucide-react'
import { GraduationCap } from 'lucide-react'

type RegistrationStatus = 'pending' | 'approved' | 'rejected' | null

export function PendingApprovalPage() {
  const auth = useAuth()
  const navigate = useNavigate()
  const [status, setStatus] = useState<RegistrationStatus>(null)
  const [rejectionReason, setRejectionReason] = useState<string | null>(null)
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    if (!auth.user) return

    async function checkStatus() {
      const { data } = await supabase
        .from('pending_registrations')
        .select('status, rejection_reason')
        .eq('user_id', auth.user!.id)
        .single()

      if (data) {
        setStatus(data.status as RegistrationStatus)
        setRejectionReason(data.rejection_reason)
      }
      setLoading(false)
    }

    checkStatus()

    // Poll every 30 seconds to check if approved
    const interval = setInterval(async () => {
      const { data } = await supabase
        .from('pending_registrations')
        .select('status, rejection_reason')
        .eq('user_id', auth.user!.id)
        .single()

      if (data) {
        setStatus(data.status as RegistrationStatus)
        setRejectionReason(data.rejection_reason)

        // If approved, redirect to onboarding
        if (data.status === 'approved') {
          clearInterval(interval)
          navigate('/onboarding')
        }
      }
    }, 30000)

    return () => clearInterval(interval)
  }, [auth.user, navigate])

  const handleSignOut = async () => {
    await auth.signOut()
    navigate('/login')
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-primary-950 via-primary-900 to-primary-800 flex items-center justify-center p-4">
      <div className="w-full max-w-md">
        {/* Logo */}
        <div className="flex flex-col items-center mb-8">
          <div className="flex h-14 w-14 items-center justify-center rounded-2xl bg-accent-500 shadow-lg mb-4">
            <GraduationCap size={28} className="text-white" />
          </div>
          <h1 className="text-3xl font-bold text-white tracking-tight">EduTrack</h1>
        </div>

        <div className="rounded-2xl bg-white shadow-modal p-8 text-center">
          {loading ? (
            <div className="py-8">
              <div className="animate-spin h-10 w-10 border-4 border-primary-200 border-t-primary-600 rounded-full mx-auto mb-4" />
              <p className="text-sm text-slate-500">Checking your application status…</p>
            </div>
          ) : status === 'rejected' ? (
            <>
              <div className="flex justify-center mb-4">
                <div className="rounded-full bg-danger-100 p-4">
                  <XCircle size={36} className="text-danger-600" />
                </div>
              </div>
              <h2 className="text-lg font-bold text-slate-900 mb-2">Application Not Approved</h2>
              <p className="text-sm text-slate-500 mb-3">
                Unfortunately your registration was not approved at this time.
              </p>
              {rejectionReason && (
                <div className="bg-danger-50 border border-danger-100 rounded-lg px-4 py-3 mb-4 text-sm text-danger-700 text-left">
                  <p className="font-medium mb-1">Reason:</p>
                  <p>{rejectionReason}</p>
                </div>
              )}
              <p className="text-xs text-slate-400 mb-6">
                Contact support at support@edutrack.ug if you believe this is an error.
              </p>
              <button
                onClick={handleSignOut}
                className="flex items-center gap-2 mx-auto text-sm text-slate-500 hover:text-slate-700"
              >
                <LogOut size={15} /> Sign out
              </button>
            </>
          ) : status === 'approved' ? (
            <>
              <div className="flex justify-center mb-4">
                <div className="rounded-full bg-success-100 p-4">
                  <CheckCircle2 size={36} className="text-success-600" />
                </div>
              </div>
              <h2 className="text-lg font-bold text-slate-900 mb-2">Application Approved!</h2>
              <p className="text-sm text-slate-500 mb-6">
                Your application has been approved. Setting up your school workspace…
              </p>
              <button
                onClick={() => navigate('/onboarding')}
                className="w-full rounded-lg bg-primary-600 px-4 py-2.5 text-sm font-medium text-white hover:bg-primary-700"
              >
                Continue to School Setup
              </button>
            </>
          ) : (
            <>
              <div className="flex justify-center mb-4">
                <div className="rounded-full bg-amber-100 p-4">
                  <Clock size={36} className="text-amber-600" />
                </div>
              </div>
              <h2 className="text-lg font-bold text-slate-900 mb-2">Application Submitted</h2>
              <p className="text-sm text-slate-500 mb-2">
                Your registration has been received and is waiting for review.
              </p>
              <p className="text-sm text-slate-500 mb-6">
                You will be able to proceed once an administrator approves your account.
                This page checks automatically every 30 seconds.
              </p>
              <div className="bg-slate-50 rounded-lg px-4 py-3 text-xs text-slate-500 mb-6">
                Signed in as <span className="font-medium text-slate-700">{auth.user?.email}</span>
              </div>
              <button
                onClick={handleSignOut}
                className="flex items-center gap-2 mx-auto text-sm text-slate-500 hover:text-slate-700"
              >
                <LogOut size={15} /> Sign out
              </button>
            </>
          )}
        </div>

        <p className="mt-6 text-center text-xs text-primary-400">
          &copy; {new Date().getFullYear()} EduTrack Uganda. All rights reserved.
        </p>
      </div>
    </div>
  )
}
