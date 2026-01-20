# Local Retail Control Platform - Flutter Хэрэгжүүлэх Төлөвлөгөө

## Төслийн товч танилцуулга

**Зорилго**: Жижиг жижиглэнгийн худалдаачдад зориулсан offline-first, mobile-first бараа материалын удирдлага болон борлуулалтын систем

**Платформ**: Flutter (Android + iOS)

**Гол хэрэглэгчид**:
- **Эзэмшигч (Owner)**: Бүрэн хяналт, тайлан, dashboard
- **Худалдагч (Seller)**: Хурдан борлуулалт бүртгэх, ээлж хянах
- **Систем**: Синк, сэрэмжлүүлэг, өгөгдөл хадгалах

**Хөгжүүлэлтийн хугацаа**: 16 долоо хоног (4 сар)

---

## 1. Технологийн стек

### Frontend (Mobile)
- **Framework**: Flutter 3.19+
- **State Management**: Riverpod 2.x (Code Generation)
- **Local Database**: Drift 2.x (encrypted SQLite)
- **Network**: Dio + Retrofit
- **Background Tasks**: WorkManager

### Backend (Санал болгож буй)
- **API**: Node.js + TypeScript (Express/Fastify)
- **Database**: PostgreSQL
- **Cache/Queue**: Redis
- **Auth**: Phone OTP + JWT tokens

### Аюулгүй байдал
- Local DB: AES-256 encryption
- Transport: TLS 1.2+ certificate pinning
- Storage: flutter_secure_storage (Keychain/Keystore)

---

## 2. Төслийн бүтэц (Clean Architecture)

```
lib/
├── core/
│   ├── sync/              # Offline-first sync engine ⭐ CRITICAL
│   │   ├── delta_sync_manager.dart
│   │   ├── conflict_resolver.dart
│   │   └── sync_queue_manager.dart
│   ├── database/          # Drift database ⭐ CRITICAL
│   │   └── app_database.dart
│   ├── security/          # Encryption utilities
│   └── network/           # API client setup
│
├── features/
│   ├── auth/              # OTP login ⭐ CRITICAL
│   ├── inventory/         # Product CRUD + stock calculation
│   ├── sales/             # Quick Sale flow ⭐ CRITICAL
│   ├── dashboard/         # Owner/Seller dashboards
│   ├── shifts/            # Shift management
│   ├── alerts/            # Low stock alerts
│   └── onboarding/        # Store setup wizard
│
└── l10n/                  # Mongolian + English
```

---

## 3. MVP функцууд (Эхний 16 долоо хоног)

### Үндсэн функцууд
1. **Product CRUD** - Бараа бүртгэл (нэр, SKU, үнэ, үлдэгдэл)
2. **Quick Sale Flow** - 3 алхамд борлуулалт (бараа сонгох → тоо → баталгаажуулах)
3. **Dashboard** - Реал цагийн мэдээлэл (үлдэгдэл, борлуулалт, сэрэмжлүүлэг)
4. **Shift Tracking** - Ээлж эхлэх/хаах, худалдагч бүртгэх
5. **Alerts** - Бага үлдэгдэл, сөрөг тоо, сэрэмжлүүлэг
6. **Audit Log** - Бүх өөрчлөлтийн түүх
7. **Onboarding** - Анхны тохиргоо явц

### Offline-First онцлог
- Интернэтгүй бүрэн ажиллах
- Local database (encrypted Drift)
- Background sync (WorkManager)
- Conflict resolution (Last-Writer-Wins + manual merge)

---

## 4. Өгөгдлийн загвар (Data Model)

### Үндсэн entities
```dart
// Store - Дэлгүүр
class Store {
  String id;
  String ownerId;
  String name;
  String? location;
  DateTime createdAt;
}

// Product - Бараа
class Product {
  String id;
  String storeId;
  String name;
  String sku;              // Автоматаар үүсгэх
  String unit;             // Ширхэг, кг, литр гэх мэт
  double sellPrice;
  double? costPrice;
  int lowStockThreshold;   // Сэрэмжлүүлгийн босго
}

// InventoryEvent - Үлдэгдлийн өөрчлөлт (Event Sourcing)
class InventoryEvent {
  String id;
  String productId;
  EventType type;          // INITIAL, SALE, ADJUST, RETURN
  int qtyChange;           // +10 or -5
  String actorId;
  String? shiftId;
  String? reason;
  DateTime timestamp;
}

// Sale - Борлуулалт
class Sale {
  String id;
  String sellerId;
  String shiftId;
  List<SaleItem> items;    // [{productId, qty, unitPrice}]
  double totalAmount;
  PaymentMethod method;
  DateTime timestamp;
}

// Shift - Ээлж
class Shift {
  String id;
  String sellerId;
  DateTime openedAt;
  DateTime? closedAt;
  double? openBalance;     // Эхлэх мөнгө (опционал)
  double? closeBalance;
}

// SyncQueue - Синк дараалал ⭐ CRITICAL
class SyncQueue {
  int id;
  String entityType;       // 'product', 'sale', 'inventory_event'
  String operation;        // 'create', 'update', 'delete'
  String payload;          // JSON
  DateTime createdAt;
  bool synced;
  int retryCount;
}
```

