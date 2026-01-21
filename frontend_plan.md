# Sprint 7: Frontend Implementation Plan
**Material 3 + Utility Styling System**

## Хураангуй

Sprint 7-д дизайн файлууд дээр үндэслэн Flutter app-ийн бүрэн frontend-ийг хөгжүүлнэ. Одоогоор database ба localization бэлэн, гэхдээ UI/UX хэрэгжээгүй байна. 10 дэлгэц (HTML + PNG design exports), Material 3 theme, utility-based styling system үүсгэж, Riverpod state management ашиглан app-ийг бүрэн ажиллагаатай болгоно.

---

## Судалгааны Үр Дүн

### ✅ Бэлэн Байгаа Зүйлс
- **Database**: Drift schema бүрэн (9 tables, event sourcing queries)
- **Backend API**: Node.js/Fastify (auth, sales, inventory, shifts, alerts endpoints)
- **Localization**: Англи + Монгол ARB файлууд гүйцэд
- **Dependencies**: Riverpod, Drift, Supabase, Shimmer гэх мэт гол packages суусан
- **Folder Structure**: Feature-based architecture бэлэн (auth/, dashboard/, sales/, inventory/, shifts/, alerts/)

### 🎨 Дизайн System (10 дэлгэц)

**Screens:**
1. Splash & Init Screen
2. Auth Phone & OTP
3. Owner Dashboard
4. Quick Sale - Product Selection (grid)
5. Quick Sale - Cart
6. Product Detail View
7. Alerts Center
8. Shift Management
9. Sync & Conflict Center

**Color Palette:**
- Primary: `#c2755b` (terracotta/rust)
- Success: `#00878F` (teal)
- Warning: `#E0A63B`
- Danger: `#AF4D4D`
- Background Light: `#fbfaf9`
- Background Dark: `#1d2025`

**Typography:**
- Display: Epilogue (weights 400-900)
- Body: Noto Sans + Noto Sans Mongolian

**Visual Effects:**
- Glass morphism (backdrop blur 12px)
- Soft shadows: `0 4px 20px -2px rgba(194,117,91,0.1)`
- Border radius: 8px - 32px
- Animations: shimmer, pulse, fade-in-up

### ❌ Үүсгэх Шаардлагатай

1. GoRouter (navigation) - одоогоор байхгүй
2. Dio (HTTP client) - одоогоор байхгүй
3. Theme system (Material 3 customization)
4. Design tokens (Dart constants)
5. 25+ reusable UI components
6. 12+ Riverpod providers
7. 9 main screens
8. Utility styling helpers (Tailwind-like)

---

## Хэрэгжүүлэлтийн Төлөвлөгөө

**Стратеги:** Foundation → Components → State → Screens → Polish

### 📅 Үе Шат 1: Foundation (Суурь) - 1-2 хоног

**Зорилго:** Dependencies, theme system, routing-г бэлтгэх.

#### 1.1 Dependencies нэмэх

**Файл:** [pubspec.yaml](pubspec.yaml)

```yaml
dependencies:
  go_router: ^14.0.0
  dio: ^5.4.0
  flutter_svg: ^2.0.10
  flutter_animate: ^4.5.0  # Хялбар API, declarative syntax
```

