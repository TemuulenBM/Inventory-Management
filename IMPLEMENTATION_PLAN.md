# Local Retail Control Platform - Бүрэн Хэрэгжүүлэлтийн Төлөвлөгөө

## Техникийн Stack

| Layer | Технологи | Тайлбар |
|-------|-----------|---------|
| **Mobile** | Flutter | iOS + Android |
| **Backend** | Fastify + TypeScript | REST API |
| **Database** | Supabase PostgreSQL | Cloud hosted (аль хэдийн бэлэн) |
| **ORM** | Prisma | Type-safe DB access |
| **Auth** | JWT + Phone OTP | Custom implementation |
| **Local DB** | Drift (SQLite) | Offline-first |

> **Тэмдэглэл:** Database Supabase дээр аль хэдийн үүсгэгдсэн, migration хийгдсэн.
> Docker хэрэггүй - Supabase cloud DB ашиглана.

---

## Нийт Хугацаа: 8 Sprint (16 долоо хоног)

```
Sprint 1:    Prisma + Supabase Integration
Sprint 2:    Backend суурь + Auth API
Sprint 3:    Store + User API
Sprint 4:    Product + Inventory API
Sprint 5:    Sales + Shift API
Sprint 6:    Alerts + Sync API
Sprint 7:    Flutter App (Core)
Sprint 8:    Flutter App (Features) + Launch
```

---

# 🗄️ PHASE 1: DATABASE (Sprint 1)

## Sprint 1: Supabase JS Client Integration (2 долоо хоног)

### Checklist

#### 1.1 Supabase Connection Setup
- [x] Supabase Dashboard-аас connection string авах
- [x] `backend/.env` файлд Supabase credentials тохируулах
- [x] Connection test хийх

#### 1.2 Supabase JS Client Setup
- [x] `@supabase/supabase-js` суулгах
- [x] `supabase gen types` - TypeScript types генерэйт хийх
- [x] Type-safe Supabase client wrapper үүсгэх (`src/config/supabase.ts`)
- [x] Environment config файл үүсгэх (`src/config/env.ts`)
- [x] Models type exports:
  - [x] `Store` - дэлгүүр
  - [x] `User` - хэрэглэгч (owner, manager, seller)
  - [x] `Product` - бараа
  - [x] `InventoryEvent` - үлдэгдлийн event
  - [x] `Sale` - борлуулалт
  - [x] `SaleItem` - борлуулалтын бараа
  - [x] `Shift` - ээлж
  - [x] `Alert` - сэрэмжлүүлэг
  - [x] `OtpToken` - OTP код
  - [x] `RefreshToken` - JWT refresh token (schema-д үүсгэх хэрэгтэй)

#### 1.3 Seed Data (Optional)
- [x] `src/scripts/seed.ts` файл үүсгэх
- [x] Test store, user, products үүсгэх
- [x] `npm run db:seed` ажиллуулах

### Deliverables
- ✅ Supabase JS Client суулгагдсан
- ✅ Database types генерэйт хийгдсэн
- ✅ Type-safe Supabase client бэлэн
- ✅ Connection тест амжилттай
- ✅ Test өгөгдөл үүссэн (1 store, 3 users, 10 products, inventory events)

**Тэмдэглэл:** Prisma-ийн оронд Supabase JS Client ашиглах болсон - үнэгүй, REST API-р ажилладаг, RLS дэмждэг.

**Seed Data:**
```bash
# Database өгөгдөл үүсгэх
npm run db:seed

# Database types шинэчлэх
npm run db:types

# Connection тест хийх
npm run db:test
```

---

# 🔧 PHASE 2: BACKEND API (Sprint 2-6)

## Sprint 2: Backend Суурь + Auth (2 долоо хоног)

### Checklist

#### 2.1 Project Setup
- [x] `/backend` folder бүтэц үүсгэх
- [x] `package.json` dependencies:
  ```
  fastify@5.2.0, @fastify/cors@11.2.0, @fastify/helmet@13.0.2,
  @fastify/jwt@10.0.0, @fastify/rate-limit@10.3.0
  @supabase/supabase-js@2.91.0, bcrypt, zod, pino, fastify-plugin
  ```