---

## 5. Offline-First Sync стратеги

### A. Event Sourcing загвар
Бүх үлдэгдлийн өөрчлөлтийг **InventoryEvent** хэлбэрээр хадгална:
- Одоогийн үлдэгдэл = бүх events-ийн нийлбэр
- Бүрэн audit trail (хэн, хэзээ, яагаад)
- Conflict resolution хялбар (events-ийг цагийн дарааллаар replay)

```dart
// Одоогийн үлдэгдэл тооцох
Future<int> getCurrentStock(String productId) async {
  final events = await db.getInventoryEvents(productId);
  return events.fold(0, (sum, e) => sum + e.qtyChange);
}
```

### B. Sync Queue Manager
Offline үед бүх үйлдлийг **SyncQueue** руу нэмнэ:

```dart
// Борлуулалт хийх
Future<void> recordSale(Sale sale) async {
  // 1. Local DB-д хадгал
  await db.insertSale(sale);

  // 2. Үлдэгдэл шинэчил
  await db.insertInventoryEvent(InventoryEvent(
    type: EventType.SALE,
    qtyChange: -sale.quantity,
    actorId: sale.sellerId,
  ));

  // 3. Sync queue-д нэм
  await syncQueue.enqueue(
    entityType: 'sale',
    operation: 'create',
    payload: jsonEncode(sale),
  );

  // 4. Background-д sync хий (хэрэв online бол)
  if (await isOnline()) {
    syncManager.processQueue();
  }
}
```

### C. Conflict Resolution
**Үндсэн стратеги**: Last-Writer-Wins (LWW) + manual merge

1. **Энгийн тохиолдол**: Хамгийн сүүлд өөрчлөгдсөн хувилбар ялна
2. **Эзэмшигчийн adjustment**: Приоритеттэй (худалдагчийн борлуулалтаас өмнө)
3. **Давхцсан timestamp**: Эзэмшигчийн dashboard дээр гараар шийдвэрлэх UI

```dart
class ConflictResolver {
  ConflictResolution resolve(LocalData local, ServerData server) {
    if (local.updatedAt.isAfter(server.updatedAt)) {
      return ConflictResolution.useLocal();
    } else if (server.updatedAt.isAfter(local.updatedAt)) {
      return ConflictResolution.useServer();
    } else {
      // Timestamp адилхан - эзэмшигчид асуух
      return ConflictResolution.requireManual(local, server);
    }
  }
}
```

### D. Delta Sync
Зөвхөн өөрчлөгдсөн өгөгдөл sync хийнэ:

```dart
// API: GET /stores/{id}/products?since=2024-01-15T10:30:00Z
Future<void> syncProducts() async {
  final lastSync = await getLastSyncTimestamp('products');

  // 1. Push local changes
  final unsyncedProducts = await db.getUnsyncedProducts();
  await api.batchUpdateProducts(unsyncedProducts);

  // 2. Pull server changes (delta)
  final serverProducts = await api.getProducts(since: lastSync);

  // 3. Merge with conflict resolution
  for (final product in serverProducts) {
    await mergeWithConflictResolution(product);
  }

  await setLastSyncTimestamp('products', DateTime.now());
}
```

---

## 6. Хэрэгжүүлэх дараалал (16 долоо хоног)

### Sprint 1 (1-2 долоо хоног): Суурь + Нэвтрэх
**Зорилго**: Төслийн суурь бүтэц, authentication

**Tasks**:
- [x] Flutter project үүсгэх (folder structure, dependencies)
- [ ] Drift database schema + encryption setup
- [ ] Phone OTP authentication (request/verify)
- [ ] Secure token storage (flutter_secure_storage)
- [ ] Basic routing (go_router)
- [ ] Mongolian localization файлууд (app_mn.arb)

**Deliverables**:
- Login + OTP verification screens
- Encrypted local database ready
- Auth state management (Riverpod)

---

### Sprint 2 (3-4 долоо хоног): Бараа удирдлага + Sync
**Зорилго**: Product CRUD + offline-first sync суурь

**Tasks**:
- [ ] Product entity + models (Freezed)
- [ ] ProductLocalDataSource (Drift CRUD)
- [ ] SyncQueueManager implementation ⭐
- [ ] ProductRepository (offline-first logic)
- [ ] Product List screen (search, filter)
- [ ] Add Product form (validation)
- [ ] Unit tests (product domain logic)

**Deliverables**:
- Offline-д бараа нэмэх/засах
- Sync queue operational
- 70%+ test coverage on product logic

**Шалгах**: Offline-д бараа нэм → online бол → server синктэй болох

---

### Sprint 3 (5-6 долоо хоног): Quick Sale + Үлдэгдэл
**Зорилго**: Борлуулалтын урсгал, үлдэгдэл тооцоолох

