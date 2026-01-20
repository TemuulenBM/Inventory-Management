# Database Architecture Guide

## Тойм

**Local Retail Control Platform** нь **offline-first** архитектур ашигладаг тул **хоёр өгөгдлийн сан** ашигладаг:

1. **Mobile (Flutter App)**: Drift (SQLite) - Offline-first local database
2. **Backend (API Server)**: PostgreSQL - Centralized cloud database

## 1. Mobile Database (Drift/SQLite)

### Онцлог
- **Offline-first**: Интернэтгүй бүрэн ажиллана
- **Encrypted**: AES-256 шифрлэлттэй
- **Event Sourcing**: Үлдэгдлийн бүх өөрчлөлт event хэлбэрээр
- **Sync Queue**: Offline үйлдлүүдийг queue-д хадгалж, online болоход sync хийнэ

### Байршил
- iOS: `~/Library/Application Support/<app_name>/retail_control_db.sqlite`
- Android: `/data/data/mn.retail.retail_control_platform/databases/retail_control_db.sqlite`

### Schema файл
[`lib/core/database/app_database.dart`](lib/core/database/app_database.dart)

---

## 2. Backend Database (PostgreSQL)

### Онцлог
- **Centralized**: Бүх дэлгүүрийн өгөгдөл нэг газарт
- **Multi-tenant**: Олон дэлгүүр, store_id-аар ялгана
- **Materialized View**: Performance-ийн тулд үлдэгдлийг урьдчилан тооцоолсон view
- **Auto-alerts**: Trigger ашиглан автомат сэрэмжлүүлэг үүсгэнэ

### Schema файл
[`database_schema.sql`](database_schema.sql)

---

## Tables Overview

| Table | Зориулалт | Flutter | Backend |
|-------|-----------|---------|---------|
| **stores** | Дэлгүүрийн мэдээлэл | ✅ | ✅ |
| **users** | Хэрэглэгчид (Owner, Seller) | ✅ | ✅ |
| **products** | Бараа бүтээгдэхүүн | ✅ | ✅ |
| **inventory_events** | Үлдэгдлийн өөрчлөлт (Event Sourcing) | ✅ | ✅ |
| **sales** | Борлуулалтын бүртгэл | ✅ | ✅ |
| **sale_items** | Борлуулалтын бараанууд | ✅ | ✅ |
| **shifts** | Худалдагчийн ээлж | ✅ | ✅ |
| **alerts** | Систем сэрэмжлүүлэг | ✅ | ✅ |
| **sync_queue** | Offline sync queue | ✅ | ❌ |
| **sync_log** | Backend sync tracking | ❌ | ✅ |
| **otp_tokens** | OTP нэвтрэх код | ❌ | ✅ |

---

## Event Sourcing Pattern (Үлдэгдлийн тооцоолол)

### Ойлголт
Үлдэгдлийн өөрчлөлт бүрийг **immutable event** хэлбэрээр хадгална. Одоогийн үлдэгдэл = бүх event-ийн нийлбэр.

### Давуу тал
✅ **Бүрэн audit trail** - Хэн, хэзээ, яагаад өөрчилсөн бүгд хадгалагдана
✅ **Time-travel** - Аль ч өдрийн үлдэгдлийг тооцоолж болно
✅ **Conflict resolution** - Offline sync хийхэд conflict-ыг шийдвэрлэхэд хялбар
✅ **Returns/void** - Буцаалт хялбар (шинэ event нэмнэ)

### Жишээ

```sql
-- Анхны үлдэгдэл
INSERT INTO inventory_events (product_id, event_type, qty_change, actor_id)
VALUES ('product-123', 'INITIAL', 100, 'owner-1');  -- +100

-- Борлуулалт
INSERT INTO inventory_events (product_id, event_type, qty_change, actor_id, shift_id)
VALUES ('product-123', 'SALE', -5, 'seller-1', 'shift-1');  -- -5

-- Гар засвар
INSERT INTO inventory_events (product_id, event_type, qty_change, actor_id, reason)
VALUES ('product-123', 'ADJUST', -10, 'owner-1', 'Гэмтсэн');  -- -10

-- Одоогийн үлдэгдэл = 100 - 5 - 10 = 85
SELECT SUM(qty_change) FROM inventory_events WHERE product_id = 'product-123';
```

