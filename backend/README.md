# Inventory Management System - Backend

Production-level Elixir/Phoenix JSON API for inventory management with proper OOP/OOD principles, comprehensive logging, exception handling, and testing.

## 🏗️ Architecture

This backend follows clean architecture principles with clear separation of concerns:

```
lib/
├── inventory/                  # Domain Layer
│   ├── item.ex                # Item schema and validations
│   ├── movement.ex            # Movement schema and validations
│   ├── stock_calculator.ex    # Pure business logic for stock calculations
│   ├── inventory.ex           # Main context (facade pattern)
│   ├── repo.ex                # Data access layer
│   └── application.ex         # OTP application supervisor
│
└── inventory_web/             # Web Layer
    ├── controllers/           # Request handlers
    │   ├── item_controller.ex
    │   ├── movement_controller.ex
    │   ├── fallback_controller.ex
    │   ├── item_json.ex       # JSON serializers
    │   ├── movement_json.ex
    │   └── error_json.ex
    ├── router.ex              # Route definitions
    ├── endpoint.ex            # HTTP endpoint configuration
    └── telemetry.ex           # Monitoring and metrics
```

## 📊 Data Model

### Items Table
```sql
CREATE TABLE items (
  id BIGSERIAL PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  sku VARCHAR(100) NOT NULL UNIQUE,
  unit VARCHAR(20) NOT NULL CHECK (unit IN ('pcs', 'kg', 'litre')),
  inserted_at TIMESTAMP NOT NULL,
  updated_at TIMESTAMP NOT NULL
);
```

### Inventory Movements Table
```sql
CREATE TABLE inventory_movements (
  id BIGSERIAL PRIMARY KEY,
  item_id BIGINT NOT NULL REFERENCES items(id) ON DELETE RESTRICT,
  quantity DECIMAL(10, 2) NOT NULL CHECK (quantity > 0),
  movement_type VARCHAR(20) NOT NULL CHECK (movement_type IN ('IN', 'OUT', 'ADJUSTMENT')),
  created_at TIMESTAMP NOT NULL
);
```

**Key Design Decisions:**
- Stock is **computed**, not stored (as per requirements)
- Database constraints ensure data integrity
- Indexes on foreign keys and frequently queried fields
- ON DELETE RESTRICT prevents orphaned movements

## 🧮 Stock Calculation Logic

Stock is calculated dynamically using the formula:

```
Stock = sum(IN) - sum(OUT) ± ADJUSTMENT
```

Implementation in `StockCalculator` module:
1. Fetch all movements for an item
2. Iterate through movements and apply formula
3. Validate that stock never goes negative
4. Return computed stock value

**Negative Stock Prevention:**
- Before recording any OUT or negative ADJUSTMENT movement
- Calculate current stock from all existing movements
- Validate that new movement won't cause negative stock
- Use database transaction to ensure consistency
- Rollback transaction if validation fails

## 🚀 Setup Instructions

### Prerequisites
- **Docker & Docker Compose** (recommended)
- **OR** Elixir 1.14+ and PostgreSQL 14+ (manual setup)

### Option 1: Using Docker (Recommended)

1. **Start PostgreSQL:**
   ```bash
   # From project root
   docker-compose up -d postgres
   ```

2. **Install dependencies:**
   ```bash
   cd backend
   mix deps.get
   ```

3. **Configure environment (optional):**
   ```bash
   cp .env.example .env
   # Edit .env if needed
   ```

4. **Create and migrate database:**
   ```bash
   mix ecto.setup
   ```
   
   This will:
   - Create the database
   - Run migrations
   - Run seeds (optional sample data)

5. **Start the server:**
   ```bash
   mix phx.server
   ```
   
   Server will start on http://localhost:4000

### Option 2: Manual Setup (Without Docker)

1. **Ensure PostgreSQL is running locally**

2. **Configure database:**
   
   Edit `config/dev.exs` with your PostgreSQL credentials

3. **Install dependencies:**
   ```bash
   cd backend
   mix deps.get
   ```

4. **Create and migrate database:**
   ```bash
   mix ecto.setup
   ```

5. **Start the server:**
   ```bash
   mix phx.server
   ```

### Database Management UI (Optional)

