// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inventory_event_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$EventActorImpl _$$EventActorImplFromJson(Map<String, dynamic> json) =>
    _$EventActorImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      avatarUrl: json['avatarUrl'] as String?,
    );

Map<String, dynamic> _$$EventActorImplToJson(_$EventActorImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'avatarUrl': instance.avatarUrl,
    };

_$InventoryEventModelImpl _$$InventoryEventModelImplFromJson(
        Map<String, dynamic> json) =>
    _$InventoryEventModelImpl(
      id: json['id'] as String,
      storeId: json['storeId'] as String,
      productId: json['productId'] as String,
      type: $enumDecode(_$InventoryEventTypeEnumMap, json['type']),
      qtyChange: (json['qtyChange'] as num).toInt(),
      timestamp: DateTime.parse(json['timestamp'] as String),
      actor: EventActor.fromJson(json['actor'] as Map<String, dynamic>),
      productName: json['productName'] as String?,
      shiftId: json['shiftId'] as String?,
      reason: json['reason'] as String?,
    );

Map<String, dynamic> _$$InventoryEventModelImplToJson(
        _$InventoryEventModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'storeId': instance.storeId,
      'productId': instance.productId,
      'type': _$InventoryEventTypeEnumMap[instance.type]!,
      'qtyChange': instance.qtyChange,
      'timestamp': instance.timestamp.toIso8601String(),
      'actor': instance.actor,
      'productName': instance.productName,
      'shiftId': instance.shiftId,
      'reason': instance.reason,
    };

const _$InventoryEventTypeEnumMap = {
  InventoryEventType.initial: 'INITIAL',
  InventoryEventType.sale: 'SALE',
  InventoryEventType.adjust: 'ADJUST',
  InventoryEventType.return_: 'RETURN',
};
