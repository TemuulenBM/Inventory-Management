import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:retail_control_platform/core/providers/store_provider.dart';
import 'package:retail_control_platform/core/services/sales_service.dart';
import 'package:retail_control_platform/features/inventory/domain/product_with_stock.dart';
import 'package:retail_control_platform/features/inventory/presentation/providers/product_provider.dart';
import 'package:retail_control_platform/features/sales/domain/cart_item.dart';
import 'package:retail_control_platform/features/shifts/presentation/providers/shift_provider.dart';

part 'cart_provider.g.dart';

/// SalesService provider
@riverpod
SalesService salesService(SalesServiceRef ref) {
  final db = ref.watch(databaseProvider);
  return SalesService(db: db);
}

/// Cart state notifier
@riverpod
class CartNotifier extends _$CartNotifier {
  @override
  List<CartItem> build() {
    return [];
  }

  /// Add product to cart or increment quantity if already exists
  void addProduct(ProductWithStock product, {int quantity = 1}) {
    final existingIndex = state.indexWhere((item) => item.product.id == product.id);

    if (existingIndex >= 0) {
      // Product already in cart - increment quantity
      final updatedCart = [...state];
      final existingItem = updatedCart[existingIndex];
      updatedCart[existingIndex] = existingItem.copyWith(
        quantity: existingItem.quantity + quantity,
      );
      state = updatedCart;
    } else {
      // New product - add to cart
      state = [...state, CartItem(product: product, quantity: quantity)];
    }
  }

  /// Update quantity for a specific cart item
  void updateQuantity(String productId, int newQuantity) {
    if (newQuantity <= 0) {
      removeProduct(productId);
      return;
    }

    final updatedCart = state.map((item) {
      if (item.product.id == productId) {
        return item.copyWith(quantity: newQuantity);
      }
      return item;
    }).toList();

    state = updatedCart;
  }

  /// Remove product from cart
  void removeProduct(String productId) {
    state = state.where((item) => item.product.id != productId).toList();
  }

  /// Хөнгөлөлт оруулах (нэг ширхэгт ноогдох дүн)
  void setDiscount(String productId, int discountAmount) {
    final updatedCart = state.map((item) {
      if (item.product.id == productId) {
        // Хөнгөлөлт нь анхны үнээс хэтрэхгүй байх
        final clampedDiscount = discountAmount.clamp(0, item.originalPrice);
        return item.copyWith(discountAmount: clampedDiscount);
      }
      return item;
    }).toList();
    state = updatedCart;
  }

  /// Clear entire cart
  void clear() {
    state = [];
  }
}

/// Cart total (sum of all item subtotals) - хөнгөлөлтийн дараах
@riverpod
int cartTotal(CartTotalRef ref) {
  final cartItems = ref.watch(cartNotifierProvider);
  return cartItems.fold(0, (sum, item) => sum + item.subtotal);
}

/// Нийт хөнгөлөлтийн дүн
@riverpod
int cartTotalDiscount(CartTotalDiscountRef ref) {
  final cartItems = ref.watch(cartNotifierProvider);
  return cartItems.fold(0, (sum, item) => sum + item.totalDiscount);
}

/// Cart item count
@riverpod
int cartItemCount(CartItemCountRef ref) {
  final cartItems = ref.watch(cartNotifierProvider);
  return cartItems.fold(0, (sum, item) => sum + item.quantity);
}

/// Checkout actions - stateless functional pattern
/// State management UI layer (cart_screen)-д хийгдэнэ
@riverpod
class CheckoutActions extends _$CheckoutActions {
  @override
  void build() {
    // No state management - purely functional
  }

  /// Борлуулалт хийх (checkout)
  ///
  /// Returns:
  /// - Success: saleId (String)
  /// - Failure: null
  ///
  /// Errors: Throw exception (UI-д catch хийх)
  Future<String?> checkout({
    String paymentMethod = 'cash',
  }) async {
    final storeId = ref.read(storeIdProvider);
    final userId = ref.read(currentUserIdProvider);
    final cartItems = ref.read(cartNotifierProvider);

    // Validation
    if (storeId == null || userId == null) {
      throw Exception('Хэрэглэгч нэвтрээгүй байна');
    }

    if (cartItems.isEmpty) {
      throw Exception('Сагс хоосон байна');
    }

    // Get current shift (if any)
    final currentShift = await ref.read(currentShiftProvider(storeId).future);
    final shiftId = currentShift?.id;

    // Call service
    final service = ref.read(salesServiceProvider);
    final result = await service.completeSale(
      storeId: storeId,
      sellerId: userId,
      items: cartItems,
      paymentMethod: paymentMethod,
      shiftId: shiftId,
    );

    return result.when(
      success: (saleId) {
        // Side effects AFTER successful sale
        ref.read(cartNotifierProvider.notifier).clear();
        ref.invalidate(productListProvider);
        return saleId;
      },
      error: (message, _, __) {
        // Return null for error - UI will handle
        return null;
      },
    );
  }
}

