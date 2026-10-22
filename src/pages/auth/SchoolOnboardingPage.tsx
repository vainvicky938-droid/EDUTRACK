import { useState, useEffect, useRef } from 'react'
import { useNavigate } from 'react-router-dom'
import { useForm } from 'react-hook-form'
import { zodResolver } from '@hookform/resolvers/zod'
import { z } from 'zod'
import { supabase } from '@/lib/supabase'
import { useAuth } from '@/stores/authStore'
import { Input } from '@/components/ui/Input'
import { Select } from '@/components/ui/Select'
import { Button } from '@/components/ui/Button'
import { Alert } from '@/components/ui/Alert'
import { GraduationCap, Building2, MapPin, Phone, Mail } from 'lucide-react'
import type { ExtendedProfile } from '@/stores/AuthProvider'

const onboardingSchema = z.object({
  name: z.string().min(3, 'School name must be at least 3 characters'),
  type: z.enum(['secondary', 'primary', 'combined'], {
    required_error: 'Select school type',
  }),
  district: z.string().min(2, 'Enter your district'),
  address: z.string().min(5, 'Enter your school address'),
  phone: z.string().min(10, 'Enter a valid phone number'),
  email: z
    .string()
    .email('Enter a valid school email')
    .optional()
    .or(z.literal('')),
})

type OnboardingFormData = z.infer<typeof onboardingSchema>

const UGANDA_DISTRICTS = [
  'Adjumani','Agago','Alebtong','Amolatar','Amuria','Arua','Bududa',
  'Buikwe','Bukomansimbi','Bulambuli','Buliisa','Bundibugyo','Bushenyi',
  'Busia','Butaleja','Butebo','Dokolo','Fort Portal','Gulu','Hoima',
  'Ibanda','Iganga','Isingiro','Jinja','Kabale','Kaberamaido','Kalungu',
  'Kampala','Kamuli','Kanungu','Kasese','Katakwi','Kibuku','Kiryandongo',
  'Kiruhura','Kitgum','Koboko','Kole','Kotido','Kumi','Kween','Kwania',
  'Lamwo','Lira','Lwengo','Lyantonde','Manafwa','Maracha','Masaka',
  'Masindi','Mbale','Mityana','Moyo','Mubende','Mukono','Namisindwa',
  'Nakapiripirit','Namutumba','Nebbi','Ngora','Ntungamo','Nwoya',
  'Otuke','Oyam','Pader','Pakwach','Pallisa','Rakai','Rukungiri',
  'Sembabule','Serere','Sironko','Soroti','Tororo','Wakiso','Yumbe',
  'Zombo','Other',
].sort()

