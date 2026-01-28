# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Rules

1. **Монгол хэлээр харилцах** - Хэрэглэгчтэй үргэлж монгол хэлээр ярилц
2. **Сургалтын зорилготой** - Код бичихдээ яагаад ийм шийдэл сонгосон, ямар pattern ашигласан, юу сурч болох талаар тайлбарлаж өг. Хэрэглэгчийн суурь мэдлэгийг дээшлүүлэхэд туслах
3. **Git commit** - Commit message-д "Co-Authored-By" мөр хэзээ ч бүү нэм
4. **Код дээрх тайлбар монголоор** - Docblock, comment, TODO зэрэг кодын тайлбаруудыг монгол хэлээр бич
5. **Junior Developer Support** - Танд туслах үед:
   - **Best Practices тайлбарлах**: Clean code зарчим, SOLID principles, design patterns-уудыг яагаад ашигласан талаар тайлбарлах
   - **Code Quality Checklist**: Код бичсний дараа дараах зүйлсийг заавал шалгах
     - Type safety: Бүх variable болон parameter-үүд зөв type-тай эсэхийг шалгах
     - Error handling: Try-catch, null checks зэргийг зөв хийсэн эсэхийг шалгах
     - Tests: Unit болон integration тестүүд бичсэн эсэхийг шалгах
     - Performance: Memory leak, unnecessary re-renders байхгүй эсэхийг шалгах
   - **Алдааны тайлбар**: Хэрэв код дээр алдаа олдвол эсвэл сайжруулалт хийвэл:
     - Яагаад хуучин код буруу байсан талаар тайлбарлах
     - Яаж сайжруулсан, ямар principle ашигласан талаар тайлбарлах
     - Ирээдүйд ийм алдаанаас хэрхэн зайлсхийх талаар зөвлөмж өгөх
   - **Альтернатив шийдлүүд**: Нэг асуудлыг хэд хэдэн аргаар шийдэж болох бол:
     - Сонгосон шийдлийн давуу ба сул талуудыг тайлбарлах (trade-offs)
     - Бусад хувилбаруудыг яагаад сонгоогүй талаар тайлбарлах
     - Энэ тохиолдолд яагаад энэ шийдэл хамгийн тохиромжтой талаар тайлбарлах

## Project Overview

Local Retail Control Platform - an offline-first retail inventory and sales management system for small retailers in Mongolia. The project consists of:

- **Flutter mobile app** (main application) - offline-first with local SQLite database
- **Node.js backend** (in `/backend`) - Fastify API server with Supabase

## Build & Development Commands

### Flutter App

```bash
flutter pub get                                              # Install dependencies
dart run build_runner build --delete-conflicting-outputs     # Code generation (Drift, Freezed, Riverpod)
dart run build_runner watch --delete-conflicting-outputs     # Watch mode for code gen
flutter run                                                  # Run app
flutter test                                                 # Run all tests
flutter test test/path/to/test_file.dart                     # Run single test
flutter analyze                                              # Static analysis
flutter gen-l10n                                             # Regenerate localization

# macOS/iOS specific
cd ios && pod install && cd ..                               # Install iOS dependencies
cd macos && pod install && cd ..                             # Install macOS dependencies
```

**IMPORTANT**:
- After modifying `*.dart` files with `@freezed`, `@riverpod`, or Drift tables, always run `build_runner build`
- Use `build_runner watch` during active development to auto-regenerate on file changes
- Run `pod install` after adding new iOS/macOS dependencies
- **macOS Xcode 26 Compatibility**: Firebase packages are temporarily disabled in `pubspec.yaml` (commented out) for Xcode 26 compatibility. Sentry is used instead for monitoring.

### Backend (Node.js)

