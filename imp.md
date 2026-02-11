# Төслийн Гүнзгий Review + Бизнес Feature Төлөвлөгөө

## Context

**Бизнес**: Хүүхдийн хувцасны жижиглэн худалдаа (Алтжин Бөмбөгөр, Sunday Plaza)
**Асуудлууд**: Бараа тоолого мэдэхгүй, худалдагчийн хяналт байхгүй, ашиг тооцдоггүй, салбар хооронд бараа шилжүүлэг бүртгэдэггүй, үнэ буулгалт/хөнгөлөлт бүртгэдэггүй

**Зорилго**: Бүх бизнесийн feature + ноцтой bug засваруудыг хослуулж, production-д бэлэн болгох

---

## Одоогийн Байдлын Хураангуй

| Бизнесийн асуудал              | Хийгдсэн | Дутуу                                                          |
| ------------------------------ | -------- | -------------------------------------------------------------- |
| Салбар болгоны бараа тоолого   | **100%** | ✅ Бүрэн хийгдсэн (Фаза 5)                                     |
| Худалдагчийн хяналт            | **100%** | ✅ Бүрэн хийгдсэн (Фаза 4)                                     |
| Сайн/муу зарагддаг бараа       | **100%** | ✅ Бүрэн хийгдсэн (Фаза 3)                                     |
| **Салбар хоорондын шилжүүлэг** | **100%** | ✅ Бүрэн хийгдсэн (Фаза 2)                                     |
| Орлого/ашгийн тооцоо           | **100%** | ✅ Бүрэн хийгдсэн (Фаза 3)                                     |
| **Хөнгөлөлт/үнэ буулгалт**     | **100%** | ✅ Бүрэн хийгдсэн (Фаза 3)                                     |

---

## ФАЗА 1: Security + Суурь засвар ✅ ДУУССАН (2026-02-10)

> Шинэ feature нэмэхээс өмнөх ноцтой засварууд
> Migration-ууд Supabase-д push хийгдсэн ✅

### 1.1 JWT Secret лог устгах ✅