**Tasks**:
- [ ] Sale + InventoryEvent entities
- [ ] Stock calculation engine (event sourcing) ⭐
- [ ] Quick Sale screen (3-step flow)
- [ ] Product search with typeahead
- [ ] Sale attribution to shifts
- [ ] Real-time inventory updates (Drift streams)
- [ ] Integration tests (offline sale flow)

**Deliverables**:
- ≤3 tap-аар борлуулалт бүртгэх
- Үлдэгдэл автоматаар шинэчлэгдэх
- <10 секундэд борлуулалт дуусах (NFR requirement)

**Шалгах**: Offline борлуулалт → үлдэгдэл бууралт → sync хийхэд server updated

---

### Sprint 4 (7-8 долоо хоног): Dashboard + Сэрэмжлүүлэг
**Зорилго**: Эзэмшигчийн dashboard, alert engine

**Tasks**:
- [ ] Dashboard data aggregation (Drift SQL joins)
- [ ] Alert engine (low stock threshold checking)
- [ ] Dashboard widgets (sales summary, top products, alerts)
- [ ] Firebase Cloud Messaging setup
- [ ] Push notification integration
- [ ] Performance optimization (lazy load, pagination)

**Deliverables**:
- Реал цагийн dashboard
- Автомат сэрэмжлүүлэг (бага үлдэгдэл, сөрөг тоо)
- Dashboard <2 секундэд ачаалагдах

---

### Sprint 5 (9-10 долоо хоног): Ээлж + Audit
**Зорилго**: Shift tracking, audit log

**Tasks**:
- [ ] Shift entity + management logic
- [ ] Shift open/close UI
- [ ] Shift report generation
- [ ] Audit history screen (filterable logs)
- [ ] Seller management (CRUD)
- [ ] Role-based access control (RBAC)

**Deliverables**:
- Ээлж эхлэх/хаах
- Борлуулалт ээлжид холбогдох
- Audit log (хэн, хэзээ, юу өөрчилсөн)
- Худалдагч manual adjustment хийж чадахгүй

---

### Sprint 6 (11-12 долоо хоног): Onboarding + Тохиргоо
**Зорилго**: Анхны ээлжээс эхлүүлэх явц, performance

**Tasks**:
- [ ] Multi-step onboarding wizard
- [ ] Settings screen (threshold, timezone, currency)
- [ ] Global error handling + retry
- [ ] Offline indicator UI (banner)
- [ ] App launch optimization (<4s cold start)
- [ ] Performance profiling (Flutter DevTools)

**Deliverables**:
- Guided onboarding (store setup → products → sellers)
- Settings page
- <4 секундэд app launch (NFR-01)

---

### Sprint 7 (13-14 долоо хоног): Тестлэгээ + Аюулгүй байдал
**Зорилго**: Integration tests, security audit

**Tasks**:
- [ ] Integration test suite (critical flows)
- [ ] Security audit (encryption, cert pinning, token handling)
- [ ] Low-end device testing (2GB RAM Android)
- [ ] Accessibility (large text, contrast)
- [ ] Mongolian translation QA
- [ ] Beta bug fixes

**Deliverables**:
- 80%+ test coverage
- Security hardening done
- Beta-ready build

---

### Sprint 8 (15-16 долоо хоног): Production launch
**Зорилго**: Play Store/App Store release

**Tasks**:
- [ ] Release builds (signed APK/IPA)
- [ ] Store listings (screenshots, descriptions)
- [ ] Production backend deploy
- [ ] Monitoring setup (Sentry, Firebase Analytics)
- [ ] User documentation (Mongolian PDF + in-app help)
- [ ] Pilot store deployment (family baby shop)

**Deliverables**:
- Production app live on stores
- Monitoring operational
- Pilot feedback collected

---

## 7. Чухал dependency-үүд

```yaml
dependencies:
  # State Management
  flutter_riverpod: ^2.5.1
  riverpod_annotation: ^2.3.5

  # Local Database ⭐
  drift: ^2.16.0
  encrypted_drift: ^0.3.0
  sqlite3_flutter_libs: ^0.5.20

  # Network
  dio: ^5.4.1
  retrofit: ^4.1.0
  connectivity_plus: ^5.0.2

  # Background Tasks ⭐
  workmanager: ^0.5.2

  # Security ⭐
  flutter_secure_storage: ^9.0.0
  encrypt: ^5.0.3

  # Code Generation
  freezed_annotation: ^2.4.1
  json_annotation: ^4.8.1

  # Localization
  flutter_localizations:
    sdk: flutter
  intl: ^0.19.0

  # Monitoring
  firebase_analytics: ^10.8.9
  firebase_crashlytics: ^3.4.18
  sentry_flutter: ^7.18.0
```

---

## 8. Performance шаардлага (NFR)

