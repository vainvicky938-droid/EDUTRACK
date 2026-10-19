import { PageHeader } from '@/components/layout/PageHeader'

export function AdminSettingsPage() {
  return (
    <div>
      <PageHeader title="Platform Settings" description="Configure platform-wide settings and subscription plans." />
      <div className="rounded-xl border border-dashed border-slate-300 bg-white p-10 text-center text-sm text-slate-400">
        Platform settings — coming in Phase 9.
      </div>
    </div>
  )
}
