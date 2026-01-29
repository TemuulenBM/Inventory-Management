# ⚠️ Schema Change Checklist

**Database schema эсвэл API response format өөрчилж байвал энэ checklist-ийг ҮРГЭЛЖ дагаж мөрдөнө үү!**

Schema mismatch нь sync failure, data loss, production bugs үүсгэнэ. Эдгээр алхмуудыг дагаж мөрдөх нь таны app-ийг найдвартай байлгана.

---

## 🎯 Хэзээ ашиглах вэ?

Дараах тохиолдлуудад энэ checklist шаардлагатай:

- [x] Database table-д column **нэмэх/өөрчлөх/устгах**
- [x] API endpoint response format **өөрчлөх** (шинэ field буцаах гэх мэт)
- [x] Sync-тэй холбоотой **бүх өөрчлөлт** (mobile ↔ backend data exchange)
- [x] Data type өөрчлөх (TEXT → INTEGER, VARCHAR → JSONB гэх мэт)

**Жишээ:**
```sql
-- Энэ өөрчлөлт checklist шаардлагатай!
ALTER TABLE products ADD COLUMN discount INTEGER DEFAULT 0;
```

---

## 📋 Алхам 1: Backend Changes

### 1.1 Supabase Migration Бичих

- [ ] Migration файл үүсгэх
  ```bash
  cd supabase
  supabase migration new add_product_discount
  # Файл: supabase/migrations/YYYYMMDDHHMMSS_add_product_discount.sql
  ```

- [ ] Migration SQL бичих
  ```sql
  -- Шинэ column нэмэх
  ALTER TABLE products ADD COLUMN discount INTEGER DEFAULT 0;

  -- Index нэмэх (хэрэв шаардлагатай бол)
  CREATE INDEX idx_products_discount ON products(discount);
  ```

- [ ] Migration apply хийх (test environment)
  ```bash
  supabase db push
  ```

- [ ] Migration verify хийх
  ```bash
  # Supabase dashboard → Table Editor → products table шалгах
  # Эсвэл psql query:
  SELECT column_name, data_type, is_nullable
  FROM information_schema.columns
  WHERE table_name = 'products';
  ```

### 1.2 Backend Service Update

- [ ] **Sync endpoints** update хийх
  - Файл: `backend/src/modules/sync/sync.service.ts`
  - `/stores/:storeId/changes` endpoint select fields шинэчлэх

  ```typescript
  // ӨМНӨ:
  const { data: products } = await supabase
    .from('products')
    .select('*') // Бүх талбар татдаг

  // ДАРАА (explicit болгох):
  .select('id, store_id, name, ..., discount') // ← Шинэ field нэмэх
  ```

- [ ] **CRUD operations** update хийх
  - Create/Update queries шинэчлэх
  - Default values зөв эсэхийг шалгах

### 1.3 Zod Schema Update

- [ ] Validation schemas шинэчлэх
  - Файл: `backend/src/modules/*/schemas.ts`

  ```typescript
  // products.schema.ts
  export const createProductSchema = z.object({
    name: z.string(),
    // ...
    discount: z.number().int().min(0).default(0), // ← ШИНЭ
  });
  ```

### 1.4 Schema Validation Test Update

- [ ] Backend test update хийх
  - Файл: `backend/tests/integration/schema-sync.test.ts`
  - `requiredFields` array-д шинэ талбар нэмэх

  ```typescript
  const requiredFields = [
    'id',
    'store_id',
    // ...
    'discount', // ← НЭМЭХ
  ];
  ```

- [ ] Test ажиллуулах
  ```bash
  cd backend
  npm test -- schema-sync.test.ts
  # PASS хийх ёстой ✅
  ```

---

## 📱 Алхам 2: Mobile Changes

### 2.1 Drift Table Update

- [ ] Table definition шинэчлэх
  - Файл: `lib/core/database/app_database.dart`

  ```dart
  class Products extends Table {
    TextColumn get id => text()();
    // ... бусад columns
    IntColumn get discount => integer().withDefault(const Constant(0))(); // ← НЭМЭХ

    @override
    Set<Column> get primaryKey => {id};
  }
  ```

- [ ] Schema version bump (хэрэв breaking change бол)
  ```dart
  @DriftDatabase(
    tables: [Products, Sales, ...],
    version: 9, // ← Increment хийх
  )
  ```

