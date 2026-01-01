@echo off
REM Inventory Management System - Setup Script for Windows
REM This script sets up the entire development environment

echo ========================================
echo Setting up Inventory Management System
echo ========================================
echo.

REM Check if Docker is installed
docker --version >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Docker is not installed. Please install Docker Desktop first.
    echo Visit: https://www.docker.com/products/docker-desktop
    pause
    exit /b 1
)

docker-compose --version >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Docker Compose is not installed. Please install Docker Compose first.
    pause
    exit /b 1
)

REM Step 1: Start PostgreSQL with Docker Compose
echo.
echo [Step 1] Starting PostgreSQL with Docker Compose...
docker-compose up -d postgres
if errorlevel 1 (
    echo [ERROR] Failed to start PostgreSQL
    pause
    exit /b 1
)
echo [OK] PostgreSQL started
echo.

REM Wait for PostgreSQL to be ready
echo [INFO] Waiting for PostgreSQL to be ready...
timeout /t 5 /nobreak >nul

:wait_postgres
docker-compose exec -T postgres pg_isready -U postgres >nul 2>&1
if errorlevel 1 (
    echo Waiting for PostgreSQL...
    timeout /t 2 /nobreak >nul
    goto wait_postgres
)
echo [OK] PostgreSQL is ready
echo.

REM Step 2: Setup Backend
echo [Step 2] Setting up Backend (Elixir/Phoenix)...

REM Check if Elixir is installed
elixir --version >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Elixir is not installed. Please install Elixir 1.14+ first.
    echo Visit: https://elixir-lang.org/install.html
    pause
    exit /b 1
)

cd backend

REM Copy .env.example to .env if it doesn't exist
if not exist .env (
    echo Creating .env file...
    copy .env.example .env
    echo [OK] Created .env file
)

REM Install dependencies
echo Installing Elixir dependencies...
call mix local.hex --force
call mix local.rebar --force
call mix deps.get

REM Setup database
echo Setting up database...
call mix ecto.create
call mix ecto.migrate
call mix run priv/repo/seeds.exs

echo [OK] Backend setup complete
echo.

cd ..

REM Step 3: Setup Frontend
echo [Step 3] Setting up Frontend (React/TypeScript)...

REM Check if Node.js is installed
node --version >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Node.js is not installed. Please install Node.js 18+ first.
    echo Visit: https://nodejs.org/
    pause
    exit /b 1
)

cd frontend

REM Copy .env.example to .env if it doesn't exist
if not exist .env (
    echo Creating .env file...
    copy .env.example .env
    echo [OK] Created .env file
)

REM Install dependencies
echo Installing Node.js dependencies...
call npm install

echo [OK] Frontend setup complete
echo.

cd ..

REM Step 4: Run tests
echo [Step 4] Running backend tests...
cd backend
call mix test
echo [OK] All tests passed
echo.

cd ..

REM Final instructions
echo ========================================
echo Setup Complete!
echo ========================================
echo.
echo To start the application:
echo.
echo Terminal 1 - Backend:
echo   cd backend
echo   mix phx.server
echo   -^> http://localhost:4000
echo.
echo Terminal 2 - Frontend:
echo   cd frontend
echo   npm run dev
echo   -^> http://localhost:5173
echo.
echo Optional - Database Management:
echo   docker-compose --profile tools up -d pgadmin
echo   -^> http://localhost:5050 (admin@inventory.local / admin)
echo.
echo To stop PostgreSQL:
echo   docker-compose down
echo.
echo Happy coding!
echo.
pause
