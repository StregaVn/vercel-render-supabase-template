# 📘 Template Customization Guide

This guide explains how to customize this template for your specific project.

## 🎯 Overview

This template provides a production-ready foundation. You'll need to:
1. Rename the project
2. Customize the database schema
3. Update authentication settings
4. Configure your deployment

**Time to customize:** ~30 minutes

---

## 📝 Step 1: Project Setup (5 minutes)

### 1.1 Create Your Repository

```bash
# Option 1: Use GitHub template
# Click "Use this template" button on GitHub

# Option 2: Use GitHub CLI
gh repo create my-awesome-app --template vercel-render-supabase-template --public
cd my-awesome-app
```

### 1.2 Update Project Name

**Backend** (`backend-template/pom.xml`):
```xml
<groupId>com.yourcompany</groupId>
<artifactId>your-app-name</artifactId>
<name>Your App Name</name>
```

**Frontend** (`frontend-template/package.json`):
```json
{
  "name": "your-app-name",
  "description": "Your app description"
}
```

**Frontend** (`frontend-template/index.html`):
```html
<title>Your App Name</title>
```

###

 1.3 Update Java Package Name

```bash
# Rename the package from the template default
# backend-template/src/main/java/com/template/app
# to your package name:
# backend-template/src/main/java/com/yourcompany/yourapp
```

---

## 🗄️ Step 2: Database Configuration (10 minutes)

### 2.1 Design Your Schema

Edit `templates/SUPABASE_SETUP_TEMPLATE.sql`:

```sql
-- Change schema name
CREATE SCHEMA IF NOT EXISTS your_app_schema;
SET search_path TO your_app_schema;

-- Add your tables
CREATE TABLE your_table (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### 2.2 Update Application Configuration

**Backend** (`backend-template/src/main/resources/application.yml`):
```yaml
spring:
  datasource:
    url: ${DB_URL:jdbc:postgresql://localhost:5433/your_db?currentSchema=your_app_schema}
  jpa:
    properties:
      hibernate:
        default_schema: your_app_schema
```

### 2.3 Update Docker Compose

`docker-compose.yml`:
```yaml
environment:
  POSTGRES_DB: your_db_name
  POSTGRES_USER: your_db_user
  POSTGRES_PASSWORD: your_db_password
```

---

## 🔐 Step 3: Authentication (5 minutes)

### 3.1 Generate JWT Secret

```bash
openssl rand -base64 32
```

Copy this value for your environment variables.

### 3.2 Create Admin User

Generate a password hash:

```bash
cd backend-template
./mvnw exec:java -Dexec.mainClass="com.template.app.util.PasswordHashGenerator"
```

Update the admin user SQL in `templates/SUPABASE_SETUP_TEMPLATE.sql`:
```sql
INSERT INTO users (email, password_hash, user_type)
VALUES (
    'your-admin@yourcompany.com',
    'YOUR_GENERATED_HASH',
    'ADMIN'
);
```

### 3.3 Update Default Credentials

Update in documentation:
- `README.md`
- `DEPLOYMENT_PLAN.md`

---

## 🎨 Step 4: Frontend Customization (10 minutes)

### 4.1 Update Branding

**Logo and Favicon:**
- Replace `frontend-template/public/vite.svg` with your logo
- Add favicon to `frontend-template/public/`

**Colors** (`frontend-template/tailwind.config.js`):
```javascript
module.exports = {
  theme: {
    extend: {
      colors: {
        primary: '#your-primary-color',
        secondary: '#your-secondary-color',
      }
    }
  }
}
```

### 4.2 Update Login Page

Edit `frontend-template/src/pages/Login.tsx`:
- Change "Sign in to..." text
- Update branding/logo
- Customize styling

### 4.3 Update Main Layout

Edit `frontend-template/src/components/Layout.tsx`:
- Update navigation items
- Change app title
- Customize header/footer

---

## 🚀 Step 5: Deployment Configuration

### 5.1 Update Render Configuration

`render.yaml`:
```yaml
services:
  - type: web
    name: your-app-backend
    env: docker
    dockerfilePath: ./backend-template/Dockerfile
    envVars:
      - key: SPRING_PROFILES_ACTIVE
        value: render
```

### 5.2 Update Environment Variable Templates

**Render** (`templates/RENDER_ENV_VARS_TEMPLATE.txt`):
```bash
# Update schema name in DB_URL
DB_URL=jdbc:postgresql://...?currentSchema=your_app_schema
```

**Vercel** (`templates/VERCEL_ENV_VARS_TEMPLATE.txt`):
```bash
# Update with your Render backend URL
VITE_API_URL=https://your-app-backend.onrender.com
```

### 5.3 Update CORS Origins

`backend-template/src/main/resources/application-render.yml`:
```yaml
cors:
  allowed-origins: https://your-app.vercel.app,https://*.vercel.app
```

---

## 🧪 Step 6: Test Locally

### 6.1 Start Local Environment

```bash
# Terminal 1: Database
docker compose up -d

# Terminal 2: Backend
cd backend-template
./mvnw spring-boot:run

# Terminal 3: Frontend
cd frontend-template
npm install
npm run dev
```

### 6.2 Verify

- [ ] Backend: http://localhost:8080/actuator/health returns 200
- [ ] Frontend: http://localhost:5173 loads
- [ ] Login works with test credentials
- [ ] Database migrations applied

---

## 📚 Step 7: Update Documentation

### 7.1 Update README.md

- [ ] Change project name and description
- [ ] Update technology stack (if modified)
- [ ] Update login credentials
- [ ] Update production URLs (after deployment)

### 7.2 Update DEPLOYMENT_PLAN.md

- [ ] Update project-specific steps
- [ ] Add custom environment variables
- [ ] Document any custom configuration

---

## ✅ Customization Checklist

### Code Changes
- [ ] Updated `pom.xml` (groupId, artifactId, name)
- [ ] Updated `package.json` (name, description)
- [ ] Renamed Java package structure
- [ ] Updated database schema name
- [ ] Created custom tables in SQL template
- [ ] Generated new JWT secret
- [ ] Created admin user with strong password
- [ ] Updated frontend branding (logo, colors, text)
- [ ] Customized login page
- [ ] Updated navigation/layout

### Configuration
- [ ] Updated `docker-compose.yml`
- [ ] Updated `application.yml` (all profiles)
- [ ] Updated `render.yaml`
- [ ] Updated environment variable templates
- [ ] Configured CORS for your domain
- [ ] Updated `vercel.json` (if needed)

### Documentation
- [ ] Updated `README.md`
- [ ] Updated login credentials in all docs
- [ ] Updated `DEPLOYMENT_PLAN.md`
- [ ] Added project-specific notes

### Testing
- [ ] Backend builds successfully
- [ ] Frontend builds successfully
- [ ] Local environment runs
- [ ] Login works
- [ ] Database migrations work

---

## 🎓 Best Practices

### 1. Environment Variables

**Never commit secrets!**
- Use `.env` files locally (in `.gitignore`)
- Use platform environment variables in production
- Store secrets in password manager

### 2. Database Migrations

- Always use Flyway migrations (versioned)
- Test migrations locally first
- Never modify existing migrations (create new ones)

### 3. Security

- Change all default passwords
- Use strong JWT secrets (32+ bytes)
- Enable HTTPS in production
- Review CORS settings

### 4. Git Workflow

- Create feature branches
- Use meaningful commit messages
- Tag releases (v1.0.0, v1.1.0, etc.)

---

## 🆘 Common Issues

### "Package does not exist"
**Cause:** Didn't update Java package imports after renaming  
**Solution:** Find and replace old package name in all files

### "Connection refused" in production
**Cause:** Wrong database URL or credentials  
**Solution:** Verify environment variables in Render

### "CORS error" in browser
**Cause:** Frontend URL not in CORS_ALLOWED_ORIGINS  
**Solution:** Add your Vercel URL to backend CORS config

### "404 on routes" in Vercel
**Cause:** Missing or incorrect vercel.json  
**Solution:** Ensure `vercel.json` is in `frontend/` directory

---

## 📞 Need Help?

- Check [TROUBLESHOOTING.md](./docs/TROUBLESHOOTING.md)
- Review [KNOWLEDGE_BASE.md](./docs/KNOWLEDGE_BASE.md)
- Open a GitHub issue

---

**Next:** Deploy your customized app with [DEPLOYMENT_PLAN.md](./docs/DEPLOYMENT_PLAN.md) →