| Metric | Target | Хэрхэн хэмжих |
|--------|--------|---------------|
| App launch | <4s | DevTools performance tab |
| Quick Sale flow | <10s | Stopwatch from open → saved |
| UI interactions | <1.5s | Tap → visual feedback |
| Delta sync | <5s | Network tab (delta endpoint) |
| Offline capacity | 6 months / 10k events | Database size test |
| Sync reliability | <1% conflicts | Analytics tracking |

---

## 9. Эрсдэл ба бууруулах арга

| Эрсдэл | Магадлал | Нөлөөлөл | Шийдэл |
|--------|----------|----------|--------|
| Offline sync conflict | Дунд | Өндөр | Event sourcing + manual merge UI + extensive testing |
| 2GB RAM төхөөрөмж удаан | Өндөр | Дунд | Performance profiling on actual devices, lazy load, pagination |
| Mongolian keyboard асуудал | Дунд | Бага | Mongolian locale-р Sprint 1-д л тест хийх |
| Backend downtime | Бага | Өндөр | Local queue + exponential backoff retry + offline mode indicator |

---

## 10. Verification (Шалгах арга)

### Sprint дууссан тутам шалгах
1. **Functional**: Бүх user story acceptance criteria биелсэн эсэх
2. **Performance**: NFR үзүүлэлтүүд хангагдсан эсэх (DevTools)
3. **Security**: Sensitive data encrypted, tokens secured
4. **Offline**: Интернэтгүй бүх үндсэн функц ажиллах
5. **Mongolian**: UI бүх текст орчуулагдсан

### End-to-end тест сценари (Sprint 7)
```
Сценари: Offline борлуулалтаас эхлээд sync хүртэл

1. Апп offline горимд байх
2. Худалдагч нэвтрэх
3. Ээлж эхлүүлэх
4. Бараа сонгох (typeahead search)
5. Тоо хэмжээ оруулах (quantity: 2)
6. Борлуулалт баталгаажуулах (Confirm Sale)
7. Үлдэгдэл шууд шинэчлэгдэж, dashboard updated харагдах
8. Online болох
9. Background sync автоматаар эхлэх
10. Server sync log-д тухайн борлуулалт харагдах
11. Өөр төхөөрөмж дээр sync хийхэд үлдэгдэл зөв харагдах

✅ PASS: Бүх алхам амжилттай
❌ FAIL: Алдаа гарсан алхам + log
```

---

## 11. Критик файлууд (эхэлж хийх)

### Эхний 5 файл (өндөр приоритет)

1. **`lib/core/database/app_database.dart`** ⭐⭐⭐
   - Drift schema (Products, Sales, InventoryEvents, SyncQueue)
   - Encryption setup
   - Migration logic

2. **`lib/core/sync/delta_sync_manager.dart`** ⭐⭐⭐
   - Offline-first sync logic
   - Conflict resolution
   - Queue processing

3. **`lib/features/auth/data/repositories/auth_repository_impl.dart`** ⭐⭐
   - OTP authentication
   - Token management
   - Secure storage

4. **`lib/features/inventory/domain/usecases/calculate_stock_usecase.dart`** ⭐⭐⭐
   - Stock calculation from events
   - Real-time inventory accuracy

5. **`lib/features/sales/presentation/screens/quick_sale_screen.dart`** ⭐⭐
   - Quick Sale UI (3-step flow)
   - Performance critical (<10s per sale)

---

## 12. Success Metrics (Амжилтын үзүүлэлт)

### Техникийн үзүүлэлт
- [ ] 80%+ code coverage
- [ ] 0 critical security vulnerabilities
- [ ] <4s app launch на 2GB RAM Android
- [ ] <1% sync conflicts requiring manual resolution

### Бизнесийн үзүүлэлт (Pilot store)
- [ ] 70% daily active sellers (1 сарын дараа)
- [ ] Эзэмшигч dashboard ≥1/өдөр нээх
- [ ] Average sale time <10s
- [ ] Үлдэгдлийн алдагдал 30% буурах (3 сарын дараа)

---

## 13. Дараачийн үе шат (Post-MVP)

### Phase 2 (17-24 долоо хоног)
- Multi-store support (1 эзэмшигч → олон дэлгүүр)
- CSV import/export (product list, sales)
- Returns/void sale flow
- Advanced reports (cash vs sales reconciliation)

### Phase 3 (25-36 долоо хоног)
- Public product listing
- Simple online order capture
- SMS/Push notifications for low stock
- Web admin panel (owner dashboard on desktop)

---

## Хавсралт: Mongolian Localization

### Үндсэн terminууд
```json
{
  "quickSale": "Түргэн борлуулалт",
  "dashboard": "Хяналтын самбар",
  "inventory": "Бараа материал",
  "product": "Бараа",
  "quantity": "Тоо хэмжээ",
  "price": "Үнэ",
  "sellPrice": "Борлуулах үнэ",
  "costPrice": "Өртөг",
  "lowStock": "Бага үлдэгдэл",
  "alert": "Сэрэмжлүүлэг",
  "shift": "Ээлж",
  "seller": "Худалдагч",
  "owner": "Эзэмшигч",
  "syncStatus": "Синк байдал",
  "offline": "Офлайн горим",
  "lastSync": "Сүүлийн синк"
}
```