### 2.2 Build Runner Ажиллуулах

- [ ] Code generation хийх
  ```bash
  dart run build_runner build --delete-conflicting-outputs
  ```

- [ ] Compile errors байвал засах
  - ProductsCompanion, Product model автоматаар шинэчлэгдэнэ
  - Бусад файлууд compile error өгч болно → засах

### 2.3 Sync Pull Logic Update

- [ ] `_upsert*()` functions шинэчлэх
  - Файл: `lib/core/sync/sync_queue_manager.dart`

  ```dart
  Future<void> _upsertProduct(Map<String, dynamic> data) async {
    await db.into(db.products).insertOnConflictUpdate(
      ProductsCompanion.insert(
        id: data['id'],
        // ...
        discount: Value(data['discount'] ?? 0), // ← НЭМЭХ
      ),
    );
  }
  ```

### 2.4 Sync Push Logic Update (хэрэв create/update бол)

- [ ] Payload fields шинэчлэх
  - Файл: `lib/core/services/product_service.dart` (жишээ)

  ```dart
  await enqueueOperation(
    entityType: 'product',
    operation: 'create_product',
    payload: {
      'name': name,
      // ...
      'discount': discount, // ← НЭМЭХ
    },
  );
  ```

### 2.5 Mobile Schema Test Update

- [ ] Test data шинэчлэх
  - Файл: `test/core/sync/schema_sync_test.dart`

  ```dart
  final backendProductData = {
    'id': 'test',
    // ...
    'discount': 0, // ← НЭМЭХ
  };
  ```

- [ ] Test ажиллуулах
  ```bash
  flutter test test/core/sync/schema_sync_test.dart
  # PASS хийх ёстой ✅
  ```

---

## 🧪 Алхам 3: Testing

### 3.1 Unit Tests

- [ ] Backend unit tests
  ```bash
  cd backend
  npm test
  ```

- [ ] Mobile unit tests
  ```bash
  flutter test
  ```

### 3.2 Integration Tests

- [ ] **Multi-device sync scenario** manual test:

  **Device A (online):**
  1. Бараа үүсгэх (шинэ field бүхий)
     - Жишээ: discount = 15%
  2. Sync button дарах
  3. Backend verify:
     ```bash
     curl -X GET "http://localhost:3000/stores/{storeId}/products" \
       -H "Authorization: Bearer {token}"
     # Response: discount field байгаа эсэхийг шалгах
     ```

  **Device B (pull sync):**
  4. App нээх (автоматаар pull sync)
  5. Products list харах
  6. Verify: Шинэ field (discount) зөв харагдаж байна уу?

### 3.3 Offline → Online Flow

- [ ] Offline mode test:
  1. Airplane mode ON
  2. Бараа үүсгэх (шинэ field бүхий)
  3. SyncQueue-д pending operation харагдах
  4. Airplane mode OFF
  5. Sync button дарах
  6. Backend verify: Шинэ field хадгалагдсан уу?

---

## 📚 Алхам 4: Documentation

### 4.1 CLAUDE.md Update

- [ ] Database Tables section шинэчлэх
  ```markdown
  ## Database Tables

  | Table | Purpose |
  |-------|---------|
  | `products` | Product catalog with **discount** support (v9+) |
  ```

- [ ] Schema Change History нэмэх
  ```markdown
  ## Schema Change History

  ### 2026-01-29: Product discount field нэмсэн
  - **Migration:** `supabase/migrations/20260129_add_discount.sql`
  - **Backend:** `sync.service.ts` - /changes endpoint
  - **Mobile:** `sync_queue_manager.dart` - _upsertProduct()
  - **Issue:** Product discount pricing support
  - **PR:** #456
  ```

### 4.2 Migration README

- [ ] Migration түүх бичих
  - Файл: `supabase/migrations/README.md`

  ```markdown
  ## 20260129_add_discount.sql

  **Purpose:** Product discount pricing support нэмэх

  **Changes:**
  - `products` table: `discount INTEGER DEFAULT 0` column нэмсэн
  - Index: `idx_products_discount` үүсгэсэн

  **Breaking:** No (nullable field биш, default value бүхий)

  **Rollback:**
  ```sql
  ALTER TABLE products DROP COLUMN discount;
  ```
  ```

### 4.3 API Docs Update (Optional)

- [ ] Swagger/Postman schemas шинэчлэх
  - Backend Swagger JSON
  - Postman collection

