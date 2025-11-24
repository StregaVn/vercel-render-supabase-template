# Frontend Template

React + TypeScript + Vite frontend template for deployment to Vercel with Render backend.

## 📁 Structure

```
frontend-template/
├── public/                    # Static assets
│   └── vite.svg               # App icon
├── src/
│   ├── components/            # Reusable UI components
│   │   ├── Layout.tsx         # Main layout wrapper
│   │   └── ProtectedRoute.tsx # Route authentication guard
│   ├── contexts/              # React contexts
│   │   └── AuthContext.tsx    # Authentication state management
│   ├── pages/                 # Page components (routes)
│   │   ├── Login.tsx          # Login page
│   │   └── Dashboard.tsx      # Dashboard (example)
│   ├── services/              # API service layer
│   ├── types/                 # TypeScript type definitions
│   ├── utils/                 # Utility functions
│   │   └── api.ts             # Axios client with auth handling
│   ├── App.tsx                # Main app component with routing
│   ├── main.tsx               # Application entry point
│   ├── config.ts              # Configuration (API URL, etc.)
│   └── index.css              # Global styles (Tailwind)
├── eslint.config.js           # ESLint configuration
├── index.html                 # HTML template
├── package.json               # Dependencies and scripts
├── postcss.config.js          # PostCSS configuration (Tailwind)
├── tailwind.config.js         # Tailwind CSS configuration
├── tsconfig.json              # TypeScript configuration
├── vercel.json                # Vercel deployment config (SPA routing)
└── vite.config.ts             # Vite build configuration
```

## 🚀 Quick Start

### 1. Install Dependencies

```bash
npm install
```

### 2. Configure Environment Variables

Create a `.env` file:

```bash
VITE_API_URL=http://localhost:8080
```

For production, set this in Vercel:
```
VITE_API_URL=https://your-backend.onrender.com
```

### 3. Run Development Server

```bash
npm run dev
```

