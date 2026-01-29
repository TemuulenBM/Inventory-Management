# Pull Request

## 📝 Өөрчлөлтүүд (Changes)

<!-- Өөрийн өөрчлөлтүүдийг энд дэлгэрэнгүй тайлбарлах -->

**Юу хийсэн:**
-

**Яагаад хийсэн:**
-

**Хэрхэн шийдсэн:**
-

---

## ⚠️ Schema Changes Checklist

<!-- Хэрэв database schema эсвэл API response format өөрчлөгдсөн бол энэ хэсгийг бөглө -->

**Schema өөрчлөлт байна уу?** (database column, API response field гэх мэт)

- [ ] **Тийм** - Дараах checklist-ийг БӨГЛӨНӨ ҮҮ
- [ ] **Үгүй** - Энэ хэсгийг skip хий

---

### 🔴 Backend Changes (Тийм гэж сонгосон бол)

- [ ] **Supabase migration файл** үүсгэсэн
  - Файл: `supabase/migrations/YYYYMMDDHHMMSS_description.sql`
  - Migration apply хийгдсэн: `supabase db push`

- [ ] **Backend sync endpoints** update хийсэн
  - Файл: `backend/src/modules/sync/sync.service.ts`
  - `/stores/:storeId/changes` endpoint шинэ field буцааж байна

- [ ] **Zod schemas** update хийсэн
  - Файл: `backend/src/modules/*/schemas.ts`
  - Validation schemas шинэчлэгдсэн

- [ ] **Schema validation test** update хийсэн
  - Файл: `backend/tests/integration/schema-sync.test.ts`
  - `requiredFields` array шинэчлэгдсэн
  - Test ажиллаж байна: `npm test -- schema-sync.test.ts` ✅

---

### 📱 Mobile Changes (Тийм гэж сонгосон бол)

- [ ] **Drift tables** update хийсэн
  - Файл: `lib/core/database/app_database.dart`
  - Table definition шинэчлэгдсэн

- [ ] **Build runner** ажиллуулсан
  ```bash
  dart run build_runner build --delete-conflicting-outputs
  ```

- [ ] **Sync pull logic** update хийсэн
  - Файл: `lib/core/sync/sync_queue_manager.dart`
  - `_upsert*()` functions шинэ field handle хийж байна

- [ ] **Sync push logic** update хийсэн (хэрэв create/update operation бол)
  - Payload fields шинэчлэгдсэн

- [ ] **Schema test** update хийсэн
  - Файл: `test/core/sync/schema_sync_test.dart`
  - Sample backend data шинэчлэгдсэн
  - Test ажиллаж байна: `flutter test test/core/sync/schema_sync_test.dart` ✅

---

### 🧪 Testing

- [ ] **Unit tests PASS** хийсэн
  - Backend: `npm test` ✅
  - Mobile: `flutter test` ✅

- [ ] **Integration tests PASS** хийсэн (хэрэв байвал)
  - Multi-device sync scenario
  - Offline → Online flow

- [ ] **Manual testing** хийгдсэн
  - Device A: Шинэ field бүхий өгөгдөл үүсгэх → Sync
  - Device B: Pull → Шинэ field харагдаж байна ✅
  - Offline mode: Operation хийх → Online болох → Sync ✅

- [ ] **Manual testing screenshots/video** байгаа (optional)
  <!-- Screenshots энд оруулах -->

---

### 📚 Documentation

- [ ] **CLAUDE.md** update хийсэн
  - Database Tables section шинэчлэгдсэн
  - Schema Change History нэмсэн

- [ ] **Migration README** update хийсэн
  - `supabase/migrations/README.md` шинэчлэгдсэн

- [ ] **API docs** update хийсэн (хэрэв байвал)
  - Swagger/Postman collections

---

## 🚨 Breaking Changes

<!-- Хэрэв breaking change байвал дэлгэрэнгүй тайлбарла -->

**Breaking change байна уу?**

- [ ] **Тийм** - Доорх мэдээллийг бөглө
- [ ] **Үгүй**

**Breaking change тайлбар:**
<!-- Column устгасан, rename хийсэн, incompatible type change гэх мэт -->

**Migration strategy:**
<!-- Хэрхэн deploy хийх вэ? Multi-step approach шаардлагатай юу? -->

**Rollback plan:**
<!-- Хэрэв асуудал гарвал хэрхэн буцаах вэ? -->

---

## 🔗 Related Issues

<!-- GitHub issue links -->
Closes #

---

## 📸 Screenshots/Videos (optional)

<!-- Screenshots эсвэл screen recordings энд оруулах -->

---

## ✅ Reviewer Checklist

**Merge хийхээс өмнө reviewer шалгах:**

- [ ] Code quality сайн байна (clean code, no unnecessary changes)
- [ ] Schema changes **хоёр талд** хийгдсэн (backend + mobile)
- [ ] Tests **PASS** хийсэн (CI/CD green) ✅
- [ ] Manual testing хийгдсэн эсвэл screenshots байгаа
- [ ] Documentation update хийгдсэн
- [ ] Breaking changes тодорхой тэмдэглэгдсэн (хэрэв байвал)
- [ ] Rollback plan бичигдсэн (хэрэв breaking change бол)

---

## 📚 Reference

- [Schema Change Checklist](../SCHEMA_CHANGE_CHECKLIST.md)
- [CLAUDE.md](../CLAUDE.md)

---

**АНХААР:** Schema өөрчлөлт хийх үед SCHEMA_CHANGE_CHECKLIST.md-г заавал дагаж мөрдөнө үү! Schema mismatch нь production sync failure үүсгэнэ.