- **Файл**: [backend/src/config/env.ts:89](backend/src/config/env.ts#L89)
- `console.log(\`JWT_SECRET: ${env.JWT_SECRET.substring(0, 10)}...\`)` мөрийг устгах

### 1.2 OTP RLS дүрэм нэмэх ✅

- **Шинэ файл**: `supabase/migrations/20260211000000_add_missing_rls.sql`
- `otp_tokens` → RLS идэвхжүүлж, зөвхөн service_role эрхтэй
- `invitations` → RLS идэвхжүүлж, зөвхөн super_admin/owner удирдах

### 1.3 OTP brute-force хамгаалалт ✅

- **Файл**: [backend/src/modules/auth/auth.service.ts:128](backend/src/modules/auth/auth.service.ts#L128)
- `otp_tokens`-д `attempt_count` нэмэх, 3 удаа буруу → хүчингүй болгох

### 1.4 Sync data validation ✅

- **Файл**: [backend/src/modules/sync/sync.schema.ts:32](backend/src/modules/sync/sync.schema.ts#L32)
- `z.record(z.any())` → operation type бүрт тусдаа Zod schema (discriminated union)

### 1.5 Sync race condition ✅

- **Файл**: [lib/core/sync/sync_provider.dart:149](lib/core/sync/sync_provider.dart#L149)
- `sync()` эхэнд `if (state.status == SyncStatus.syncing) return;` нэмэх

### 1.6 N+1 query засах ✅

- **Файл**: [lib/core/database/app_database.dart:342-357](lib/core/database/app_database.dart#L342)
- `getLowStockProducts()` → GROUP BY + HAVING нэг query болгох
- Pattern: [app_database.dart:318](lib/core/database/app_database.dart#L318)-ийн `getStockLevels()` дагах

---

## ФАЗА 2: Салбар Хоорондын Бараа Шилжүүлэг ✅ ДУУССАН (2026-02-10)

> Таны хамгийн том operational дутагдал. Sunday Plaza → Алтжин Бөмбөгөр бараа шилжүүлэх
> Migration Supabase-д push хийгдсэн ✅ | Backend type-safe (no `as any`) ✅ | Тест бүгд passed ✅

### 2.1 Database schema өөрчлөлт ✅

- **Шинэ migration**: `supabase/migrations/20260211000001_add_transfers.sql`
- `inventory_events.event_type`-д `TRANSFER_OUT`, `TRANSFER_IN` нэмэх
- Шинэ `transfers` хүснэгт:
  ```sql
  CREATE TABLE transfers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    source_store_id UUID NOT NULL REFERENCES stores(id),
    destination_store_id UUID NOT NULL REFERENCES stores(id),
    initiated_by UUID NOT NULL REFERENCES users(id),
    status VARCHAR(20) DEFAULT 'pending', -- pending, completed, cancelled
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    completed_at TIMESTAMPTZ
  );
  CREATE TABLE transfer_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    transfer_id UUID NOT NULL REFERENCES transfers(id) ON DELETE CASCADE,
    product_id UUID NOT NULL REFERENCES products(id),
    quantity INTEGER NOT NULL CHECK (quantity > 0)
  );
  ```
- RLS: Owner өөрийн store-уудын transfer-уудыг л харах

### 2.2 Drift (Flutter) database-д нэмэх ✅

- **Файл**: [lib/core/database/app_database.dart](lib/core/database/app_database.dart)
- `Transfers`, `TransferItems` table class нэмэх
- `schemaVersion` дараагийн version болгох + migration нэмэх
- DAO method-ууд: `createTransfer()`, `getTransfers()`, `completeTransfer()`

### 2.3 Backend API endpoint-ууд ✅

- **Шинэ файлууд**:
  - `backend/src/modules/transfer/transfer.schema.ts`
  - `backend/src/modules/transfer/transfer.service.ts`
  - `backend/src/modules/transfer/transfer.routes.ts`
- **Endpoint-ууд**:
  - `POST /stores/:storeId/transfers` — шилжүүлэг эхлүүлэх
  - `GET /stores/:storeId/transfers` — шилжүүлгийн жагсаалт
  - `PATCH /stores/:storeId/transfers/:id/complete` — шилжүүлэг баталгаажуулах
  - `PATCH /stores/:storeId/transfers/:id/cancel` — цуцлах
- **Бизнес логик**:
  1. Owner "Sunday Plaza → Алтжин Бөмбөгөр, 5ш цамц" гэж үүсгэнэ
  2. Source store-д `TRANSFER_OUT` inventory event (-5)
  3. Destination store-д `TRANSFER_IN` inventory event (+5)
  4. Бүгд нэг transaction дотор (атомик)

### 2.4 Flutter Transfer UI ✅

- **Шинэ файлууд**:
  - `lib/features/transfer/domain/models/transfer.dart` (Freezed model)
  - `lib/features/transfer/presentation/providers/transfer_provider.dart`
  - `lib/features/transfer/presentation/screens/transfer_list_screen.dart`
  - `lib/features/transfer/presentation/screens/create_transfer_screen.dart`
- **UX flow**:
  1. Settings эсвэл Dashboard-с "Бараа шилжүүлэг" товч
  2. Эхлэх салбар (auto: одоогийн store), очих салбар сонгох
  3. Бараа сонгох + тоо ширхэг оруулах
  4. Баталгаажуулах → 2 store-ийн inventory шинэчлэгдэнэ

### 2.5 Sync дэмжлэг нэмэх ✅

- `sync.schema.ts`-д `create_transfer` operation type нэмэх
- `sync_queue_manager.dart`-д transfer push/pull logic нэмэх
- Offline: Шилжүүлэг SyncQueue-д орж, online болоход sync хийгдэнэ

---

## ФАЗА 3: Хөнгөлөлт + Ашиг/Орлогын Тооцоо ✅ ДУУССАН (2026-02-10)

> Үнэ буулгалт бүртгэж, ашигтай ажиллаж байна уу мэдэх
> Migration: `20260211200000_add_discount_and_cost.sql` ✅ | Drift v10 ✅ | Backend type-safe ✅ | Тест бүгд passed ✅

### 3.1 Хөнгөлөлтийн database schema ✅

- **Шинэ migration**: `supabase/migrations/20260211000002_add_discount_and_cost.sql`
- `sale_items` хүснэгтэд шинэ баганууд:
  ```sql
  ALTER TABLE sale_items ADD COLUMN original_price INTEGER NOT NULL DEFAULT 0;
  ALTER TABLE sale_items ADD COLUMN discount_amount INTEGER NOT NULL DEFAULT 0;
  ALTER TABLE sale_items ADD COLUMN cost_price INTEGER DEFAULT 0;
  -- unit_price = original_price - discount_amount (бодит зарсан үнэ)
  -- subtotal = unit_price * quantity
  ```
- `sales` хүснэгтэд:
  ```sql
  ALTER TABLE sales ADD COLUMN total_discount INTEGER NOT NULL DEFAULT 0;
  -- Нийт хөнгөлөлтийн дүн (бүх item-ийн discount нийлбэр)
  ```
- **Drift** дээр мөн адил баганууд нэмэх + migration

### 3.2 Checkout UI-д хөнгөлөлт оруулах ✅

- **Файл**: [lib/features/sales/presentation/screens/cart_screen.dart](lib/features/sales/presentation/screens/cart_screen.dart)
- **Файл**: [lib/core/widgets/modals/bottom_action_sheet.dart](lib/core/widgets/modals/bottom_action_sheet.dart)
- Cart item бүрт "Хөнгөлөлт" товч нэмэх:
  - Товч дарахад → dialog гарна: **хөнгөлөлтийн дүн (₮)** эсвэл **хувь (%)** оруулах
  - Жишээ: ₮25,000 цамц → 10% буулгалт → ₮22,500 болж харагдана
  - Зураасан зарагдах үнэ: ~~₮25,000~~ → ₮22,500 (-₮2,500)
- Payment sheet-д нийт хөнгөлөлт харуулах:
  ```
  Дүн:           ₮75,000
  Хөнгөлөлт:     -₮7,500
  ──────────────────────
  Төлөх дүн:     ₮67,500
  ```
- **Role-based хязгаарлалт**:
  - `seller` → хамгийн ихдээ **10%** хөнгөлөлт (store тохиргооноос)
  - `manager` → хамгийн ихдээ **20%**
  - `owner` → хязгааргүй
  - Хязгаараас хэтэрвэл → "Owner-ийн зөвшөөрөл шаардлагатай" гэсэн мессеж

### 3.3 Backend хөнгөлөлтийн дэмжлэг ✅

- **Файл**: [backend/src/modules/sales/sales.schema.ts](backend/src/modules/sales/sales.schema.ts)
  ```typescript
  items: z.array(
    z.object({
      product_id: z.string().uuid(),
      quantity: z.number().int().min(1),
      unit_price: z.number().min(0), // Бодит зарсан үнэ (хөнгөлөлтийн дараа)
      original_price: z.number().min(0), // Анхны үнэ
      discount_amount: z.number().min(0).default(0), // Хөнгөлөлтийн дүн
    }),
  );
  ```
- **Файл**: [backend/src/modules/sales/sales.service.ts](backend/src/modules/sales/sales.service.ts)
  - `createSale()` дотор хөнгөлөлтийн validation:
    - `discount_amount <= original_price` (үнээс илүү хөнгөлөлт өгч болохгүй)
    - `unit_price == original_price - discount_amount` (тооцоо тохирч байх)
    - Seller-ийн хөнгөлөлтийн хязгаар шалгах (role + store тохиргоо)
  - `sale_items`-д `cost_price` хадгалах (products.cost_price-с хуулах)
- **Store тохиргоо**: `stores` хүснэгтэд `max_seller_discount_pct` (default: 10), `max_manager_discount_pct` (default: 20) нэмэх

### 3.4 Ашгийн report endpoint ✅

- **Файл**: [backend/src/modules/reports/reports.service.ts](backend/src/modules/reports/reports.service.ts)
- Шинэ endpoint: `GET /stores/:storeId/reports/profit`
- Query params: `startDate`, `endDate`, `groupBy` (day/week/month)
- Буцаах:
  ```json
  {
    "totalRevenue": 5000000,
    "totalCost": 3200000,
    "totalDiscount": 350000,
    "grossProfit": 1450000,
    "profitMargin": 29,
    "byProduct": [
      {
        "name": "Цамц S",
        "revenue": 500000,
        "cost": 300000,
        "discount": 25000,
        "profit": 175000,
        "margin": 35
      }
    ],
    "byDay": [
      {
        "date": "2026-02-10",
        "revenue": 250000,
        "cost": 160000,
        "discount": 15000,
        "profit": 75000
      }
    ]
  }
  ```
- Шинэ endpoint: `GET /stores/:storeId/reports/discounts`
  - Хэн хэдий чинээ хөнгөлөлт өгсөн (seller-ээр)
  - Ямар бараанд олон хөнгөлөлт өгөгдсөн
  - Нийт хөнгөлөлтийн impact on profit

### 3.5 Dashboard-д ашиг + хөнгөлөлт харуулах ✅

- **Файл**: [lib/features/dashboard/presentation/screens/dashboard_screen.dart](lib/features/dashboard/presentation/screens/dashboard_screen.dart)
- Одоогийн "ӨНӨӨДРИЙН БОРЛУУЛАЛТ" card-ийн доор:
  - **Өнөөдрийн ашиг**: ₮180,000 (36% margin)
  - **Өнөөдрийн хөнгөлөлт**: ₮15,000 (3% of revenue)
  - **Энэ сарын ашиг**: ₮4,500,000
- Trend chart: Өдөр бүрийн ашиг/алдагдал (7 хоног)

### 3.6 Муу зарагддаг бараа report ✅

- **Backend**: `GET /stores/:storeId/reports/slow-moving`
- Сүүлийн 30 хоногт 0-3 ширхэг зарагдсан бараа
- **Dashboard**: "Муу зарагддаг бараа" section нэмэх → Дахиж захиалахгүй байх шийдвэрт тусална

---

## ФАЗА 4: Худалдагчийн Хяналт ✅ ДУУССАН (2026-02-10)

> Худалдагч мөнгө дутааж, бараа алдаж байгааг мэдэх
> Migration: `20260211300000_add_shift_reconciliation.sql` ✅ | Drift v11 ✅ | 3 шинэ alert type ✅ | Тест бүгд passed ✅

### 4.1 Cash reconciliation (Мөнгө тулгалт) ✅

- **Файл**: [backend/src/modules/shift/shift.service.ts](backend/src/modules/shift/shift.service.ts)
- Shift хаах үед тооцоолол:
  ```
  Хүлээгдэж буй = open_balance + cash_sales - cash_refunds
  Зөрүү = close_balance - хүлээгдэж буй
  ```
- Зөрүү > ₮5,000 бол **ALERT** автомат үүсгэх
- `shifts` хүснэгтэд `expected_balance`, `discrepancy` багана нэмэх

### 4.2 Seller Performance UI ✅

- **Шинэ файлууд**:
  - `lib/features/employees/presentation/screens/seller_performance_screen.dart`
  - `lib/features/employees/presentation/providers/seller_performance_provider.dart`
- Backend-д `GET /stores/:storeId/reports/seller-performance` аль хэдийн **бий** (дахин бичих шаардлагагүй)
- UI харуулах зүйлс:
  - Худалдагч бүрийн нийт борлуулалт
  - Shift тоо, дундаж борлуулалт
  - **Мөнгө зөрүүний түүх** (discrepancy history)
  - Буцаалт/void тоо

### 4.3 Сэжигтэй үйлдлийн alert ✅

- **Файл**: [backend/src/modules/alerts/alerts.service.ts](backend/src/modules/alerts/alerts.service.ts)
- Шинэ alert type-ууд:
  - `CASH_DISCREPANCY` — Мөнгө тулгалт зөрүүтэй
  - `EXCESSIVE_DISCOUNT` — Худалдагч хэт их хөнгөлөлт өгч байна (өдрийн нийлбэр > тохируулсан хязгаар)
  - `HIGH_VOID_RATE` — Олон борлуулалт цуцлагдсан
  - `UNUSUAL_RETURN` — Ердийн бусаар олон буцаалт
- Owner-ийн app дээр push notification эсвэл alert дэлгэцэд харуулах

---

## ФАЗА 5: Multi-Store Dashboard + Code Quality ✅ ДУУССАН (2026-02-10)

> Owner-ийн нэгдсэн dashboard + code quality засварууд
> Backend endpoint ✅ | Flutter UI + Provider ✅ | Route ✅ | Тест бүгд passed ✅

### 5.1 Owner-ийн нэгдсэн dashboard ✅

- **Backend**: `GET /users/:userId/stores/dashboard` endpoint нэмсэн ([user.routes.ts](backend/src/modules/user/user.routes.ts))
  - Бүх store-ийн өнөөдрийн борлуулалт, ашиг, хөнгөлөлт, low stock, идэвхтэй ажилтнууд
- **Flutter**:
  - `lib/features/dashboard/presentation/providers/multi_store_dashboard_provider.dart` (provider + models)
  - `lib/features/dashboard/presentation/screens/multi_store_dashboard_screen.dart` (UI)
- Бүх салбарыг нэг дэлгэцэд:
  - Нийт хураангуй карт (gradient, бүх store-ийн нийлбэр)
  - Салбар бүрийн өнөөдрийн борлуулалт + ашиг
  - Low stock тоо (салбараар)
  - Ажиллаж буй худалдагчид
- Owner 2+ store-тэй бол Dashboard header дээр "Бүх салбар" товч харагдана
- Route: `/dashboard/multi` нэмсэн ([route_names.dart](lib/core/routing/route_names.dart), [app_router.dart](lib/core/routing/app_router.dart))

### 5.2 Code quality засварууд ✅

- **Dockerfile Prisma reference устгах** ✅: [backend/Dockerfile](backend/Dockerfile) — бүх Prisma мөрүүд устгасан
- **Provider error дарагдал засах** ✅: [product_provider.dart](lib/features/inventory/presentation/providers/product_provider.dart) — `return []` → `throw Exception(message)`
- **Provider invalidation бүрэн болгох** ✅: [sync_provider.dart](lib/core/sync/sync_provider.dart) — `todaySalesTotalProvider`, `yesterdaySalesTotalProvider`, `todayProfitSummaryProvider`, `topProductsProvider` нэмсэн
- **Backend console.log → structured logging** ✅: [user.routes.ts](backend/src/modules/user/user.routes.ts) — `console.error` → `request.log.error`
- **Flutter debugPrint цэвэрлэх** ✅: [user_stores_provider.dart](lib/features/store/presentation/providers/user_stores_provider.dart) — `debugPrint` + unused import устгасан

---

## Шалгах Алхмууд (Verification)

### Фаза бүрийн дараа

```bash
flutter analyze                    # Static analysis
flutter test                       # Бүх тест
cd backend && npm test             # Backend тест
cd backend && npm run lint         # Lint
```

### Feature-specific шалгалт

- **Transfer**: Sunday Plaza-с Алтжин Бөмбөгөр рүү бараа шилжүүлж, 2 store-ийн stock шалгах
- **Хөнгөлөлт**: Бараанд 10% хөнгөлөлт өгч борлуулалт хийх → sale_items.discount_amount зөв хадгалагдсан, ашгийн тооцоонд тусгагдсан эсэх
- **Хөнгөлөлт хязгаар**: Seller-ээр 15% хөнгөлөлт оруулахад хязгаарлалт ажиллаж байгааг шалгах (default max 10%)
- **Ашиг**: Борлуулалт хийж, dashboard дээр ашиг + хөнгөлөлт зөв тооцоолж байгааг шалгах
- **Мөнгө тулгалт**: Shift хааж, зориуд зөрүүтэй close_balance оруулж, alert үүсэж байгааг шалгах
- **Multi-store**: 2 store-тэй owner-ээр login хийж, нэгдсэн dashboard харагдаж байгааг шалгах

---

## Хугацааны Тооцоо

| Фаза     | Хугацаа         | Агуулга                                          |
| -------- | --------------- | ------------------------------------------------ |
| Фаза 1   | 1-2 өдөр        | Security + суурь bug засвар                      |
| Фаза 2   | 3-4 өдөр        | Салбар хоорондын шилжүүлэг (хамгийн том feature) |
| Фаза 3   | 3-4 өдөр        | Хөнгөлөлт/үнэ буулгалт + ашгийн тооцоо           |
| Фаза 4   | 2-3 өдөр        | Худалдагчийн хяналт + cash reconciliation        |
| Фаза 5   | 2-3 өдөр        | Multi-store dashboard + code quality             |
| **Нийт** | **~12-17 өдөр** |                                                  |

---

## Өөрчлөх/Үүсгэх Файлуудын Жагсаалт

### Шинэ файлууд (Feature)

| Файл                                                                            | Фаза |
| ------------------------------------------------------------------------------- | ---- |
| `supabase/migrations/20260211000000_add_missing_rls.sql`                        | 1    |
| `supabase/migrations/20260211000001_add_transfers.sql`                          | 2    |
| `supabase/migrations/20260211000002_add_discount_and_cost.sql`                  | 3    |
| `supabase/migrations/20260211000003_add_shift_discrepancy.sql`                  | 4    |
| `backend/src/modules/transfer/transfer.schema.ts`                               | 2    |
| `backend/src/modules/transfer/transfer.service.ts`                              | 2    |
| `backend/src/modules/transfer/transfer.routes.ts`                               | 2    |
| `lib/features/transfer/domain/models/transfer.dart`                             | 2    |
| `lib/features/transfer/presentation/providers/transfer_provider.dart`           | 2    |
| `lib/features/transfer/presentation/screens/transfer_list_screen.dart`          | 2    |
| `lib/features/transfer/presentation/screens/create_transfer_screen.dart`        | 2    |
| `lib/features/employees/presentation/screens/seller_performance_screen.dart`    | 4    |
| `lib/features/dashboard/presentation/screens/multi_store_dashboard_screen.dart` | 5    |

### Засах файлууд (Bug fix + Enhancement)

| Файл                                                                  | Фаза | Шалтгаан                               |
| --------------------------------------------------------------------- | ---- | -------------------------------------- |
| `backend/src/config/env.ts`                                           | 1    | JWT secret лог устгах                  |
| `backend/src/modules/auth/auth.service.ts`                            | 1, 5 | OTP attempt limit + `any` type засах   |
| `backend/src/modules/sync/sync.schema.ts`                             | 1    | Data validation нэмэх                  |
| `lib/core/sync/sync_provider.dart`                                    | 1, 5 | Race condition + provider invalidation |
| `lib/core/database/app_database.dart`                                 | 1, 2 | N+1 query + transfer tables            |
| `backend/src/modules/sales/sales.service.ts`                          | 3, 5 | cost_price + transaction fix           |
| `backend/src/modules/reports/reports.service.ts`                      | 3, 4 | Ашиг + slow-moving report              |
| `backend/src/modules/shift/shift.service.ts`                          | 4    | Cash reconciliation                    |
| `backend/src/modules/alerts/alerts.service.ts`                        | 4    | Сэжигтэй үйлдлийн alert                |
| `lib/features/dashboard/presentation/screens/dashboard_screen.dart`   | 3, 5 | Ашиг харуулах                          |
| `lib/features/inventory/presentation/providers/product_provider.dart` | 5    | Error handling засах                   |
| `backend/Dockerfile`                                                  | 5    | Prisma reference устгах                |