---

---

# BACKEND API ХӨГЖҮҮЛЭЛТИЙН ТӨЛӨВЛӨГӨӨ (SUPABASE)

## Технологийн Стек (Батлагдсан - Supabase Platform)

### Platform: Supabase (Backend-as-a-Service)
- **Supabase PostgreSQL**: Managed PostgreSQL database
- **Supabase Authentication**: Built-in Phone OTP + JWT
- **Supabase Edge Functions**: TypeScript/Deno serverless functions (sync logic, business rules)
- **Supabase Real-time**: WebSocket subscriptions (dashboard live updates)
- **Supabase Storage**: File storage (optional - product images)
- **Supabase Client SDK**: Flutter package (supabase_flutter)

### Төслийн бүтэц: Flutter + Supabase
```
/Local Retail Control Platform/
├── supabase/         # Supabase configuration (ШИНЭ)
│   ├── migrations/   # Database migrations
│   ├── functions/    # Edge Functions
│   └── config.toml
├── lib/              # Flutter app
├── database_schema.sql  # Initial schema reference
└── DATABASE_GUIDE.md
```

---

## Supabase Project Structure

```
supabase/
├── migrations/
│   ├── 20240120_initial_schema.sql     # database_schema.sql хуулбар
│   ├── 20240121_rls_policies.sql       # Row Level Security policies
│   └── 20240122_functions.sql          # PostgreSQL functions
├── functions/
│   ├── sync-batch/                     # ⭐ CRITICAL Edge Function
│   │   ├── index.ts                    # Batch sync processing
│   │   └── _shared/
│   │       ├── conflict-resolver.ts
│   │       └── validators.ts
│   ├── sync-delta/                     # Delta sync Edge Function
│   │   └── index.ts
│   ├── calculate-stock/                # Stock calculation function
│   │   └── index.ts
│   └── refresh-materialized-views/     # Cron job function
│       └── index.ts
├── seed.sql                            # Sample data
└── config.toml                         # Supabase config
```

**Flutter Integration:**
```
lib/core/supabase/
├── supabase_client.dart                # Singleton client
├── auth_service.dart                   # Phone OTP wrapper
├── sync_service.dart                   # Sync queue manager
└── realtime_service.dart               # Dashboard subscriptions
```

---

## Supabase Services (Endpoints)

### Authentication (Built-in Supabase Auth)
```dart
// Flutter: supabase.auth.signInWithOtp()
await supabase.auth.signInWithOtp(phone: '+97699887766');
await supabase.auth.verifyOTP(phone: '+97699887766', token: '123456');
```

### Database Operations (Direct + RLS)
```dart
// Products - Direct database access via Supabase Client
final products = await supabase
  .from('products')
  .select()
  .eq('store_id', storeId)
  .order('created_at', ascending: false);

// Insert with RLS (Row Level Security)
await supabase.from('products').insert({
  'store_id': storeId,
  'name': 'Product Name',
  'sell_price': 5000,
});
```

### Edge Functions (Custom Logic)
```
POST   /functions/v1/sync-batch          # ⭐ Batch sync processing
GET    /functions/v1/sync-delta?since=... # Delta sync
POST   /functions/v1/calculate-stock     # Manual stock recalculation
```

### Real-time Subscriptions
```dart
// Dashboard live updates
supabase
  .from('sales')
  .stream(primaryKey: ['id'])
  .eq('store_id', storeId)
  .listen((data) {
    // Update dashboard automatically
  });
```

---

## Offline-First Sync Logic (Supabase Implementation)

### Batch Sync Flow
```
Mobile (Offline) → Drift SyncQueue
                         ↓
            Online check → True
                         ↓
      POST /functions/v1/sync-batch
            {operations: [...]}
                         ↓
      Edge Function Processing:
      - Start Supabase transaction
      - Validate each operation (Zod)
      - Check conflicts (timestamps)
      - Insert/Update via Supabase client
      - Log to sync_log table
      - Commit transaction
                         ↓
      Return: {processed, failed, conflicts}
                         ↓
      Flutter: Mark SyncQueue items synced
```

### Delta Sync Flow
```
Mobile: Call Edge Function
        GET /functions/v1/sync-delta?since=2024-01-20T10:00:00Z
                  ↓
Edge Function queries Supabase:
  SELECT * FROM products
  WHERE updated_at >= $since
  AND store_id = $user_store_id  (RLS enforced)
                  ↓
Return: {
  products: [...],
  sales: [...],
  inventoryEvents: [...]
}
                  ↓
Flutter: Merge with local Drift DB
         (conflict resolution if needed)
```

