# Postman Collection Guide

Энэхүү заавар нь Local Retail Control Platform API-г Postman ашиглан тест хийх аргыг тайлбарлана.

---

## 1. Collection Import хийх

1. Postman-г нээх
2. **Import** товчийг дарах
3. `postman_collection.json` файлыг сонгох эсвэл drag & drop хийх
4. Collection амжилттай import хийгдэнэ

---

## 2. Environment Variables

Collection-д дараах хувьсагчид автоматаар тохируулагдана:

| Variable | Default Value | Description |
|----------|---------------|-------------|
| `base_url` | `http://localhost:3000` | API server URL |
| `access_token` | (empty) | JWT access token (auto-populated) |
| `refresh_token` | (empty) | JWT refresh token (auto-populated) |
| `store_id` | (empty) | Store ID (auto-populated) |
| `user_id` | (empty) | User ID (auto-populated) |
| `product_id` | (empty) | Product ID (auto-populated) |

**Анхааруулга:** Variables-ууд нь автоматаар populate хийгдэнэ (test scripts-аар), гараар оруулах шаардлагагүй.

---

## 3. Authentication Flow (Зөвлөмж)

### Step 1: Request OTP
1. **Auth** folder-оос **Request OTP** request-г нээх
2. Body-д утасны дугаар оруулах (Mongolian format: `+976XXXXXXXX`)
3. **Send** дарах
4. Terminal/Console-оос OTP код-г харах (development mode-д)

```json
{
  "phone": "+97699119911"
}
```

### Step 2: Verify OTP
1. **Verify OTP** request-г нээх
2. Body-д phone болон OTP код оруулах
3. **Send** дарах
4. `access_token`, `refresh_token`, `store_id`, `user_id` автоматаар collection variables-д хадгалагдана

```json
{
  "phone": "+97699119911",
  "otp": "123456"
}
```

### Step 3: Use Protected Endpoints
JWT token автоматаар бүх request-д Bearer token-аар нэмэгдэнэ. Одоо та бүх endpoints-ийг ашиглаж болно!

---

## 4. Typical Workflow

### A. Store Setup
1. ✅ **Create Store** - Шинэ дэлгүүр үүсгэх (эсвэл OTP verify-с store_id авах)
2. ✅ **Get Store** - Store мэдээлэл шалгах

### B. Product Management
1. ✅ **Create Product** - Шинэ бараа нэмэх (product_id автоматаар хадгалагдана)
2. ✅ **Create Inventory Event** - Эхлэх үлдэгдэл оруулах (INITIAL event)
3. ✅ **List Products** - Барааны жагсаалт харах
4. ✅ **Get Stock Levels** - Бүх барааны үлдэгдэл харах

### C. Sales Flow
1. ✅ **Open Shift** - Ээлж нээх
2. ✅ **Get Active Shift** - Идэвхтэй ээлж шалгах
3. ✅ **Create Sale** - Борлуулалт бүртгэх
4. ✅ **List Sales** - Борлуулалтын түүх харах
5. ✅ **Close Shift** - Ээлж хаах

### D. Reports
1. ✅ **Daily Report** - Өдрийн тайлан
2. ✅ **Top Products** - Шилдэг барааны жагсаалт
3. ✅ **Seller Performance** - Худалдагчийн үзүүлэлт

### E. Alerts
1. ✅ **List Alerts** - Сэрэмжлүүлэг харах (low stock, negative inventory)
2. ✅ **Resolve Alert** - Шийдвэрлэх

---

## 5. Auto-populated Variables

Дараах requests-ууд автоматаар variables-ийг populate хийнэ:

| Request | Auto-populates |
|---------|----------------|
| Verify OTP | `access_token`, `refresh_token`, `store_id`, `user_id` |
| Refresh Token | `access_token` |
| Create Store | `store_id` |
| Create Product | `product_id` |

Test scripts-ийн жишээ:
```javascript
const response = pm.response.json();
if (response.success && response.accessToken) {
  pm.collectionVariables.set('access_token', response.accessToken);
}
```

---

## 6. Query Parameters

Олон endpoints-д query parameters байдаг:

### Pagination
```
?page=1&limit=20
?offset=0&limit=20
```

### Filters
```
?search=coca
?lowStock=true
?payment_method=cash
?alert_type=low_stock
?resolved=false
```

### Date Ranges
```
?from=2026-01-01&to=2026-01-31
?date=2026-01-21
?since=2026-01-21T00:00:00Z
```

---

## 7. Common Request Bodies

### Create Sale
```json
{
  "items": [
    {
      "product_id": "{{product_id}}",
      "quantity": 2,
      "unit_price": 2500
    }
  ],
  "payment_method": "cash"
}
```

### Create Inventory Event
```json
{
  "productId": "{{product_id}}",
  "eventType": "INITIAL",
  "qtyChange": 100,
  "reason": "Анхны үлдэгдэл"
}
```

### Batch Sync
```json
{
  "device_id": "mobile-device-123",
  "operations": [
    {
      "operation_type": "create_sale",
      "client_id": "client-sale-001",
      "client_timestamp": "2026-01-21T10:00:00Z",
      "data": {
        "items": [
          {
            "product_id": "{{product_id}}",
            "quantity": 1,
            "unit_price": 2500
          }
        ],
        "payment_method": "cash"
      }
    }
  ]
}
```

---

## 8. Error Handling

API нь дараах error format ашигладаг:

```json
{
  "statusCode": 400,
  "error": "Bad Request",
  "message": "Бараа олдсонгүй"
}
```

Common HTTP Status Codes:
- `200` - Success
- `201` - Created
- `400` - Bad Request (validation error)
- `401` - Unauthorized (token шаардлагатай)
- `403` - Forbidden (эрхгүй)
- `404` - Not Found
- `500` - Internal Server Error

---

## 9. Tips & Tricks

### Tip 1: Use Environment for Multiple Servers
Production server ашиглах бол `base_url` variable-г өөрчлөх:
```
https://api.retailcontrol.mn
```

### Tip 2: Console Logging
Terminal дээр server logs харах:
```bash
npm run dev
```

OTP codes, inventory events, зэрэг мэдээлэл console-д харагдана.

### Tip 3: Test Multiple Scenarios
Folders доторх бүх requests-ийг нэг дор ажиллуулах:
1. Folder дээр right-click
2. **Run folder** сонгох
3. Collection Runner нээгдэнэ

### Tip 4: Pre-request Scripts
Өөрийн pre-request scripts нэмэх боломжтой (timestamp generate гэх мэт).

---

## 10. Troubleshooting

### Problem: 401 Unauthorized
**Solution:** Access token дууссан байж болно. Refresh Token request ажиллуулах эсвэл дахин OTP verify хийх.

### Problem: Variables not populating
**Solution:** Request-ийн "Tests" tab-г шалгах, test scripts ажиллаж байгаа эсэхийг харах.

### Problem: Store ID missing
**Solution:** Create Store эсвэл Verify OTP request эхлээд ажиллуулах.

### Problem: Product ID missing
**Solution:** Create Product request эхлээд ажиллуулах.

---

## 11. API Documentation

Илүү дэлгэрэнгүй мэдээлэл:
- **Swagger UI:** http://localhost:3000/docs
- **API Summary:** [API_SUMMARY.md](./API_SUMMARY.md)

---

*Happy Testing! 🚀*