---

## Sync Strategy (Offline-First)

### 1. Mobile → Backend (Push)

```
[Mobile Offline Operation]
      ↓
[Add to SyncQueue table]
      ↓
[Network available?]
      ↓ YES
[POST /sync with batched operations]
      ↓
[Backend validates & saves]
      ↓
[Mark as synced in SyncQueue]
```

### 2. Backend → Mobile (Pull)

```
[Mobile: GET /stores/{id}/products?since=2024-01-15T10:00:00Z]
      ↓
[Backend: Return only changed records (delta sync)]
      ↓
[Mobile: Merge with conflict resolution]
      ↓
[Update local database]
```

### 3. Conflict Resolution

| Scenario | Strategy |
|----------|----------|
| **Same timestamp** | Owner adjustment wins > Seller sale |
| **Different timestamp** | Last-Writer-Wins (most recent) |
| **Critical conflict** | Flag for manual resolution (dashboard UI) |

---

## PostgreSQL Setup

### 1. Install PostgreSQL

```bash
# macOS (Homebrew)
brew install postgresql@16
brew services start postgresql@16

# Ubuntu/Debian
sudo apt update
sudo apt install postgresql postgresql-contrib
```

### 2. Create Database

```bash
# Connect to PostgreSQL
psql postgres

# Create database
CREATE DATABASE retail_control_db;

# Create user
CREATE USER retail_backend WITH PASSWORD 'your_secure_password';

# Grant privileges
GRANT ALL PRIVILEGES ON DATABASE retail_control_db TO retail_backend;
```

### 3. Run Schema

```bash
psql -U retail_backend -d retail_control_db -f database_schema.sql
```

### 4. Verify Tables

```sql
-- Connect
psql -U retail_backend -d retail_control_db

-- List tables
\dt

-- Check sample data
SELECT * FROM product_stock_levels;
```

---

## Performance Optimization

### 1. Materialized View (product_stock_levels)

```sql
-- Manually refresh
SELECT refresh_product_stock_levels();

-- Auto-refresh every hour (cron or pg_cron extension)
-- Install: CREATE EXTENSION pg_cron;
SELECT cron.schedule('refresh-stock', '0 * * * *',
  'SELECT refresh_product_stock_levels()');
```

### 2. Indexes

```sql
-- Check index usage
SELECT
    schemaname,
    tablename,
    indexname,
    idx_scan,
    idx_tup_read,
    idx_tup_fetch
FROM pg_stat_user_indexes
ORDER BY idx_scan DESC;
```

### 3. Query Performance

```sql
-- Enable query timing
\timing

-- Analyze slow queries
EXPLAIN ANALYZE
SELECT * FROM product_stock_levels WHERE store_id = '...';
```

---

## Backup & Recovery

### Automated Daily Backup

```bash
#!/bin/bash
# backup.sh

DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="/backups/retail_control"
mkdir -p $BACKUP_DIR

# Full backup
pg_dump -U retail_backend -d retail_control_db \
  -F c -f "$BACKUP_DIR/backup_$DATE.dump"

# Keep last 30 days
find $BACKUP_DIR -name "backup_*.dump" -mtime +30 -delete
```

### Restore from Backup

```bash
# Drop and recreate database
dropdb -U retail_backend retail_control_db
createdb -U retail_backend retail_control_db

# Restore
pg_restore -U retail_backend -d retail_control_db backup_20240115.dump
```

---

## Security Best Practices

### 1. Connection Security

```sql
-- Require SSL
ALTER SYSTEM SET ssl = on;

-- Restrict connections (pg_hba.conf)
hostssl all all 0.0.0.0/0 scram-sha-256
```

### 2. Row-Level Security (RLS)

```sql
-- Enable RLS on stores table
ALTER TABLE stores ENABLE ROW LEVEL SECURITY;

-- Policy: Users can only see their own store
CREATE POLICY store_isolation ON stores
    FOR ALL
    USING (owner_id = current_setting('app.user_id')::UUID);
```