### Conflict Resolution (Edge Function Logic)
```typescript
// supabase/functions/sync-batch/index.ts
function resolveConflict(local, server) {
  // 1. Last-Writer-Wins
  if (local.updated_at > server.updated_at) return 'local';
  if (server.updated_at > local.updated_at) return 'server';

  // 2. Owner Priority (same timestamp)
  if (local.actor_role === 'owner') return 'local';

  // 3. Flag for manual merge
  return 'manual';
}
```

---

## Supabase Database Setup

### 1. Supabase Project үүсгэх
```bash
# Supabase CLI суулгах
brew install supabase/tap/supabase

# Login
supabase login

# Initialize project
supabase init

# Link to cloud project
supabase link --project-ref your-project-ref
```

### 2. Database Migration
```bash
# database_schema.sql-г migration болгох
cp database_schema.sql supabase/migrations/20240120_initial_schema.sql

# Push migration to Supabase
supabase db push

# Generate TypeScript types for Flutter
supabase gen types typescript --local > lib/core/supabase/database.types.ts
```

**Tables** (database_schema.sql-ийн дагуу):
- stores, users, products, inventory_events, sales, sale_items, shifts, alerts, sync_log
- ⚠️ otp_tokens **хасагдана** (Supabase Auth ашиглана)

---

## Authentication Flow (Supabase Phone Auth)

### 1. Request OTP (Built-in Supabase)
```dart
// Flutter
final response = await supabase.auth.signInWithOtp(
  phone: '+97699887766',
  // Supabase автоматаар SMS илгээнэ (Twilio/MessageBird integration)
);

// Supabase:
// 1. Generate 6-digit OTP
// 2. Send SMS via configured provider
// 3. Store in auth.otp_tokens (automatic)
```

### 2. Verify OTP → JWT (Built-in)
```dart
// Flutter
final response = await supabase.auth.verifyOTP(
  phone: '+97699887766',
  token: '123456',
  type: OtpType.sms,
);

// Supabase returns:
// - session (accessToken, refreshToken)
// - user (id, phone, email, user_metadata)
```

### 3. User Metadata (Custom Fields)
```dart
// Create store + user record after OTP verification
final session = supabase.auth.currentSession;
final userId = session?.user.id;

// Insert into users table
await supabase.from('users').insert({
  'id': userId,  // Link to auth.users
  'store_id': storeId,
  'role': 'owner',
  'phone': '+97699887766',
});
```

### 4. JWT Structure (Supabase Auto-generated)
```json
{
  "sub": "uuid",              // User ID
  "phone": "+97699887766",
  "role": "authenticated",    // Supabase role
  "user_metadata": {
    "store_id": "uuid",       // Custom metadata
    "app_role": "owner"
  },
  "exp": 1705750800
}
```

---

## Performance Optimization (Supabase)

### 1. Materialized View Refresh (Supabase pg_cron)
```sql
-- Enable pg_cron extension
CREATE EXTENSION IF NOT EXISTS pg_cron;

-- Schedule refresh every 5 minutes
SELECT cron.schedule(
  'refresh-product-stock',
  '*/5 * * * *',  -- Every 5 minutes
  $$REFRESH MATERIALIZED VIEW CONCURRENTLY product_stock_levels$$
);
```

**Alternative**: Edge Function with cron trigger
```typescript
// supabase/functions/refresh-materialized-views/index.ts
Deno.serve(async (req) => {
  const supabaseClient = createClient(...);
  await supabaseClient.rpc('refresh_product_stock_levels');
  return new Response(JSON.stringify({ success: true }));
});

// config.toml
[functions.refresh-materialized-views]
schedule = "*/5 * * * *"  # Cron trigger
```

### 2. Supabase Caching (Built-in)
- **PostgREST caching**: Automatic for GET requests (configurable TTL)
- **Edge caching**: Supabase CDN caches responses
- **Client-side caching**: Flutter Drift local DB serves as cache

```dart
// Flutter: Local-first approach (no additional caching needed)
// Drift DB = cache, Supabase = source of truth
```

### 3. Connection Pooling (Supabase Managed)
- Supabase automatically manages PostgreSQL connections
- Pooling configured per plan (Free: 60 connections, Pro: 500+)
- No manual configuration needed

---

## Security Measures (Supabase)

✅ **Transport**: TLS 1.3 (Automatic - Supabase managed)
✅ **Auth**: Supabase JWT (1h access, configurable refresh)
✅ **Row Level Security (RLS)**: PostgreSQL policies enforce data isolation
```sql
-- Example RLS policy for products table
ALTER TABLE products ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can only access their store's products"
  ON products FOR ALL
  USING (
    store_id = (
      SELECT store_id FROM users
      WHERE id = auth.uid()
    )
  );
```
✅ **Validation**: Zod schemas in Edge Functions
✅ **SQL Injection**: Supabase client parameterized queries
✅ **Rate Limiting**: Supabase built-in (configurable per plan)
✅ **RBAC**: RLS policies + app_role in user_metadata
✅ **OTP**: Supabase Auth (configurable expiry, auto rate-limiting)
✅ **CORS**: Supabase dashboard configuration