Start pgAdmin with Docker:
```bash
# From project root
docker-compose --profile tools up -d pgadmin
```

Access at http://localhost:5050
- Email: `admin@inventory.local`
- Password: `admin`

### Stopping Services

```bash
# From project root
docker-compose down
```

## 🧪 Running Tests

### Run all tests:
```bash
mix test
```

### Run with coverage:
```bash
mix test --cover
```

### Run specific test file:
```bash
mix test test/inventory/stock_calculator_test.exs
```

### Test Coverage
The test suite includes:
- ✅ Unit tests for `StockCalculator` (stock calculation logic)
- ✅ Unit tests for negative stock rejection
- ✅ Integration tests for `Inventory` context
- ✅ Controller tests for API endpoints
- ✅ Edge cases and error scenarios

## 📡 API Endpoints

### Items

**GET /api/items**
- Returns all items with current stock
- Response: `{"data": [{"id": 1, "name": "...", "current_stock": "100.00", ...}]}`

**GET /api/items/:id**
- Returns single item with stock
- Response: `{"data": {"id": 1, ...}}`

**POST /api/items**
- Creates a new item
- Body: `{"name": "Widget", "sku": "WGT-001", "unit": "pcs"}`
- Response: 201 Created

### Movements

**POST /api/movements**
- Records inventory movement
- Body: `{"item_id": 1, "quantity": 100, "movement_type": "IN"}`
- Returns 422 if would cause negative stock
- Response: 201 Created

**GET /api/movements**
- Returns all movements
- Response: `{"data": [...]}`

**GET /api/items/:item_id/movements**
- Returns movement history for an item
- Response: `{"data": [...]}`

### Error Responses

All errors follow consistent format:
```json
{
  "error": {
    "code": "insufficient_stock",
    "message": "Insufficient stock for this operation...",
    "details": {"field": ["error message"]}
  }
}
```

## 🔍 Logging

The application uses structured logging throughout:

- **Request/Response logging**: All HTTP requests are logged
- **Business logic logging**: Stock calculations and validations
- **Database logging**: Query execution times (dev only)
- **Error logging**: All errors with context

Log levels:
- Development: `:debug`
- Test: `:warning`
- Production: `:info`

## 🏭 Production Considerations

### Environment Variables (Production)
```bash
DATABASE_URL=ecto://user:pass@host/database
SECRET_KEY_BASE=<generate with: mix phx.gen.secret>
PHX_HOST=yourdomain.com
PORT=4000
```

### Running in Production
```bash
MIX_ENV=prod mix compile
MIX_ENV=prod mix ecto.migrate
MIX_ENV=prod mix phx.server
```

## 🎯 Design Principles Applied

1. **Context Pattern**: `Inventory` module serves as the main API boundary
2. **Separation of Concerns**: Clear layers (domain, business logic, web)
3. **Single Responsibility**: Each module has one clear purpose
4. **Dependency Injection**: Repo and modules are easily testable
5. **Error Handling**: Tagged tuples with fallback controller
6. **Validation**: Multi-layer (database, Ecto, business logic)
7. **Logging**: Comprehensive logging for observability
8. **Testing**: High test coverage with unit and integration tests

## 📝 Assumptions

1. SKU must be unique across all items
2. Quantity is always positive (negative adjustments use ADJUSTMENT type)
3. Movements cannot be deleted (audit trail)
4. Items cannot be deleted if they have movements
5. Stock is calculated on-demand (not cached)
6. Timestamps use UTC
7. Decimal precision: 10 digits, 2 decimal places

## 🔧 Troubleshooting

**Database connection error:**
```bash
# Check PostgreSQL is running
# Update credentials in config/dev.exs
mix ecto.reset
```

**Port already in use:**
```bash
# Change port in config/dev.exs
config :inventory, InventoryWeb.Endpoint, http: [port: 4001]
```

## 📚 Further Improvements

For production deployment, consider:
- [ ] Database connection pooling tuning
- [ ] Query result caching (Redis)
- [ ] Rate limiting
- [ ] API authentication/authorization
- [ ] Pagination for large datasets
- [ ] Background jobs for heavy operations
- [ ] Monitoring and alerting (Datadog, New Relic)
- [ ] Load balancing
- [ ] Database read replicas