```bash
cd backend
npm install              # Install dependencies
npm run dev              # Development server (tsx watch)
npm run build            # TypeScript compile
npm test                 # Run all tests (vitest)
npm run test:unit        # Unit tests only
npm run test:integration # Integration tests only
npm run test:e2e         # E2E tests only
npm run test:coverage    # Run tests with coverage
npm run lint             # ESLint
npm run format           # Prettier
npm run db:types         # Generate Supabase types from remote project
npm run db:test          # Test Supabase connection
npm run db:seed          # Seed database
npm run docker:up        # Start PostgreSQL & Redis containers
npm run docker:down      # Stop containers
npm run docker:logs      # View container logs
```

## Architecture

### Product Category System

Products are categorized using a centralized constant system:
- Category values defined in [lib/core/constants/product_categories.dart](lib/core/constants/product_categories.dart)
- Ensures consistency across Product Form, Products List, and database
- Categories: 'Хувцас', 'Хүнс', 'Ундаа', 'Гэр ахуй', 'Бусад'
- ALWAYS use `ProductCategories.values` for category dropdowns
- NEVER hardcode category strings

### Flutter App Structure

```
lib/
├── core/                    # Shared infrastructure
│   ├── api/                 # API client, endpoints, result types
│   ├── database/            # Drift tables (app_database.dart)
│   ├── providers/           # Global Riverpod providers
│   ├── routing/             # GoRouter configuration
│   ├── services/            # Service layer (base_service.dart pattern)
│   ├── sync/                # Offline sync logic
│   ├── theme/               # App theming
│   └── widgets/             # Reusable UI components
│       ├── buttons/
│       ├── cards/
│       ├── indicators/
│       ├── inputs/
│       ├── layout/
│       └── modals/
└── features/                # Feature modules
    ├── auth/                # Authentication (OTP flow)
    ├── inventory/           # Products & stock management
    ├── sales/               # Cart & sales transactions
    ├── shifts/              # Seller shift management
    ├── alerts/              # System notifications
    ├── dashboard/           # Main dashboard
    └── onboarding/          # Splash & intro screens
```

Each feature follows: `domain/` (models) → `presentation/providers/` → `presentation/screens/`

### Code Generation Patterns

**Freezed models** (immutable data classes):
```dart
@freezed
class CartItem with _$CartItem {
  const factory CartItem({...}) = _CartItem;
  factory CartItem.fromJson(Map<String, dynamic> json) => _$CartItemFromJson(json);
}
```

**Riverpod providers** (state management):
```dart
@riverpod
class CartNotifier extends _$CartNotifier {
  @override
  List<CartItem> build() => [];

  void addItem(CartItem item) {
    state = [...state, item];
  }
}
```

**Drift database tables**:
```dart
class Products extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  @override
  Set<Column> get primaryKey => {id};
}
```

### Key Dependencies

**Flutter**:
- `riverpod` - State management
- `drift` - Local SQLite database
- `freezed` - Immutable models
- `go_router` - Navigation
- `supabase_flutter` - Backend client
- `dio` - HTTP client
- `image_picker` & `flutter_image_compress` - Image handling
- `pinput` - OTP input widget
- `flutter_secure_storage` - Secure token storage
- `flutter_animate` - Animations

**Backend**:
- `fastify` - Web framework
- `@supabase/supabase-js` - Database client
- `zod` - Schema validation
- `bullmq` - Job queue (Redis)
- `vitest` - Testing framework

### Offline-First with Event Sourcing

The core architectural pattern is **Event Sourcing** for inventory management:
- Inventory changes are stored as immutable events (`INITIAL`, `SALE`, `ADJUST`, `RETURN`)
- Current stock = sum of all `qty_change` values for a product
- Enables full audit trail, time-travel queries, and offline conflict resolution

### Dual Database Strategy

1. **Mobile (Drift/SQLite)**: Local encrypted database for offline operation
   - Tables defined in [lib/core/database/app_database.dart](lib/core/database/app_database.dart)
   - `SyncQueue` table stores offline operations for later sync

2. **Backend (PostgreSQL via Supabase)**: Centralized cloud database
   - Schema in [database_schema.sql](database_schema.sql)
   - Materialized view `product_stock_levels` for performance
   - Call `refresh_product_stock_levels()` after inventory changes

### Backend Architecture (Fastify)

