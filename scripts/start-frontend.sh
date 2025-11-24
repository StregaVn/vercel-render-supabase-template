#!/bin/bash

# ============================================
# START FRONTEND SERVER
# ============================================
# This script starts the Vite development server
#
# Usage:
#   chmod +x scripts/start-frontend.sh
#   ./scripts/start-frontend.sh
# ============================================

set -e  # Exit on error

echo "=========================================="
echo "🎨 Starting Frontend Server"
echo "=========================================="
echo ""

# Navigate to frontend directory
cd "$(dirname "$0")/../frontend" || exit 1

# Check if .env exists
if [ ! -f .env ]; then
    echo "⚠️  Warning: .env file not found"
    echo "Creating .env with default configuration..."
    echo "VITE_API_URL=http://localhost:8080" > .env
    echo "✓ Created .env"
    echo ""
fi

# Load environment variables from .env
echo "📝 Loading environment variables from .env..."
set -a
source .env 2>/dev/null || true
set +a
echo "✓ Environment variables loaded"
echo ""

# Check Node version
if command -v node &> /dev/null; then
    NODE_VERSION=$(node -v | cut -d'v' -f2 | cut -d'.' -f1)
    echo "📦 Node version: $(node -v)"
    echo "📦 npm version: $(npm -v)"
    if [ "$NODE_VERSION" -lt 20 ]; then
        echo "⚠️  Warning: Node.js 20+ recommended, found $(node -v)"
    fi
else
    echo "❌ Error: Node.js not found"
    exit 1
fi
echo ""

# Check if node_modules exists
if [ ! -d node_modules ]; then
    echo "📦 node_modules not found, installing dependencies..."
    npm install
    echo ""
fi

# Display configuration
echo "=========================================="
echo "Configuration"
echo "=========================================="
echo "API URL: ${VITE_API_URL:-http://localhost:8080}"
echo "=========================================="
echo ""

# Start the development server
echo "🚀 Starting Vite dev server..."
echo ""
echo "Access points:"
echo "  App:  http://localhost:5173"
echo ""
echo "Features:"
echo "  ⚡ Hot Module Replacement (HMR)"
echo "  🔄 Auto-reload on file changes"
echo "  🐛 Source maps for debugging"
echo ""
echo "Press Ctrl+C to stop"
echo ""
echo "=========================================="
echo ""

# Run npm dev
npm run dev

# Note: This will run until stopped with Ctrl+C

