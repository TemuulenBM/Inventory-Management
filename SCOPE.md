# Local Retail Control Platform - Төслийн Хүрээ

## Төслийн Зорилго

Монголын жижиг дэлгүүр, лангуу эзэмшигчдэд зориулсан **offline-first** бараа материал, борлуулалтын удирдлагын систем. POS систем, barcode scanner шаардахгүй - гар утсаар бүрэн удирдана.

---

## Зорилтот Платформ

| Платформ | Хувилбар | Тэмдэглэл |
|----------|----------|-----------|
| **Android** | 8.1+ (API 27+) | Primary |
| **iOS** | 12.0+ | Primary |

---

## Хэрэглэгчийн Дүрүүд (Actors)

| Дүр | Тайлбар | Эрх |
|-----|---------|-----|
| **Owner** | Дэлгүүр эзэмшигч (1-3 дэлгүүртэй) | Бүрэн хяналт, тохиргоо, тайлан |
| **Manager** | Менежер | Owner-той ижил, гэхдээ тохиргоо хязгаартай |
| **Seller** | Худалдагч / Касс | Борлуулалт, ээлж |
| **System** | Backend / Sync | Автомат сэрэмжлүүлэг, sync |

---

## MVP Функцууд (Must Have)

### 1. Бараа Бүртгэл (FR-01)
- Бараа үүсгэх: нэр, SKU, unit, үнэ, анхны үлдэгдэл
- Бараа засах, устгах (soft delete)
- Бараа хайх, шүүх

### 2. Үлдэгдлийн Тооцоолол (FR-02)
- **Event Sourcing pattern** - бүх өөрчлөлт event хэлбэрээр
- Event types: `INITIAL`, `SALE`, `ADJUST`, `RETURN`
- Одоогийн үлдэгдэл = SUM(qty_change)

### 3. Гар Засвар (FR-03)
- Owner/Manager үлдэгдэл гараар засах
- Шалтгаан заавал бичих
- Audit log-д бүртгэх

### 4. Түүх / Audit Log (FR-04)
- Бүх өөрчлөлт: хэн, хэзээ, юу, яагаад
- Шүүлт: огноо, бараа, хэрэглэгч

### 5. Quick Sale (FR-05)
- **≤3 алхам**: Бараа сонгох → Тоо → Баталгаажуулах
- Offline үед local-д хадгалах
- Shift-д холбогдох

### 6. Ээлж (FR-06, FR-07)
- Ээлж нээх/хаах
- Борлуулалт бүр seller_id, shift_id-тай
- Ээлжийн тайлан

### 7. Dashboard (FR-08)
- Өнөөдрийн нийт борлуулалт
- Бага үлдэгдэлтэй бараа
- Top борлуулалттай бараа
- Худалдагч тус бүрийн борлуулалт
- Last sync timestamp

### 8. Сэрэмжлүүлэг (FR-09)
- Бага үлдэгдэл (threshold тохируулах боломжтой)
- Сөрөг үлдэгдэл
- Сэжигтэй үйлдэл

### 9. Offline-First (FR-10)
- Интернэтгүй бүрэн ажиллах
- Local SQLite database
- Background sync (online болоход)

### 10. Conflict Resolution (FR-11)
- Last-writer-wins (default)
- Owner засвар > Seller борлуулалт
- Чухал conflict → гар шийдвэр

### 11. Нэвтрэлт (FR-12)
- Утасны дугаар + OTP
- Secure token storage

### 12. Эрхийн Хяналт (FR-13)
- Role-based: Owner > Manager > Seller
- Seller гар засвар хийх эрхгүй

### 13. Өгөгдлийн Нууцлал (FR-14)
- Local DB шифрлэлт (SQLCipher)
- TLS 1.2+ транспорт

### 14. Дэлгүүр Тохиргоо (FR-17)
- Валют (MNT)
- Цагийн бүс
- Бага үлдэгдлийн босго

### 15. Onboarding
- Дэлгүүр үүсгэх
- Эхний бараанууд нэмэх
- Худалдагч урих

---

## Post-MVP Функцууд (Nice to Have)