```
backend/src/
├── config/            # Environment, Supabase client
├── plugins/           # CORS, Helmet, Rate-limit, JWT, Swagger
├── modules/           # Feature modules
│   ├── auth/          # OTP auth, middleware (authenticate, authorize, requireStore)
│   ├── store/         # Store CRUD
│   ├── user/          # User management
│   ├── product/       # Product catalog
│   ├── inventory/     # Stock events
│   ├── shift/         # Shift management
│   ├── sales/         # Sales transactions
│   ├── alerts/        # System alerts
│   ├── reports/       # Analytics
│   └── sync/          # Offline sync endpoint
└── server.ts          # Entry point
```

Each module follows: `<module>.schema.ts` (Zod validation) → `<module>.service.ts` (business logic) → `<module>.routes.ts`

Example: `auth.schema.ts`, `auth.service.ts`, `auth.routes.ts`, `auth.middleware.ts`

**User roles**: `owner`, `manager`, `seller`

### Sync Flow

1. Offline operations → `SyncQueue` table
2. When online → POST `/sync` with batched operations
3. Conflict resolution: Owner adjustment > Seller sale; otherwise last-writer-wins

## Database Tables

| Table | Purpose |
|-------|---------|
| `stores` | Store information |
| `users` | Users (owner, manager, seller roles) |
| `products` | Product catalog with image support (`imageUrl`, `localImagePath`, `imageSynced`) |
| `inventory_events` | Event-sourced inventory changes (INITIAL, SALE, ADJUST, RETURN) |
| `sales` / `sale_items` | Sales transactions |
| `shifts` | Seller work shifts |
| `alerts` | System alerts (low stock, etc.) |
| `invitations` | Invite-only registration system |
| `trusted_devices` | Device trust for OTP-free login |
| `sync_queue` | Offline sync queue (mobile only) |

### Product Images
Products support images with offline-first capability:
- `imageUrl`: Supabase Storage URL (cloud)
- `localImagePath`: Local file path (offline)
- `imageSynced`: Sync status flag
- Images compressed before upload (flutter_image_compress)
- Auto-sync when connection restored

## Database Migrations

Migrations are stored in [supabase/migrations/](supabase/migrations/):
- `20260120072918_initial_schema_fixed.sql` - Initial schema
- `20260120073000_rls_policies.sql` - Row Level Security policies
- `20260124140000_add_trusted_devices.sql` - Trusted devices for OTP-free login
- `20260126000000_add_product_image.sql` - Product image support
- `20260126120000_add_invitations_table.sql` - Invite-only registration system
- `20260126130000_allow_null_store_id.sql` - Allow NULL store_id for super-admin users

**Running migrations**:
```bash
# Push to remote Supabase project
supabase db push

# Or manually via SQL editor in Supabase dashboard
```

**Database maintenance**:
- After inventory changes, refresh materialized view: `SELECT refresh_product_stock_levels();`
- Stock levels calculated from `inventory_events` via event sourcing

## Environment Setup

### Flutter App
Copy `.env.example` to `.env`:
- `SUPABASE_URL`, `SUPABASE_ANON_KEY`
- `ENVIRONMENT` (development/staging/production)

### Backend
Required in `backend/.env`:
- `SUPABASE_URL`, `SUPABASE_ANON_KEY`, `SUPABASE_SERVICE_KEY`
- `JWT_SECRET` (change in production)
- Optional: `PORT` (default 3000), `RATE_LIMIT_MAX`, `SMS_PROVIDER`, `SMS_API_KEY`

### Local Development with Docker
For local backend development with PostgreSQL and Redis:
```bash
cd backend
npm run docker:up        # Start containers
npm run docker:logs      # View logs
npm run docker:down      # Stop containers
```

Docker Compose includes:
- PostgreSQL (for local DB testing)
- Redis (for BullMQ job queues and rate limiting)

## Testing

### Flutter (mocktail)
```dart
// Use mocktail for mocking
import 'package:mocktail/mocktail.dart';

class MockDatabase extends Mock implements AppDatabase {}

test('example test', () {
  final mockDb = MockDatabase();
  when(() => mockDb.getProducts()).thenAnswer((_) async => []);
  // Test implementation
});
```

