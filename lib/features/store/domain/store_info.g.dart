// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'store_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$StoreInfoImpl _$$StoreInfoImplFromJson(Map<String, dynamic> json) =>
    _$StoreInfoImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      location: json['location'] as String?,
      role: json['role'] as String,
    );

Map<String, dynamic> _$$StoreInfoImplToJson(_$StoreInfoImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'location': instance.location,
      'role': instance.role,
    };