| Функц | Тайлбар | Priority |
|-------|---------|----------|
| Multi-store | Нэг owner олон дэлгүүр | Medium |
| CSV Import/Export | Бараа, борлуулалт экспорт | Medium |
| Returns/Void | Буцаалт, цуцлалт | Medium |
| Push notifications | Бага үлдэгдэл, ээлж сануулга | Medium |
| Online ordering | Захиалга хүлээн авах | Low |
| Cash reconciliation | Касс тооцоо | Low |
| Fine-grained permissions | Нарийн эрхийн тохиргоо | Low |

---

## Техникийн Stack

### Frontend (Flutter)
| Технологи | Зориулалт |
|-----------|-----------|
| Flutter 3.x | Cross-platform UI |
| Riverpod | State management |
| GoRouter | Navigation |
| Drift + SQLCipher | Local encrypted DB |
| Freezed | Immutable models |

### Backend (Supabase)
| Технологи | Зориулалт |
|-----------|-----------|
| Supabase Auth | Phone + OTP нэвтрэлт |
| Supabase PostgreSQL | Cloud database |
| Row Level Security | Data isolation |
| Supabase Realtime | Live updates |
| Edge Functions | Custom logic (хэрэгтэй бол) |

### Localization
- Монгол (mn) - Primary
- English (en) - Secondary

---

## Non-Functional Requirements

### Performance
| Шаардлага | Зорилт |
|-----------|--------|
| App cold start | < 4 секунд (2GB RAM төхөөрөмж) |
| UI response | < 1.5 секунд |
| Delta sync | < 5 секунд |
| Full sync | < 30 секунд (2000 бараа хүртэл) |
| Local storage | 6 сар / 10,000 event |

### Security
| Шаардлага | Хэрэгжүүлэлт |
|-----------|--------------|
| Transport | TLS 1.2+ |
| Data at rest | AES-256 (SQLCipher) |
| Token expiry | 30 хоног + refresh |
| RBAC | Role-based access control |

### Usability
| Шаардлага | Зорилт |
|-----------|--------|
| Sale flow | ≤ 3 алхам |
| Add product | ≤ 3 дэлгэц |
| Language | Монгол primary |

---

## Data Model (Товч)

```
Store
├── id, owner_id, name, location, timezone

User
├── id, store_id, name, phone, role (owner/manager/seller)

Product
├── id, store_id, name, sku, unit, sell_price, cost_price, low_stock_threshold

InventoryEvent (Event Sourcing)
├── id, store_id, product_id, type, qty_change, actor_id, shift_id, reason, timestamp

Sale
├── id, store_id, seller_id, shift_id, total_amount, payment_method, timestamp

SaleItem
├── id, sale_id, product_id, quantity, unit_price, subtotal

Shift
├── id, store_id, seller_id, opened_at, closed_at, open_balance, close_balance

Alert
├── id, store_id, type, product_id, message, level, resolved

SyncQueue (Local only)
├── id, entity_type, operation, payload, synced, retry_count
```

---

## Success Metrics

| Metric | Зорилт |
|--------|--------|
| Daily Active Sellers | 70% (эхний сард) |
| Owner dashboard check | ≥1 удаа/өдөр |
| Time per sale | < 10 секунд |
| Sync conflicts | < 1% гар шийдвэр |
| Stock loss detection | Тодорхой бууралт (3 сарын дараа) |

---

## Roadmap

| Үе шат | Хугацаа | Зорилт |
|--------|---------|--------|
| **Pilot** | 0-3 сар | MVP, гэр бүлийн дэлгүүрт туршилт |
| **Expand** | 3-9 сар | Орон нутаг, CSV, multi-store |
| **Online** | 9-15 сар | Online захиалга |
| **Scale** | 15-24 сар | Logistics, marketplace |

---

## Эрсдэл & Шийдэл

| Эрсдэл | Шийдэл |
|--------|--------|
| Offline multi-device conflict | Event ordering + merge UI |
| Хэрэглэгч дасахгүй байх | ≤3 алхам, time-to-sale хэмжих |
| Өгөгдөл итгэхгүй байх | Audit trail + rollback + loss report |

---

*Сүүлд шинэчлэгдсэн: 2026-01-20*