Visit [http://localhost:5173](http://localhost:5173)

### 4. Build for Production

```bash
npm run build
```

Output will be in `dist/` directory.

## 📦 Core Features Included

### Authentication
- **AuthContext** for global auth state
- **ProtectedRoute** for guarding authenticated routes
- **Cookie-based authentication** (httpOnly cookies from backend)
- **Auto-redirect** to login on 401/403

### Routing
- **React Router v7** for client-side routing
- **Vercel SPA routing** via `vercel.json` (all routes → index.html)
- **Protected routes** with automatic login redirect

### API Integration
- **Axios client** with interceptors
- **Automatic cookie handling** (`withCredentials: true`)
- **Base URL configuration** via environment variable
- **Error handling** with 401/403 redirect

### UI/UX
- **Tailwind CSS** for styling
- **Headless UI** for accessible components
- **Heroicons** for icons
- **Responsive design** out of the box

### Type Safety
- **TypeScript** throughout
- **Type definitions** for API responses
- **Strict type checking**

### Developer Experience
- **Hot Module Replacement (HMR)** with Vite
- **Fast builds** (Vite uses esbuild)
- **ESLint** for code quality
- **TypeScript checking** before build

## 🔧 Customization

### Add a New Page

**1. Create Page Component:**

```typescript
// src/pages/MyNewPage.tsx
import { Layout } from '../components/Layout';

export function MyNewPage() {
  return (
    <Layout>
      <h1 className="text-2xl font-bold">My New Page</h1>
      <p>Content goes here</p>
    </Layout>
  );
}
```

**2. Add Route in App.tsx:**

```typescript
import { MyNewPage } from './pages/MyNewPage';

// In your Routes:
<Route path="/my-page" element={
  <ProtectedRoute>
    <MyNewPage />
  </ProtectedRoute>
} />
```

### Create an API Service

**1. Define Types:**

```typescript
// src/types/item.ts
export interface Item {
  id: string;
  name: string;
  description: string;
  createdAt: string;
}

export interface CreateItemRequest {
  name: string;
  description: string;
}
```

**2. Create Service:**

```typescript
// src/services/itemService.ts
import { apiClient } from '../utils/api';
import { Item, CreateItemRequest } from '../types/item';

export const itemService = {
  // Get all items
  getAll: async (): Promise<Item[]> => {
    const response = await apiClient.get<Item[]>('/api/items');
    return response.data;
  },

  // Create item
  create: async (data: CreateItemRequest): Promise<Item> => {
    const response = await apiClient.post<Item>('/api/items', data);
    return response.data;
  },

  // Delete item
  delete: async (id: string): Promise<void> => {
    await apiClient.delete(`/api/items/${id}`);
  },
};
```

**3. Use in Component with React Query:**

```typescript
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { itemService } from '../services/itemService';

export function ItemsPage() {
  const queryClient = useQueryClient();

  // Fetch items
  const { data: items, isLoading } = useQuery({
    queryKey: ['items'],
    queryFn: itemService.getAll,
  });

  // Create item mutation
  const createMutation = useMutation({
    mutationFn: itemService.create,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['items'] });
    },
  });

  // Render
  return (
    <Layout>
      {isLoading ? (
        <p>Loading...</p>
      ) : (
        <div>
          {items?.map(item => (
            <div key={item.id}>{item.name}</div>
          ))}
        </div>
      )}
    </Layout>
  );
}
```

### Customize Tailwind Theme

Edit `tailwind.config.js`:

```javascript
export default {
  theme: {
    extend: {
      colors: {
        primary: {
          50: '#f0f9ff',
          500: '#0ea5e9',
          600: '#0284c7',
          // ... more shades
        },
      },
      fontFamily: {
        sans: ['Inter', 'sans-serif'],
      },
    },
  },
};
```

### Add Authentication Refresh

If you need token refresh logic, update `AuthContext.tsx`:

```typescript
// Add token refresh function
const refreshToken = async () => {
  try {
    await apiClient.post('/api/auth/refresh');
    setIsAuthenticated(true);
  } catch (error) {
    setIsAuthenticated(false);
    navigate('/login');
  }
};

// Call on mount and periodically
useEffect(() => {
  refreshToken();
  const interval = setInterval(refreshToken, 15 * 60 * 1000); // Every 15 min
  return () => clearInterval(interval);
}, []);
```

### Add Loading Spinner Component

```typescript
// src/components/Spinner.tsx
export function Spinner() {
  return (
    <div className="flex items-center justify-center">
      <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-500" />
    </div>
  );
}
```

## 🚢 Deploy to Vercel

### Option 1: Vercel Dashboard (Recommended)

**1. Push to GitHub:**
```bash
git add .
git commit -m "Setup frontend"
git push
```

**2. Import in Vercel:**
- Go to [Vercel Dashboard](https://vercel.com/dashboard)
- New Project → Import your repository
- Configure:
  - **Framework Preset:** Vite
  - **Root Directory:** `frontend` (if in subdirectory)
  - **Build Command:** `npm run build` (auto-detected)
  - **Output Directory:** `dist` (auto-detected)

**3. Add Environment Variable:**
- Settings → Environment Variables
- Add `VITE_API_URL` with your Render backend URL
- Apply to: Production, Preview, Development

**4. Deploy:**
- Click "Deploy"
- Vercel will build and deploy your app

### Option 2: Vercel CLI

```bash
npm i -g vercel
vercel login
vercel --prod
```

## 📚 Technology Stack

- **React 19** - UI library
- **TypeScript** - Type safety
- **Vite 7** - Build tool
- **React Router v7** - Client-side routing
- **Tailwind CSS** - Utility-first CSS
- **Headless UI** - Accessible components
- **Heroicons** - Icon library
- **Axios** - HTTP client
- **React Query** - Server state management
- **Vercel** - Hosting platform

## 🔍 Troubleshooting

### Development Server Won't Start

```bash
# Clear node_modules and reinstall
rm -rf node_modules package-lock.json
npm install

# Check Node version (20.x+ required)
node -v

# Try a different port
npm run dev -- --port 3000
```

### API Calls Failing (CORS)

**Check backend CORS configuration:**
```yaml
# backend application.yml
app:
  cors:
    allowed-origins: http://localhost:5173,https://your-app.vercel.app
```

### Login Not Working

**1. Check cookie settings in backend:**
```java
// AuthController.java
ResponseCookie cookie = ResponseCookie.from("auth_token", token)
    .httpOnly(true)
    .secure(true)        // HTTPS only
    .sameSite("None")    // Required for cross-origin
    .path("/")
    .build();
```

**2. Check axios config:**
```typescript
// utils/api.ts
export const apiClient = axios.create({
  baseURL: API_BASE_URL,
  withCredentials: true,  // Must be true for cookies
});
```

### Routing 404 on Vercel

**Ensure `vercel.json` exists in frontend directory:**
```json
{
  "rewrites": [
    { "source": "/(.*)", "destination": "/index.html" }
  ]
}
```

### Environment Variables Not Working

- **Prefix required:** All Vite env vars must start with `VITE_`
- **Restart dev server:** Changes to `.env` require restart
- **Vercel:** Redeploy after adding/changing env vars
- **Check in code:** `console.log(import.meta.env.VITE_API_URL)`

## 📖 Further Reading

- [Vite Documentation](https://vitejs.dev/)
- [React Router Documentation](https://reactrouter.com/)
- [Tailwind CSS Documentation](https://tailwindcss.com/)
- [React Query Documentation](https://tanstack.com/query/latest)
- [Vercel Documentation](https://vercel.com/docs)
- [Deployment Guide](../docs/DEPLOYMENT_PLAN.md)

## 🆘 Support

See `../docs/TROUBLESHOOTING.md` for common issues and solutions.

