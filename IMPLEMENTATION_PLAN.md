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

## Sprint 1: Prisma + Supabase Integration (2 долоо хоног)

### Checklist

#### 1.1 Supabase Connection Setup
- [ ] Supabase Dashboard-аас connection string авах
- [ ] `backend/.env` файлд `DATABASE_URL` тохируулах
- [ ] Connection test хийх

#### 1.2 Prisma Schema (Supabase DB-тэй sync)
- [ ] `npx prisma db pull` - Supabase schema-г татах
- [ ] `backend/prisma/schema.prisma` шалгах, засах
- [ ] Models баталгаажуулах:
  - [ ] `Store` - дэлгүүр
  - [ ] `User` - хэрэглэгч (owner, manager, seller)
  - [ ] `Product` - бараа
  - [ ] `InventoryEvent` - үлдэгдлийн event
  - [ ] `Sale` - борлуулалт
  - [ ] `SaleItem` - борлуулалтын бараа
  - [ ] `Shift` - ээлж
  - [ ] `Alert` - сэрэмжлүүлэг
  - [ ] `OtpToken` - OTP код
  - [ ] `RefreshToken` - JWT refresh token
- [ ] `npx prisma generate` - Client үүсгэх

#### 1.3 Seed Data (Optional)
- [ ] `prisma/seed.ts` файл үүсгэх
- [ ] Test store, user, products үүсгэх
- [ ] `npx prisma db seed` ажиллуулах

### Deliverables
- ✅ Prisma Supabase-тай холбогдсон
- ✅ Prisma schema sync хийгдсэн
- ✅ Prisma Client generate хийгдсэн

---

# 🔧 PHASE 2: BACKEND API (Sprint 2-6)

## Sprint 2: Backend Суурь + Auth (2 долоо хоног)

### Checklist

#### 2.1 Project Setup
- [ ] `/backend` folder бүтэц үүсгэх
- [ ] `package.json` dependencies:
  ```
  fastify, @fastify/cors, @fastify/helmet, @fastify/jwt, @fastify/rate-limit
  @prisma/client, bcrypt, zod, pino
  ```
- [ ] TypeScript config (`tsconfig.json`)
- [ ] ESLint + Prettier config
- [ ] Folder structure:
  ```
  backend/src/
  ├── config/          # Environment, constants
  ├── plugins/         # Fastify plugins
  ├── modules/
  │   ├── auth/
  │   ├── stores/
  │   ├── users/
  │   ├── products/
  │   ├── sales/
  │   ├── inventory/
  │   ├── shifts/
  │   └── alerts/
  ├── middleware/      # Auth, validation
  ├── utils/           # Helpers
  └── server.ts        # Entry point
  ```

#### 2.2 Core Plugins
- [ ] CORS plugin
- [ ] Helmet (security headers)
- [ ] Rate limiting (100 req/min)
- [ ] JWT plugin
- [ ] Error handler
- [ ] Request logger (Pino)

#### 2.3 Auth Module
- [ ] **POST /auth/otp/request** - OTP илгээх
  - [ ] Phone number validation (Mongolian format)
  - [ ] Rate limit: 3 OTP/5 min
  - [ ] OTP generate (6 digit)
  - [ ] OTP хадгалах (5 min expiry)
  - [ ] SMS илгээх (mock for now)
- [ ] **POST /auth/otp/verify** - OTP баталгаажуулах
  - [ ] OTP шалгах
  - [ ] User үүсгэх/олох
  - [ ] JWT access token (1 цаг)
  - [ ] JWT refresh token (30 хоног)
- [ ] **POST /auth/refresh** - Token шинэчлэх
- [ ] **POST /auth/logout** - Гарах
- [ ] **GET /auth/me** - Current user

#### 2.4 Auth Middleware
- [ ] `authenticate` - JWT шалгах
- [ ] `authorize(['owner', 'manager'])` - Role шалгах
- [ ] `requireStore` - Store-д хамаарах эсэх

### Deliverables
- ✅ Backend server ажиллаж байгаа (localhost:3000)
- ✅ Auth endpoints бүгд ажиллаж байгаа
- ✅ JWT authentication бэлэн

---

## Sprint 3: Store + User Management API (2 долоо хоног)

### Checklist

#### 3.1 Store Module
- [ ] **POST /stores** - Store үүсгэх (owner only)
- [ ] **GET /stores/:id** - Store мэдээлэл
- [ ] **PUT /stores/:id** - Store засах
- [ ] **GET /stores/:id/stats** - Store статистик

#### 3.2 User Module
- [ ] **GET /stores/:id/users** - Store-ийн хэрэглэгчид
- [ ] **POST /stores/:id/users** - Seller/Manager нэмэх
- [ ] **PUT /stores/:id/users/:userId** - User засах
- [ ] **DELETE /stores/:id/users/:userId** - User устгах (soft)
- [ ] **PUT /stores/:id/users/:userId/role** - Role солих

#### 3.3 Authorization Rules
- [ ] Owner: бүх эрх
- [ ] Manager: seller удирдах, тайлан харах
- [ ] Seller: зөвхөн борлуулалт, өөрийн ээлж

### Deliverables
- ✅ Store CRUD ажиллаж байгаа
- ✅ User management ажиллаж байгаа
- ✅ Role-based access control бэлэн

