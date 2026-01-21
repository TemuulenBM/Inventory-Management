# API Summary - Local Retail Control Platform

**Base URL:** `http://localhost:3000` (development)
**API Documentation:** http://localhost:3000/docs (Swagger UI)

---

## Authentication

All endpoints (except `/health` and `/auth/*`) require JWT Bearer token:

```
Authorization: Bearer <access_token>
```

---

## Endpoints Overview

### Health Check
- `GET /health` - Server health check

### Auth Module (5 endpoints)
- `POST /auth/otp/request` - OTP илгээх
- `POST /auth/otp/verify` - OTP баталгаажуулах + JWT tokens авах
- `POST /auth/refresh` - Access token шинэчлэх
- `POST /auth/logout` - Гарах
- `GET /auth/me` - Current user мэдээлэл

### Store Module (4 endpoints)
- `POST /stores` - Store үүсгэх
- `GET /stores/:id` - Store мэдээлэл
- `PUT /stores/:id` - Store засах (owner only)
- `GET /stores/:id/stats` - Store статистик (owner, manager)

### User Module (5 endpoints)
- `GET /stores/:storeId/users` - Store-ийн хэрэглэгчид (owner, manager)
- `POST /stores/:storeId/users` - Seller/Manager нэмэх (owner only)
- `PUT /stores/:storeId/users/:userId` - User засах (owner, manager)
- `DELETE /stores/:storeId/users/:userId` - User устгах (owner only)
- `PUT /stores/:storeId/users/:userId/role` - Role солих (owner only)

### Product Module (6 endpoints)
- `GET /stores/:storeId/products` - Бараа жагсаалт (pagination, search, filter)
- `GET /stores/:storeId/products/:productId` - Бараа дэлгэрэнгүй
- `POST /stores/:storeId/products` - Бараа нэмэх
- `PUT /stores/:storeId/products/:productId` - Бараа засах
- `DELETE /stores/:storeId/products/:productId` - Бараа устгах (soft delete)
- `POST /stores/:storeId/products/bulk` - Олон бараа нэмэх

### Inventory Module (4 endpoints)
- `GET /stores/:storeId/inventory-events` - Event түүх
- `POST /stores/:storeId/inventory-events` - Manual adjustment
- `GET /stores/:storeId/stock-levels` - Бүх барааны үлдэгдэл
- `GET /stores/:storeId/products/:productId/stock-history` - Нэг барааны түүх

### Shift Module (5 endpoints)
- `POST /stores/:id/shifts/open` - Ээлж нээх
- `POST /stores/:id/shifts/close` - Ээлж хаах
- `GET /stores/:id/shifts` - Ээлжийн түүх
- `GET /stores/:id/shifts/:shiftId` - Ээлж дэлгэрэнгүй
- `GET /stores/:id/shifts/active` - Идэвхтэй ээлж

### Sales Module (4 endpoints)
- `POST /stores/:id/sales` - Борлуулалт бүртгэх
- `GET /stores/:id/sales` - Борлуулалтын түүх
- `GET /stores/:id/sales/:saleId` - Борлуулалт дэлгэрэнгүй
- `POST /stores/:id/sales/:saleId/void` - Борлуулалт цуцлах (owner, manager)

### Reports Module (3 endpoints)
- `GET /stores/:id/reports/daily` - Өдрийн тайлан
- `GET /stores/:id/reports/top-products` - Шилдэг бараа
- `GET /stores/:id/reports/seller-performance` - Худалдагчийн үзүүлэлт

### Alerts Module (3 endpoints)
- `GET /stores/:storeId/alerts` - Сэрэмжлүүлэг жагсаалт (owner, manager)
- `GET /stores/:storeId/alerts/:alertId` - Сэрэмжлүүлэг дэлгэрэнгүй (owner, manager)
- `PUT /stores/:storeId/alerts/:alertId/resolve` - Сэрэмжлүүлэг шийдвэрлэх (owner, manager)

### Sync Module (2 endpoints)
- `POST /sync` - Batch sync operations from mobile
- `GET /stores/:storeId/changes` - Delta sync (pull changes)

---

## Total API Endpoints: **45+**

---

## Role-Based Access Control

| Role | Access |
|------|--------|
| **Owner** | Бүх эрх (store, users, products, inventory, sales, reports, alerts) |
| **Manager** | Users удирдах, тайлан харах, alerts харах (store settings засах эрхгүй) |
| **Seller** | Sales бүртгэх, өөрийн shift удирдах, өөрийн sales харах |

---

## Key Features

### Event Sourcing
- Inventory үлдэгдлийг event sourcing pattern-аар удирдана
- Event types: `INITIAL`, `SALE`, `ADJUST`, `RETURN`
- Current stock = SUM(qty_change) for product

### Offline-First Sync
- Mobile app offline дээр бүх үйлдлүүдийг local DB-д хадгална
- Online болоход `/sync` endpoint руу batch илгээнэ
- Server `/changes` endpoint-оор delta sync хийнэ
- Conflict resolution: last-write-wins (timestamp-based)

### Alert Triggers
- Low stock alert (үлдэгдэл босгоос доош)
- Negative inventory alert (сөрөг үлдэгдэл)
- Automatically triggered after sales and inventory events

### Security
- JWT authentication (access token: 1 hour, refresh token: 30 days)
- Rate limiting: 100 requests/minute
- CORS, Helmet security headers
- Input validation with Zod schemas
- Phone-based OTP authentication (Mongolian format)

### Performance
- Database indexes on all foreign keys and frequently queried columns
- Materialized view for stock levels (`product_stock_levels`)
- Pagination on all list endpoints

---

## Development

```bash
# Start server
npm run dev

# Build
npm run build

# Run tests
npm test

# Database types generate
npm run db:types

# Database seed
npm run db:seed
```

---

## Environment Variables

Required in `.env`:
```
SUPABASE_URL=
SUPABASE_ANON_KEY=
SUPABASE_SERVICE_KEY=
JWT_SECRET=
PORT=3000
HOST=0.0.0.0
NODE_ENV=development
```

---

*Last updated: 2026-01-21 (Sprint 6 completed)*