- [x] TypeScript config (`tsconfig.json`)
- [x] ESLint + Prettier config
- [x] Folder structure:
  ```
  backend/src/
  ├── config/          # Environment, Supabase client
  ├── plugins/         # Fastify plugins
  ├── modules/         # Feature modules
  ├── scripts/         # Seed scripts
  ├── types/           # Database types
  └── server.ts        # Entry point
  ```

#### 2.2 Core Plugins
- [x] CORS plugin (`src/plugins/cors.ts`)
- [x] Helmet (security headers) (`src/plugins/helmet.ts`)
- [x] Rate limiting (100 req/min) (`src/plugins/rate-limit.ts`)
- [x] JWT plugin (`src/plugins/jwt.ts`)
- [x] Error handler (`src/plugins/error-handler.ts`)
- [x] Request logger (Pino) - Built into Fastify server config

#### 2.3 Auth Module
- [x] **POST /auth/otp/request** - OTP илгээх
  - [x] Phone number validation (Mongolian format)
  - [x] Rate limit: 3 OTP/5 min
  - [x] OTP generate (6 digit)
  - [x] OTP хадгалах (5 min expiry)
  - [x] SMS илгээх (mock for now)
- [x] **POST /auth/otp/verify** - OTP баталгаажуулах
  - [x] OTP шалгах
  - [x] User үүсгэх/олох
  - [x] JWT access token (1 цаг)
  - [x] JWT refresh token (30 хоног)
- [x] **POST /auth/refresh** - Token шинэчлэх
- [x] **POST /auth/logout** - Гарах
- [x] **GET /auth/me** - Current user

#### 2.4 Auth Middleware
- [x] `authenticate` - JWT шалгах (jwt.ts plugin-д байна)
- [x] `authorize(['owner', 'manager'])` - Role-based access control
- [x] `requireStore` - Store ownership validation
- [x] `requireAuth` - Combined helper middleware
- [x] `optionalAuth` - Optional authentication
- [x] TypeScript type definitions (`types/fastify.d.ts`)

### Deliverables
- ✅ Backend server ажиллаж байгаа (localhost:3000)
- ✅ Core plugins бүгд ажиллаж байгаа (CORS, Helmet, JWT, Rate Limiting, Error Handler)
- ✅ Health check endpoint: `GET /health`
- ✅ Auth endpoints (2.3 - дууссан)
- ✅ Auth middleware (2.4 - дууссан)

**Үүссэн файлууд:**
```
backend/src/
├── server.ts                      # Fastify server entry point
├── plugins/
│   ├── index.ts                   # Plugin registry
│   ├── cors.ts                    # CORS configuration
│   ├── helmet.ts                  # Security headers
│   ├── rate-limit.ts              # Rate limiting (100 req/min)
│   ├── jwt.ts                     # JWT authentication
│   └── error-handler.ts           # Global error handler
├── config/
│   ├── env.ts                     # Environment configuration
│   └── supabase.ts                # Supabase client + types
├── utils/
│   ├── phone.ts                   # Phone validation utility
│   └── otp.ts                     # OTP generator utility
├── types/
│   └── fastify.d.ts               # Fastify type extensions
└── modules/auth/
    ├── auth.schema.ts             # Zod validation schemas
    ├── auth.service.ts            # Auth business logic
    ├── auth.routes.ts             # Auth endpoints
    └── auth.middleware.ts         # Auth middleware (authorize, requireStore, etc.)
```

**Тест:**
```bash
# Server эхлүүлэх
npm run dev

# Health check
curl http://localhost:3000/health

# OTP хүсэх
curl -X POST http://localhost:3000/auth/otp/request \
  -H "Content-Type: application/json" \
  -d '{"phone": "+97699119911"}'

# OTP verify (console-аас OTP код харах)
curl -X POST http://localhost:3000/auth/otp/verify \
  -H "Content-Type: application/json" \
  -d '{"phone": "+97699119911", "otp": "123456"}'

# Current user мэдээлэл (JWT token шаардлагатай)
curl http://localhost:3000/auth/me \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN"
```

---

## Sprint 3: Store + User Management API (2 долоо хоног)

### Checklist

