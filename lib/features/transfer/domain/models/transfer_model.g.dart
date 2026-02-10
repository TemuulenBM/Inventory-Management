// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transfer_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TransferModelImpl _$$TransferModelImplFromJson(Map<String, dynamic> json) =>
    _$TransferModelImpl(
      id: json['id'] as String,
      sourceStore:
          TransferStore.fromJson(json['sourceStore'] as Map<String, dynamic>),
      destinationStore: TransferStore.fromJson(
          json['destinationStore'] as Map<String, dynamic>),
      initiatedBy:
          TransferUser.fromJson(json['initiatedBy'] as Map<String, dynamic>),
      status: json['status'] as String,
      notes: json['notes'] as String?,
      items: (json['items'] as List<dynamic>)
          .map((e) => TransferItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdAt: json['createdAt'] as String,
      completedAt: json['completedAt'] as String?,
    );

Map<String, dynamic> _$$TransferModelImplToJson(_$TransferModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'sourceStore': instance.sourceStore,
      'destinationStore': instance.destinationStore,
      'initiatedBy': instance.initiatedBy,
      'status': instance.status,
      'notes': instance.notes,
      'items': instance.items,
      'createdAt': instance.createdAt,
      'completedAt': instance.completedAt,
    };

_$TransferStoreImpl _$$TransferStoreImplFromJson(Map<String, dynamic> json) =>
    _$TransferStoreImpl(
      id: json['id'] as String,
      name: json['name'] as String,
    );

Map<String, dynamic> _$$TransferStoreImplToJson(_$TransferStoreImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
    };

_$TransferUserImpl _$$TransferUserImplFromJson(Map<String, dynamic> json) =>
    _$TransferUserImpl(
      id: json['id'] as String,
      name: json['name'] as String,
    );

Map<String, dynamic> _$$TransferUserImplToJson(_$TransferUserImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
    };

_$TransferItemModelImpl _$$TransferItemModelImplFromJson(
        Map<String, dynamic> json) =>
    _$TransferItemModelImpl(
      id: json['id'] as String,
      productId: json['productId'] as String,
      productName: json['productName'] as String,
      quantity: (json['quantity'] as num).toInt(),
    );

Map<String, dynamic> _$$TransferItemModelImplToJson(
        _$TransferItemModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'productId': instance.productId,
      'productName': instance.productName,
      'quantity': instance.quantity,
    };
