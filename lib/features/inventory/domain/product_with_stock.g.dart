// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_with_stock.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ProductWithStockImpl _$$ProductWithStockImplFromJson(
        Map<String, dynamic> json) =>
    _$ProductWithStockImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      sku: json['sku'] as String,
      sellPrice: (json['sellPrice'] as num).toDouble(),
      costPrice: (json['costPrice'] as num).toDouble(),
      stockQuantity: (json['stockQuantity'] as num).toInt(),
      isLowStock: json['isLowStock'] as bool,
      storeId: json['storeId'] as String,
      imageUrl: json['imageUrl'] as String?,
      unit: json['unit'] as String?,
      category: json['category'] as String?,
      lowStockThreshold: (json['lowStockThreshold'] as num?)?.toInt(),
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$ProductWithStockImplToJson(
        _$ProductWithStockImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'sku': instance.sku,
      'sellPrice': instance.sellPrice,
      'costPrice': instance.costPrice,
      'stockQuantity': instance.stockQuantity,
      'isLowStock': instance.isLowStock,
      'storeId': instance.storeId,
      'imageUrl': instance.imageUrl,
      'unit': instance.unit,
      'category': instance.category,
      'lowStockThreshold': instance.lowStockThreshold,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };
