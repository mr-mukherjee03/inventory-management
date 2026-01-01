# Quick Start Guide

## Automated Setup 

### Windows
```bash
setup.bat
```

### Linux/Mac
```bash
chmod +x setup.sh
./setup.sh
```

This will automatically:
1. Start PostgreSQL with Docker
2. Setup backend (dependencies + database)
3. Setup frontend (dependencies)
4. Run tests

## Manual Setup

### 1. Start Database
```bash
docker-compose up -d postgres
```

### 2. Backend
```bash
cd backend
mix deps.get
mix ecto.setup
mix phx.server
```
→ http://localhost:4000

### 3. Frontend 
```bash
cd frontend
npm install
npm run dev
```
→ http://localhost:5173

## Testing

```bash
cd backend
mix test --cover
```

## Stopping

```bash
docker-compose down
```

## Troubleshooting

**Port 5432 already in use:**
- Stop local PostgreSQL: `sudo service postgresql stop` (Linux)
- Or change port in `docker-compose.yml`

**Database connection error:**
- Ensure Docker is running
- Check: `docker-compose ps`
- Restart: `docker-compose restart postgres`

**Frontend can't connect to backend:**
- Ensure backend is running on port 4000
- Check proxy config in `frontend/vite.config.ts`