### 3. Audit Logging

```sql
-- Enable query logging (postgresql.conf)
log_statement = 'all'
log_duration = on
```

---

## Monitoring & Maintenance

### 1. Database Size

```sql
SELECT
    pg_size_pretty(pg_database_size('retail_control_db')) AS db_size;
```

### 2. Table Sizes

```sql
SELECT
    schemaname,
    tablename,
    pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) AS size
FROM pg_tables
WHERE schemaname = 'public'
ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC;
```

### 3. Vacuum & Analyze

```sql
-- Manual vacuum
VACUUM ANALYZE;

-- Auto-vacuum settings (postgresql.conf)
autovacuum = on
autovacuum_max_workers = 3
```

---

## API Endpoints (Санал болгож буй)

### Products

```
GET    /api/v1/stores/{storeId}/products?since=timestamp
POST   /api/v1/stores/{storeId}/products
PUT    /api/v1/stores/{storeId}/products/{id}
DELETE /api/v1/stores/{storeId}/products/{id}
```

### Sales

```
POST   /api/v1/stores/{storeId}/sales
GET    /api/v1/stores/{storeId}/sales?since=timestamp
```

### Inventory

```
POST   /api/v1/stores/{storeId}/inventory-events
GET    /api/v1/stores/{storeId}/inventory-events?since=timestamp
GET    /api/v1/stores/{storeId}/stock-levels
```

### Sync

```
POST   /api/v1/sync
Body: {
  "operations": [
    {"type": "product", "action": "create", "data": {...}},
    {"type": "sale", "action": "create", "data": {...}}
  ]
}
```

---

## Testing SQL Queries

### 1. Get Current Stock

```sql
SELECT * FROM product_stock_levels
WHERE store_id = '550e8400-e29b-41d4-a716-446655440000';
```

### 2. Today's Sales

```sql
SELECT SUM(total_amount) AS today_sales
FROM sales
WHERE store_id = '550e8400-e29b-41d4-a716-446655440000'
  AND timestamp >= CURRENT_DATE;
```

### 3. Top Selling Products

```sql
SELECT
    p.name,
    SUM(si.quantity) AS total_quantity,
    SUM(si.subtotal) AS total_revenue
FROM sale_items si
JOIN sales s ON si.sale_id = s.id
JOIN products p ON si.product_id = p.id
WHERE s.store_id = '550e8400-e29b-41d4-a716-446655440000'
  AND s.timestamp >= CURRENT_DATE
GROUP BY p.id, p.name
ORDER BY total_quantity DESC
LIMIT 5;
```

### 4. Low Stock Alerts

```sql
SELECT
    p.name,
    psl.current_stock,
    p.low_stock_threshold
FROM product_stock_levels psl
JOIN products p ON psl.product_id = p.id
WHERE psl.store_id = '550e8400-e29b-41d4-a716-446655440000'
  AND psl.is_low_stock = TRUE
ORDER BY psl.current_stock ASC;
```

---

## Troubleshooting

### Issue 1: Materialized View Not Updating

```sql
-- Check last refresh time
SELECT * FROM product_stock_levels LIMIT 1;

-- Manual refresh
SELECT refresh_product_stock_levels();
```

### Issue 2: Slow Queries

```sql
-- Find slow queries
SELECT query, mean_exec_time, calls
FROM pg_stat_statements
ORDER BY mean_exec_time DESC
LIMIT 10;
```

### Issue 3: Deadlocks

```sql
-- Check for deadlocks
SELECT * FROM pg_stat_database WHERE datname = 'retail_control_db';

-- Monitor locks
SELECT * FROM pg_locks WHERE NOT granted;
```

---

## Migration Strategy

### Version 1 → Version 2 Example

```sql
-- migrations/002_add_product_category.sql

-- Add category column
ALTER TABLE products ADD COLUMN category VARCHAR(100);

-- Create index
CREATE INDEX idx_products_category ON products(category);

-- Update version
-- (track schema version in a separate table)
```

---

## Холбоо барих

Асуулт, санал байвал:
- GitHub Issues: [төслийн repository]
- Email: support@retailcontrol.mn
