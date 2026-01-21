# Local Retail Control Platform - Backend API

Offline-first retail inventory and sales management system backend.

---

## 🚀 Quick Start

```bash
# Install dependencies
npm install

# Setup environment variables
cp .env.example .env
# Edit .env with your Supabase credentials

# Start development server
npm run dev

# Build for production
npm run build

# Start production server
npm start
```

Server runs on: **http://localhost:3000**

---

## 📚 API Documentation

### Swagger UI (Interactive)
Open in browser: **http://localhost:3000/docs**

### Postman Collection
Import `postman_collection.json` into Postman for easy testing.

📖 [Postman Guide](./POSTMAN_GUIDE.md) - Detailed guide on using the Postman collection

### API Summary
📖 [API Summary](./API_SUMMARY.md) - Complete list of all 45+ endpoints

---

## 🏗️ Architecture

### Tech Stack
- **Framework:** Fastify 5.x (TypeScript)
- **Database:** Supabase PostgreSQL
- **Auth:** JWT + Phone OTP
- **Validation:** Zod schemas
- **Documentation:** OpenAPI/Swagger

### Key Features
- ✅ **Event Sourcing** for inventory management
- ✅ **Offline-first sync** (batch operations + delta sync)
- ✅ **Alert system** (low stock, negative inventory)
- ✅ **Role-based access control** (owner, manager, seller)
- ✅ **Rate limiting** (100 req/min)
- ✅ **Security headers** (CORS, Helmet)

---

## 📁 Project Structure

```
backend/
├── src/
│   ├── config/           # Environment & Supabase config
│   ├── plugins/          # Fastify plugins (CORS, JWT, Swagger, etc.)
│   ├── modules/          # Feature modules
│   │   ├── auth/         # Authentication (OTP, JWT)
│   │   ├── store/        # Store management
│   │   ├── user/         # User management
│   │   ├── product/      # Product CRUD
│   │   ├── inventory/    # Inventory events (event sourcing)
│   │   ├── shift/        # Shift management
│   │   ├── sales/        # Sales transactions
│   │   ├── reports/      # Analytics & reports
│   │   ├── alerts/       # Alert system
│   │   └── sync/         # Offline-first sync
│   ├── types/            # TypeScript type definitions
│   ├── utils/            # Utility functions
│   └── server.ts         # Entry point
├── tests/                # Unit & integration tests
├── postman_collection.json    # Postman collection
├── API_SUMMARY.md        # API documentation summary
├── POSTMAN_GUIDE.md      # Postman usage guide
└── package.json
```

---

## 🔐 Authentication

### Phone-based OTP Flow

1. **Request OTP**
   ```bash
   POST /auth/otp/request
   { "phone": "+97699119911" }
   ```

2. **Verify OTP**
   ```bash
   POST /auth/otp/verify
   { "phone": "+97699119911", "otp": "123456" }
   ```
   Returns:
   - `accessToken` (expires in 1 hour)
   - `refreshToken` (expires in 30 days)

3. **Use Access Token**
   ```bash
   Authorization: Bearer <access_token>
   ```

4. **Refresh Token**
   ```bash
   POST /auth/refresh
   { "refreshToken": "<refresh_token>" }
   ```

---

## 📊 Database

### Supabase PostgreSQL

**Schema:** See [database_schema.sql](../database_schema.sql)

**Key Tables:**
- `stores` - Store information
- `users` - Users (owner, manager, seller)
- `products` - Product catalog
- `inventory_events` - Event-sourced inventory changes
- `sales` / `sale_items` - Sales transactions
- `shifts` - Seller work shifts
- `alerts` - System alerts

**Materialized View:**
- `product_stock_levels` - Optimized stock level calculation

### Scripts

```bash
# Generate TypeScript types from Supabase
npm run db:types

# Seed test data
npm run db:seed

# Test connection
npm run db:test
```

---

## 🧪 Testing

```bash
# Run all tests
npm test

# Run unit tests
npm run test:unit

# Run integration tests
npm run test:integration

# Watch mode
npm run test:watch
```

---

## 🛠️ Development

### Available Scripts

