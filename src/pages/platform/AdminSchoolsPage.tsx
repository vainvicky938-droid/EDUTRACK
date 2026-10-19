import { useEffect, useState } from 'react'
import { supabase } from '@/lib/supabase'
import { PageHeader } from '@/components/layout/PageHeader'
import { Card, CardBody } from '@/components/ui/Card'
import { Table, TableHead, TableBody, TableRow, Th, Td, TableEmpty, TableLoading } from '@/components/ui/Table'
import { StatusBadge } from '@/components/ui/Badge'
import { formatDate } from '@/lib/utils'
import type { School } from '@/types'

export function AdminSchoolsPage() {
  const [schools, setSchools] = useState<School[]>([])
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    supabase.from('schools').select('*').order('created_at', { ascending: false })
      .then(({ data }) => { setSchools((data ?? []) as School[]); setLoading(false) })
  }, [])

  return (
    <div>
      <PageHeader title="All Schools" description="Every school workspace registered on the platform." />
      <Card>
        <CardBody className="p-0">
          <Table>
            <TableHead>
              <TableRow>
                <Th>School</Th>
                <Th>Type</Th>
                <Th>District</Th>
                <Th>Status</Th>
                <Th>Registered</Th>
              </TableRow>
            </TableHead>
            <TableBody>
              {loading ? <TableLoading /> : schools.length === 0 ? <TableEmpty /> : schools.map(s => (
                <TableRow key={s.id}>
                  <Td><p className="font-medium">{s.name}</p><p className="text-xs text-slate-500">{s.email ?? '—'}</p></Td>
                  <Td className="capitalize">{s.type}</Td>
                  <Td>{s.district ?? '—'}</Td>
                  <Td><StatusBadge status={s.status} /></Td>
                  <Td>{formatDate(s.created_at)}</Td>
                </TableRow>
              ))}
            </TableBody>
          </Table>
        </CardBody>
      </Card>
    </div>
  )
}