#### 3.1 Store Module
- [x] **POST /stores** - Store үүсгэх
- [x] **GET /stores/:id** - Store мэдээлэл
- [x] **PUT /stores/:id** - Store засах (owner only)
- [x] **GET /stores/:id/stats** - Store статистик (owner, manager)

#### 3.2 User Module
- [x] **GET /stores/:storeId/users** - Store-ийн хэрэглэгчид (owner, manager)
- [x] **POST /stores/:storeId/users** - Seller/Manager нэмэх (owner only)
- [x] **PUT /stores/:storeId/users/:userId** - User засах (owner, manager)
- [x] **DELETE /stores/:storeId/users/:userId** - User устгах (owner only)
- [x] **PUT /stores/:storeId/users/:userId/role** - Role солих (owner only)

#### 3.3 Authorization Rules
- [x] Owner: бүх эрх (create store, update store, manage users, change roles)
- [x] Manager: seller удирдах, тайлан харах (view users, edit users, view stats)
- [x] Seller: зөвхөн борлуулалт, өөрийн ээлж (store/user endpoints-д хандах эрхгүй)

### Deliverables
- ✅ Store CRUD ажиллаж байгаа
- ✅ User management ажиллаж байгаа
- ✅ Role-based access control бэлэн

---

## Sprint 4: Product + Inventory API (2 долоо хоног)

### Checklist

#### 4.1 Product Module
- [x] **GET /stores/:storeId/products** - Бараа жагсаалт (pagination, search, filter)
- [x] **GET /stores/:storeId/products/:productId** - Бараа дэлгэрэнгүй
- [x] **POST /stores/:storeId/products** - Бараа нэмэх
- [x] **PUT /stores/:storeId/products/:productId** - Бараа засах
- [x] **DELETE /stores/:storeId/products/:productId** - Бараа устгах (soft delete)
- [x] **POST /stores/:storeId/products/bulk** - Олон бараа нэмэх

#### 4.2 Inventory Module (Event Sourcing)
- [x] **GET /stores/:storeId/inventory-events** - Event түүх
- [x] **POST /stores/:storeId/inventory-events** - Manual adjustment
- [x] **GET /stores/:storeId/stock-levels** - Бүх барааны үлдэгдэл
- [x] **GET /stores/:storeId/products/:productId/stock-history** - Нэг барааны түүх

#### 4.3 Stock Calculation
- [x] Event sourcing logic: `current_stock = SUM(qty_change)` (product_stock_levels view)
- [x] Low stock check trigger
- [x] Negative stock alert trigger

### Deliverables
- ✅ Product CRUD ажиллаж байгаа
- ✅ Event sourcing inventory бэлэн
- ✅ Stock calculation зөв ажиллаж байгаа
- ✅ Low stock + Negative stock alerts автоматаар ажиллаж байгаа

---

## Sprint 5: Sales + Shift API (2 долоо хоног)

### Checklist

#### 5.1 Shift Module
- [x] **POST /stores/:id/shifts/open** - Ээлж нээх
- [x] **POST /stores/:id/shifts/close** - Ээлж хаах
- [x] **GET /stores/:id/shifts** - Ээлжийн түүх
- [x] **GET /stores/:id/shifts/:shiftId** - Ээлж дэлгэрэнгүй
- [x] **GET /stores/:id/shifts/active** - Идэвхтэй ээлж

#### 5.2 Sales Module
- [x] **POST /stores/:id/sales** - Борлуулалт бүртгэх
- [x] **GET /stores/:id/sales** - Борлуулалтын түүх
- [x] **GET /stores/:id/sales/:saleId** - Борлуулалт дэлгэрэнгүй
- [x] **POST /stores/:id/sales/:saleId/void** - Борлуулалт цуцлах

#### 5.3 Sales Reports
- [x] **GET /stores/:id/reports/daily** - Өдрийн тайлан
- [x] **GET /stores/:id/reports/top-products** - Шилдэг бараа
- [x] **GET /stores/:id/reports/seller-performance** - Худалдагчийн үзүүлэлт

### Deliverables
- ✅ Shift management ажиллаж байгаа
- ✅ Sales бүртгэл + inventory update ажиллаж байгаа
- ✅ Reports ажиллаж байгаа

