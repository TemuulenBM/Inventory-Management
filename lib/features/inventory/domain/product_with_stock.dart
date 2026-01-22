import 'package:freezed_annotation/freezed_annotation.dart';

part 'product_with_stock.freezed.dart';
part 'product_with_stock.g.dart';

/// Product with stock level (joined from DB)
@freezed
class ProductWithStock with _$ProductWithStock {
  const factory ProductWithStock({
    required String id,
    required String name,
    required String sku,
    required double sellPrice,
    required double costPrice,
    required int stockQuantity,
    required bool isLowStock,
    required String storeId,
    String? imageUrl,
    String? unit,
    String? category,
    int? lowStockThreshold,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _ProductWithStock;

  factory ProductWithStock.fromJson(Map<String, dynamic> json) =>
      _$ProductWithStockFromJson(json);
}
