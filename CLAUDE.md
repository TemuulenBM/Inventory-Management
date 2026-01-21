# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Rules

1. **Монгол хэлээр харилцах** - Хэрэглэгчтэй үргэлж монгол хэлээр ярилц
2. **Сургалтын зорилготой** - Код бичихдээ яагаад ийм шийдэл сонгосон, ямар pattern ашигласан, юу сурч болох талаар тайлбарлаж өг. Хэрэглэгчийн суурь мэдлэгийг дээшлүүлэхэд туслах
3. **Git commit** - Commit message-д "Co-Authored-By" мөр хэзээ ч бүү нэм

## Project Overview

Local Retail Control Platform - an offline-first retail inventory and sales management system for small retailers in Mongolia. The project consists of:

- **Flutter mobile app** (main application) - offline-first with local SQLite database
- **Node.js backend** (in `/backend`) - Fastify API server (not yet implemented)

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

### Key Flutter Dependencies

- **State Management**: Riverpod with code generation (`riverpod_generator`)
- **Local Database**: Drift with SQLCipher encryption
- **Backend**: Supabase for auth and real-time sync
- **Models**: Freezed for immutable data classes
- **Localization**: Flutter's built-in l10n (English + Mongolian)

### Backend Architecture (Fastify)

- **Entry point**: [backend/src/server.ts](backend/src/server.ts)
- **Plugin system**: Security (CORS, Helmet, Rate-limit) → JWT → Error handler
- **Module structure**: Each module has `schema.ts` (Zod), `service.ts`, `routes.ts`
- **Auth middleware**: `authenticate` (JWT verify), `authorize(roles[])`, `requireStore()` - see [backend/src/modules/auth/auth.middleware.ts](backend/src/modules/auth/auth.middleware.ts)
- **User roles**: `owner`, `manager`, `seller`

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
