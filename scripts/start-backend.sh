#!/bin/bash

# ============================================
# START BACKEND SERVER
# ============================================
# This script starts the Spring Boot backend server
#
# Usage:
#   chmod +x scripts/start-backend.sh
#   ./scripts/start-backend.sh
# ============================================

set -e  # Exit on error

echo "=========================================="
echo "🚀 Starting Backend Server"
echo "=========================================="
echo ""

# Navigate to backend directory
cd "$(dirname "$0")/../backend" || exit 1

# Check if .env exists
if [ ! -f .env ]; then
    echo "⚠️  Warning: .env file not found"
    echo "Creating .env from env.example..."
    if [ -f env.example ]; then
        cp env.example .env
        echo "✓ Created .env - please update with your credentials"
        echo ""
        read -p "Press Enter to continue or Ctrl+C to abort..."
    else
        echo "❌ Error: env.example not found"
        exit 1
    fi
fi

# Load environment variables from .env
echo "📝 Loading environment variables from .env..."
set -a
source .env
set +a
echo "✓ Environment variables loaded"
echo ""

# Check Java version
if command -v java &> /dev/null; then
    JAVA_VERSION=$(java -version 2>&1 | head -n 1 | cut -d'"' -f2 | cut -d'.' -f1)
    echo "☕ Java version: $JAVA_VERSION"
    if [ "$JAVA_VERSION" -lt 21 ]; then
        echo "❌ Error: Java 21+ required, found Java $JAVA_VERSION"
        exit 1
    fi
else
    echo "❌ Error: Java not found"
    exit 1
fi
echo ""

# Display configuration
echo "=========================================="
echo "Configuration"
echo "=========================================="
echo "Database: ${DB_URL:-Not set}"
echo "Port:     ${PORT:-8080}"
echo "Profile:  ${SPRING_PROFILES_ACTIVE:-default}"
echo "=========================================="
echo ""

# Make mvnw executable
chmod +x mvnw 2>/dev/null || true

# Start the server
echo "🚀 Starting Spring Boot..."
echo ""
echo "Access points:"
echo "  API:    http://localhost:8080"
echo "  Health: http://localhost:8080/actuator/health"
echo ""
echo "Press Ctrl+C to stop"
echo ""
echo "=========================================="
echo ""

# Run with Maven wrapper
./mvnw spring-boot:run

# Note: This will run until stopped with Ctrl+C

