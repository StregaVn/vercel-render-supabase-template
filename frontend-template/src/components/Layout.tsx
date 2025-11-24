import { Fragment } from 'react'
import type { ReactNode } from 'react'
import { Disclosure, Transition } from '@headlessui/react'
import { Link } from 'react-router-dom'
import {
  Bars3Icon,
  XMarkIcon,
  ArrowRightOnRectangleIcon,
} from '@heroicons/react/24/outline'
import { useAuth } from '../contexts/AuthContext'

const navigation = [
  { name: 'Dashboard', href: '/', current: false },
  { name: 'Reports', href: '/reports/high-level-summary', current: false },
]

function classNames(...classes: Array<string | undefined | false>) {
  return classes.filter(Boolean).join(' ')
}

interface LayoutProps {
  children: ReactNode
  headerActions?: ReactNode
}

export default function Layout({ children, headerActions }: LayoutProps) {
  const { logout, isAdmin } = useAuth()

  return (
    <div className="flex min-h-screen flex-col bg-slate-100">
      <Disclosure as="header" className="border-b border-slate-200 bg-white">
        {({ open }) => (
          <>
            <div className="mx-auto flex w-full max-w-6xl items-center justify-between px-6 pb-2">
              <div className="flex items-center gap-8">
                <Link to="/" className="flex flex-col items-center">
                  <img
                    src="/finvisors-logo.png"
                    alt="FinVisors"
                    className="h-56 w-56 object-contain"
                  />
                  <span className="text-base font-semibold tracking-tight text-brand-700 -mt-14">
                    Locum Production
                  </span>
                </Link>
                <nav className="hidden gap-4 md:flex">
                  {navigation.map((item) => (
                    <Link
                      key={item.name}
                      to={item.href}
                      className={classNames(
                        item.current
                          ? 'text-brand-700'
                          : 'text-slate-500 hover:text-slate-900',
                        'text-sm font-medium',
                      )}
                    >
                      {item.name}
                    </Link>
                  ))}
                  {isAdmin && (
                    <Link
                      to="/users"
                      className="text-slate-500 hover:text-slate-900 text-sm font-medium"
                    >
                      Users
                    </Link>
                  )}
                </nav>
              </div>
              <div className="flex items-center gap-3">
                {headerActions}
                <button
                  onClick={() => logout()}
                  className="inline-flex items-center gap-2 rounded-md px-3 py-2 text-sm font-medium text-slate-500 hover:bg-slate-100 hover:text-slate-900"
                  title="Logout"
                >
                  <ArrowRightOnRectangleIcon className="h-5 w-5" />
                  <span className="hidden md:inline">Logout</span>
                </button>
                <Disclosure.Button className="inline-flex items-center justify-center rounded-md p-2 text-slate-500 hover:bg-slate-100 hover:text-slate-900 md:hidden">
                  <span className="sr-only">Open main menu</span>
                  {open ? (
                    <XMarkIcon className="h-6 w-6" aria-hidden="true" />
                  ) : (
                    <Bars3Icon className="h-6 w-6" aria-hidden="true" />
                  )}
                </Disclosure.Button>
              </div>
            </div>

            <Transition
              as={Fragment}
              enter="transition duration-150 ease-out"
              enterFrom="transform -translate-y-2 opacity-0"
              enterTo="transform translate-y-0 opacity-100"
              leave="transition duration-100 ease-in"
              leaveFrom="transform translate-y-0 opacity-100"
              leaveTo="transform -translate-y-2 opacity-0"
            >
              <Disclosure.Panel className="md:hidden">
                <div className="space-y-1 px-6 pb-4">
                  {navigation.map((item) => (
                    <Disclosure.Button
                      key={item.name}
                      as={Link}
                      to={item.href}
                      className={classNames(
                        item.current
                          ? 'bg-brand-50 text-brand-700'
                          : 'text-slate-600 hover:bg-slate-100 hover:text-slate-900',
                        'block rounded-md px-3 py-2 text-base font-medium',
                      )}
                    >
                      {item.name}
                    </Disclosure.Button>
                  ))}
                  {isAdmin && (
                    <Disclosure.Button
                      as={Link}
                      to="/users"
                      className="block rounded-md px-3 py-2 text-base font-medium text-slate-600 hover:bg-slate-100 hover:text-slate-900"
                    >
                      Users
                    </Disclosure.Button>
                  )}
                  <button
                    onClick={() => logout()}
                    className="block w-full text-left rounded-md px-3 py-2 text-base font-medium text-slate-600 hover:bg-slate-100 hover:text-slate-900"
                  >
                    Logout
                  </button>
                  {headerActions && (
                    <div className="pt-2 space-y-2">
                      {headerActions}
                    </div>
                  )}
                </div>
              </Disclosure.Panel>
            </Transition>
          </>
        )}
      </Disclosure>

      {children}

      <footer className="border-t border-slate-200 bg-white">
        <div className="mx-auto w-full max-w-6xl px-6 py-4">
          <div className="flex items-center justify-between text-xs text-slate-500">
            <div className="flex flex-col gap-1">
              <span>&copy; {new Date().getFullYear()} FinVisors</span>
              <span className="text-[10px] text-slate-400">
                Last updated: {new Date(import.meta.env.VITE_BUILD_TIME || Date.now()).toLocaleString('en-US', {
                  month: 'short',
                  day: 'numeric',
                  year: 'numeric',
                  hour: 'numeric',
                  minute: '2-digit',
                  timeZoneName: 'short'
                })}
              </span>
            </div>
            <div className="flex items-center gap-3">
              <a className="hover:text-slate-900" href="#" aria-label="Status page">
                Status
              </a>
              <a className="hover:text-slate-900" href="#" aria-label="Compliance reports">
                Compliance
              </a>
              <a className="hover:text-slate-900" href="#" aria-label="Support">
                Support
              </a>
            </div>
          </div>
        </div>
      </footer>
    </div>
  )
}

