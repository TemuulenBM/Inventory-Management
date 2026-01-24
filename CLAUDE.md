# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Rules

1. **Монгол хэлээр харилцах** - Хэрэглэгчтэй үргэлж монгол хэлээр ярилц
2. **Сургалтын зорилготой** - Код бичихдээ яагаад ийм шийдэл сонгосон, ямар pattern ашигласан, юу сурч болох талаар тайлбарлаж өг. Хэрэглэгчийн суурь мэдлэгийг дээшлүүлэхэд туслах
3. **Git commit** - Commit message-д "Co-Authored-By" мөр хэзээ ч бүү нэм
4. **Код дээрх тайлбар монголоор** - Docblock, comment, TODO зэрэг кодын тайлбаруудыг монгол хэлээр бич

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
```

**IMPORTANT**: After modifying `*.dart` files with `@freezed`, `@riverpod`, or Drift tables, always run `build_runner build`.

### Backend (Node.js)

```bash
cd backend
npm install              # Install dependencies
npm run dev              # Development server (tsx watch)
npm run build            # TypeScript compile
npm test                 # Run all tests (vitest)
npm run test:unit        # Unit tests only
npm run test:integration # Integration tests only
npm run lint             # ESLint
npm run format           # Prettier
npm run db:types         # Generate Supabase types
npm run db:seed          # Seed database
npm run docker:up        # Start PostgreSQL & Redis
npm run docker:down      # Stop containers
```

## Architecture

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
}
```

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

Each module follows: `schema.ts` (Zod validation) → `service.ts` (business logic) → `routes.ts`

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
| `products` | Product catalog |
| `inventory_events` | Event-sourced inventory changes |
| `sales` / `sale_items` | Sales transactions |
| `shifts` | Seller work shifts |
| `alerts` | System alerts (low stock, etc.) |
| `sync_queue` | Offline sync queue (mobile only) |

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

## Localization

ARB files in `lib/l10n/`:
- `app_en.arb` - English (template)
- `app_mn.arb` - Mongolian

## API Endpoints

- `GET /health` - Health check
- `POST /auth/send-otp` - Send OTP to phone
- `POST /auth/verify-otp` - Verify OTP and get tokens
- `POST /auth/refresh` - Refresh access token
- `GET /auth/me` - Get current user
- `/stores/:storeId/*` - Store-scoped endpoints (require `requireStore` middleware)