---

## ✅ Pull Request Review Checklist

**Merge хийхээс өмнө reviewer энэ checklist шалгах:**

- [ ] Checklist-ийн **бүх зүйл** хийгдсэн
- [ ] **Schema tests PASS** хийсэн (CI/CD green)
  - Backend: `schema-sync.test.ts` ✅
  - Mobile: `schema_sync_test.dart` ✅
- [ ] **Manual testing** screenshots байгаа (optional)
- [ ] **Documentation** update хийгдсэн
- [ ] **Breaking changes** тэмдэглэгдсэн (хэрэв байвал)
- [ ] **Rollback plan** бичигдсэн

---

## 🚨 Санамж: Schema Change Risks

### HIGH RISK: Breaking Changes

Эдгээр өөрчлөлтүүд production app ажиллахгүй болгож болзошгүй:

- ❌ Column **устгах** (existing mobile app-д шаардлагатай field)
- ❌ Column **rename** хийх (mobile app буруу field нэр ашиглана)
- ❌ Data type **incompatible** өөрчлөх (TEXT → INTEGER гэх мэт)
- ❌ NOT NULL constraint **нэмэх** (existing null values-тай)

**Шийдэл:**
1. **Deprecated approach:** Хуучин column хадгалах + шинэ column нэмэх
2. **Migration strategy:** Multi-step deployment (backend → mobile)
3. **Feature flag:** Шинэ schema feature-ийг toggle хийх боломжтой болгох

### MEDIUM RISK: Nullable Fields

- ⚠️ Nullable field нэмэх → Mobile Value() wrapper зөв эсэхийг шалгах
- ⚠️ Default values зөв эсэх

### LOW RISK: Additive Changes

- ✅ Шинэ **nullable** column нэмэх (backward compatible)
- ✅ Шинэ **default value** бүхий column нэмэх
- ✅ Index нэмэх/устгах (app logic-д нөлөөлөхгүй)

---

## 📖 Жишээ: Бодит Schema Change

**Task:** Product-д `discount` field нэмэх (хөнгөлөлт тооцох)

### Backend Changes

```bash
# 1. Migration
supabase migration new add_product_discount

# 2. SQL бичих
echo "ALTER TABLE products ADD COLUMN discount INTEGER DEFAULT 0;" > \
  supabase/migrations/20260129120000_add_product_discount.sql

# 3. Apply
supabase db push

# 4. Sync endpoint update (sync.service.ts)
# requiredFields array-д 'discount' нэмэх

# 5. Schema test update
# schema-sync.test.ts: requiredFields.push('discount')

# 6. Test
cd backend && npm test -- schema-sync
```

### Mobile Changes

```dart
// 1. Drift table update (app_database.dart)
class Products extends Table {
  // ...
  IntColumn get discount => integer().withDefault(const Constant(0))();
}

// 2. Build runner
// dart run build_runner build --delete-conflicting-outputs

// 3. Sync pull logic (sync_queue_manager.dart)
Future<void> _upsertProduct(Map<String, dynamic> data) async {
  await db.into(db.products).insertOnConflictUpdate(
    ProductsCompanion.insert(
      // ...
      discount: Value(data['discount'] ?? 0),
    ),
  );
}

// 4. Schema test update (schema_sync_test.dart)
final backendProductData = {
  // ...
  'discount': 0,
};

// 5. Test
// flutter test test/core/sync/schema_sync_test.dart
```

### Testing

```bash
# Manual test:
1. Backend-с discount=15 бүхий бараа үүсгэх
2. Mobile app-аас pull sync
3. Verify: discount field харагдаж байна
4. Offline mode: Бараа үүсгэх (discount=20)
5. Online mode: Sync → Backend шалгах
```

---

## 🎯 Дүгнэлт

Schema changes нь **хоёр тал** (Backend + Mobile) хамт шинэчлэгдэх ёстой:

1. ✅ Backend migration → Mobile Drift update
2. ✅ Backend /changes endpoint → Mobile _upsert* functions
3. ✅ Backend tests → Mobile tests
4. ✅ Documentation бүгд шинэчлэгдэнэ

**Checklist дагаагүй schema changes = Production sync failure!**

Асуулт байвал: `/help` эсвэл team-д асуу.

---

**Сүүлд шинэчилсэн:** 2026-01-29
**Хувилбар:** 1.0
