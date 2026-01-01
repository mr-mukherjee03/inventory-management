#!/bin/bash

# Inventory Management System - Setup Script
# This script sets up the entire development environment

set -e  # Exit on error

echo "🚀 Setting up Inventory Management System..."
echo ""

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo -e "${YELLOW}⚠️  Docker is not installed. Please install Docker first.${NC}"
    exit 1
fi

if ! command -v docker-compose &> /dev/null; then
    echo -e "${YELLOW}⚠️  Docker Compose is not installed. Please install Docker Compose first.${NC}"
    exit 1
fi

# Step 1: Start PostgreSQL with Docker Compose
echo -e "${BLUE}📦 Step 1: Starting PostgreSQL with Docker Compose...${NC}"
docker-compose up -d postgres
echo -e "${GREEN}✅ PostgreSQL started${NC}"
echo ""

# Wait for PostgreSQL to be ready
echo -e "${BLUE}⏳ Waiting for PostgreSQL to be ready...${NC}"
sleep 5

# Check if PostgreSQL is healthy
until docker-compose exec -T postgres pg_isready -U postgres > /dev/null 2>&1; do
    echo "Waiting for PostgreSQL..."
    sleep 2
done
echo -e "${GREEN}✅ PostgreSQL is ready${NC}"
echo ""

# Step 2: Setup Backend
echo -e "${BLUE}🔧 Step 2: Setting up Backend (Elixir/Phoenix)...${NC}"

# Check if Elixir is installed
if ! command -v elixir &> /dev/null; then
    echo -e "${YELLOW}⚠️  Elixir is not installed. Please install Elixir 1.14+ first.${NC}"
    echo "Visit: https://elixir-lang.org/install.html"
    exit 1
fi

cd backend

# Copy .env.example to .env if it doesn't exist
if [ ! -f .env ]; then
    echo "Creating .env file..."
    cp .env.example .env
    echo -e "${GREEN}✅ Created .env file${NC}"
fi

# Install dependencies
echo "Installing Elixir dependencies..."
mix local.hex --force
mix local.rebar --force
mix deps.get

# Setup database
echo "Setting up database..."
mix ecto.create
mix ecto.migrate
mix ecto.seed

echo -e "${GREEN}✅ Backend setup complete${NC}"
echo ""

cd ..

# Step 3: Setup Frontend
echo -e "${BLUE}🎨 Step 3: Setting up Frontend (React/TypeScript)...${NC}"

# Check if Node.js is installed
if ! command -v node &> /dev/null; then
    echo -e "${YELLOW}⚠️  Node.js is not installed. Please install Node.js 18+ first.${NC}"
    echo "Visit: https://nodejs.org/"
    exit 1
fi

cd frontend

# Copy .env.example to .env if it doesn't exist
if [ ! -f .env ]; then
    echo "Creating .env file..."
    cp .env.example .env
    echo -e "${GREEN}✅ Created .env file${NC}"
fi

# Install dependencies
echo "Installing Node.js dependencies..."
npm install

echo -e "${GREEN}✅ Frontend setup complete${NC}"
echo ""

cd ..

# Step 4: Run tests
echo -e "${BLUE}🧪 Step 4: Running backend tests...${NC}"
cd backend
mix test
echo -e "${GREEN}✅ All tests passed${NC}"
echo ""

cd ..

# Final instructions
echo -e "${GREEN}════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}✅ Setup Complete!${NC}"
echo -e "${GREEN}════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "${BLUE}To start the application:${NC}"
echo ""
echo -e "${YELLOW}Terminal 1 - Backend:${NC}"
echo "  cd backend"
echo "  mix phx.server"
echo "  → http://localhost:4000"
echo ""
echo -e "${YELLOW}Terminal 2 - Frontend:${NC}"
echo "  cd frontend"
echo "  npm run dev"
echo "  → http://localhost:5173"
echo ""
echo -e "${BLUE}Optional - Database Management:${NC}"
echo "  docker-compose --profile tools up -d pgadmin"
echo "  → http://localhost:5050 (admin@inventory.local / admin)"
echo ""
echo -e "${BLUE}To stop PostgreSQL:${NC}"
echo "  docker-compose down"
echo ""
echo -e "${GREEN}Happy coding! 🚀${NC}"
