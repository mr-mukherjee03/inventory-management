# Inventory Management System

A inventory management system built with **Elixir/Phoenix** (backend) and **React/TypeScript** (frontend).

## Project Overview

This system manages inventory items and tracks stock movements with the following key features:

- Create and manage inventory items (name, SKU, unit)
- Record inventory movements (IN, OUT, ADJUSTMENT)
- **Stock calculated dynamically** (not stored)
- **Negative stock prevention** with clear error messages
- Movement history tracking
- RESTful JSON API
- Simple, functional web UI
- Comprehensive test coverage

## Architecture

### Backend (Elixir + Phoenix)
- **Domain Layer**: Item and Movement schemas with validations
- **Business Logic**: StockCalculator for pure stock calculations
- **Context Layer**: Inventory context (facade pattern)
- **Web Layer**: Controllers, JSON views, error handling
- **Database**: PostgreSQL with proper constraints and indexes

### Frontend (React + TypeScript)
- **Components**: ItemList, ItemForm, MovementForm
- **State Management**: React Query for server state
- **API Client**: Axios with error handling
- **Styling**: Clean, responsive CSS

## Data Model

### Entities

**Item**
- `id`: Unique identifier
- `name`: Item name
- `sku`: Stock Keeping Unit (unique)
- `unit`: pcs / kg / litre

**Inventory Movement**
- `id`: Unique identifier
- `item_id`: Reference to item
- `quantity`: Movement quantity (always positive)
- `movement_type`: IN / OUT / ADJUSTMENT
- `created_at`: Timestamp

### Business Rules

1. **Stock Calculation**: `Stock = sum(IN) - sum(OUT) ± ADJUSTMENT`
2. **No Negative Stock**: System prevents movements that would result in negative stock
3. **Stock Not Stored**: Calculated on-demand from movements
4. **Audit Trail**: Movements cannot be deleted

## Quick Start

### Prerequisites
- **Docker & Docker Compose** (recommended)
- **OR** Manual setup: Elixir 1.14+, PostgreSQL 14+, Node.js 18+

### Option 1: Automated Setup (Recommended)

**Windows:**
```bash
setup.bat
```

**Linux/Mac:**
```bash
chmod +x setup.sh
./setup.sh
```

This will:
- Start PostgreSQL with Docker Compose
- Setup backend (install deps, create DB, run migrations)
- Setup frontend (install deps)
- Run tests

### Option 2: Manual Setup

1. **Start PostgreSQL with Docker**
   ```bash
   docker-compose up -d postgres
   ```
   
   PostgreSQL will be available at `localhost:5432`
   - Username: `postgres`
   - Password: `postgres`
   - Database: `inventory_dev`

2. **Backend Setup**
   ```bash
   cd backend
   cp .env.example .env  # Optional: customize settings
   mix deps.get
   mix ecto.setup
   mix phx.server
   ```
   Backend runs on http://localhost:4000

3. **Frontend Setup** (in a new terminal)
   ```bash
   cd frontend
   cp .env.example .env  # Optional: customize settings
   npm install
   npm run dev
   ```
   Frontend runs on http://localhost:5173

4. **Access the application**
   
   Open http://localhost:5173 in your browser

### Optional: Database Management UI

Start pgAdmin for database management:
```bash
docker-compose --profile tools up -d pgadmin
```
Access at http://localhost:5050
- Email: `admin@inventory.local`
- Password: `admin`

### Stopping Services

```bash
docker-compose down
```

## Running Tests

### Backend Tests
```bash
cd backend
mix test                    # Run all tests
mix test --cover           # With coverage report
```

**Test Coverage:**
- Stock calculation with various movement types
- Negative stock rejection (unit and integration)
- Item CRUD operations
- Movement recording with validation
- API endpoint tests
- Error handling

### Frontend
```bash
cd frontend
npm run lint               # ESLint checks
```

## API Documentation

### Items

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/items` | List all items with stock |
| GET | `/api/items/:id` | Get single item |
| POST | `/api/items` | Create new item |

### Movements

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/movements` | Record movement |
| GET | `/api/movements` | List all movements |
| GET | `/api/items/:item_id/movements` | Get item history |