---

## Sprint 4: Product + Inventory API (2 долоо хоног)

### Checklist

#### 4.1 Product Module
- [ ] **GET /stores/:id/products** - Бараа жагсаалт (pagination, search, filter)
- [ ] **GET /stores/:id/products/:productId** - Бараа дэлгэрэнгүй
- [ ] **POST /stores/:id/products** - Бараа нэмэх
- [ ] **PUT /stores/:id/products/:productId** - Бараа засах
- [ ] **DELETE /stores/:id/products/:productId** - Бараа устгах (soft)
- [ ] **POST /stores/:id/products/bulk** - Олон бараа нэмэх

#### 4.2 Inventory Module (Event Sourcing)
- [ ] **GET /stores/:id/inventory-events** - Event түүх
- [ ] **POST /stores/:id/inventory-events** - Manual adjustment
- [ ] **GET /stores/:id/stock-levels** - Бүх барааны үлдэгдэл
- [ ] **GET /stores/:id/products/:productId/stock-history** - Нэг барааны түүх

#### 4.3 Stock Calculation
- [ ] Event sourcing logic: `current_stock = SUM(qty_change)`
- [ ] Low stock check trigger
- [ ] Negative stock alert trigger

### Deliverables
- ✅ Product CRUD ажиллаж байгаа
- ✅ Event sourcing inventory бэлэн
- ✅ Stock calculation зөв ажиллаж байгаа

---

## Sprint 5: Sales + Shift API (2 долоо хоног)

### Checklist

#### 5.1 Shift Module
- [ ] **POST /stores/:id/shifts/open** - Ээлж нээх
- [ ] **POST /stores/:id/shifts/close** - Ээлж хаах
- [ ] **GET /stores/:id/shifts** - Ээлжийн түүх
- [ ] **GET /stores/:id/shifts/:shiftId** - Ээлж дэлгэрэнгүй
- [ ] **GET /stores/:id/shifts/active** - Идэвхтэй ээлж

#### 5.2 Sales Module
- [ ] **POST /stores/:id/sales** - Борлуулалт бүртгэх
- [ ] **GET /stores/:id/sales** - Борлуулалтын түүх
- [ ] **GET /stores/:id/sales/:saleId** - Борлуулалт дэлгэрэнгүй
- [ ] **POST /stores/:id/sales/:saleId/void** - Борлуулалт цуцлах

#### 5.3 Sales Reports
- [ ] **GET /stores/:id/reports/daily** - Өдрийн тайлан
- [ ] **GET /stores/:id/reports/top-products** - Шилдэг бараа
- [ ] **GET /stores/:id/reports/seller-performance** - Худалдагчийн үзүүлэлт

### Deliverables
- ✅ Shift management ажиллаж байгаа
- ✅ Sales бүртгэл + inventory update ажиллаж байгаа
- ✅ Reports ажиллаж байгаа

---

## Sprint 6: Alerts + Sync + Final API (2 долоо хоног)

### Checklist

#### 6.1 Alert Module
- [ ] **GET /stores/:id/alerts** - Сэрэмжлүүлэг жагсаалт
- [ ] **PUT /stores/:id/alerts/:alertId/resolve** - Шийдвэрлэсэн гэж тэмдэглэх
- [ ] Alert triggers: low stock, negative inventory, suspicious activity

#### 6.2 Sync Module (Offline-first)
- [ ] **POST /sync** - Batch sync endpoint
- [ ] **GET /stores/:id/changes** - Delta sync (`?since=timestamp`)
- [ ] Conflict resolution: timestamp-based (last-writer-wins)

#### 6.3 API Documentation
- [ ] OpenAPI/Swagger spec
- [ ] Postman collection
- [ ] API versioning (/api/v1/)

#### 6.4 Security & Performance
- [ ] Input validation (Zod schemas)
- [ ] Rate limiting per endpoint
- [ ] Database indexes review

### Deliverables
- ✅ Alert system ажиллаж байгаа
- ✅ Sync endpoint бэлэн
- ✅ API documentation бэлэн

---

# 📱 PHASE 3: FLUTTER APP (Sprint 7-8)

## Sprint 7: Flutter Core + Auth + Products (2 долоо хоног)

### Checklist

#### 7.1 Project Restructure
- [ ] Feature-based folder structure
- [ ] GoRouter setup
- [ ] Theme setup (Material 3)
- [ ] Riverpod providers setup
- [ ] API client (Dio)
- [ ] Offline-first architecture

#### 7.2 Auth Feature
- [ ] Login screen (phone input)
- [ ] OTP verification screen
- [ ] Auth provider (Riverpod)
- [ ] Token storage (flutter_secure_storage)
- [ ] Auto-login, Logout

#### 7.3 Onboarding Feature
- [ ] Welcome screen
- [ ] Store setup screen
- [ ] First products screen
- [ ] Invite seller screen

#### 7.4 Products Feature
- [ ] Products list screen (search, low stock highlight)
- [ ] Add/Edit product screen
- [ ] Product detail screen (stock history)
- [ ] Offline support (local DB + sync queue)

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

*Сүүлд шинэчлэгдсэн: 2026-01-20*