---

## Supabase Local Development

### Supabase CLI (Local Docker Stack)
```bash
# Start local Supabase (PostgreSQL + Auth + Storage + Realtime)
supabase start

# Services available:
# - PostgreSQL: localhost:54322
# - Kong API Gateway: localhost:54321
# - Studio (GUI): http://localhost:54323
# - Auth: http://localhost:54321/auth/v1
# - REST API: http://localhost:54321/rest/v1
```

**No custom Docker Compose needed** - Supabase CLI handles everything.

### Environment Variables (.env)
```bash
# Supabase project credentials
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key
SUPABASE_SERVICE_KEY=your-service-role-key  # Edge Functions only

# Local development (supabase start)
SUPABASE_URL=http://localhost:54321
SUPABASE_ANON_KEY=local-anon-key
```

### Flutter Configuration
```dart
// lib/core/supabase/supabase_client.dart
final supabase = Supabase.initialize(
  url: dotenv.env['SUPABASE_URL']!,
  anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
);
```

---

## Testing Strategy (Supabase)

### Edge Function Tests (Deno Test)
```typescript
// supabase/functions/sync-batch/test.ts
import { assertEquals } from 'https://deno.land/std@0.192.0/testing/asserts.ts';

Deno.test('Batch sync should process operations', async () => {
  const response = await fetch('http://localhost:54321/functions/v1/sync-batch', {
    method: 'POST',
    headers: { 'Authorization': 'Bearer test-token' },
    body: JSON.stringify({ operations: [...] }),
  });

  const data = await response.json();
  assertEquals(data.processed, 2);
  assertEquals(data.conflicts.length, 0);
});
```

### Flutter Integration Tests
```dart
// test/integration/supabase_sync_test.dart
void main() {
  testWidgets('Offline sale sync to Supabase', (tester) async {
    // 1. Create local product in Drift
    // 2. Record offline sale
    // 3. Call sync service
    // 4. Verify Supabase database updated
    // 5. Verify local SyncQueue marked synced
  });
}
```

### Database Tests (pgTAP)
```sql
-- supabase/tests/rls_policies_test.sql
BEGIN;
SELECT plan(3);

SELECT has_table('products');
SELECT col_is_pk('products', 'id');
SELECT policies_are('products', ARRAY['Users can only access their store''s products']);

SELECT * FROM finish();
ROLLBACK;
```

---

## Implementation Phases (Supabase)

### Week 1-2: Supabase Setup + Authentication
- [x] Supabase project үүсгэх (Cloud or self-hosted)
- [x] Supabase CLI суулгах, local development setup
- [x] Database migration (database_schema.sql → Supabase)
- [x] RLS policies үүсгэх (Row Level Security)
- [x] Flutter: supabase_flutter package суулгах
- [ ] Phone OTP authentication integration
- [ ] User metadata setup (store_id, app_role)

### Week 3-4: Edge Functions - Sync Engine ⭐
- [ ] Edge Function: sync-batch үүсгэх
  - Batch operation processing
  - Conflict resolution logic
  - Transaction management
  - Validation (Zod schemas)
- [ ] Edge Function: sync-delta үүсгэх
  - Delta query implementation
  - RLS-aware queries
- [ ] Flutter: SyncService implementation
  - Call Edge Functions
  - Handle conflicts
  - Update SyncQueue
- [ ] Deno tests for Edge Functions

### Week 5-6: Database Functions + Flutter Integration
- [ ] PostgreSQL functions:
  - refresh_product_stock_levels()
  - calculate_current_stock()
  - trigger_low_stock_alerts()
- [ ] Flutter: Supabase client wrapper services
  - AuthService (OTP wrapper)
  - ProductService (CRUD via Supabase client)
  - SaleService (with inventory event creation)
- [ ] Real-time subscriptions setup
  - Dashboard live updates
  - Stock level changes

### Week 7-8: Performance + Background Jobs
- [ ] Materialized view refresh (pg_cron or Edge Function cron)
- [ ] Database indexing optimization
- [ ] Edge Function performance testing
- [ ] Flutter: Optimize Drift ↔ Supabase sync
- [ ] Load testing (100 concurrent stores)

### Week 9-10: Testing + Deployment
- [ ] Edge Function tests (Deno test suite)
- [ ] Flutter integration tests (Supabase mocking)
- [ ] Database tests (pgTAP)
- [ ] E2E offline-sync flow test
- [ ] Production deployment:
  - Supabase project configuration
  - Edge Functions deployment
  - DNS setup
  - Monitoring (Supabase Dashboard + Sentry)

---

## SMS Provider (Mongolia) - Supabase Auth Integration

### Supabase Auth SMS Configuration

Supabase Auth дараах SMS provider-уудыг дэмждэг:
1. **Twilio** (Default, recommended)
2. **MessageBird**
3. **Vonage**
4. **Textlocal**

