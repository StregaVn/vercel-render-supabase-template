import { createContext, useContext, useState, useEffect } from 'react'
import type { ReactNode } from 'react'
import { useNavigate } from 'react-router-dom'
import apiClient from '../utils/api'

interface User {
    email: string
    userType: 'CUSTOMER' | 'ADMIN'
    userId: string
    firstName: string
    lastName: string
}

interface AuthContextType {
    user: User | null
    isLoading: boolean
    isAuthenticated: boolean
    isAdmin: boolean
    login: (email: string, password: string) => Promise<void>
    logout: () => Promise<void>
    checkAuth: () => Promise<void>
}

const AuthContext = createContext<AuthContextType | undefined>(undefined)

export function AuthProvider({ children }: { children: ReactNode }) {
    const [user, setUser] = useState<User | null>(null)
    const [isLoading, setIsLoading] = useState(true)
    const navigate = useNavigate()

    // Check authentication status on mount (skip on login page)
    useEffect(() => {
        // Don't check auth if we're on the login page
        if (window.location.pathname !== '/login') {
            checkAuth()
        } else {
            setIsLoading(false)
        }
    }, [])

    const checkAuth = async () => {
        try {
            // Call the /api/auth/me endpoint to get current user info
            const response = await apiClient.get('/api/auth/me')
            if (response.data) {
                setUser({
                    email: response.data.email,
                    userType: response.data.userType,
                    userId: response.data.userId,
                    firstName: response.data.firstName,
                    lastName: response.data.lastName,
                })
            }
            setIsLoading(false)
        } catch (error) {
            // Not authenticated or error occurred
            setUser(null)
            setIsLoading(false)
        }
    }

    const login = async (email: string, password: string) => {
        const response = await apiClient.post('/api/auth/login', { email, password })
        if (response.data.success) {
            // Auth successful, cookie is set
            await checkAuth()
            navigate('/')
        }
    }

    const logout = async () => {
        try {
            await apiClient.post('/api/auth/logout')
        } catch (error) {
            // Even if logout fails, clear local state
        } finally {
            setUser(null)
            navigate('/login')
        }
    }

    const value: AuthContextType = {
        user,
        isLoading,
        isAuthenticated: user !== null,
        isAdmin: user?.userType === 'ADMIN',
        login,
        logout,
        checkAuth,
    }

    return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>
}

export function useAuth() {
    const context = useContext(AuthContext)
    if (context === undefined) {
        throw new Error('useAuth must be used within an AuthProvider')
    }
    return context
}

