import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:retail_control_platform/features/inventory/domain/product_with_stock.dart';
import 'package:retail_control_platform/features/sales/domain/cart_item.dart';

part 'cart_provider.g.dart';

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