**Үүссэн файлууд:**
```
backend/src/modules/
├── shift/
│   ├── shift.schema.ts         # Shift validation schemas
│   ├── shift.service.ts        # Shift business logic
│   └── shift.routes.ts         # Shift endpoints (5 routes)
├── sales/
│   ├── sales.schema.ts         # Sales validation schemas
│   ├── sales.service.ts        # Sales business logic (with inventory events)
│   └── sales.routes.ts         # Sales endpoints (4 routes)
└── reports/
    ├── reports.schema.ts       # Reports validation schemas
    ├── reports.service.ts      # Reports business logic
    └── reports.routes.ts       # Reports endpoints (3 routes)
```

**Тэмдэглэл:**
- Sales модуль нь inventory events-тэй холбогдож, борлуулалт үүсгэх үед автоматаар SALE event үүсгэнэ
- Void sale функц нь RETURN event үүсгэж, stock-ыг буцаана
- Reports модуль нь өдөр, төлбөрийн хэлбэр, цаг зэргээр задарсан тайлан өгнө

---

## Sprint 6: Alerts + Sync + Final API (2 долоо хоног)

### Checklist

#### 6.1 Alert Module
- [x] **GET /stores/:id/alerts** - Сэрэмжлүүлэг жагсаалт
- [x] **GET /stores/:id/alerts/:alertId** - Сэрэмжлүүлэг дэлгэрэнгүй
- [x] **PUT /stores/:id/alerts/:alertId/resolve** - Шийдвэрлэсэн гэж тэмдэглэх
- [x] Alert triggers: low stock, negative inventory (sales болон inventory events дээр автомат)

#### 6.2 Sync Module (Offline-first)
- [x] **POST /sync** - Batch sync endpoint
- [x] **GET /stores/:id/changes** - Delta sync (`?since=timestamp`)
- [x] Conflict resolution: timestamp-based (last-writer-wins)

