import { useRef, useState } from 'react'
import { useQuery } from '@tanstack/react-query'
import { useNavigate, Link } from 'react-router-dom'
import apiClient from '../utils/api'
import Layout from '../components/Layout'
import { parseCSV } from '../utils/csvParser'

export default function Dashboard() {
  const fileInputRef = useRef<HTMLInputElement>(null)
  const navigate = useNavigate()
  const [uploading, setUploading] = useState(false)
  const [uploadMessage, setUploadMessage] = useState<string | null>(null)

  const { data: healthcareOrgs } = useQuery({
    queryKey: ['healthcare-orgs'],
    queryFn: async () => {
      const response = await apiClient.get('/api/healthcare-orgs')
      return response.data
    },
    staleTime: 60_000,
  })

  const { data: facilities } = useQuery({
    queryKey: ['facilities'],
    queryFn: async () => {
      const response = await apiClient.get('/api/facilities')
      return response.data
    },
    staleTime: 60_000,
  })

  const { data: providers } = useQuery({
    queryKey: ['providers'],
    queryFn: async () => {
      const response = await apiClient.get('/api/providers')
      return response.data
    },
    staleTime: 60_000,
  })

  const { data: timesheets } = useQuery({
    queryKey: ['timesheets'],
    queryFn: async () => {
      const response = await apiClient.get('/api/timesheets')
      return response.data
    },
    staleTime: 60_000,
  })

  const handleUploadClick = () => {
    fileInputRef.current?.click()
  }

  const handleFileChange = async (event: React.ChangeEvent<HTMLInputElement>) => {
    const file = event.target.files?.[0]
    if (!file) return

    // Validate file type
    if (!file.name.toLowerCase().endsWith('.csv')) {
      setUploadMessage('✗ Please select a CSV file.')
      event.target.value = ''
      return
    }

    setUploading(true)
    setUploadMessage(null)

    try {
      // Parse CSV file in the browser
      const csvData = await parseCSV(file)

      if (csvData.length === 0) {
        setUploadMessage('✗ CSV file is empty.')
        return
      }

      // Navigate to timesheet table page with parsed data
      navigate('/timesheets/upload', { state: { csvData } })
    } catch (error) {
      console.error('CSV parsing failed:', error)
      setUploadMessage(`✗ Failed to parse CSV: ${error instanceof Error ? error.message : 'Unknown error'}`)
    } finally {
      setUploading(false)
      // Reset input to allow selecting the same file again
      event.target.value = ''
    }
  }

  const headerActions = (
    <>
      <input
        ref={fileInputRef}
        type="file"
        accept=".csv"
        onChange={handleFileChange}
        className="hidden"
      />
      <button
        type="button"
        onClick={handleUploadClick}
        disabled={uploading}
        className="btn-primary hidden md:inline-flex disabled:opacity-50 disabled:cursor-not-allowed"
      >
        {uploading ? 'Uploading...' : 'Upload File'}
      </button>
      <button
        type="button"
        onClick={handleUploadClick}
        disabled={uploading}
        className="btn-primary inline-flex md:hidden disabled:opacity-50 disabled:cursor-not-allowed"
      >
        {uploading ? 'Uploading...' : 'Upload'}
      </button>
    </>
  )

  return (
    <Layout headerActions={headerActions}>
      <main className="mx-auto flex w-full max-w-6xl flex-1 flex-col gap-6 px-6 py-12">
        {uploadMessage && (
          <div className={`rounded-lg border px-4 py-3 ${uploadMessage.startsWith('✓')
            ? 'border-emerald-200 bg-emerald-50 text-emerald-900'
            : 'border-red-200 bg-red-50 text-red-900'
            }`}>
            {uploadMessage}
          </div>
        )}

        <section className="grid gap-4 md:grid-cols-2 lg:grid-cols-4">
          <Link
            to="/healthcare-orgs"
            className="card cursor-pointer transition-all hover:shadow-lg hover:border-brand-300"
          >
            <h2 className="text-sm font-medium text-slate-500">Healthcare Organizations</h2>
            <p className="mt-2 text-2xl font-semibold text-slate-900">
              {Array.isArray(healthcareOrgs) ? healthcareOrgs.length : '—'}
            </p>
            <p className="mt-3 text-sm text-slate-500">
              Total healthcare organizations in the system.
            </p>
          </Link>
          <Link
            to="/facilities"
            className="card cursor-pointer transition-all hover:shadow-lg hover:border-brand-300"
          >
            <h2 className="text-sm font-medium text-slate-500">Facilities</h2>
            <p className="mt-2 text-2xl font-semibold text-slate-900">
              {Array.isArray(facilities) ? facilities.length : '—'}
            </p>
            <p className="mt-3 text-sm text-slate-500">
              Total facilities in the system.
            </p>
          </Link>
          <Link
            to="/providers"
            className="card cursor-pointer transition-all hover:shadow-lg hover:border-brand-300"
          >
            <h2 className="text-sm font-medium text-slate-500">Providers</h2>
            <p className="mt-2 text-2xl font-semibold text-slate-900">
              {Array.isArray(providers) ? providers.length : '—'}
            </p>
            <p className="mt-3 text-sm text-slate-500">
              Total providers in the system.
            </p>
          </Link>
          <Link
            to="/timesheets"
            className="card cursor-pointer transition-all hover:shadow-lg hover:border-brand-300"
          >
            <h2 className="text-sm font-medium text-slate-500">Timesheets</h2>
            <p className="mt-2 text-2xl font-semibold text-slate-900">
              {Array.isArray(timesheets) ? timesheets.length : '—'}
            </p>
            <p className="mt-3 text-sm text-slate-500">
              Total timesheets in the system.
            </p>
          </Link>
          <Link
            to="/reports/high-level-summary"
            className="card cursor-pointer transition-all hover:shadow-lg hover:border-brand-300"
          >
            <h2 className="text-sm font-medium text-slate-500">High Level Summary</h2>
            <p className="mt-2 text-2xl font-semibold text-slate-900">
              View
            </p>
            <p className="mt-3 text-sm text-slate-500">
              View financial and operational metrics summary.
            </p>
          </Link>
          <Link
            to="/reports/details"
            className="card cursor-pointer transition-all hover:shadow-lg hover:border-brand-300"
          >
            <h2 className="text-sm font-medium text-slate-500">Details</h2>
            <p className="mt-2 text-2xl font-semibold text-slate-900">
              View
            </p>
            <p className="mt-3 text-sm text-slate-500">
              View detailed breakdown by client and facility.
            </p>
          </Link>
        </section>
      </main>
    </Layout>
  )
}

