# 🔧 Troubleshooting Guide

Quick reference for common issues and their solutions.

---

## 🚨 Deployment Issues

### Backend Won't Start on Render

**Symptoms:**
- Build succeeds but service crashes
- Logs show "Application failed to start"

**Common Causes & Solutions:**

#### 1. Database Connection Failed
```
Caused by: org.postgresql.util.PSQLException: Connection refused
```

**Check:**
- [ ] DB_URL is correct (use Transaction mode port 6543)
- [ ] DB_USERNAME format: `postgres.{PROJECT_REF}`
- [ ] DB_PASSWORD is correct
- [ ] Supabase project is active

**Fix:**
```bash
# Correct format:
DB_URL=jdbc:postgresql://aws-X-us-east-X.pooler.supabase.com:6543/postgres?currentSchema=your_schema
DB_USERNAME=postgres.pzuxndjjwyeowcanuayr
```

#### 2. Missing Environment Variables
```
Could not resolve placeholder 'JWT_SECRET' in value "${JWT_SECRET}"
```

**Fix:** Verify all 11 environment variables are set in Render:
- SPRING_PROFILES_ACTIVE
- DB_URL
- DB_USERNAME
- DB_PASSWORD
- DB_POOL_SIZE
- DB_MIN_IDLE
- SUPABASE_URL
- SUPABASE_ANON_KEY
- SUPABASE_SERVICE_KEY
- JWT_SECRET
- JWT_EXPIRATION_MS
- CORS_ALLOWED_ORIGINS

#### 3. Docker Build Fails
```
Error: failed to solve: failed to compute cache key
```

**Fix:**
- Verify Dockerfile exists in `backend-template/`
- Check Dockerfile path in Render settings
- Ensure Docker Build Context is set to `.` (root)

---

### Frontend Won't Deploy on Vercel

**Symptoms:**
- Build fails
- "Failed to load config from vite.config.ts"

**Solutions:**

#### 1. Root Directory Not Set
**Fix:**
- Go to Project Settings → General
- Set **Root Directory** to `frontend-template`
- Redeploy

#### 2. Build Command Fails
```
Error: Cannot find module 'vite'
```

**Fix:**
- Verify `package.json` exists
- Check **Install Command**: `npm install`
- Check **Build Command**: `npm run build`

#### 3. Environment Variable Missing
**Fix:**
- Go to Project Settings → Environment Variables
- Add `VITE_API_URL` with your Render backend URL
- Redeploy

---

## 🔐 Authentication Issues

### Login Returns 401

**Symptoms:**
- Login form submits
- Returns "Invalid email or password"
- Backend logs show "User not found" or "Invalid password"

**Solutions:**

#### 1. User Doesn't Exist
```sql
-- Verify user exists
SELECT email, user_type, active 
FROM your_schema.users 
WHERE email = 'your-email@example.com';
```

**Fix:** Run the admin user SQL script in Supabase

#### 2. Password Hash Mismatch
**Fix:** Generate new hash using your application:
```bash
cd backend-template
./mvnw exec:java -Dexec.mainClass="com.template.app.util.PasswordHashGenerator"
```

Update in database:
```sql
UPDATE your_schema.users 
SET password_hash = 'NEW_HASH_HERE'
WHERE email = 'your-email@example.com';
```

---

### Login Success but Not Authenticated

**Symptoms:**
- Login returns 200 with `{success: true}`
- User redirects but immediately back to login
- Browser doesn't store cookie

**Cause:** Cookie security settings

**Fix:** Verify in `AuthController.java`:
```java
ResponseCookie cookie = ResponseCookie.from(TOKEN_COOKIE_NAME, token)
    .httpOnly(true)
    .secure(true)        // Must be true for HTTPS
    .sameSite("None")    // Must be "None" for cross-origin
    .path("/")
    .maxAge(Duration.ofHours(24))
    .build();
```