/// Sales history provider
@riverpod
Future<List<SaleWithItems>> salesHistory(
  SalesHistoryRef ref, {
  int limit = 20,
}) async {
  final storeId = ref.watch(storeIdProvider);
  if (storeId == null) return [];

  final service = ref.watch(salesServiceProvider);
  final result = await service.getSalesHistory(storeId, limit: limit);

  return result.when(
    success: (sales) => sales,
    error: (_, __, ___) => [],
  );
}

/// Today's sales total
@riverpod
Future<int> todaySalesTotal(TodaySalesTotalRef ref) async {
  final storeId = ref.watch(storeIdProvider);
  if (storeId == null) return 0;

  final service = ref.watch(salesServiceProvider);
  final result = await service.getTodaySales(storeId);

  return result.when(
    success: (total) => total,
    error: (_, __, ___) => 0,
  );
}

/// Yesterday's sales total (for growth comparison)
@riverpod
Future<int> yesterdaySalesTotal(YesterdaySalesTotalRef ref) async {
  final storeId = ref.watch(storeIdProvider);
  if (storeId == null) return 0;

  final service = ref.watch(salesServiceProvider);
  final result = await service.getYesterdaySales(storeId);

  return result.when(
    success: (total) => total,
    error: (_, __, ___) => 0,
  );
}

/// Өнөөдрийн ашгийн хураангуй (Dashboard-д харуулах)
/// {revenue, cost, discount, profit}
@riverpod
Future<Map<String, int>> todayProfitSummary(TodayProfitSummaryRef ref) async {
  final storeId = ref.watch(storeIdProvider);
  if (storeId == null) return {'revenue': 0, 'cost': 0, 'discount': 0, 'profit': 0};

  final db = ref.watch(databaseProvider);
  return db.getTodayProfitSummary(storeId);
}

/// Сүүлийн 7 хоногийн өдөр тутмын борлуулалт (Dashboard sparkline)
@riverpod
Future<List<int>> weeklySalesTrend(WeeklySalesTrendRef ref) async {
  final storeId = ref.watch(storeIdProvider);
  if (storeId == null) return List.filled(7, 0);

  final db = ref.watch(databaseProvider);
  return db.getWeeklySalesTrend(storeId);
}

/// Шилдэг борлуулалттай бүтээгдэхүүн (Top products)
class TopProductItem {
  final String id;
  final String name;
  final int salesCount;
  final double revenue;
  final String? imageUrl;        // Cloud URL (Supabase Storage)
  final String? localImagePath;  // Local file path (offline)
  final String? category;        // Category-based өнгөнд хэрэгтэй

  TopProductItem({
    required this.id,
    required this.name,
    required this.salesCount,
    required this.revenue,
    this.imageUrl,
    this.localImagePath,
    this.category,
  });

  factory TopProductItem.fromMap(Map<String, dynamic> map) {
    return TopProductItem(
      id: map['id'] as String,
      name: map['name'] as String,
      salesCount: (map['total_quantity'] as num?)?.toInt() ?? 0,
      revenue: (map['total_revenue'] as num?)?.toDouble() ?? 0.0,
      imageUrl: map['image_url'] as String?,
      localImagePath: map['local_image_path'] as String?,
      category: map['category'] as String?,
    );
  }
}

/// Өнөөдрийн шилдэг борлуулалттай бүтээгдэхүүнүүд (Top 5)
@riverpod
Future<List<TopProductItem>> topProducts(TopProductsRef ref) async {
  final storeId = ref.watch(storeIdProvider);
  if (storeId == null) return [];

  final db = ref.watch(databaseProvider);
  final results = await db.getTopSellingProducts(storeId, limit: 5);

  return results.map((map) => TopProductItem.fromMap(map)).toList();
}
