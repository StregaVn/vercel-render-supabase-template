import { Routes, Route } from 'react-router-dom'
import Dashboard from './pages/Dashboard'
import HealthcareOrganizations from './pages/HealthcareOrganizations'
import Facilities from './pages/Facilities'
import Providers from './pages/Providers'
import Timesheets from './pages/Timesheets'
import TimesheetTable from './pages/TimesheetTable'
import Login from './pages/Login'
import Users from './pages/Users'
import HighLevelSummary from './pages/Reports/HighLevelSummary'
import ConsolidatedReport from './pages/Reports/ConsolidatedReport'
import Details from './pages/Reports/Details'
import ProtectedRoute from './components/ProtectedRoute'

export default function App() {
  return (
    <Routes>
      <Route path="/login" element={<Login />} />
      <Route
        path="/"
        element={
          <ProtectedRoute>
            <Dashboard />
          </ProtectedRoute>
        }
      />
      <Route
        path="/healthcare-orgs"
        element={
          <ProtectedRoute>
            <HealthcareOrganizations />
          </ProtectedRoute>
        }
      />
      <Route
        path="/facilities"
        element={
          <ProtectedRoute>
            <Facilities />
          </ProtectedRoute>
        }
      />
      <Route
        path="/providers"
        element={
          <ProtectedRoute>
            <Providers />
          </ProtectedRoute>
        }
      />
      <Route
        path="/timesheets"
        element={
          <ProtectedRoute>
            <Timesheets />
          </ProtectedRoute>
        }
      />
      <Route
        path="/timesheets/upload"
        element={
          <ProtectedRoute>
            <TimesheetTable />
          </ProtectedRoute>
        }
      />
      <Route
        path="/users"
        element={
          <ProtectedRoute requireAdmin>
            <Users />
          </ProtectedRoute>
        }
      />
      <Route
        path="/reports/high-level-summary"
        element={
          <ProtectedRoute>
            <HighLevelSummary />
          </ProtectedRoute>
        }
      />
      <Route
        path="/reports/consolidated"
        element={
          <ProtectedRoute>
            <ConsolidatedReport />
          </ProtectedRoute>
        }
      />
      <Route
        path="/reports/details"
        element={
          <ProtectedRoute>
            <Details />
          </ProtectedRoute>
        }
      />
    </Routes>
  )
}
