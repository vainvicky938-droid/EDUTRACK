import { useState, useEffect, useCallback, type ReactNode } from 'react'
import type { User, Session } from '@supabase/supabase-js'
import { supabase } from '@/lib/supabase'
import type { UserProfile, SchoolContext } from '@/types'
import { AuthContext, type AuthState } from './authStore'

export interface ExtendedProfile extends UserProfile {
  is_platform_admin: boolean
  onboarding_status: 'pending_approval' | 'pending_onboarding' | 'complete'
}

interface Props {
  children: ReactNode
}

export function AuthProvider({ children }: Props) {
  const [user, setUser] = useState<User | null>(null)
  const [session, setSession] = useState<Session | null>(null)
  const [profile, setProfile] = useState<ExtendedProfile | null>(null)
  const [currentSchool, setCurrentSchool] = useState<SchoolContext | null>(null)
  const [loading, setLoading] = useState(false)
  const [initialized, setInitialized] = useState(false)

  const fetchProfile = useCallback(async (userId: string) => {
    const { data } = await supabase
      .from('user_profiles')
      .select('*')
      .eq('id', userId)
      .single()
    if (data) setProfile(data as ExtendedProfile)
  }, [])

  const refreshProfile = useCallback(async () => {
    if (user) await fetchProfile(user.id)
  }, [user, fetchProfile])

  useEffect(() => {
    // Restore session on mount
    supabase.auth.getSession().then(({ data: { session: s } }) => {
      setSession(s)
      setUser(s?.user ?? null)
      if (s?.user) {
        fetchProfile(s.user.id).finally(() => setInitialized(true))
      } else {
        setInitialized(true)
      }
    })

    // Listen for auth changes
    const { data: { subscription } } = supabase.auth.onAuthStateChange(
      (_event, s) => {
        setSession(s)
        setUser(s?.user ?? null)
        if (s?.user) {
          fetchProfile(s.user.id)
        } else {
          setProfile(null)
          setCurrentSchool(null)
        }
      }
    )

    return () => subscription.unsubscribe()
  }, [fetchProfile])

  // Subscribe to real-time changes on user_profiles so onboarding_status
  // updates are picked up immediately without requiring a sign out / sign in
  useEffect(() => {
    if (!user) return

    const channel = supabase
      .channel(`profile:${user.id}`)
      .on(
        'postgres_changes',
        {
          event: 'UPDATE',
          schema: 'public',
          table: 'user_profiles',
          filter: `id=eq.${user.id}`,
        },
        (payload) => {
          // Merge the updated fields into the current profile
          setProfile((prev) =>
            prev ? { ...prev, ...(payload.new as ExtendedProfile) } : null
          )
        }
      )
      .subscribe()

    return () => {
      supabase.removeChannel(channel)
    }
  }, [user])

  const signIn = useCallback(
    async (email: string, password: string): Promise<{ error: string | null }> => {
      setLoading(true)
      try {
        const { error } = await supabase.auth.signInWithPassword({ email, password })
        if (error) return { error: error.message }
        return { error: null }
      } finally {
        setLoading(false)
      }
    },
    []
  )

  const signOut = useCallback(async () => {
    setLoading(true)
    await supabase.auth.signOut()
    setCurrentSchool(null)
    setProfile(null)
    setLoading(false)
  }, [])

  const state: AuthState = {
    user,
    session,
    profile,
    currentSchool,
    loading,
    initialized,
  }

  return (
    <AuthContext.Provider
      value={{
        ...state,
        signIn,
        signOut,
        setCurrentSchool,
        refreshProfile,
      }}
    >
      {children}
    </AuthContext.Provider>
  )
}