#### 6.3 API Documentation
- [x] OpenAPI/Swagger spec (http://localhost:3000/docs)
- [x] Postman collection (backend/postman_collection.json)
- [ ] API versioning (/api/v1/) - Optional (эрэлт хэрэгцээнээс хамаарна)

#### 6.4 Security & Performance
- [x] Input validation (Zod schemas - бүх endpoints)
- [x] Rate limiting per endpoint (100 req/min)
- [x] Database indexes review (бүх шаардлагатай indexes байгаа)

### Deliverables
- ✅ Alert system ажиллаж байгаа
- ✅ Sync endpoint бэлэн
- ✅ API documentation бэлэн

**Үүссэн файлууд:**
```
backend/
├── src/modules/
│   ├── alerts/
│   │   ├── alerts.schema.ts       # Alert validation schemas
│   │   ├── alerts.service.ts      # Alert business logic + triggers
│   │   └── alerts.routes.ts       # Alert endpoints (3 routes)
│   └── sync/
│       ├── sync.schema.ts         # Sync validation schemas
│       ├── sync.service.ts        # Batch sync + delta sync logic
│       └── sync.routes.ts         # Sync endpoints (2 routes)
├── src/plugins/
│   └── swagger.ts                 # OpenAPI/Swagger documentation
├── postman_collection.json        # Postman collection (45+ requests)
├── POSTMAN_GUIDE.md               # Postman usage guide
├── API_SUMMARY.md                 # API documentation summary
└── README.md                      # Backend README
```

**Alert Triggers:**
- Sales болон Inventory Events үүсгэх үед автоматаар checkLowStock() болон checkNegativeStock() функцууд ажиллана
- Duplicate alert үүсгэхгүй байх (resolved=false байгаа эсэхийг шалгана)

**Sync Flow:**
1. Mobile app offline mode-д үйлдэл хийнэ → local DB-д хадгална
2. Online болоход POST /sync endpoint руу batch operations илгээнэ
3. Server дээр нэг бүрчлэн process хийнэ (success/failed/conflict)
4. Mobile app GET /stores/:id/changes endpoint-оор server-ийн шинэ өгөгдлүүдийг татна

**Тэмдэглэл:**
- Conflict resolution: last-write-wins (updated_at timestamp харьцуулна)
- Swagger documentation: http://localhost:3000/docs
- Бүх validation Zod schema-аар хийгдсэн

---

# 📱 PHASE 3: FLUTTER APP (Sprint 7-8)

## Sprint 7: Flutter Core + Auth + Products (2 долоо хоног)

### Checklist

#### 7.1 Project Restructure
- [x] Feature-based folder structure
- [x] GoRouter setup
- [x] Theme setup (Material 3)
- [x] Riverpod providers setup
- [x] API client (Dio)
- [x] Offline-first architecture

#### 7.2 Auth Feature
- [x] Login screen (phone input)
- [x] OTP verification screen
- [x] Auth provider (Riverpod)
- [x] Token storage (flutter_secure_storage)
- [x] Auto-login, Logout

#### 7.3 Onboarding Feature
- [x] Welcome screen
- [x] Store setup screen
- [x] First products screen
- [x] Invite seller screen

#### 7.4 Products Feature
- [x] Products list screen (search, low stock highlight)
- [x] Add/Edit product screen
- [x] Product detail screen (stock history)
- [x] Offline support (local DB + sync queue)

### Deliverables
- ✅ Auth flow ажиллаж байгаа
- ✅ Onboarding flow ажиллаж байгаа
- ✅ Products CRUD ажиллаж байгаа (online + offline)

---

## Sprint 8: Sales + Dashboard + Launch (2 долоо хоног)

### Checklist

#### 8.1 Quick Sale Feature
- [ ] Product search/select screen
- [ ] Cart screen (quantities)
- [ ] Confirm sale screen
- [ ] Offline sale queue

#### 8.2 Shift Feature
- [ ] Open/Close shift screens
- [ ] Active shift indicator
- [ ] Shift history

#### 8.3 Dashboard Feature (Owner)
- [ ] Today's sales summary
- [ ] Low stock alerts
- [ ] Top selling products
- [ ] Seller performance

#### 8.4 Settings & Alerts
- [ ] Store/Profile settings
- [ ] Alerts list + resolve

#### 8.5 Testing
- [ ] Unit tests
- [ ] Widget tests
- [ ] Integration tests

#### 8.6 Launch Preparation
- [ ] App icons + Splash screen
- [ ] App Store / Play Store listings
- [ ] Privacy policy + Terms
- [ ] Backend deployment (VPS)
- [ ] Monitoring setup (Sentry)

### Deliverables
- ✅ Бүх feature ажиллаж байгаа
- ✅ Offline mode бүрэн ажиллаж байгаа
- ✅ App Store / Play Store-д бэлэн

---

# 📋 PRE-LAUNCH CHECKLIST

### Backend
- [ ] Production server setup (VPS/Cloud)
- [ ] Domain + SSL certificate
- [ ] Database backup automation
- [ ] Monitoring (uptime, errors)
- [ ] Environment variables secured

### Mobile App
- [ ] App icons (all sizes)
- [ ] Splash screen
- [ ] Error handling
- [ ] Loading/Empty states
- [ ] Offline indicators

### Store Listings
- [ ] App name: "Retail Control" / "Дэлгүүрийн Удирдлага"
- [ ] Description (MN + EN)
- [ ] Screenshots (5+ per platform)
- [ ] Privacy policy URL

### Testing
- [ ] Real device testing (Android + iOS)
- [ ] Slow network / Offline testing
- [ ] Multi-user testing

---

# 📅 Timeline Summary

| Sprint | Хугацаа | Гол зорилт |
|--------|---------|-----------|
| 1 | 2 долоо хоног | Prisma + Supabase integration |
| 2 | 2 долоо хоног | Backend core + Auth API |
| 3 | 2 долоо хоног | Store + User API |
| 4 | 2 долоо хоног | Product + Inventory API |
| 5 | 2 долоо хоног | Sales + Shift API |
| 6 | 2 долоо хоног | Alerts + Sync API |
| 7 | 2 долоо хоног | Flutter Core + Auth + Products |
| 8 | 2 долоо хоног | Flutter Sales + Dashboard + Launch |

**Нийт: 16 долоо хоног (4 сар)**

---

# 🚀 LAUNCH DAY CHECKLIST

- [ ] Backend deployed & tested
- [ ] App submitted to stores
- [ ] App approved & published
- [ ] First beta users invited
- [ ] Feedback collection started
- [ ] Support channel ready

---

*Сүүлд шинэчлэгдсэн: 2026-01-21*
