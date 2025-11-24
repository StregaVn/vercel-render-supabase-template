#!/bin/bash

# ============================================
# LOCAL DEVELOPMENT SETUP SCRIPT
# ============================================
# This script sets up your local development environment
# Run this once after cloning the repository
#
# Usage:
#   chmod +x scripts/setup-local-dev.sh
#   ./scripts/setup-local-dev.sh
# ============================================

set -e  # Exit on error

echo "=========================================="
echo "🚀 Setting Up Local Development Environment"
echo "=========================================="
echo ""

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# ============================================
# Check Prerequisites
# ============================================
echo "📋 Checking prerequisites..."
echo ""

# Check Java
if command -v java &> /dev/null; then
    JAVA_VERSION=$(java -version 2>&1 | head -n 1 | cut -d'"' -f2 | cut -d'.' -f1)
    if [ "$JAVA_VERSION" -ge 21 ]; then
        echo -e "${GREEN}✓${NC} Java $JAVA_VERSION detected"
    else
        echo -e "${RED}✗${NC} Java 21+ required, found Java $JAVA_VERSION"
        exit 1
    fi
else
    echo -e "${RED}✗${NC} Java not found. Please install Java 21+"
    exit 1
fi

# Check Node.js
if command -v node &> /dev/null; then
    NODE_VERSION=$(node -v | cut -d'v' -f2 | cut -d'.' -f1)
    if [ "$NODE_VERSION" -ge 20 ]; then
        echo -e "${GREEN}✓${NC} Node.js $(node -v) detected"
    else
        echo -e "${YELLOW}⚠${NC} Node.js 20+ recommended, found $(node -v)"
    fi
else
    echo -e "${RED}✗${NC} Node.js not found. Please install Node.js 20+"
    exit 1
fi

# Check Docker
if command -v docker &> /dev/null; then
    echo -e "${GREEN}✓${NC} Docker $(docker -v | cut -d' ' -f3 | tr -d ',') detected"
else
    echo -e "${YELLOW}⚠${NC} Docker not found. Docker is optional for local PostgreSQL."
fi

echo ""

# ============================================
# Backend Setup
# ============================================
echo "=========================================="
echo "🔧 Setting Up Backend"
echo "=========================================="
echo ""

cd backend

# Create .env from example if it doesn't exist
if [ ! -f .env ]; then
    if [ -f env.example ]; then
        echo "📝 Creating backend/.env from env.example..."
        cp env.example .env
        echo -e "${GREEN}✓${NC} Created backend/.env"
        echo -e "${YELLOW}⚠${NC} Please update backend/.env with your actual credentials"
    else
        echo -e "${YELLOW}⚠${NC} env.example not found, skipping .env creation"
    fi
else
    echo -e "${GREEN}✓${NC} backend/.env already exists"
fi

# Make mvnw executable
if [ -f mvnw ]; then
    chmod +x mvnw
    echo -e "${GREEN}✓${NC} Made mvnw executable"
fi

# Optional: Download dependencies (commented out by default to save time)
# echo "📦 Downloading Maven dependencies..."
# ./mvnw dependency:go-offline

cd ..
echo ""

# ============================================
# Frontend Setup
# ============================================
echo "=========================================="
echo "🎨 Setting Up Frontend"
echo "=========================================="
echo ""

cd frontend

# Create .env from example if it doesn't exist
if [ ! -f .env ]; then
    echo "📝 Creating frontend/.env..."
    echo "VITE_API_URL=http://localhost:8080" > .env
    echo -e "${GREEN}✓${NC} Created frontend/.env"
else
    echo -e "${GREEN}✓${NC} frontend/.env already exists"
fi

# Install npm dependencies
if [ -d node_modules ]; then
    echo -e "${GREEN}✓${NC} node_modules already exists"
    read -p "Reinstall dependencies? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "📦 Reinstalling npm dependencies..."
        rm -rf node_modules package-lock.json
        npm install
    fi
else
    echo "📦 Installing npm dependencies..."
    npm install
    echo -e "${GREEN}✓${NC} npm dependencies installed"
fi

cd ..
echo ""

# ============================================
# Docker Setup (Optional)
# ============================================
if command -v docker &> /dev/null; then
    echo "=========================================="
    echo "🐳 Docker Setup"
    echo "=========================================="
    echo ""
    
    if [ -f docker-compose.yml ]; then
        read -p "Start local PostgreSQL with Docker? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            echo "🐳 Starting PostgreSQL container..."
            docker-compose up -d
            echo ""
            echo -e "${GREEN}✓${NC} PostgreSQL running on localhost:5433"
            echo ""
            echo "Connection details:"
            echo "  Host: localhost"
            echo "  Port: 5433"
            echo "  Database: Check docker-compose.yml"
            echo "  Username: Check docker-compose.yml"
            echo "  Password: Check docker-compose.yml"
        fi
    fi
fi

echo ""

# ============================================
# Summary
# ============================================
echo "=========================================="
echo "✨ Setup Complete!"
echo "=========================================="
echo ""
echo "Next steps:"
echo ""
echo "1. Update configuration:"
echo "   - backend/.env (database, JWT secret, Supabase credentials)"
echo "   - docker-compose.yml (if using local PostgreSQL)"
echo ""
echo "2. Start development servers:"
echo "   ./scripts/start-backend.sh   # Terminal 1"
echo "   ./scripts/start-frontend.sh  # Terminal 2"
echo ""
echo "3. Access the application:"
echo "   Frontend: http://localhost:5173"
echo "   Backend:  http://localhost:8080"
echo "   Health:   http://localhost:8080/actuator/health"
echo ""
echo "4. Database (if using Docker):"
echo "   Start: docker-compose up -d"
echo "   Stop:  docker-compose down"
echo "   Logs:  docker-compose logs -f postgres"
echo ""
echo "📚 For more information, see:"
echo "   - README.md"
echo "   - docs/DEPLOYMENT_PLAN.md"
echo "   - docs/TROUBLESHOOTING.md"
echo ""
echo "Happy coding! 🚀"
echo ""

