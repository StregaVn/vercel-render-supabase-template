// API Configuration
// Local development uses localhost:8080
// For Render deployment, set VITE_API_URL environment variable in Vercel:
// Example: https://your-app.onrender.com
// Vercel will automatically inject this during build
export const API_BASE_URL = import.meta.env.VITE_API_URL || 'http://localhost:8080';

// Build timestamp update
