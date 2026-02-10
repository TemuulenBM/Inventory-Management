import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:retail_control_platform/features/inventory/domain/product_with_stock.dart';

part 'cart_item.freezed.dart';
part 'cart_item.g.dart';

/// Сагсны нэг бараа (бүтээгдэхүүн + тоо ширхэг + хөнгөлөлт)
@freezed
class CartItem with _$CartItem {
  const CartItem._();

  const factory CartItem({
    required ProductWithStock product,
    required int quantity,
    /// Хөнгөлөлтийн дүн (₮) - нэг ширхэгт ноогдох
    @Default(0) int discountAmount,
  }) = _CartItem;

  factory CartItem.fromJson(Map<String, dynamic> json) =>
      _$CartItemFromJson(json);

  /// Анхны үнэ (хөнгөлөлтийн өмнөх)
  int get originalPrice => product.sellPrice;

  /// Бодит зарах үнэ (хөнгөлөлтийн дараах, нэг ширхэгт)
  int get effectivePrice => product.sellPrice - discountAmount;

  /// Нийт дүн (хөнгөлөлтийн дараах)
  int get subtotal => effectivePrice * quantity;

  /// Нийт хөнгөлөлтийн дүн (бүх ширхэгт)
  int get totalDiscount => discountAmount * quantity;

  /// Хөнгөлөлт байгаа эсэх
  bool get hasDiscount => discountAmount > 0;

  /// Хөнгөлөлтийн хувь
  double get discountPercent =>
      originalPrice > 0 ? (discountAmount / originalPrice) * 100 : 0;
}
