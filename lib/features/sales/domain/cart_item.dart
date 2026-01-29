import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:retail_control_platform/features/inventory/domain/product_with_stock.dart';

part 'cart_item.freezed.dart';
part 'cart_item.g.dart';

/// Cart item with product and quantity
@freezed
class CartItem with _$CartItem {
  const CartItem._();

  const factory CartItem({
    required ProductWithStock product,
    required int quantity,
  }) = _CartItem;

  factory CartItem.fromJson(Map<String, dynamic> json) =>
      _$CartItemFromJson(json);

  /// Calculate subtotal for this cart item
  int get subtotal => product.sellPrice * quantity;
}