### Example Requests

**Create Item:**
```bash
curl -X POST http://localhost:4000/api/items \
  -H "Content-Type: application/json" \
  -d '{"name": "Widget A", "sku": "WGT-001", "unit": "pcs"}'
```

**Record Movement:**
```bash
curl -X POST http://localhost:4000/api/movements \
  -H "Content-Type: application/json" \
  -d '{"item_id": 1, "quantity": 100, "movement_type": "IN"}'
```

**Test Negative Stock Rejection:**
```bash
# This will return 422 error if stock is insufficient
curl -X POST http://localhost:4000/api/movements \
  -H "Content-Type: application/json" \
  -d '{"item_id": 1, "quantity": 1000, "movement_type": "OUT"}'
```

## Design Decisions

### Backend
1. **Context Pattern**: Clean API boundary with `Inventory` context
2. **Separation of Concerns**: Domain, business logic, and web layers
3. **Transaction Safety**: Database transactions for consistency
4. **Comprehensive Logging**: Structured logging throughout
5. **Error Handling**: Tagged tuples with fallback controller
6. **Validation**: Multi-layer (database, Ecto, business logic)

### Frontend
1. **Type Safety**: Full TypeScript coverage
2. **React Query**: Automatic caching and refetching
3. **Error Boundaries**: Graceful error handling
4. **Responsive Design**: Mobile-friendly layout
5. **No UI Framework**: Clean, simple CSS (as per requirements)

## Stock Calculation Logic

The stock calculation is implemented in `backend/lib/inventory/stock_calculator.ex`:

```elixir
def calculate_stock(movements) do
  Enum.reduce(movements, Decimal.new("0"), fn movement, acc ->
    case movement.movement_type do
      "IN" -> Decimal.add(acc, movement.quantity)
      "OUT" -> Decimal.sub(acc, movement.quantity)
      "ADJUSTMENT" -> Decimal.add(acc, movement.quantity)
    end
  end)
end
```

**Negative Stock Prevention:**
1. Before recording OUT or negative ADJUSTMENT
2. Calculate current stock from all movements
3. Validate new movement won't cause negative stock
4. Use database transaction to ensure consistency
5. Return error if validation fails

## Assumptions

1. **SKU Uniqueness**: Each SKU must be unique across all items
2. **Positive Quantities**: All movement quantities are positive (negatives use ADJUSTMENT type)
3. **Immutable Movements**: Movements cannot be edited or deleted (audit trail)
4. **UTC Timestamps**: All timestamps stored in UTC
5. **Decimal Precision**: 10 digits, 2 decimal places
6. **No Authentication**: Simple demo system (add auth for production)

## Production Deployment

### Backend
```bash
MIX_ENV=prod mix compile
MIX_ENV=prod mix ecto.migrate
MIX_ENV=prod mix phx.server
```

Required environment variables:
- `DATABASE_URL`: PostgreSQL connection string
- `SECRET_KEY_BASE`: Generate with `mix phx.gen.secret`
- `PHX_HOST`: Your domain name

### Frontend
```bash
npm run build
# Serve the dist/ folder with nginx or similar
```

## Project Structure

```
inventory-system/
├── backend/                 # Elixir/Phoenix API
│   ├── lib/
│   │   ├── inventory/      # Domain and business logic
│   │   └── inventory_web/  # Web layer
│   ├── test/               # Test suite
│   ├── config/             # Configuration
│   └── priv/repo/          # Migrations and seeds
│
├── frontend/               # React/TypeScript UI
│   ├── src/
│   │   ├── api/           # API client
│   │   ├── components/    # React components
│   │   └── App.tsx        # Main app
│   └── public/
│
└── README.md              # This file
```

## Learning Resources

- [Phoenix Framework](https://www.phoenixframework.org/)
- [Ecto Documentation](https://hexdocs.pm/ecto/)
- [React Query](https://tanstack.com/query/latest)
- [TypeScript](https://www.typescriptlang.org/)

## License

This project is for educational/assignment purposes.
