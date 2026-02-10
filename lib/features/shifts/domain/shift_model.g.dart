// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shift_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ShiftModelImpl _$$ShiftModelImplFromJson(Map<String, dynamic> json) =>
    _$ShiftModelImpl(
      id: json['id'] as String,
      sellerId: json['sellerId'] as String,
      sellerName: json['sellerName'] as String,
      storeId: json['storeId'] as String,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: json['endTime'] == null
          ? null
          : DateTime.parse(json['endTime'] as String),
      totalSales: (json['totalSales'] as num).toDouble(),
      transactionCount: (json['transactionCount'] as num).toInt(),
      notes: json['notes'] as String?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
      openBalance: (json['openBalance'] as num?)?.toInt(),
      closeBalance: (json['closeBalance'] as num?)?.toInt(),
      expectedBalance: (json['expectedBalance'] as num?)?.toInt(),
      discrepancy: (json['discrepancy'] as num?)?.toInt(),
    );

Map<String, dynamic> _$$ShiftModelImplToJson(_$ShiftModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'sellerId': instance.sellerId,
      'sellerName': instance.sellerName,
      'storeId': instance.storeId,
      'startTime': instance.startTime.toIso8601String(),
      'endTime': instance.endTime?.toIso8601String(),
      'totalSales': instance.totalSales,
      'transactionCount': instance.transactionCount,
      'notes': instance.notes,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'openBalance': instance.openBalance,
      'closeBalance': instance.closeBalance,
      'expectedBalance': instance.expectedBalance,
      'discrepancy': instance.discrepancy,
    };