If changed, rebuild and redeploy backend.

---

### Cookies Not Being Sent

**Symptoms:**
- Login works
- Refresh page → logged out
- Network tab shows cookie not sent with requests

**Fix:** Verify frontend API client:
```typescript
// utils/api.ts
export const apiClient = axios.create({
  baseURL: API_BASE_URL,
  withCredentials: true,  // MUST BE TRUE
  headers: {
    'Content-Type': 'application/json',
  },
});
```

---

## 🌐 CORS Issues

### "Blocked by CORS policy"

**Symptoms:**
```
Access to fetch at 'https://backend.onrender.com/api/...' 
from origin 'https://frontend.vercel.app' 
has been blocked by CORS policy
```

**Solutions:**

#### 1. Frontend URL Not in CORS_ALLOWED_ORIGINS
**Fix:**
1. Go to Render Dashboard → Your Service → Environment
2. Update `CORS_ALLOWED_ORIGINS`:
```bash
CORS_ALLOWED_ORIGINS=http://localhost:*,https://your-app.vercel.app,https://*.vercel.app
```
3. Save and wait for redeploy

#### 2. CORS Not Allowing Credentials
**Fix:** Verify backend CORS config:
```java
configuration.setAllowCredentials(true);  // Must be true
```

#### 3. Preflight Request Failing
**Check:** Backend logs for OPTIONS requests

**Fix:** Ensure OPTIONS is allowed:
```java
configuration.setAllowedMethods(
    Arrays.asList("GET", "POST", "PUT", "DELETE", "OPTIONS")
);
```

---

## 🗄️ Database Issues

### "MaxClientsInSessionMode"

```
FATAL: MaxClientsInSessionMode: max clients reached
```

**Cause:** Using Session mode (port 5432) which has strict limits

**Fix:** Switch to Transaction mode (port 6543):
1. Update `DB_URL` in Render:
```bash
# Change from:
DB_URL=jdbc:postgresql://host:5432/postgres?...

# To:
DB_URL=jdbc:postgresql://host:6543/postgres?...
```
2. Save and redeploy

---

### "Connection timed out"

**Symptoms:**
- Requests hang for 30+ seconds
- Eventually timeout

**Solutions:**

#### 1. Wrong Database Host
**Fix:** Get correct host from Supabase:
1. Settings → Database → Connection Pooling
2. Copy Transaction mode connection string
3. Extract host (e.g., `aws-1-us-east-2.pooler.supabase.com`)

#### 2. Pool Size Too Large
**Fix:** Reduce pool size:
```bash
DB_POOL_SIZE=5
DB_MIN_IDLE=1
```

#### 3. Network Issue
**Check:** Test connection directly:
```bash
psql "postgresql://postgres.ref:password@host:6543/postgres"
```

---

### "Schema does not exist"

```
PSQLException: ERROR: schema "your_schema" does not exist
```

**Fix:**
1. Verify schema name in SQL:
```sql
-- Supabase SQL Editor
\dn

-- Should list your schema
```

2. Create if missing:
```sql
CREATE SCHEMA IF NOT EXISTS your_schema;
```

3. Update `DB_URL`:
```bash
DB_URL=jdbc:postgresql://...?currentSchema=your_schema
```

---

## 🎨 Frontend Issues

### 404 on Routes (e.g., /login)

**Symptoms:**
- Direct navigation to `/login` shows 404
- Clicking links works
- Refresh breaks routes

**Fix:** Add `vercel.json` to `frontend-template/` directory:
```json
{
  "rewrites": [
    {
      "source": "/(.*)",
      "destination": "/index.html"
    }
  ]
}
```

Commit and push to trigger redeployment.

---

### API Calls Return 404

**Symptoms:**
```
GET http://localhost:8080/api/... 404 (Not Found)
```

**Solutions:**