**Font Setup:**
- Download Epilogue fonts (weights 400-900) from Google Fonts
- Download Noto Sans + Noto Sans Mongolian (weights 400-700)
- Add to `assets/fonts/` directory
- Configure in pubspec.yaml:
```yaml
fonts:
  - family: Epilogue
    fonts:
      - asset: assets/fonts/Epilogue-Regular.ttf
      - asset: assets/fonts/Epilogue-Medium.ttf
        weight: 500
      - asset: assets/fonts/Epilogue-SemiBold.ttf
        weight: 600
      - asset: assets/fonts/Epilogue-Bold.ttf
        weight: 700
      - asset: assets/fonts/Epilogue-ExtraBold.ttf
        weight: 800
      - asset: assets/fonts/Epilogue-Black.ttf
        weight: 900
  - family: Noto Sans
    fonts:
      - asset: assets/fonts/NotoSans-Regular.ttf
      - asset: assets/fonts/NotoSans-Medium.ttf
        weight: 500
      - asset: assets/fonts/NotoSans-SemiBold.ttf
        weight: 600
      - asset: assets/fonts/NotoSans-Bold.ttf
        weight: 700
  - family: Noto Sans Mongolian
    fonts:
      - asset: assets/fonts/NotoSansMongolian-Regular.ttf
      - asset: assets/fonts/NotoSansMongolian-Medium.ttf
        weight: 500
      - asset: assets/fonts/NotoSansMongolian-SemiBold.ttf
        weight: 600
      - asset: assets/fonts/NotoSansMongolian-Bold.ttf
        weight: 700
```

**Команд:**
```bash
flutter pub get
```

#### 1.2 Design Token Constants

**Үүсгэх файлууд:**

1. **`lib/core/constants/app_colors.dart`**
   - Бүх өнгө (primary, success, warning, danger, backgrounds, text colors)
   - Light/dark mode variants

2. **`lib/core/constants/app_spacing.dart`**
   - Tailwind-style spacing system (xs=4, sm=8, md=16, lg=24, xl=32, xxl=48)
   - Padding presets (EdgeInsets.all variants)

3. **`lib/core/constants/app_radius.dart`**
   - Border radius constants (xs=4, sm=8, md=12, lg=16, xl=24, xxl=32)
   - BorderRadius presets

**Жишээ:**
```dart
// app_colors.dart
class AppColors {
  static const primary = Color(0xFFC2755B);
  static const success = Color(0xFF00878F);
  static const backgroundLight = Color(0xFFFBFAF9);
  // ... 20+ colors
}
```

#### 1.3 Material 3 Theme System

**Үүсгэх файлууд:**

1. **`lib/core/theme/color_scheme.dart`**
   - `lightColorScheme` (Material 3 ColorScheme with design colors)
   - `darkColorScheme`

2. **`lib/core/theme/text_theme.dart`**
   - Custom TextTheme (Epilogue for display, Noto Sans for body)
   - Font weights, sizes, letter spacing

3. **`lib/core/theme/component_themes.dart`**
   - ElevatedButtonTheme (primary color, rounded corners)
   - CardTheme (glass effect ready)
   - InputDecorationTheme (form styling)
   - AppBarTheme, BottomNavigationBarTheme

4. **`lib/core/theme/app_theme.dart`**
   - `AppTheme.light` (combines all themes)
   - `AppTheme.dark`

#### 1.4 Utility Helpers

**Үүсгэх файлууд:**

1. **`lib/core/utils/style_helpers.dart`**
   - `AppShadows` class (soft, glass, glow shadows)
   - `AppGradients` class (warmGlow, etc.)
   - `glassDecoration()` function (glassmorphism helper)
   - BuildContext extensions (`context.theme`, `context.spacing`)

2. **`lib/core/utils/screen_util.dart`** (Custom ScreenUtil - Recommended)
   - `isSmallScreen()` - width < 360
   - `isTablet()` - width >= 600
   - `screenWidth()`, `screenHeight()`
   - Extension methods for responsive sizing

**Жишээ:**
```dart
// Glassmorphism helper
BoxDecoration glassDecoration({double blur = 12}) {
  return BoxDecoration(
    color: Colors.white.withOpacity(0.7),
    borderRadius: BorderRadius.circular(AppRadius.lg),
    border: Border.all(color: Colors.white.withOpacity(0.5)),
    boxShadow: [AppShadows.glass],
  );
}
```

#### 1.5 Navigation (GoRouter)

**Үүсгэх файлууд:**

