import { useState } from 'react'
import { useForm } from 'react-hook-form'
import { zodResolver } from '@hookform/resolvers/zod'
import { z } from 'zod'
import { Eye, EyeOff, Mail, Lock, X, Send } from 'lucide-react'
import { useAuth } from '@/stores/authStore'
import { useNavigate, useLocation, Link } from 'react-router-dom'
import { Input } from '@/components/ui/Input'
import { Textarea } from '@/components/ui/Textarea'
import { Button } from '@/components/ui/Button'
import { Alert } from '@/components/ui/Alert'

const loginSchema = z.object({
  email: z.string().email('Enter a valid email address'),
  password: z.string().min(6, 'Password must be at least 6 characters'),
})

type LoginFormData = z.infer<typeof loginSchema>

export function LoginPage() {
  const auth = useAuth()
  const navigate = useNavigate()
  const location = useLocation()
  const [showPassword, setShowPassword] = useState(false)
  const [serverError, setServerError] = useState<string | null>(null)
  const [showContactModal, setShowContactModal] = useState(false)
  const [contactSent, setContactSent] = useState(false)
  const [contactEmail, setContactEmail] = useState('')
  const [contactMessage, setContactMessage] = useState('')

  const from =
    (location.state as { from?: { pathname: string } })?.from?.pathname ??
    '/dashboard'

  const {
    register,
    handleSubmit,
    formState: { errors, isSubmitting },
  } = useForm<LoginFormData>({
    resolver: zodResolver(loginSchema),
  })

  const onSubmit = async (data: LoginFormData) => {
    setServerError(null)
    const { error } = await auth.signIn(data.email, data.password)
    if (error) {
      setServerError(error)
      return
    }
    navigate(from, { replace: true })
  }

  const handleContactSubmit = (e: React.FormEvent) => {
    e.preventDefault()
    // In MVP: just shows confirmation. Email integration comes in a later phase.
    setContactSent(true)
    setTimeout(() => {
      setShowContactModal(false)
      setContactSent(false)
      setContactEmail('')
      setContactMessage('')
    }, 3000)
  }

  return (
    <div>
      <h2 className="text-xl font-bold text-slate-900 mb-1">Sign in to EduTrack</h2>
      <p className="text-sm text-slate-500 mb-6">
        Enter your credentials to access your school workspace.
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

      <form onSubmit={handleSubmit(onSubmit)} noValidate className="space-y-4">
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
          label="Password"
          type={showPassword ? 'text' : 'password'}
          autoComplete="current-password"
          placeholder="••••••••"
          required
          leftElement={<Lock size={16} />}
          rightElement={
            <button
              type="button"
              onClick={() => setShowPassword((v) => !v)}
              className="pointer-events-auto text-slate-400 hover:text-slate-600"
              aria-label={showPassword ? 'Hide password' : 'Show password'}
            >
              {showPassword ? <EyeOff size={16} /> : <Eye size={16} />}
            </button>
          }
          error={errors.password?.message}
          {...register('password')}
        />

        <Button
          type="submit"
          variant="primary"
          size="lg"
          loading={isSubmitting || auth.loading}
          className="w-full"
        >
          Sign In
        </Button>
      </form>

      {/* Bottom links */}
      <div className="mt-5 space-y-2 text-center text-sm text-slate-500">
        <p>
          Having trouble signing in?{' '}
          <button
            onClick={() => setShowContactModal(true)}
            className="text-primary-600 hover:underline font-medium"
          >
            Contact administrator
          </button>
        </p>
        <p>
          New to EduTrack?{' '}
          <Link
            to="/signup"
            className="text-primary-600 hover:underline font-medium"
          >
            Request access
          </Link>
        </p>
      </div>

      {/* Contact Admin Modal */}
      {showContactModal && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4">
          <div
            className="absolute inset-0 bg-slate-900/50"
            onClick={() => setShowContactModal(false)}
          />
          <div className="relative z-10 w-full max-w-md rounded-2xl bg-white shadow-xl p-6">
            <div className="flex items-center justify-between mb-4">
              <h3 className="text-base font-semibold text-slate-900">
                Contact Administrator
              </h3>
              <button
                onClick={() => setShowContactModal(false)}
                className="rounded-lg p-1.5 text-slate-400 hover:bg-slate-100"
              >
                <X size={16} />
              </button>
            </div>

            {contactSent ? (
              <div className="py-6 text-center">
                <div className="flex justify-center mb-3">
                  <div className="rounded-full bg-success-100 p-3">
                    <Send size={24} className="text-success-600" />
                  </div>
                </div>
                <p className="font-medium text-slate-900">Message received</p>
                <p className="text-sm text-slate-500 mt-1">
                  The administrator will get back to you shortly.
                </p>
              </div>
            ) : (
              <form onSubmit={handleContactSubmit} className="space-y-4">
                <p className="text-sm text-slate-500">
                  Send a message to the EduTrack platform administrator.
                </p>
                <Input
                  label="Your email"
                  type="email"
                  placeholder="you@example.com"
                  required
                  leftElement={<Mail size={16} />}
                  value={contactEmail}
                  onChange={(e) => setContactEmail(e.target.value)}
                />
                <Textarea
                  label="Message"
                  placeholder="Describe your issue or question…"
                  required
                  value={contactMessage}
                  onChange={(e) => setContactMessage(e.target.value)}
                />
                <div className="flex gap-3 justify-end">
                  <Button
                    type="button"
                    variant="outline"
                    size="sm"
                    onClick={() => setShowContactModal(false)}
                  >
                    Cancel
                  </Button>
                  <Button
                    type="submit"
                    variant="primary"
                    size="sm"
                    disabled={!contactEmail || !contactMessage}
                  >
                    Send Message
                  </Button>
                </div>
              </form>
            )}
          </div>
        </div>
      )}
    </div>
  )
}
