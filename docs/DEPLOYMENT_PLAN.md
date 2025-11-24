# 🚀 Complete Deployment Plan

**Estimated Time:** 20-30 minutes  
**Cost:** $0-7/month (free tiers available)

---

## 📊 Deployment Overview

| Phase | Service | Time | Status |
|-------|---------|------|--------|
| Phase 1 | Supabase Database | 5 min | 🔲 |
| Phase 2 | Render Backend | 5 min | 🔲 |
| Phase 3 | Vercel Frontend | 5 min | 🔲 |
| Phase 4 | Configuration | 5 min | 🔲 |
| Phase 5 | Testing | 5 min | 🔲 |

---

## ✅ Prerequisites

- [ ] GitHub account
- [ ] Supabase account (sign up at https://supabase.com)
- [ ] Render account (sign up at https://render.com)
- [ ] Vercel account (sign up at https://vercel.com)
- [ ] Code pushed to GitHub repository

---

## 🗄️ Phase 1: Supabase Database Setup (5 minutes)

### 1.1 Create Supabase Project

1. Go to https://supabase.com/dashboard
2. Click **"New Project"**
3. Fill in details:
   - **Name**: `your-app-name`
   - **Database Password**: Generate a strong password (save it!)
   - **Region**: Choose closest to your users
4. Click **"Create new project"**
5. Wait 2-3 minutes for setup

### 1.2 Get Connection Details

1. Go to **Settings** → **Database**
2. Scroll to **Connection string** section
3. Click **"Connection Pooling"** tab
4. Select **"Transaction"** mode (important!)
5. Copy the connection string (port 6543)

**Format:**
```
postgres://postgres.{ref}:[YOUR-PASSWORD]@{host}:6543/postgres
```

Save these values:
```bash
SUPABASE_HOST=aws-X-us-east-X.pooler.supabase.com
SUPABASE_PROJECT_REF=xxxxxxxxxxxxx
SUPABASE_DB_PASSWORD=your-password
```

### 1.3 Get API Keys

1. Go to **Settings** → **API**
2. Copy these keys:
   - **Project URL**: `https://{ref}.supabase.co`
   - **`anon` `public`** key (Publishable key)
   - **`service_role`** key (Secret key) - **Keep this secret!**

### 1.4 Run Database Setup

1. Go to **SQL Editor**
2. Click **"New query"**
3. Copy contents of `templates/SUPABASE_SETUP_TEMPLATE.sql`
4. Click **"Run"**
5. Verify: You should see "Success" messages

### 1.5 Verify Setup

Run this query to verify admin user:
```sql
SELECT email, user_type, active 
FROM your_schema.users 
WHERE email = 'your-admin@example.com';
```

You should see 1 row returned.

**✅ Phase 1 Complete!**

---

## 🖥️ Phase 2: Render Backend Deployment (5 minutes)

### 2.1 Create Render Account

1. Go to https://dashboard.render.com
2. Sign up / Log in with GitHub

### 2.2 Create Web Service

1. Click **"New +"** → **"Web Service"**
2. Connect your GitHub repository
3. Select your repository
4. Fill in details:
   - **Name**: `your-app-backend`
   - **Region**: Same as Supabase
   - **Branch**: `main`
   - **Root Directory**: `backend-template`
   - **Environment**: `Docker`
   - **Dockerfile Path**: `./backend-template/Dockerfile`
   - **Docker Build Context**: `.` (root)

### 2.3 Set Instance Type

- **Free**: $0/month (sleeps after 15 min inactivity)
- **Starter**: $7/month (always on, 512MB RAM)

Choose based on your needs.

### 2.4 Add Environment Variables

Click **"Add Environment Variable"** for each:

```bash
# Spring Profile
SPRING_PROFILES_ACTIVE=render

# Database (from Phase 1)
DB_URL=jdbc:postgresql://aws-X-us-east-X.pooler.supabase.com:6543/postgres?currentSchema=your_schema
DB_USERNAME=postgres.{YOUR_PROJECT_REF}
DB_PASSWORD={YOUR_SUPABASE_DB_PASSWORD}
DB_POOL_SIZE=10
DB_MIN_IDLE=2

# Supabase API (from Phase 1)
SUPABASE_URL=https://{YOUR_PROJECT_REF}.supabase.co
SUPABASE_ANON_KEY={YOUR_PUBLISHABLE_KEY}
SUPABASE_SERVICE_KEY={YOUR_SECRET_KEY}

# JWT Authentication
JWT_SECRET={GENERATE_NEW: openssl rand -base64 32}
JWT_EXPIRATION_MS=86400000

# CORS - Update after Vercel deployment
CORS_ALLOWED_ORIGINS=http://localhost:*,https://*.vercel.app
```

**Important:** Make sure to replace all `{placeholders}` with actual values!

### 2.5 Deploy

1. Click **"Create Web Service"**
2. Wait for build (3-5 minutes)
3. Watch logs for "Started Application"

### 2.6 Verify Deployment

Once deployed, test the health endpoint:

```bash
curl https://your-app-backend.onrender.com/actuator/health
```

Expected response:
```json
{"status":"UP","groups":["liveness","readiness"]}
```

**Save your backend URL:**
```
RENDER_BACKEND_URL=https://your-app-backend.onrender.com
```

**✅ Phase 2 Complete!**

---

## 🎨 Phase 3: Vercel Frontend Deployment (5 minutes)

### 3.1 Create Vercel Account

1. Go to https://vercel.com
2. Sign up / Log in with GitHub

### 3.2 Import Project

1. Click **"Add New..."** → **"Project"**
2. Import your GitHub repository
3. Vercel will detect Vite automatically

### 3.3 Configure Build Settings

**Framework Preset**: Vite  
**Root Directory**: `frontend-template`  
**Build Command**: `npm run build`  
**Output Directory**: `dist`  
**Install Command**: `npm install`

### 3.4 Add Environment Variables

Click **"Environment Variables"**:

**Key**: `VITE_API_URL`  
**Value**: `{YOUR_RENDER_BACKEND_URL}` (from Phase 2)  
**Environments**: Production, Preview, Development (check all)

Example:
```
VITE_API_URL=https://your-app-backend.onrender.com
```

### 3.5 Deploy

1. Click **"Deploy"**
2. Wait for build (1-2 minutes)
3. You'll get a URL: `https://your-app.vercel.app`

**Save your frontend URL:**
```
VERCEL_FRONTEND_URL=https://your-app.vercel.app
```

**✅ Phase 3 Complete!**

---

## ⚙️ Phase 4: Final Configuration (5 minutes)

### 4.1 Update CORS in Render

1. Go back to Render Dashboard
2. Select your web service
3. Go to **Environment**
4. Find `CORS_ALLOWED_ORIGINS`
5. Update to include your Vercel URL:

```bash
CORS_ALLOWED_ORIGINS=http://localhost:*,https://your-app.vercel.app,https://*.vercel.app
```

6. Click **"Save Changes"**
7. Wait for redeploy (~2 minutes)

### 4.2 Verify Cookie Settings

Ensure your backend has these settings (already in template):

```java
ResponseCookie cookie = ResponseCookie.from(TOKEN_COOKIE_NAME, token)
    .httpOnly(true)
    .secure(true)        // HTTPS only
    .sameSite("None")    // Required for cross-origin
    .path("/")
    .maxAge(Duration.ofHours(24))
    .build();
```

**✅ Phase 4 Complete!**

---

## 🧪 Phase 5: Testing & Verification (5 minutes)

### 5.1 Test Health Endpoints

**Backend:**
```bash
curl https://your-app-backend.onrender.com/actuator/health
# Expected: {"status":"UP"}
```

**Frontend:**
```bash
curl https://your-app.vercel.app
# Expected: HTML response
```

### 5.2 Test Login Flow

1. Open `https://your-app.vercel.app/login`
2. Enter credentials:
   - Email: `your-admin@example.com`
   - Password: `your-password`
3. Click **"Sign in"**
4. You should be redirected to dashboard

### 5.3 Verify Browser Console

Open Developer Tools (F12) → Console:
- ✅ No CORS errors
- ✅ No cookie errors
- ✅ API calls succeed (200 status)

### 5.4 Test API Endpoints

Try accessing a protected endpoint:
```bash
# This should return 401 (expected - not authenticated)
curl https://your-app-backend.onrender.com/api/your-endpoint
```

After login, it should work from the browser.

**✅ Phase 5 Complete!**

---

## 🎉 Deployment Complete!

### Your Live URLs

- **Frontend**: `https://your-app.vercel.app`
- **Backend**: `https://your-app-backend.onrender.com`
- **Database**: Supabase Dashboard

### Next Steps

1. **Update Documentation**
   - Add production URLs to README.md
   - Document any custom configuration

2. **Security**
   - [ ] Change admin password
   - [ ] Review JWT secret
   - [ ] Enable Supabase Row Level Security (optional)
   - [ ] Set up monitoring

3. **Optional Enhancements**
   - [ ] Custom domain (Vercel + Render)
   - [ ] Email notifications (Supabase)
   - [ ] Database backups (Supabase)
   - [ ] Error tracking (Sentry)
   - [ ] Analytics (Vercel Analytics)

---

## 🐛 Troubleshooting

### Backend won't start
- Check Render logs for errors
- Verify all environment variables are set
- Ensure DB_URL uses Transaction mode (port 6543)

### Frontend can't reach backend
- Verify CORS_ALLOWED_ORIGINS includes your Vercel URL
- Check VITE_API_URL is set correctly in Vercel
- Test backend health endpoint directly

### Login fails
- Check backend logs for authentication errors
- Verify admin user exists in database
- Test password hash generation

### Cookies not being set
- Ensure secure=true and sameSite="None" in backend
- Verify both sites use HTTPS
- Check browser console for cookie errors

For more solutions, see [TROUBLESHOOTING.md](./TROUBLESHOOTING.md)

---

## 📊 Deployment Checklist

### Pre-Deployment
- [ ] Code pushed to GitHub
- [ ] All tests passing
- [ ] Environment variables documented
- [ ] Database schema finalized

### Phase 1: Supabase
- [ ] Project created
- [ ] Connection details saved
- [ ] API keys saved
- [ ] Database setup SQL executed
- [ ] Admin user created

### Phase 2: Render
- [ ] Web service created
- [ ] Docker detected
- [ ] All 11 environment variables set
- [ ] Build successful
- [ ] Health endpoint returns 200

### Phase 3: Vercel
- [ ] Project imported
- [ ] Root Directory set to `frontend-template`
- [ ] VITE_API_URL environment variable set
- [ ] Build successful
- [ ] Site accessible

### Phase 4: Configuration
- [ ] CORS updated with Vercel URL
- [ ] Backend redeployed
- [ ] Secure cookies enabled

### Phase 5: Testing
- [ ] Health endpoints work
- [ ] Login successful
- [ ] No CORS errors
- [ ] API calls work
- [ ] Routes work (no 404s)

### Post-Deployment
- [ ] Documentation updated
- [ ] Admin password changed
- [ ] Monitoring set up
- [ ] Team notified

---

**🎊 Congratulations! Your app is live!**

For maintenance and updates, see [KNOWLEDGE_BASE.md](./KNOWLEDGE_BASE.md)

