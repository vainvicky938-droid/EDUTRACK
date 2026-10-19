import { PageHeader } from '@/components/layout/PageHeader'

export function AdminUsersPage() {
  return (
    <div>
      <PageHeader title="Platform Users" description="All registered users across the platform." />
      <div className="rounded-xl border border-dashed border-slate-300 bg-white p-10 text-center text-sm text-slate-400">
        Full user management — coming in Phase 9.
      </div>
    </div>
  )
}
