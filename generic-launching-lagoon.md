# Sprint 8 — 4 Feature Хэрэгжүүлэлтийн Төлөвлөгөө

## Хэрэгжүүлэх дараалал

1. **Settings screen** (бие даасан, template тогтоох)
2. **Alerts list screen** (бие даасан, dashboard link бэлэн)
3. **Shift management UI** (бие даасан, checkout-д dependency)
4. **Checkout flow UI** (shift provider дээр суурилсан)

---

## Feature 1: Settings Screen

### Шинэ файлууд
- `lib/features/settings/presentation/screens/settings_screen.dart`
- `lib/features/settings/presentation/widgets/settings_section.dart`

### Засварлах файлууд
- `lib/core/routing/app_router.dart` — SettingsScreen import-г шинэ файл руу солих
- `lib/core/routing/placeholder_screens.dart` — SettingsScreen class устгах

### Бүтэц
- Profile section: CircleAvatar + нэр + утас + role badge
- Дэлгүүрийн мэдээлэл: нэр, байршил (read-only)
- Аппын тохиргоо: Ээлж > , Сэрэмжлүүлэг > , Синк >
- Logout товч: `ConfirmDialog` → `AuthNotifier.signOut()` → authPhone

### Provider холболт
- `ref.watch(currentUserProvider)` — UserModel
- `ref.watch(storeIdProvider)` — store ID
- `ref.read(authNotifierProvider.notifier).signOut()` — logout

---

## Feature 2: Alerts List Screen

### Шинэ файлууд
- `lib/features/alerts/presentation/screens/alerts_screen.dart`

### Засварлах файлууд
- `lib/core/routing/app_router.dart` — AlertsCenterScreen import солих
- `lib/core/routing/placeholder_screens.dart` — AlertsCenterScreen class устгах

### Бүтэц
- Filter chips: AlertType enum (lowStock, negativeStock, expiringSoon, priceChange, syncConflict, systemIssue)
- Alert card list: `AlertCard` widget reuse, type icon + message + severity badge + timestamp
- Actions: Шийдвэрлэх (resolve), Хаах (dismiss)
- Empty state: Сэрэмжлүүлэг байхгүй
- Pull-to-refresh

### Provider холболт
- `ref.watch(alertListProvider(typeFilter:, severityFilter:, unresolvedOnly:))` — filtered list
- `ref.watch(unreadAlertCountProvider(storeId))` — badge тоо
- `ref.read(alertActionsProvider.notifier).resolve()` / `.dismiss()`

### Анхаарах
- `AlertCard` widget дотор тусдаа `AlertSeverity` enum байгаа → domain model-ийн enum-тай mapping функц хэрэгтэй

---

## Feature 3: Shift Management UI

### Шинэ файлууд
- `lib/features/shifts/presentation/screens/shift_management_screen.dart`
- `lib/features/shifts/presentation/widgets/active_shift_card.dart`
- `lib/features/shifts/presentation/widgets/open_shift_dialog.dart`
- `lib/features/shifts/presentation/widgets/close_shift_dialog.dart`

### Засварлах файлууд
- `lib/core/routing/app_router.dart` — ShiftManagementScreen import солих
- `lib/core/routing/placeholder_screens.dart` — ShiftManagementScreen class устгах

### Бүтэц
- Active shift hero card: teal border, seller name, duration (live timer), totalSales, transactionCount
- Ээлж нээгдээгүй бол: "Ээлж нээх" товч → OpenShiftDialog (optional notes input)
- Ээлж байгаа бол: "Ээлж хаах" товч → CloseShiftDialog (summary + confirm)
- Shift history section: `ShiftCard` widget reuse, жагсаалт

### Provider холболт
- `ref.watch(currentShiftProvider(storeId))` — active shift (AsyncValue<ShiftModel?>)
- `ref.watch(shiftHistoryProvider(storeId))` — түүх (AsyncValue<List<ShiftModel>>)
- `ref.read(shiftActionsProvider.notifier).openShift()` / `.closeShift(shiftId:)`

---

## Feature 4: Checkout Flow UI

### Засварлах файлууд
- `lib/features/sales/presentation/screens/cart_screen.dart` — "Төлөх" товчны onTap холбох

### Хийх зүйлс
Cart screen дээр `_showCheckoutSheet()` нэмэх:
1. "Төлөх" товч → `PaymentBottomSheet` харуулах (widget аль хэдийн `bottom_action_sheet.dart`-д бэлэн)
2. Төлбөрийн хэлбэр сонгох (cash/card)
3. "Баталгаажуулах" → `CheckoutActions.checkout(paymentMethod:)` дуудах
4. Амжилттай → `SuccessDialog` + navigate back to QuickSaleSelect
5. Алдаа → `ErrorDialog`

### Provider холболт
- `ref.read(checkoutActionsProvider.notifier).checkout(paymentMethod:)` — checkout
- `ref.watch(cartTotalProvider)` — нийт дүн
- `ref.watch(cartItemCountProvider)` — тоо
- `ref.read(cartNotifierProvider.notifier).updateQuantity()` / `.removeProduct()` / `.clear()`

### Navigation flow
QuickSaleSelect → Cart → [Төлөх] → PaymentBottomSheet → [Баталгаажуулах] → SuccessDialog → QuickSaleSelect

---

## Нэгдсэн тэмдэглэл

- **build_runner ажиллуулах шаардлагагүй** — шинэ @riverpod/@freezed файл нэмэхгүй, бүх providers аль хэдийн code-gen хийгдсэн
- `placeholder_screens.dart`-д зөвхөн `SyncConflictsScreen` placeholder үлдэнэ
- Reuse хийх бэлэн widgets: `AlertCard`, `ShiftCard`, `ConfirmDialog`, `SuccessDialog`, `ErrorDialog`, `PaymentBottomSheet`, `PrimaryButton`

## Баталгаажуулалт (Verification)

1. Settings → Profile, store info харагдаж байгаа, Logout ажиллаж байгаа
2. Alerts → Filter chips, alert cards, resolve/dismiss ажиллаж байгаа
3. Shifts → Ээлж нээх/хаах, active shift card, history харагдаж байгаа
4. Checkout → Төлөх → PaymentBottomSheet → Success → QuickSaleSelect
5. `flutter analyze` — Error байхгүй