### Setup (Twilio via Supabase Dashboard)
```bash
# Supabase Dashboard → Authentication → Settings → Phone Auth
# Enable Phone Login
# Configure SMS Provider:
Provider: Twilio
Account SID: AC...
Auth Token: ...
Twilio Phone Number: +1234567890
Message Template: "Таны нэвтрэх код: {{ .Code }}. 5 минутын хугацаатай."
```

**Cost** (Twilio):
- ~$1,500/month (100 stores × 10 OTP/day × 30 days × $0.05/SMS)

### Alternative: Custom SMS Hook (Mongolian Providers)
```typescript
// supabase/functions/send-sms-hook/index.ts
// Custom Edge Function for Unitel/Mobicom integration

Deno.serve(async (req) => {
  const { phone, otp } = await req.json();

  // Call Unitel/Mobicom SMS Gateway
  await fetch('https://sms.unitel.mn/api/send', {
    method: 'POST',
    body: JSON.stringify({
      phone: phone,
      message: `Таны нэвтрэх код: ${otp}. 5 минутын хугацаатай.`,
    }),
  });

  return new Response(JSON.stringify({ success: true }));
});
```

**Cost** (Unitel/Mobicom): ~$600-900/month (~$0.02-0.03/SMS)

---

## Critical Files (Supabase Implementation)

### Top 5 Priority Files

1. **`supabase/functions/sync-batch/index.ts`** ⭐⭐⭐
   - Edge Function: Batch sync processing
   - Conflict resolution logic
   - Transaction management
   - Zod validation

2. **`supabase/migrations/20240120_initial_schema.sql`** ⭐⭐⭐
   - Database schema (from database_schema.sql)
   - PostgreSQL functions
   - Triggers, indexes

3. **`supabase/migrations/20240121_rls_policies.sql`** ⭐⭐⭐
   - Row Level Security policies
   - Multi-tenant data isolation
   - RBAC enforcement

4. **`lib/core/supabase/sync_service.dart`** ⭐⭐⭐
   - Flutter: Sync queue manager
   - Call Edge Functions
   - Handle conflicts, update local DB

5. **`lib/core/supabase/supabase_client.dart`** ⭐⭐
   - Flutter: Supabase client singleton
   - Authentication state management
   - Error handling wrapper

---

## Success Criteria (Supabase)

### Performance
- [ ] Delta sync < 5s (Edge Function execution)
- [ ] Supabase API response < 200ms (95th percentile)
- [ ] Support 100 concurrent stores
- [ ] Materialized view refresh < 10s

### Reliability
- [ ] 99.9% uptime (Supabase SLA)
- [ ] < 1% sync conflicts requiring manual resolution
- [ ] Automatic retry for failed sync operations (Flutter-side)

### Security
- [ ] RLS policies active on all tables
- [ ] Phone OTP authentication working
- [ ] JWT token expiry enforced
- [ ] Edge Functions validated (Zod)

### Cost (Supabase Pro Plan)
- [ ] Database: $25/month (base) + storage
- [ ] Auth: $0.00025/MAU (Monthly Active User)
- [ ] Edge Functions: $10/month (base) + invocations
- [ ] SMS: Twilio costs (~$1,500/month) OR Mongolian provider (~$600/month)

**Total estimated**: ~$650-1,550/month (100 stores)

---

## Шинээр үүсгэх файлууд (Supabase хувилбар)

### 1. Supabase Configuration
```
supabase/
├── config.toml                          # Supabase project config
├── .env.local                           # Local development env vars
└── seed.sql                             # Sample data for development
```

### 2. Database Migrations
```
supabase/migrations/
├── 20240120_initial_schema.sql          # database_schema.sql
├── 20240121_rls_policies.sql            # Row Level Security
├── 20240122_functions.sql               # PostgreSQL functions
└── 20240123_cron_jobs.sql               # pg_cron setup
```

### 3. Edge Functions
```
supabase/functions/
├── sync-batch/
│   ├── index.ts                         # Main handler
│   └── _shared/
│       ├── conflict-resolver.ts
│       ├── validators.ts                # Zod schemas
│       └── types.ts
├── sync-delta/
│   └── index.ts
├── calculate-stock/
│   └── index.ts
└── refresh-materialized-views/
    └── index.ts
```

### 4. Flutter Supabase Integration
```
lib/core/supabase/
├── supabase_client.dart                 # Singleton client
├── auth_service.dart                    # Phone OTP wrapper
├── sync_service.dart                    # Batch/delta sync manager
├── realtime_service.dart                # Dashboard subscriptions
└── database.types.ts                    # Generated TypeScript types
```

### 5. Flutter pubspec.yaml Changes
```yaml
dependencies:
  supabase_flutter: ^2.5.0               # Supabase SDK
  # Remove: dio, http, retrofit, etc.
```

---

**Дараагийн алхам**:
1. Supabase project setup (Week 1)
2. Database migration
3. RLS policies
4. Edge Functions хөгжүүлэлт