| Script | Description |
|--------|-------------|
| `npm run dev` | Start development server (tsx watch) |
| `npm run build` | Build TypeScript → JavaScript |
| `npm start` | Start production server |
| `npm test` | Run all tests |
| `npm run lint` | Run ESLint |
| `npm run format` | Run Prettier |
| `npm run db:types` | Generate Supabase types |
| `npm run db:seed` | Seed database |

### Environment Variables

Required in `.env`:

```bash
# Supabase
SUPABASE_URL=https://xxx.supabase.co
SUPABASE_ANON_KEY=eyJxxx...
SUPABASE_SERVICE_KEY=eyJxxx...

# JWT
JWT_SECRET=your-super-secret-jwt-key

# Server
PORT=3000
HOST=0.0.0.0
NODE_ENV=development

# Optional
RATE_LIMIT_MAX=100
SMS_PROVIDER=mock
SMS_API_KEY=
```

---

## 📦 API Modules

| Module | Endpoints | Description |
|--------|-----------|-------------|
| **Auth** | 5 | Phone OTP authentication |
| **Stores** | 4 | Store management |
| **Users** | 5 | User management (RBAC) |
| **Products** | 6 | Product CRUD + bulk import |
| **Inventory** | 4 | Event-sourced inventory |
| **Shifts** | 5 | Shift management |
| **Sales** | 4 | Sales transactions + void |
| **Reports** | 3 | Analytics & reports |
| **Alerts** | 3 | Alert system |
| **Sync** | 2 | Offline-first sync |

**Total:** 45+ endpoints

---

## 🔒 Security Features

- ✅ JWT authentication (1h access, 30d refresh)
- ✅ Phone-based OTP (Mongolian format)
- ✅ Rate limiting (100 req/min)
- ✅ CORS configuration
- ✅ Helmet security headers
- ✅ Input validation (Zod)
- ✅ Role-based access control

---

## 🚦 Event Sourcing

Inventory үлдэгдлийг event sourcing pattern-аар удирдана:

**Event Types:**
- `INITIAL` - Эхлэх үлдэгдэл
- `SALE` - Борлуулалт (хасах)
- `ADJUST` - Manual засвар
- `RETURN` - Буцаалт (нэмэх)

**Formula:**
```
Current Stock = SUM(qty_change) for product
```

**Benefits:**
- Full audit trail
- Time-travel queries
- Offline conflict resolution

---

## 🔄 Offline-First Sync

### Mobile → Server (Batch Sync)

```bash
POST /sync
{
  "device_id": "mobile-123",
  "operations": [
    {
      "operation_type": "create_sale",
      "client_id": "sale-001",
      "client_timestamp": "2026-01-21T10:00:00Z",
      "data": { ... }
    }
  ]
}
```

**Response:**
```json
{
  "success": true,
  "synced": 5,
  "failed": 0,
  "results": [...]
}
```

### Server → Mobile (Delta Sync)

```bash
GET /stores/:id/changes?since=2026-01-21T00:00:00Z
```

**Returns:**
- Products changes
- Sales changes
- Inventory events
- Shifts
- Alerts

---

## 🚨 Alert System

Автоматаар үүсдэг alerts:

1. **Low Stock Alert**
   - Trigger: `current_stock <= low_stock_threshold`
   - Level: `warning`

2. **Negative Inventory Alert**
   - Trigger: `current_stock < 0`
   - Level: `error`

Triggers автоматаар ажиллана:
- Sales үүсгэх үед
- Inventory event үүсгэх үед

---

## 📈 Performance

- ✅ Database indexes on all foreign keys
- ✅ Composite indexes for common queries
- ✅ Materialized view for stock levels
- ✅ Pagination on all list endpoints
- ✅ Connection pooling (Supabase)

---

## 🐳 Docker (Optional)

```bash
# Start PostgreSQL + Redis
npm run docker:up

# Stop containers
npm run docker:down
```

**Note:** Not required if using Supabase cloud.

---

## 📝 License

MIT

---

## 🤝 Contributing

1. Fork the repository
2. Create feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open Pull Request

---

## 📞 Support

- **Issues:** https://github.com/yourusername/retail-control/issues
- **Documentation:** [API_SUMMARY.md](./API_SUMMARY.md)
- **Postman:** [POSTMAN_GUIDE.md](./POSTMAN_GUIDE.md)

---

*Built with ❤️ for Mongolian small retailers*
