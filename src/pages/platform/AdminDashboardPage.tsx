import { useEffect, useState, useCallback } from 'react'
import { supabase } from '@/lib/supabase'
import { PageHeader } from '@/components/layout/PageHeader'
import { Card, CardBody, CardHeader, StatCard } from '@/components/ui/Card'
import { Badge } from '@/components/ui/Badge'
import { Button } from '@/components/ui/Button'
import { Modal } from '@/components/ui/Modal'
import { Alert } from '@/components/ui/Alert'
import { Table, TableHead, TableBody, TableRow, Th, Td, TableEmpty, TableLoading } from '@/components/ui/Table'
import { formatDate } from '@/lib/utils'
import { CheckCircle2, XCircle, Clock, School, RefreshCw } from 'lucide-react'

interface PendingRegistration {
  id: string
  user_id: string
  full_name: string
  email: string
  phone: string | null
  intended_school_type: string | null
  message: string | null
  status: 'pending' | 'approved' | 'rejected'
  rejection_reason: string | null
  created_at: string
  reviewed_at: string | null
}

interface Stats {
  pending: number
  approved: number
  rejected: number
  total_schools: number
}

export function AdminDashboardPage() {
  const [registrations, setRegistrations] = useState<PendingRegistration[]>([])
  const [stats, setStats] = useState<Stats>({ pending: 0, approved: 0, rejected: 0, total_schools: 0 })
  const [loading, setLoading] = useState(true)
  const [actionLoading, setActionLoading] = useState<string | null>(null)
  const [error, setError] = useState<string | null>(null)
  const [success, setSuccess] = useState<string | null>(null)
  const [filter, setFilter] = useState<'pending' | 'approved' | 'rejected' | 'all'>('pending')

  // Reject modal state
  const [rejectModal, setRejectModal] = useState<{ open: boolean; id: string; name: string }>({
    open: false, id: '', name: '',
  })
  const [rejectReason, setRejectReason] = useState('')

  const fetchData = useCallback(async () => {
    setLoading(true)
    setError(null)

    const query = supabase
      .from('pending_registrations')
      .select('*')
      .order('created_at', { ascending: false })

    if (filter !== 'all') {
      query.eq('status', filter)
    }

    const [{ data: regs, error: regsError }, { count: schoolCount }] = await Promise.all([
      query,
      supabase.from('schools').select('id', { count: 'exact', head: true }),
    ])

    if (regsError) {
      setError('Failed to load registrations.')
    } else {
      setRegistrations((regs ?? []) as PendingRegistration[])
    }

    // Get counts
    const { data: counts } = await supabase
      .from('pending_registrations')
      .select('status')

    if (counts) {
      setStats({
        pending:  counts.filter(r => r.status === 'pending').length,
        approved: counts.filter(r => r.status === 'approved').length,
        rejected: counts.filter(r => r.status === 'rejected').length,
        total_schools: schoolCount ?? 0,
      })
    }

    setLoading(false)
  }, [filter])

  useEffect(() => { fetchData() }, [fetchData])

  const handleApprove = async (id: string, name: string) => {
    setActionLoading(id)
    setError(null)

    const { error: err } = await supabase.rpc('approve_registration', {
      p_registration_id: id,
    })

    if (err) {
      setError(`Failed to approve ${name}: ${err.message}`)
    } else {
      setSuccess(`${name} has been approved. They can now set up their school.`)
      fetchData()
    }
    setActionLoading(null)
  }

  const handleRejectSubmit = async () => {
    setActionLoading(rejectModal.id)
    setError(null)

    const { error: err } = await supabase.rpc('reject_registration', {
      p_registration_id: rejectModal.id,
      p_reason: rejectReason || null,
    })

    if (err) {
      setError(`Failed to reject: ${err.message}`)
    } else {
      setSuccess(`${rejectModal.name}'s application has been rejected.`)
      setRejectModal({ open: false, id: '', name: '' })
      setRejectReason('')
      fetchData()
    }
    setActionLoading(null)
  }

  return (
    <div>
      <PageHeader
        title="Platform Administration"
        description="Manage school registrations and platform settings."
        actions={
          <Button
            variant="outline"
            size="sm"
            leftIcon={<RefreshCw size={14} />}
            onClick={fetchData}
            loading={loading}
          >
            Refresh
          </Button>
        }
      />

      {/* KPI row */}
      <div className="grid grid-cols-2 gap-4 sm:grid-cols-4 mb-6">
        <StatCard label="Pending Review"  value={stats.pending}      icon={<Clock size={20} />} />
        <StatCard label="Approved"        value={stats.approved}     icon={<CheckCircle2 size={20} />} />
        <StatCard label="Rejected"        value={stats.rejected}     icon={<XCircle size={20} />} />
        <StatCard label="Active Schools"  value={stats.total_schools} icon={<School size={20} />} />
      </div>

      {error   && <Alert variant="error"   className="mb-4" onDismiss={() => setError(null)}>{error}</Alert>}
      {success && <Alert variant="success" className="mb-4" onDismiss={() => setSuccess(null)}>{success}</Alert>}

      <Card>
        <CardHeader
          title="School Registrations"
          description="Review and approve or reject new school applications."
          action={
            <div className="flex gap-1">
              {(['pending','approved','rejected','all'] as const).map(f => (
                <button
                  key={f}
                  onClick={() => setFilter(f)}
                  className={`rounded-lg px-3 py-1.5 text-xs font-medium capitalize transition-colors ${
                    filter === f
                      ? 'bg-primary-600 text-white'
                      : 'text-slate-600 hover:bg-slate-100'
                  }`}
                >
                  {f}
                </button>
              ))}
            </div>
          }
        />
        <CardBody className="p-0">
          <Table>
            <TableHead>
              <TableRow>
                <Th>Applicant</Th>
                <Th>School Type</Th>
                <Th>Phone</Th>
                <Th>Applied</Th>
                <Th>Status</Th>
                <Th>Actions</Th>
              </TableRow>
            </TableHead>
            <TableBody>
              {loading ? (
                <TableLoading />
              ) : registrations.length === 0 ? (
                <TableEmpty message={`No ${filter === 'all' ? '' : filter} registrations.`} />
              ) : (
                registrations.map((reg) => (
                  <TableRow key={reg.id}>
                    <Td>
                      <div>
                        <p className="font-medium text-slate-900">{reg.full_name}</p>
                        <p className="text-xs text-slate-500">{reg.email}</p>
                      </div>
                    </Td>
                    <Td>
                      <span className="capitalize">{reg.intended_school_type ?? '—'}</span>
                    </Td>
                    <Td>{reg.phone ?? '—'}</Td>
                    <Td>{formatDate(reg.created_at)}</Td>
                    <Td>
                      {reg.status === 'pending'  && <Badge variant="warning">Pending</Badge>}
                      {reg.status === 'approved' && <Badge variant="success">Approved</Badge>}
                      {reg.status === 'rejected' && <Badge variant="danger">Rejected</Badge>}
                    </Td>
                    <Td>
                      {reg.status === 'pending' && (
                        <div className="flex gap-2">
                          <Button
                            size="sm"
                            variant="secondary"
                            loading={actionLoading === reg.id}
                            onClick={() => handleApprove(reg.id, reg.full_name)}
                          >
                            Approve
                          </Button>
                          <Button
                            size="sm"
                            variant="danger"
                            disabled={actionLoading === reg.id}
                            onClick={() => setRejectModal({ open: true, id: reg.id, name: reg.full_name })}
                          >
                            Reject
                          </Button>
                        </div>
                      )}
                      {reg.status !== 'pending' && (
                        <span className="text-xs text-slate-400">
                          {formatDate(reg.reviewed_at)}
                        </span>
                      )}
                    </Td>
                  </TableRow>
                ))
              )}
            </TableBody>
          </Table>
        </CardBody>
      </Card>

      {/* Applicant message panel */}
      {registrations.filter(r => r.message && r.status === 'pending').length > 0 && (
        <Card className="mt-4">
          <CardHeader title="Applicant Messages" />
          <CardBody>
            {registrations
              .filter(r => r.message && r.status === 'pending')
              .map(reg => (
                <div key={reg.id} className="mb-3 last:mb-0 rounded-lg bg-slate-50 px-4 py-3">
                  <p className="text-xs font-semibold text-slate-700 mb-1">{reg.full_name}</p>
                  <p className="text-sm text-slate-600">{reg.message}</p>
                </div>
              ))}
          </CardBody>
        </Card>
      )}

      {/* Reject modal */}
      <Modal
        open={rejectModal.open}
        onClose={() => { setRejectModal({ open: false, id: '', name: '' }); setRejectReason('') }}
        title={`Reject application — ${rejectModal.name}`}
        size="sm"
        footer={
          <>
            <Button variant="outline" onClick={() => setRejectModal({ open: false, id: '', name: '' })}>
              Cancel
            </Button>
            <Button
              variant="danger"
              loading={actionLoading === rejectModal.id}
              onClick={handleRejectSubmit}
            >
              Confirm Rejection
            </Button>
          </>
        }
      >
        <p className="text-sm text-slate-600 mb-3">
          Optionally provide a reason. The applicant will see this message.
        </p>
        <textarea
          value={rejectReason}
          onChange={e => setRejectReason(e.target.value)}
          placeholder="e.g. Incomplete information provided…"
          rows={3}
          className="w-full rounded-lg border border-slate-300 px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-primary-500 resize-none"
        />
      </Modal>
    </div>
  )
}