#### 1. Wrong API URL
**Check** `frontend-template/src/config.ts`:
```typescript
export const API_BASE_URL = import.meta.env.VITE_API_URL || 'http://localhost:8080';
```

**Verify** `VITE_API_URL` in Vercel environment variables

#### 2. Endpoint Doesn't Exist
**Check:** Backend controller mapping:
```java
@RestController
@RequestMapping("/api/your-resource")  // Must match frontend call
public class YourController {
    @GetMapping  // Creates GET /api/your-resource
    public List<YourEntity> list() { ... }
}
```

---

### Styles Not Loading

**Symptoms:**
- Page loads but has no styling
- Console shows 404 for CSS files

**Solutions:**

#### 1. Build Output Directory Wrong
**Fix:** Verify in Vercel:
- **Output Directory**: `dist` (not `build`)

#### 2. Base URL Issue
**Check** `vite.config.ts`:
```typescript
export default defineConfig({
  base: '/',  // Should be '/' for root deployment
})
```

---

## 🔄 Deployment Not Triggering

### Git Push Doesn't Deploy

**Vercel:**
1. Check git author:
```bash
git config user.name
git config user.email
```

2. Manual trigger:
- Vercel Dashboard → Deployments → Redeploy

**Render:**
- Should auto-deploy on every push to `main`
- Manual trigger: Dashboard → Manual Deploy

---

## 🐌 Performance Issues

### Render Service Slow to Start

**Symptoms:**
- First request takes 30+ seconds
- Subsequent requests fast

**Cause:** Free tier sleeps after inactivity

**Solutions:**
1. **Upgrade to paid tier** ($7/month - always on)
2. **Keep-alive service:**
```bash
# Use cron-job.org or similar
curl https://your-backend.onrender.com/actuator/health
# Run every 14 minutes
```

---

### Database Queries Slow

**Check:**
1. **Missing indexes:**
```sql
-- Check query performance
EXPLAIN ANALYZE SELECT * FROM your_table WHERE column = 'value';

-- Add index if needed
CREATE INDEX idx_column ON your_table(column);
```

2. **N+1 query problem:**
```java
// Use JOIN FETCH
@Query("SELECT e FROM Entity e LEFT JOIN FETCH e.related")
List<Entity> findAllWithRelated();
```

---

## 📱 Browser-Specific Issues

### Works in Chrome, Fails in Safari

**Likely:** Cookie settings

**Fix:**
- Ensure `sameSite="None"` (capital N)
- Ensure `secure=true`
- Test in private/incognito mode

---

### Cookies Blocked by Browser

**Check:** Browser dev tools → Application → Cookies

**Common Issues:**
- Third-party cookies disabled
- Browser extensions blocking
- Incorrect domain/path

**Fix:**
- Verify cookie attributes match requirements
- Test in incognito mode
- Check browser console for warnings

---

## 🆘 Still Stuck?

### Debugging Steps

1. **Check Logs:**
   - Render: Dashboard → Logs (Live tail)
   - Vercel: Dashboard → Deployments → Click deployment → View Function Logs
   - Browser: F12 → Console, Network, Application tabs

2. **Test Endpoints Directly:**
```bash
# Backend health
curl https://your-backend.onrender.com/actuator/health

# Frontend
curl https://your-app.vercel.app

# Test login
curl -X POST https://your-backend.onrender.com/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"password"}'
```

3. **Verify Environment:**
   - Render: Environment tab
   - Vercel: Settings → Environment Variables

4. **Check Database:**
```sql
-- Connect to Supabase SQL Editor
SELECT * FROM your_schema.users LIMIT 5;
```

### Get Help

1. Check [KNOWLEDGE_BASE.md](./KNOWLEDGE_BASE.md) for similar issues
2. Search GitHub issues
3. Open a new issue with:
   - Error message
   - Relevant logs
   - Steps to reproduce
   - Environment (Render/Vercel/Supabase versions)

---

**Most issues are configuration-related. Double-check environment variables first!**

