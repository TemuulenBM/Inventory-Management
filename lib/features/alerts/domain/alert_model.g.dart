// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'alert_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AlertModelImpl _$$AlertModelImplFromJson(Map<String, dynamic> json) =>
    _$AlertModelImpl(
      id: json['id'] as String,
      storeId: json['storeId'] as String,
      type: $enumDecode(_$AlertTypeEnumMap, json['type']),
      severity: $enumDecode(_$AlertSeverityEnumMap, json['severity']),
      title: json['title'] as String,
      message: json['message'] as String,
      productId: json['productId'] as String?,
      productName: json['productName'] as String?,
      actionDeadline: json['actionDeadline'] == null
          ? null
          : DateTime.parse(json['actionDeadline'] as String),
      isRead: json['isRead'] as bool,
      isDismissed: json['isDismissed'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      resolvedAt: json['resolvedAt'] == null
          ? null
          : DateTime.parse(json['resolvedAt'] as String),
    );

Map<String, dynamic> _$$AlertModelImplToJson(_$AlertModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'storeId': instance.storeId,
      'type': _$AlertTypeEnumMap[instance.type]!,
      'severity': _$AlertSeverityEnumMap[instance.severity]!,
      'title': instance.title,
      'message': instance.message,
      'productId': instance.productId,
      'productName': instance.productName,
      'actionDeadline': instance.actionDeadline?.toIso8601String(),
      'isRead': instance.isRead,
      'isDismissed': instance.isDismissed,
      'createdAt': instance.createdAt.toIso8601String(),
      'resolvedAt': instance.resolvedAt?.toIso8601String(),
    };

const _$AlertTypeEnumMap = {
  AlertType.lowStock: 'lowStock',
  AlertType.negativeStock: 'negativeStock',
  AlertType.suspiciousActivity: 'suspiciousActivity',
  AlertType.systemIssue: 'systemIssue',
};

const _$AlertSeverityEnumMap = {
  AlertSeverity.info: 'info',
  AlertSeverity.low: 'low',
  AlertSeverity.medium: 'medium',
  AlertSeverity.high: 'high',
  AlertSeverity.critical: 'critical',
};
