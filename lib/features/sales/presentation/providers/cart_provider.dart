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

  /// Clear entire cart
  void clear() {
    state = [];
  }
}

/// Cart total (sum of all item subtotals)
@riverpod
double cartTotal(CartTotalRef ref) {
  final cartItems = ref.watch(cartNotifierProvider);
  return cartItems.fold(0.0, (sum, item) => sum + item.subtotal);
}

/// Cart item count
@riverpod
int cartItemCount(CartItemCountRef ref) {
  final cartItems = ref.watch(cartNotifierProvider);
  return cartItems.fold(0, (sum, item) => sum + item.quantity);
}

/// Checkout actions
@riverpod
class CheckoutActions extends _$CheckoutActions {
  @override
  FutureOr<void> build() {}

  /// Борлуулалт хийх (checkout)
  Future<String?> checkout({
    String paymentMethod = 'cash',
  }) async {
    state = const AsyncValue.loading();

    final storeId = ref.read(storeIdProvider);
    final userId = ref.read(currentUserIdProvider);
    final cartItems = ref.read(cartNotifierProvider);

    if (storeId == null || userId == null) {
      state = AsyncValue.error('Хэрэглэгч нэвтрээгүй байна', StackTrace.current);
      return null;
    }

    if (cartItems.isEmpty) {
      state = AsyncValue.error('Сагс хоосон байна', StackTrace.current);
      return null;
    }

    // Get current shift (if any)
    final currentShift = await ref.read(currentShiftProvider(storeId).future);
    final shiftId = currentShift?.id;

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
        state = const AsyncValue.data(null);
        // Clear cart after successful checkout
        ref.read(cartNotifierProvider.notifier).clear();
        // Invalidate product list to refresh stock levels
        ref.invalidate(productListProvider);
        return saleId;
      },
      error: (message, _, __) {
        state = AsyncValue.error(message, StackTrace.current);
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
Future<double> todaySalesTotal(TodaySalesTotalRef ref) async {
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
Future<double> yesterdaySalesTotal(YesterdaySalesTotalRef ref) async {
  final storeId = ref.watch(storeIdProvider);
  if (storeId == null) return 0;

  final service = ref.watch(salesServiceProvider);
  final result = await service.getYesterdaySales(storeId);

  return result.when(
    success: (total) => total,
    error: (_, __, ___) => 0,
  );
}
