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
# Install dependencies
flutter pub get

# Run code generation (Drift, Freezed, Riverpod, JSON serialization)
dart run build_runner build --delete-conflicting-outputs

# Watch mode for code generation during development
dart run build_runner watch --delete-conflicting-outputs

# Run the app
flutter run

# Run tests
flutter test

# Run a single test file
flutter test test/path/to/test_file.dart

# Analyze code
flutter analyze
```

### Backend (Node.js)

```bash
cd backend

# Install dependencies
npm install

# Run development server
npm run dev

# Build
npm run build

# Run tests
npm test
npm run test:unit
npm run test:integration

# Lint
npm run lint

# Format
npm run format

# Prisma commands
npm run prisma:generate
npm run prisma:migrate

# Docker
npm run docker:up
npm run docker:down
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

2. **Backend (PostgreSQL)**: Centralized cloud database
   - Schema in [database_schema.sql](database_schema.sql)
   - Materialized view `product_stock_levels` for performance

### Key Flutter Dependencies

- **State Management**: Riverpod with code generation (`riverpod_generator`)
- **Local Database**: Drift with SQLCipher encryption
- **Backend**: Supabase for auth and real-time sync
- **Models**: Freezed for immutable data classes
- **Localization**: Flutter's built-in l10n (English + Mongolian)

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

Copy `.env.example` to `.env` and configure:
- `SUPABASE_URL` and `SUPABASE_ANON_KEY` for Supabase connection
- `ENVIRONMENT` (development/staging/production)

## Localization

ARB files in `lib/l10n/`:
- `app_en.arb` - English (template)
- `app_mn.arb` - Mongolian

Run `flutter gen-l10n` to regenerate after modifying ARB files.
