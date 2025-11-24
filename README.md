# 🚀 Vercel + Render + Supabase Template

A production-ready full-stack template for deploying modern web applications with **React/Vite**, **Spring Boot**, and **PostgreSQL**.

## 🎯 What's Included

✅ **Frontend Template** - React 19 with TypeScript, Vite 7, Tailwind CSS  
✅ **Backend Template** - Spring Boot 3.2 with Java 21, WebFlux (reactive)  
✅ **Authentication** - JWT with secure HTTP-only cookies, BCrypt password hashing  
✅ **Database** - PostgreSQL with Flyway migrations, Supabase integration  
✅ **Deployment** - Docker for Render, optimized builds for Vercel  
✅ **CI/CD** - GitHub Actions workflow for automated testing and builds  
✅ **Documentation** - Complete guides, architecture docs, troubleshooting  
✅ **Scripts** - Setup and start scripts for local development

## 📊 Tech Stack

| Layer | Technology | Hosting |
|-------|-----------|---------|
| Frontend | React + TypeScript + Vite + Tailwind | **Vercel** |
| Backend | Spring Boot + Java 21 + WebFlux | **Render** (Docker) |
| Database | PostgreSQL 17 | **Supabase** |
| Auth | JWT + BCrypt | - |

## ⚡ Quick Start

### 1. Use This Template

```bash
# Click "Use this template" button on GitHub, or:
gh repo create my-app --template vercel-render-supabase-template
cd my-app
```

### 2. Local Development (5 minutes)

```bash
# Start PostgreSQL
docker compose up -d

# Backend
cd backend-template
./mvnw spring-boot:run

# Frontend (new terminal)
cd frontend-template
npm install && npm run dev
```

**Access:** http://localhost:5173  
**Login:** admin@example.com / ChangeMe123!

### 3. Deploy to Production (15 minutes)

Follow **[docs/DEPLOYMENT_PLAN.md](./docs/DEPLOYMENT_PLAN.md)** for step-by-step deployment.

**Quick deploy:**
1. Create Supabase project → Run `templates/SUPABASE_SETUP_TEMPLATE.sql`
2. Deploy to Render → Use `render.yaml` blueprint
3. Deploy to Vercel → Connect GitHub repo

## 🎓 Learn From Real Experience

This template is built from lessons learned deploying production applications. Key highlights:

### ✅ Battle-Tested Solutions

- **Supabase Connection**: Uses Transaction mode (port 6543) to avoid connection limits
- **Secure Cookies**: Configured for cross-origin HTTPS (Vercel ↔ Render)
- **SPA Routing**: Proper `vercel.json` configuration for React Router
- **CORS Setup**: Pre-configured for frontend-backend communication
- **Docker Deployment**: Optimized multi-stage Docker build

### 📚 Comprehensive Documentation

- **[TEMPLATE_GUIDE.md](./TEMPLATE_GUIDE.md)** - How to customize this template
- **[docs/DEPLOYMENT_PLAN.md](./docs/DEPLOYMENT_PLAN.md)** - Step-by-step deployment with checklists
- **[docs/ARCHITECTURE.md](./docs/ARCHITECTURE.md)** - Architecture patterns and best practices
- **[docs/TROUBLESHOOTING.md](./docs/TROUBLESHOOTING.md)** - Common issues with solutions
- **[docs/KNOWLEDGE_BASE.md](./docs/KNOWLEDGE_BASE.md)** - Lessons learned and tips

## 💰 Cost Breakdown

| Service | Free Tier | Paid Tier | What's Included |
|---------|-----------|-----------|-----------------|
| **Vercel** | $0/month | $20/month | Unlimited deployments, CDN, HTTPS |
| **Render** | $0/month* | $7/month | 750 hrs/month, Docker support |
| **Supabase** | $0/month | $25/month | 500MB DB, 2GB bandwidth, auth |
| **Total** | **$0-7/month** | **$45-52/month** | Full production stack |

*Free tier sleeps after inactivity

## 🔐 Security Features

- ✅ HTTP-only secure cookies
- ✅ JWT authentication
- ✅ BCrypt password hashing
- ✅ CORS protection
- ✅ Environment-based configuration
- ✅ SQL injection prevention (JPA)
- ✅ XSS protection headers

## 📁 Project Structure

```
vercel-render-supabase-template/
├── docs/                          # Complete documentation
├── templates/                     # Configuration templates
├── backend-template/              # Spring Boot backend
│   ├── src/main/java/.../
│   │   ├── config/               # Security, CORS, Supabase
│   │   ├── security/             # JWT, cookies
│   │   └── api/                  # REST controllers
│   ├── Dockerfile                # Production Docker setup
│   └── pom.xml                   # Maven dependencies
├── frontend-template/             # React frontend
│   ├── src/
│   │   ├── components/           # Reusable components
│   │   ├── contexts/             # Auth context
│   │   ├── pages/                # Routes
│   │   └── utils/                # API client
│   └── vercel.json               # Vercel configuration
├── scripts/                       # Utility scripts
├── render.yaml                    # Render deployment
└── docker-compose.yml            # Local PostgreSQL
```

## 🛠️ Customization

### Update Application Name

```bash
# Backend
# Update: pom.xml, application.yml

# Frontend  
# Update: package.json, index.html, vite.config.ts
```

### Configure Authentication

```bash
# Generate JWT secret
openssl rand -base64 32

# Generate password hash
cd backend-template
./mvnw exec:java -Dexec.mainClass="...PasswordHashGenerator"
```

### Update Database Schema

```sql
-- Edit: templates/SUPABASE_SETUP_TEMPLATE.sql
-- Change schema name and tables as needed
```

## 📖 Documentation

| Document | Purpose |
|----------|---------|
| [TEMPLATE_GUIDE.md](./TEMPLATE_GUIDE.md) | How to use and customize this template |
| [DEPLOYMENT_PLAN.md](./docs/DEPLOYMENT_PLAN.md) | Complete deployment checklist |
| [ARCHITECTURE.md](./docs/ARCHITECTURE.md) | Architecture patterns |
| [TROUBLESHOOTING.md](./docs/TROUBLESHOOTING.md) | Common issues & solutions |
| [KNOWLEDGE_BASE.md](./docs/KNOWLEDGE_BASE.md) | Tips and lessons learned |

## 🧪 Testing

```bash
# Backend tests
cd backend-template
./mvnw test

# Frontend tests
cd frontend-template
npm test

# Integration tests
./scripts/test-deployment.sh
```

## 🚀 Deployment

### Prerequisites

- GitHub account
- Supabase account (free)
- Render account (free tier available)
- Vercel account (free tier available)

### Deploy Steps

1. **Database** - Create Supabase project (5 min)
2. **Backend** - Deploy to Render with Docker (5 min)
3. **Frontend** - Deploy to Vercel (5 min)
4. **Configure** - Set environment variables (5 min)

Total time: **~20 minutes**

See [DEPLOYMENT_PLAN.md](./docs/DEPLOYMENT_PLAN.md) for detailed instructions.

## 🆘 Support

- **Issues**: Check [TROUBLESHOOTING.md](./docs/TROUBLESHOOTING.md)
- **Questions**: Open a GitHub issue
- **Discussions**: GitHub Discussions

## 📝 License

MIT License - See [LICENSE](./LICENSE) for details

## 🙏 Credits

Built with experience from real-world production deployments. Special thanks to the Spring Boot, React, and PostgreSQL communities.

---

**Ready to deploy?** Start with [TEMPLATE_GUIDE.md](./TEMPLATE_GUIDE.md) →