### Backend (Vitest)
```typescript
// Unit tests in tests/unit
// Integration tests in tests/integration
// E2E tests in tests/e2e

describe('AuthService', () => {
  it('should verify OTP correctly', async () => {
    // Test implementation
  });
});
```

## Localization

ARB files in `lib/l10n/`:
- `app_en.arb` - English (template)
- `app_mn.arb` - Mongolian

After modifying ARB files, run `flutter gen-l10n` to regenerate localization code.

## API Endpoints

### Public Endpoints
- `GET /health` - Health check

### Authentication
- `POST /auth/otp/request` - Request OTP via phone
- `POST /auth/otp/verify` - Verify OTP and receive tokens (шалгана: invitation)
- `POST /auth/refresh` - Refresh access token
- `POST /auth/logout` - Logout and invalidate tokens
- `POST /auth/device/login` - Login with trusted device (OTP-free)
- `GET /auth/me` - Get current user info (requires JWT)

### Invite-Only Registration
**Business Model**: Зөвхөн урилгаар owner бүртгүүлэх систем

**Super-admin setup**:
```bash
npm run db:seed  # Test environment (creates super-admin +97694393494)
# Production: Run backend/migrations/002_create_super_admin.sql manually
```

**Endpoints** (Admin/Super-admin only):
- `POST /invitations` - Урилга илгээх
  ```json
  { "phone": "+976XXXXXXXX", "role": "owner", "expiresInDays": 7 }
  ```
- `GET /invitations` - Урилгын жагсаалт
- `DELETE /invitations/:id` - Урилга цуцлах

**Auth Flow**:
1. Super-admin POST /invitations - урилга илгээх
2. Уригдсан хүн POST /auth/otp/request - OTP хүсэх
3. POST /auth/otp/verify - Урилга шалгагдаж, шинэ owner user үүснэ (store_id = null)
4. Owner onboarding-оор store үүсгэнэ

**Урилгагүй хүн бүртгүүлэх оролдвол**:
```json
{ "success": false, "error": "Та урилга авах хэрэгтэй. Администратортай холбогдоно уу." }
```

### Store-scoped Endpoints
All store-scoped endpoints require `requireStore` middleware and follow pattern: `/stores/:storeId/*`

**Stores**
- `GET /stores/:storeId` - Get store details
- `PATCH /stores/:storeId` - Update store

**Products**
- `GET /stores/:storeId/products` - List products
- `POST /stores/:storeId/products` - Create product
- `GET /stores/:storeId/products/:id` - Get product
- `PATCH /stores/:storeId/products/:id` - Update product
- `DELETE /stores/:storeId/products/:id` - Delete product (soft delete)

**Inventory**
- `GET /stores/:storeId/inventory/events` - List inventory events
- `POST /stores/:storeId/inventory/events` - Create inventory event
- `GET /stores/:storeId/inventory/stock-levels` - Get current stock levels

**Sales**
- `GET /stores/:storeId/sales` - List sales
- `POST /stores/:storeId/sales` - Create sale transaction
- `GET /stores/:storeId/sales/:id` - Get sale details

**Shifts**
- `GET /stores/:storeId/shifts` - List shifts
- `POST /stores/:storeId/shifts` - Create shift
- `PATCH /stores/:storeId/shifts/:id` - Update shift (clock out)

**Alerts**
- `GET /stores/:storeId/alerts` - List alerts
- `POST /stores/:storeId/alerts` - Create alert
- `PATCH /stores/:storeId/alerts/:id` - Mark as read

**Sync**
- `POST /stores/:storeId/sync` - Batch sync offline operations

**Reports**
- `GET /stores/:storeId/reports/sales` - Sales reports with filters

### Authentication Middleware
- `authenticate`: Verify JWT token
- `authorize(roles)`: Check user role (owner, manager, seller)
- `requireStore`: Verify user has access to store
