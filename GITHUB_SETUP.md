# GitHub Setup Guide

This guide walks you through pushing your template repository to GitHub.

## ✅ Current Status

- ✅ Git repository initialized
- ✅ All files committed
- ⏳ Ready to push to GitHub

## 🚀 Push to GitHub

### Option 1: Create New Repository via GitHub CLI (Fastest)

If you have GitHub CLI installed:

```bash
# Navigate to template directory
cd /Users/kenso/Desktop/Projects/vercel-render-supabase-template

# Create and push to GitHub (public repository)
gh repo create vercel-render-supabase-template --public --source=. --push

# Or create as private repository
gh repo create vercel-render-supabase-template --private --source=. --push

# Add description and push
gh repo create vercel-render-supabase-template \
  --public \
  --description "Production-ready template for deploying full-stack apps to Vercel, Render, and Supabase" \
  --source=. \
  --push
```

### Option 2: Create New Repository via GitHub Web (Recommended for Template)

**1. Create Repository on GitHub:**

- Go to [https://github.com/new](https://github.com/new)
- Repository name: `vercel-render-supabase-template`
- Description: `Production-ready template for deploying full-stack apps to Vercel, Render, and Supabase`
- Choose: ☑️ Public (for template repository)
- **Do NOT** initialize with README, .gitignore, or license (we already have these)
- Click "Create repository"

**2. Mark as Template Repository:**

- Go to repository Settings
- Under "General" → "Template repository"
- Check ☑️ "Template repository"
- Save

**3. Push Your Code:**

```bash
# Navigate to template directory
cd /Users/kenso/Desktop/Projects/vercel-render-supabase-template

# Add GitHub remote (replace YOUR_USERNAME with your GitHub username)
git remote add origin https://github.com/YOUR_USERNAME/vercel-render-supabase-template.git

# Or use SSH if you have SSH keys set up
git remote add origin git@github.com:YOUR_USERNAME/vercel-render-supabase-template.git

# Push to GitHub
git branch -M main
git push -u origin main
```

### Option 3: Import into Existing Organization

If you want to create this under an organization:

```bash
cd /Users/kenso/Desktop/Projects/vercel-render-supabase-template

# Create repository under organization
gh repo create ORGANIZATION_NAME/vercel-render-supabase-template --public --source=. --push
```

## 📋 After Pushing to GitHub

### 1. Configure Repository Settings

**a) Enable Template:**
- Settings → General
- Check ☑️ "Template repository"

**b) Add Topics:**
- Click "Add topics" (top of repository page)
- Add: `vercel`, `render`, `supabase`, `template`, `react`, `spring-boot`, `typescript`, `java`, `postgresql`, `full-stack`

**c) Update About Section:**
- Click ⚙️ gear icon next to "About"
- Description: `Production-ready template for deploying full-stack apps to Vercel, Render, and Supabase`
- Website: Your deployed demo (optional)
- Topics: Same as above

**d) Add Repository Banner (Optional):**
- Create a banner image (1280x640px)
- Upload in Settings → Options → Social preview

### 2. Enable GitHub Actions

- Go to Actions tab
- Click "I understand my workflows, go ahead and enable them"
- The CI/CD workflow will run automatically on push

### 3. Add Repository Secrets (for CI/CD)

If you want to add deployment secrets:

- Settings → Secrets and variables → Actions
- Add secrets like:
  - `RENDER_API_KEY` (if using Render API for deployments)
  - `VERCEL_TOKEN` (if using Vercel CLI in CI/CD)

### 4. Create Release (Optional)

```bash
# Tag the initial release
git tag -a v1.0.0 -m "Initial release: Complete Vercel + Render + Supabase template"
git push origin v1.0.0

# Or use GitHub CLI
gh release create v1.0.0 --title "v1.0.0 - Initial Release" --notes "Complete template with backend, frontend, docs, and deployment configs"
```

## 📖 Using the Template

### For Yourself

Once pushed to GitHub, you can use the template:

```bash
# Create new project from template
gh repo create my-new-project --template YOUR_USERNAME/vercel-render-supabase-template --public

# Or via GitHub web UI:
# 1. Go to template repository
# 2. Click "Use this template" button
# 3. Create new repository
```

### For Others

Share the repository URL:
```
https://github.com/YOUR_USERNAME/vercel-render-supabase-template
```

Users can click "Use this template" to create their own copy.

## 🎯 Next Steps

### 1. Create Demo Deployment

Deploy a live demo to showcase the template:

**a) Deploy Backend to Render:**
- Follow `docs/DEPLOYMENT_PLAN.md` → Phase 4
- Use URL: `https://template-demo.onrender.com` (or similar)

**b) Deploy Frontend to Vercel:**
- Follow `docs/DEPLOYMENT_PLAN.md` → Phase 5
- Use URL: `https://template-demo.vercel.app` (or similar)

**c) Update README with Demo Links:**
```markdown
## 🌟 Live Demo

- Frontend: https://your-demo.vercel.app
- Backend API: https://your-demo.onrender.com
- Login: demo@example.com / demo123
```

### 2. Add Badges to README

```markdown
[![CI/CD](https://github.com/YOUR_USERNAME/vercel-render-supabase-template/actions/workflows/ci.yml/badge.svg)](https://github.com/YOUR_USERNAME/vercel-render-supabase-template/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Deploy to Vercel](https://vercel.com/button)](https://vercel.com/new/clone?repository-url=https://github.com/YOUR_USERNAME/vercel-render-supabase-template)
```

### 3. Add Contributing Guidelines

Create `CONTRIBUTING.md`:
```markdown
# Contributing to Vercel + Render + Supabase Template

## How to Contribute
1. Fork the repository
2. Create a feature branch: `git checkout -b feature/amazing-feature`
3. Commit your changes: `git commit -m 'Add amazing feature'`
4. Push to the branch: `git push origin feature/amazing-feature`
5. Open a Pull Request

## Development Setup
See `TEMPLATE_GUIDE.md` for setup instructions.

## Code Style
- Backend: Follow Java conventions, use Lombok and MapStruct
- Frontend: Follow React + TypeScript best practices, use ESLint
```

### 4. Add License

Create `LICENSE` file (MIT License example):
```
MIT License

Copyright (c) 2025 [Your Name]

Permission is hereby granted, free of charge, to any person obtaining a copy...
```

## 🔒 Security

### Repository Security Settings

- Settings → Security
- Enable:
  - ☑️ Dependency graph
  - ☑️ Dependabot alerts
  - ☑️ Dependabot security updates
  - ☑️ Secret scanning
  - ☑️ Code scanning (GitHub Advanced Security)

### Add SECURITY.md

Create a security policy:
```markdown
# Security Policy

## Reporting a Vulnerability

If you discover a security vulnerability, please email [your-email@example.com] instead of using the issue tracker.
```

## 📊 Analytics (Optional)

Track template usage:

- Enable "Traffic" in repository Insights
- Monitor:
  - Clones
  - Unique visitors
  - Popular content
  - Referrers

## 🎉 Promotion

Share your template:

- Tweet about it with #vercel #render #supabase hashtags
- Post on Reddit (r/webdev, r/reactjs, r/java)
- Share on Dev.to, Hashnode, Medium
- Add to awesome lists (awesome-react, awesome-spring-boot)
- Submit to template directories (Vercel templates, etc.)

## ✅ Verification Checklist

Before sharing publicly:

- [ ] README.md is complete and clear
- [ ] TEMPLATE_GUIDE.md has step-by-step instructions
- [ ] All documentation is up to date
- [ ] Example code works without modification
- [ ] CI/CD workflow runs successfully
- [ ] Repository is marked as "Template"
- [ ] Topics and description are added
- [ ] License is added
- [ ] Security policy is configured
- [ ] Demo deployment is live (optional)
- [ ] Badges are added to README (optional)

## 🚀 You're Done!

Your template repository is now ready to share with the world!

Repository URL: `https://github.com/YOUR_USERNAME/vercel-render-supabase-template`

Users can click "Use this template" to create their own projects.