1. **`lib/core/routing/app_router.dart`**
   - GoRouter configuration with routes:
     - `/splash` → SplashScreen
     - `/auth/phone` → PhoneAuthScreen
     - `/auth/otp` → OtpScreen
     - `/dashboard` → DashboardScreen
     - `/sales` → QuickSaleSelectScreen
     - `/sales/cart` → QuickSaleCartScreen
     - `/product/:id` → ProductDetailScreen
     - `/alerts` → AlertsCenterScreen
     - `/shifts` → ShiftManagementScreen
   - Auth guard redirect logic

2. **`lib/core/routing/route_names.dart`**
   - Route constant strings

#### 1.6 Update main.dart

**Өөрчлөх файл:** [lib/main.dart](lib/main.dart)

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseClientManager.initialize();

  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Retail Control Platform',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      routerConfig: goRouter,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
    );
  }
}
```

**Баталгаажуулалт:**
- `flutter run` ажиллах
- Material 3 theme харагдах (terracotta primary color)
- Navigation бэлэн (screens хараахан байхгүй ч routes defined)

---

### 📅 Үе Шат 2: Core Components - 2-3 хоног

**Зорилго:** Дахин ашиглагдах 25+ UI components үүсгэх.

#### 2.1 Layout Components (3 widgets)

1. **`lib/core/widgets/layout/app_scaffold.dart`**
   - Standard scaffold with safe area, optional bottom nav

2. **`lib/core/widgets/layout/glass_panel.dart`**
   - Glassmorphism container (blur, border, shadow)

3. **`lib/core/widgets/layout/responsive_layout.dart`**
   - Mobile/tablet switcher, grid helpers

#### 2.2 Button Components (4 widgets)

1. **`lib/core/widgets/buttons/primary_button.dart`**
   - Primary color, rounded, shadow, loading state

2. **`lib/core/widgets/buttons/secondary_button.dart`**
   - Outlined style

3. **`lib/core/widgets/buttons/icon_button_custom.dart`**
   - Rounded, glass background option

4. **`lib/core/widgets/buttons/floating_action_button_custom.dart`**
   - Large FAB with shimmer effect

#### 2.3 Input Components (4 widgets)

1. **`lib/core/widgets/inputs/phone_input.dart`**
   - +976 prefix in separate section
   - Large input field, glass card

2. **`lib/core/widgets/inputs/otp_input.dart`**
   - 6 individual digit boxes, auto-focus

3. **`lib/core/widgets/inputs/search_field.dart`**
   - Search icon, glass background, clear button

4. **`lib/core/widgets/inputs/quantity_selector.dart`**
   - [-] [12] [+] buttons

#### 2.4 Card Components (5 widgets)

1. **`lib/core/widgets/cards/glass_card.dart`**
   - Generic glass container

2. **`lib/core/widgets/cards/product_card.dart`**
   - Image, name, price, stock badge, add button
   - 2-column grid size

3. **`lib/core/widgets/cards/alert_card.dart`**
   - Severity-colored left border, icon, text

4. **`lib/core/widgets/cards/shift_card.dart`**
   - Seller, date, time range, sales total

5. **`lib/core/widgets/cards/cart_item_card.dart`**
   - Product image, name, quantity selector, subtotal, delete

#### 2.5 Indicator Components (4 widgets)

1. **`lib/core/widgets/indicators/sync_status_badge.dart`**
   - Green "Synced" or Red "Offline" with pulse animation

2. **`lib/core/widgets/indicators/stock_level_badge.dart`**
   - Color based on threshold (green/orange/red)

3. **`lib/core/widgets/indicators/online_indicator.dart`**
   - Animated pulsing dot

4. **`lib/core/widgets/indicators/loading_shimmer.dart`**
   - Product card shimmer, list item shimmer

#### 2.6 Modal Components (3 widgets)

1. **`lib/core/widgets/modals/bottom_action_sheet.dart`**
   - Glass modal from bottom, drag handle

2. **`lib/core/widgets/modals/confirm_dialog.dart`**
   - Title, message, cancel/confirm buttons, danger variant

3. **`lib/core/widgets/modals/keypad_modal.dart`**
   - Numeric keypad for quantity input

**Баталгаажуулалт:**
- Test screen үүсгэж component бүрийг харах
- Light/dark mode дээр зөв харагдах

---

### 📅 Үе Шат 3: State Management - 2 хоног

**Зорилго:** Riverpod providers үүсгэж business logic салгах.

#### 3.1 Auth State

**Файлууд:**

1. **`lib/features/auth/domain/auth_state.dart`** (Freezed)
   - States: initial, loading, authenticated, unauthenticated, error

2. **`lib/features/auth/presentation/providers/auth_provider.dart`**
   - `@riverpod class AuthNotifier`
   - Methods: `sendOtp()`, `verifyOtp()`, `signOut()`
   - `authStateChanges` stream provider

#### 3.2 Product State

**Файлууд:**

1. **`lib/features/inventory/domain/product_with_stock.dart`** (Freezed)
   - Model: id, name, sku, sellPrice, stockQuantity, isLowStock, imageUrl

2. **`lib/features/inventory/presentation/providers/product_provider.dart`**
   - `productList(searchQuery, category)` - List with filters
   - `productDetail(id)` - Single product

#### 3.3 Cart State

**Файлууд:**

1. **`lib/features/sales/domain/cart_item.dart`** (Freezed)
   - Model: product, quantity, subtotal getter

2. **`lib/features/sales/presentation/providers/cart_provider.dart`**
   - `@riverpod class CartNotifier`
   - Methods: `addProduct()`, `updateQuantity()`, `removeProduct()`, `clear()`
   - Computed: `cartTotal`, `cartItemCount`

#### 3.4 Shift State

**Файлууд:**

1. **`lib/features/shifts/domain/shift_model.dart`** (Freezed)

2. **`lib/features/shifts/presentation/providers/shift_provider.dart`**
   - `currentShift` - Active shift
   - `shiftHistory` - Past shifts

#### 3.5 Alert State

**Файлууд:**

1. **`lib/features/alerts/domain/alert_model.dart`** (Freezed)

2. **`lib/features/alerts/presentation/providers/alert_provider.dart`**
   - `alertList(filter)` - Filtered alerts
   - `unreadAlertCount` - Badge number

#### 3.6 Sync State

**Файлууд:**

1. **`lib/core/sync/sync_state.dart`** (Freezed)

2. **`lib/core/sync/sync_provider.dart`**
   - `@riverpod class SyncNotifier`
   - Methods: `sync()`, `updateOnlineStatus()`

**Баталгаажуулалт:**
```bash
dart run build_runner build --delete-conflicting-outputs
flutter analyze
```

---

### 📅 Үе Шат 4: Screen Implementation - 4-5 хоног

**Зорилго:** 9 үндсэн дэлгэцийг дизайн файлууд дээр үндэслэн хөгжүүлэх.

**Дараалал:** Splash → Auth → Dashboard → Sales → Support screens

#### 4.1 Splash & Init Screen

**Файл:** `lib/features/onboarding/presentation/screens/splash_screen.dart`

**Агуулга:**
- Glass logo container
- App title with primary accent
- Loading progress bar + shimmer
- Gradient background

**Логик:**
- DB initialization check
- Auth state check → navigate

**Design Ref:** `/design/splash_&_init_screen/` (HTML ба PNG зөвхөн reference болгон харна)

#### 4.2 Phone Auth Screen

**Файл:** `lib/features/auth/presentation/screens/phone_auth_screen.dart`

**Агуулга:**
- Gradient blobs decoration
- App logo + "Тавтай морил"
- PhoneInput widget
- "Энэ төхөөрөмжид итгэх" checkbox
- Primary "Үргэлжлүүлэх" button

**Providers:** `authNotifierProvider.sendOtp()`

**Design Ref:** `/design/auth_phone_&_otp/`

#### 4.3 OTP Screen

**Файл:** `lib/features/auth/presentation/screens/otp_screen.dart`

**Агуулга:**
- Timer countdown (59s)
- OtpInput widget (6 boxes)
- Phone number display
- Verify button
- Resend link

**Providers:** `authNotifierProvider.verifyOtp()`

**Design Ref:** `/design/auth_phone_&_otp/`

#### 4.4 Owner Dashboard

**Файл:** `lib/features/dashboard/presentation/screens/dashboard_screen.dart`

**Агуулга:**
- Header: Time + greeting + SyncStatusBadge
- Hero card: Today's sales (glass, sparkline, +12% badge)
- Low stock alerts (3 items + "Бүгдийг харах")
- Top products carousel
- FAB: "Шинэ борлуулалт"

**Providers:** `todaySalesProvider`, `lowStockAlertsProvider`, `topProductsProvider`

**Design Ref:** `/design/owner_dashboard/`

#### 4.5 Quick Sale - Product Selection

**Файл:** `lib/features/sales/presentation/screens/quick_sale_select_screen.dart`

**Агуулга:**
- App bar: Title + sync badge + barcode button
- SearchField
- Category pills
- Tabs: Онцлох / Сүүлд
- Product grid (2 columns, ProductCard)

**Providers:** `productListProvider`, `cartNotifierProvider.addProduct()`

**Design Ref:** `/design/quick_sale_select/`

#### 4.6 Quick Sale - Cart

**Файл:** `lib/features/sales/presentation/screens/quick_sale_cart_screen.dart`

**Агуулга:**
- Cart items list (CartItemCard + QuantitySelector)
- Empty state
- Bottom sheet (glass):
  - Subtotal
  - Payment method (Cash/Card/QR)
  - Total (large)
  - "Төлбөр баталгаажуулах" button

**Providers:** `cartNotifierProvider`, `cartTotalProvider`

**Design Ref:** `/design/quick_sale_cart/`

#### 4.7 Product Detail View

**Файл:** `lib/features/inventory/presentation/screens/product_detail_screen.dart`

**Агуулга:**
- Large product image
- Name, SKU, unit
- Sell price, cost price
- Stock level badge
- Actions: Edit, Delete, Adjust

**Providers:** `productDetailProvider(id)`

**Design Ref:** `/design/product_detail_view/`

#### 4.8 Alerts Center

**Файл:** `lib/features/alerts/presentation/screens/alerts_center_screen.dart`

**Агуулга:**
- Quick stats chips
- Tabs: Бүгд / Бага / Сөрөг / Сэжигтэй
- Alert cards list (severity colors)

**Providers:** `alertListProvider`, `unreadAlertCountProvider`

**Design Ref:** `/design/alerts_center/`

#### 4.9 Shift Management

**Файл:** `lib/features/shifts/presentation/screens/shift_management_screen.dart`

**Агуулга:**
- Current shift card (if active)
- Start/End shift buttons
- Shift history list

**Providers:** `currentShiftProvider`, `shiftHistoryProvider`

**Design Ref:** `/design/shift_management/`

**Баталгаажуулалт:**
- Бүх дэлгэц navigate ажиллах
- Design файлуудтай харьцуулах (pixel-perfect ±2px)
- Light/dark mode

---

### 📅 Үе Шат 5: Animations & Polish - 1-2 хоног

**Зорилго:** UX сайжруулалт, animation, bug fixes.

#### 5.1 Screen Transitions

**Файл:** `lib/core/routing/page_transitions.dart`

- Slide transition (auth → dashboard)
- Fade transition (modals)

#### 5.2 Component Animations

**Файл:** `lib/core/widgets/animations/fade_in_up.dart`

- Dashboard cards: stagger 100ms
- Product grid: stagger
- Alert list: stagger

#### 5.3 Loading States

- Product grid → LoadingShimmer
- Button loading → spinner
- Splash → logo pulse

#### 5.4 Micro-interactions

- Button press: scale(0.98)
- Card hover: scale(1.02)
- Sync badge: pulse 2s
- Cart add: scale + opacity

#### 5.5 Error Handling

**Файлууд:**
1. `lib/core/widgets/states/error_view.dart`
2. `lib/core/widgets/states/empty_view.dart`

#### 5.6 Final Testing

**Checklist:**
- [ ] Auth flow (phone → OTP → dashboard)
- [ ] Cart flow (add → cart → checkout)
- [ ] Offline indicators
- [ ] Dark mode toggle
- [ ] EN/MN localization
- [ ] 60fps animations
- [ ] No console errors

```bash
flutter analyze
flutter test
flutter run --profile
```

---

## Critical Files

Хамгийн чухал 10 файл:

1. [lib/core/theme/app_theme.dart](lib/core/theme/app_theme.dart) - Theme system aggregator
2. [lib/core/routing/app_router.dart](lib/core/routing/app_router.dart) - Navigation config
3. [lib/features/auth/presentation/providers/auth_provider.dart](lib/features/auth/presentation/providers/auth_provider.dart) - Auth state
4. [lib/features/sales/presentation/providers/cart_provider.dart](lib/features/sales/presentation/providers/cart_provider.dart) - Cart logic
5. [lib/core/widgets/cards/product_card.dart](lib/core/widgets/cards/product_card.dart) - Reusable product card
6. [lib/core/utils/style_helpers.dart](lib/core/utils/style_helpers.dart) - Utility functions
7. [lib/features/dashboard/presentation/screens/dashboard_screen.dart](lib/features/dashboard/presentation/screens/dashboard_screen.dart) - Main screen
8. [lib/features/sales/presentation/screens/quick_sale_select_screen.dart](lib/features/sales/presentation/screens/quick_sale_select_screen.dart) - POS entry
9. [lib/core/constants/app_colors.dart](lib/core/constants/app_colors.dart) - Design tokens
10. [pubspec.yaml](pubspec.yaml) - Dependencies

---

## Verification Steps

### Үе шат бүрийн шалгалт:

**Үе шат 1:**
```bash
flutter pub get
flutter run
# Check: Theme, routing бэлэн
```

**Үе шат 2:**
```bash
flutter run
# Test screen-д component бүрийг харах
```

**Үе шат 3:**
```bash
dart run build_runner build --delete-conflicting-outputs
flutter analyze
```

**Үе шат 4:**
```bash
flutter run
# Manual test: Splash → Auth → Dashboard → Sales
```

**Үе шат 5:**
```bash
flutter analyze
flutter test
flutter run --profile  # Performance check
```

---

## Нийт Хугацаа

- **Үе шат 1:** 1-2 хоног
- **Үе шат 2:** 2-3 хоног
- **Үе шат 3:** 2 хоног
- **Үе шат 4:** 4-5 хоног
- **Үе шат 5:** 1-2 хоног

**Нийт:** 10-14 хоног (2-3 долоо хоног)

**Үүсгэх файлууд:** ~60 файл (constants, theme, widgets, providers, screens)

---

## End-to-End Test Flow

Бүрэн ажиллагааг шалгах:

1. **App Launch** → Splash screen (2s) → Navigate based on auth
2. **Auth Flow** → Phone input (+976 99887766) → OTP (123456) → Dashboard
3. **Dashboard** → View today's sales, low stock alerts, top products
4. **Quick Sale** → Search product → Add to cart → Adjust quantity → Checkout → Payment → Create sale
5. **Offline Mode** → Toggle airplane mode → See offline badge → Make sale → Queue in sync_queue → Go online → Auto sync
6. **Dark Mode** → Toggle system dark mode → All screens adapt
7. **Localization** → Switch device language → See Mongolian/English

Энэ төлөвлөгөө нь design system-ийн бүх element-үүдийг хамарсан, offline-first architecture-тай нийцтэй, Material 3 + utility styling requirements-ыг биелүүлсэн байна.