export function SchoolOnboardingPage() {
  const auth = useAuth()
  const navigate = useNavigate()
  const [serverError, setServerError] = useState<string | null>(null)
  const [checking, setChecking] = useState(true)
  const [completing, setCompleting] = useState(false)
  const navigatedRef = useRef(false)

  const profile = auth.profile as ExtendedProfile | null

  // Watch for profile.onboarding_status becoming 'complete'
  // This fires both from realtime subscription AND from refreshProfile()
  useEffect(() => {
    if (navigatedRef.current) return
    if (profile?.onboarding_status === 'complete') {
      navigatedRef.current = true
      navigate('/dashboard', { replace: true })
    }
  }, [profile?.onboarding_status, navigate])

  // On mount: check if user already has a school from a previous attempt
  useEffect(() => {
    if (!auth.user) return

    async function checkExistingSchool() {
      // Check membership
      const { data: membership } = await supabase
        .from('school_memberships')
        .select('school_id, role')
        .eq('user_id', auth.user!.id)
        .eq('status', 'active')
        .maybeSingle()

      if (!membership?.school_id) {
        setChecking(false)
        return
      }

      // Has an existing school — complete onboarding
      setCompleting(true)
      const { data: school } = await supabase
        .from('schools')
        .select('id, name, type')
        .eq('id', membership.school_id)
        .single()

      if (school) {
        // Set school context first
        auth.setCurrentSchool({
          schoolId: school.id,
          schoolName: school.name,
          schoolType: school.type as 'primary' | 'secondary' | 'combined',
          role: membership.role as 'school_owner',
          extraPermissions: {},
        })

        // Update DB — realtime will update the profile in memory automatically
        await supabase
          .from('user_profiles')
          .update({ onboarding_status: 'complete' })
          .eq('id', auth.user!.id)

        // Also manually refresh in case realtime hasn't fired yet
        await auth.refreshProfile()
        // Navigation happens in the useEffect watching profile.onboarding_status
      } else {
        setChecking(false)
        setCompleting(false)
      }
    }

    checkExistingSchool()
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [auth.user])

  const {
    register,
    handleSubmit,
    formState: { errors, isSubmitting },
  } = useForm<OnboardingFormData>({
    resolver: zodResolver(onboardingSchema),
  })

  const onSubmit = async (data: OnboardingFormData) => {
    setServerError(null)
    if (!auth.user) return

    // Guard: check for existing school first
    const { data: existingMembership } = await supabase
      .from('school_memberships')
      .select('school_id, role')
      .eq('user_id', auth.user.id)
      .eq('status', 'active')
      .maybeSingle()

    if (existingMembership?.school_id) {
      // Already has a school — just complete onboarding
      const { data: existingSchool } = await supabase
        .from('schools')
        .select('id, name, type')
        .eq('id', existingMembership.school_id)
        .single()

      if (existingSchool) {
        setCompleting(true)
        auth.setCurrentSchool({
          schoolId: existingSchool.id,
          schoolName: existingSchool.name,
          schoolType: existingSchool.type as 'primary' | 'secondary' | 'combined',
          role: existingMembership.role as 'school_owner',
          extraPermissions: {},
        })
        await supabase
          .from('user_profiles')
          .update({ onboarding_status: 'complete' })
          .eq('id', auth.user.id)
        await auth.refreshProfile()
        return
      }
    }

    // Create the school slug
    const slug =
      data.name
        .toLowerCase()
        .replace(/[^a-z0-9]+/g, '-')
        .replace(/^-|-$/g, '') +
      '-' +
      Math.random().toString(36).slice(2, 6)

    // 1. Create school
    const { data: school, error: schoolError } = await supabase
      .from('schools')
      .insert({
        name: data.name,
        slug,
        type: data.type,
        district: data.district,
        address: data.address,
        phone: data.phone,
        email: data.email || null,
        status: 'trial',
        is_trial: true,
      })
      .select('id, name, type')
      .single()

    if (schoolError) {
      setServerError('Failed to create school. Please try again.')
      return
    }

    // 2. Create membership
    const { error: memberError } = await supabase
      .from('school_memberships')
      .insert({
        school_id: school.id,
        user_id: auth.user.id,
        role: 'school_owner',
        status: 'active',
      })

    if (memberError) {
      setServerError(
        'School created but failed to set up your access. Please contact support.'
      )
      return
    }

    // 3. Set school context
    auth.setCurrentSchool({
      schoolId: school.id,
      schoolName: school.name,
      schoolType: school.type as 'primary' | 'secondary' | 'combined',
      role: 'school_owner',
      extraPermissions: {},
    })

    setCompleting(true)

    // 4. Mark complete in DB — realtime fires → profile updates → navigate useEffect fires
    await supabase
      .from('user_profiles')
      .update({ onboarding_status: 'complete' })
      .eq('id', auth.user.id)

    // Also manual refresh as fallback
    await auth.refreshProfile()
    // Navigation is handled by the useEffect watching profile.onboarding_status
  }

  // Show spinner while checking or completing
  if (checking || completing) {
    return (
      <div className="min-h-screen bg-gradient-to-br from-primary-950 via-primary-900 to-primary-800 flex items-center justify-center">
        <div className="flex flex-col items-center gap-3">
          <div className="animate-spin h-10 w-10 border-4 border-primary-700 border-t-accent-400 rounded-full" />
          <p className="text-primary-300 text-sm">
            {completing ? 'Creating your workspace…' : 'Setting things up…'}
          </p>
        </div>
      </div>
    )
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-primary-950 via-primary-900 to-primary-800 flex items-center justify-center p-4">
      <div className="w-full max-w-lg">
        <div className="flex flex-col items-center mb-8">
          <div className="flex h-14 w-14 items-center justify-center rounded-2xl bg-accent-500 shadow-lg mb-4">
            <GraduationCap size={28} className="text-white" />
          </div>
          <h1 className="text-3xl font-bold text-white tracking-tight">EduTrack</h1>
          <p className="mt-1 text-primary-300 text-sm">Set up your school</p>
        </div>

        <div className="rounded-2xl bg-white shadow-modal p-8">
          <h2 className="text-xl font-bold text-slate-900 mb-1">School Details</h2>
          <p className="text-sm text-slate-500 mb-6">
            Your account has been approved. Fill in your school information to get
            started.
          </p>

          {serverError && (
            <Alert
              variant="error"
              className="mb-4"
              onDismiss={() => setServerError(null)}
            >
              {serverError}
            </Alert>
          )}

          <form
            onSubmit={handleSubmit(onSubmit)}
            noValidate
            className="space-y-4"
          >
            <Input
              label="School name"
              type="text"
              placeholder="e.g. St. Mary's College Kampala"
              required
              leftElement={<Building2 size={16} />}
              error={errors.name?.message}
              {...register('name')}
            />

            <Select
              label="School type"
              required
              placeholder="Select school type"
              options={[
                { value: 'secondary', label: 'Secondary School' },
                { value: 'primary', label: 'Primary School' },
                { value: 'combined', label: 'Combined (Primary & Secondary)' },
              ]}
              error={errors.type?.message}
              {...register('type')}
            />

            <Select
              label="District"
              required
              placeholder="Select district"
              options={UGANDA_DISTRICTS.map((d) => ({ value: d, label: d }))}
              error={errors.district?.message}
              {...register('district')}
            />

            <Input
              label="School address"
              type="text"
              placeholder="e.g. Plot 12, Nakasero Hill Road"
              required
              leftElement={<MapPin size={16} />}
              error={errors.address?.message}
              {...register('address')}
            />

            <Input
              label="School phone"
              type="tel"
              placeholder="+256 700 000000"
              required
              leftElement={<Phone size={16} />}
              error={errors.phone?.message}
              {...register('phone')}
            />

            <Input
              label="School email"
              type="email"
              placeholder="admin@yourschool.edu.ug"
              leftElement={<Mail size={16} />}
              hint="Optional but recommended"
              error={errors.email?.message}
              {...register('email')}
            />

            <Button
              type="submit"
              variant="primary"
              size="lg"
              loading={isSubmitting}
              className="w-full mt-2"
            >
              Create School Workspace
            </Button>
          </form>
        </div>

        <p className="mt-6 text-center text-xs text-primary-400">
          &copy; {new Date().getFullYear()} EduTrack Uganda. All rights reserved.
        </p>
      </div>
    </div>
  )
}
