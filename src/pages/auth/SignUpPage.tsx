import { useState } from 'react'
import { useForm } from 'react-hook-form'
import { zodResolver } from '@hookform/resolvers/zod'
import { z } from 'zod'
import { Link, useNavigate } from 'react-router-dom'
import { Eye, EyeOff, Mail, Lock, User, Phone } from 'lucide-react'
import { supabase } from '@/lib/supabase'
import { Input } from '@/components/ui/Input'
import { Select } from '@/components/ui/Select'
import { Button } from '@/components/ui/Button'
import { Alert } from '@/components/ui/Alert'

const signUpSchema = z.object({
  full_name: z.string().min(3, 'Enter your full name (at least 3 characters)'),
  email: z.string().email('Enter a valid email address'),
  phone: z.string().min(10, 'Enter a valid phone number').optional().or(z.literal('')),
  intended_school_type: z.enum(['secondary', 'primary', 'combined'], {
    required_error: 'Select your school type',
  }),
  message: z.string().max(300, 'Keep your message under 300 characters').optional().or(z.literal('')),
  password: z.string().min(8, 'Password must be at least 8 characters'),
  confirm_password: z.string(),
}).refine((d) => d.password === d.confirm_password, {
  message: 'Passwords do not match',
  path: ['confirm_password'],
})

type SignUpFormData = z.infer<typeof signUpSchema>

export function SignUpPage() {
  const navigate = useNavigate()
  const [showPassword, setShowPassword] = useState(false)
  const [showConfirm, setShowConfirm] = useState(false)
  const [serverError, setServerError] = useState<string | null>(null)

  const {
    register,
    handleSubmit,
    formState: { errors, isSubmitting },
  } = useForm<SignUpFormData>({
    resolver: zodResolver(signUpSchema),
  })

  const onSubmit = async (data: SignUpFormData) => {
    setServerError(null)

    // 1. Create auth user
    const { data: authData, error: authError } = await supabase.auth.signUp({
      email: data.email,
      password: data.password,
      options: {
        data: { full_name: data.full_name },
      },
    })

    if (authError) {
      setServerError(authError.message)
      return
    }

    const userId = authData.user?.id
    if (!userId) {
      setServerError('Account creation failed. Please try again.')
      return
    }

    // 2. Create pending registration record
    const { error: regError } = await supabase
      .from('pending_registrations')
      .insert({
        user_id: userId,
        full_name: data.full_name,
        email: data.email,
        phone: data.phone || null,
        intended_school_type: data.intended_school_type,
        message: data.message || null,
      })

    if (regError) {
      setServerError('Could not submit your registration. Please contact support.')
      return
    }

    // 3. Redirect to pending screen
    navigate('/pending-approval')
  }

  return (
    <div>
      <h2 className="text-xl font-bold text-slate-900 mb-1">Create your account</h2>
      <p className="text-sm text-slate-500 mb-6">
        Register your school on EduTrack. Your account will be reviewed before access is granted.
      </p>

      {serverError && (
        <Alert variant="error" className="mb-4" onDismiss={() => setServerError(null)}>
          {serverError}
        </Alert>
      )}

      <form onSubmit={handleSubmit(onSubmit)} noValidate className="space-y-4">
        <Input
          label="Full name"
          type="text"
          autoComplete="name"
          placeholder="e.g. John Ssemakula"
          required
          leftElement={<User size={16} />}
          error={errors.full_name?.message}
          {...register('full_name')}
        />

        <Input
          label="Email address"
          type="email"
          autoComplete="email"
          placeholder="you@school.ug"
          required
          leftElement={<Mail size={16} />}
          error={errors.email?.message}
          {...register('email')}
        />

        <Input
          label="Phone number"
          type="tel"
          autoComplete="tel"
          placeholder="+256 700 000000"
          leftElement={<Phone size={16} />}
          error={errors.phone?.message}
          {...register('phone')}
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
          error={errors.intended_school_type?.message}
          {...register('intended_school_type')}
        />

        <Input
          label="Password"
          type={showPassword ? 'text' : 'password'}
          autoComplete="new-password"
          placeholder="At least 8 characters"
          required
          leftElement={<Lock size={16} />}
          rightElement={
            <button type="button" onClick={() => setShowPassword(v => !v)}
              className="pointer-events-auto text-slate-400 hover:text-slate-600"
              aria-label={showPassword ? 'Hide password' : 'Show password'}>
              {showPassword ? <EyeOff size={16} /> : <Eye size={16} />}
            </button>
          }
          error={errors.password?.message}
          {...register('password')}
        />

        <Input
          label="Confirm password"
          type={showConfirm ? 'text' : 'password'}
          autoComplete="new-password"
          placeholder="Repeat your password"
          required
          leftElement={<Lock size={16} />}
          rightElement={
            <button type="button" onClick={() => setShowConfirm(v => !v)}
              className="pointer-events-auto text-slate-400 hover:text-slate-600"
              aria-label={showConfirm ? 'Hide password' : 'Show password'}>
              {showConfirm ? <EyeOff size={16} /> : <Eye size={16} />}
            </button>
          }
          error={errors.confirm_password?.message}
          {...register('confirm_password')}
        />

        <Button
          type="submit"
          variant="primary"
          size="lg"
          loading={isSubmitting}
          className="w-full"
        >
          Submit Registration
        </Button>
      </form>

      <p className="mt-5 text-center text-sm text-slate-500">
        Already have an account?{' '}
        <Link to="/login" className="text-primary-600 hover:underline font-medium">
          Sign in
        </Link>
      </p>
    </div>
  )
}
