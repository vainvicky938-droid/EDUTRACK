import { useState, useEffect } from 'react'
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

const onboardingSchema = z.object({
  name: z.string().min(3, 'School name must be at least 3 characters'),
  type: z.enum(['secondary', 'primary', 'combined'], { required_error: 'Select school type' }),
  district: z.string().min(2, 'Enter your district'),
  address: z.string().min(5, 'Enter your school address'),
  phone: z.string().min(10, 'Enter a valid phone number'),
  email: z.string().email('Enter a valid school email').optional().or(z.literal('')),
})

type OnboardingFormData = z.infer<typeof onboardingSchema>

const UGANDA_DISTRICTS = [
  'Kampala','Wakiso','Mukono','Jinja','Mbale','Gulu','Mbarara','Masaka',
  'Entebbe','Lira','Arua','Soroti','Kabale','Fort Portal','Hoima',
  'Masindi','Tororo','Iganga','Busia','Kasese','Mityana','Mubende',
  'Ntungamo','Bushenyi','Rukungiri','Kanungu','Ibanda','Isingiro',
  'Kiruhura','Sembabule','Lwengo','Lyantonde','Rakai','Kyotera',
  'Bukomansimbi','Kalungu','Kween','Bulambuli','Sironko',
  'Manafwa','Bududa','Namisindwa','Butaleja','Kibuku','Pallisa',
  'Kumi','Ngora','Serere','Amuria','Katakwi','Kaberamaido',
  'Dokolo','Alebtong','Otuke','Kwania','Oyam','Kole','Apac',
  'Amolatar','Pader','Agago','Kitgum','Lamwo','Nwoya',
  'Adjumani','Moyo','Yumbe','Koboko','Maracha','Nebbi',
  'Zombo','Pakwach','Buliisa','Kiryandongo','Other',
].sort()

/** Complete the onboarding for a user who already has a school */
async function completeExistingOnboarding(
  userId: string,
  schoolId: string,
  schoolName: string,
  schoolType: string,
  role: string,
  auth: ReturnType<typeof useAuth>,
  navigate: ReturnType<typeof useNavigate>
) {
  await supabase
    .from('user_profiles')
    .update({ onboarding_status: 'complete' })
    .eq('id', userId)

  // Refresh the in-memory profile so ProtectedRoute sees 'complete'
  await auth.refreshProfile()

  auth.setCurrentSchool({
    schoolId,
    schoolName,
    schoolType: schoolType as 'primary' | 'secondary' | 'combined',
    role: role as 'school_owner',
    extraPermissions: {},
  })

  navigate('/dashboard')
}

export function SchoolOnboardingPage() {
  const auth = useAuth()
  const navigate = useNavigate()
  const [serverError, setServerError] = useState<string | null>(null)
  const [checking, setChecking] = useState(true)

  // On mount: check if user already has a school created from a previous attempt
  useEffect(() => {
    if (!auth.user) return

    async function checkExistingSchool() {
      // Step 1: check membership only (no join — avoids RLS complexity)
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

      // Step 2: fetch school details separately
      const { data: school } = await supabase
        .from('schools')
        .select('id, name, type')
        .eq('id', membership.school_id)
        .single()

      if (school) {
        await completeExistingOnboarding(
          auth.user!.id, school.id, school.name, school.type, membership.role, auth, navigate
        )
        return
      }

      setChecking(false)
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

    // Guard: check for existing school before creating a new one
    const { data: existingMembership } = await supabase
      .from('school_memberships')
      .select('school_id, role')
      .eq('user_id', auth.user.id)
      .eq('status', 'active')
      .maybeSingle()

    if (existingMembership?.school_id) {
      const { data: existingSchool } = await supabase
        .from('schools')
        .select('id, name, type')
        .eq('id', existingMembership.school_id)
        .single()

      if (existingSchool) {
        await completeExistingOnboarding(
          auth.user.id, existingSchool.id, existingSchool.name,
          existingSchool.type, existingMembership.role, auth, navigate
        )
        return
      }
    }

    // Generate a URL-safe slug
    const slug = data.name
      .toLowerCase()
      .replace(/[^a-z0-9]+/g, '-')
      .replace(/^-|-$/g, '')
      + '-' + Math.random().toString(36).slice(2, 6)

    // 1. Create the school
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

    // 2. Create school membership as owner
    const { error: memberError } = await supabase
      .from('school_memberships')
      .insert({
        school_id: school.id,
        user_id: auth.user.id,
        role: 'school_owner',
        status: 'active',
      })

    if (memberError) {
      setServerError('School created but failed to set up your access. Please contact support.')
      return
    }

    // 3. Mark onboarding complete in DB + refresh in-memory profile
    await supabase
      .from('user_profiles')
      .update({ onboarding_status: 'complete' })
      .eq('id', auth.user.id)

    // CRITICAL: refresh profile before navigating so ProtectedRoute sees 'complete'
    await auth.refreshProfile()

    // 4. Set school context and navigate
    auth.setCurrentSchool({
      schoolId: school.id,
      schoolName: school.name,
      schoolType: school.type as 'primary' | 'secondary' | 'combined',
      role: 'school_owner',
      extraPermissions: {},
    })

    navigate('/dashboard')
  }

  // Show spinner while checking for existing school
  if (checking) {
    return (
      <div className="min-h-screen bg-gradient-to-br from-primary-950 via-primary-900 to-primary-800 flex items-center justify-center">
        <div className="flex flex-col items-center gap-3">
          <div className="animate-spin h-10 w-10 border-4 border-primary-700 border-t-accent-400 rounded-full" />
          <p className="text-primary-300 text-sm">Setting up your workspace…</p>
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
            Your account has been approved. Fill in your school information to get started.
          </p>

          {serverError && (
            <Alert variant="error" className="mb-4" onDismiss={() => setServerError(null)}>
              {serverError}
            </Alert>
          )}

          <form onSubmit={handleSubmit(onSubmit)} noValidate className="space-y-4">
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
                { value: 'primary',   label: 'Primary School' },
                { value: 'combined',  label: 'Combined (Primary & Secondary)' },
              ]}
              error={errors.type?.message}
              {...register('type')}
            />

            <Select
              label="District"
              required
              placeholder="Select district"
              options={UGANDA_DISTRICTS.map(d => ({ value: d, label: d }))}
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
