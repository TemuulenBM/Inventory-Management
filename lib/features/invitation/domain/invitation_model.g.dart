// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'invitation_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$InvitationModelImpl _$$InvitationModelImplFromJson(
        Map<String, dynamic> json) =>
    _$InvitationModelImpl(
      id: json['id'] as String,
      phone: json['phone'] as String,
      role: json['role'] as String,
      status: $enumDecode(_$InvitationStatusEnumMap, json['status']),
      invitedBy: json['invited_by'] as String?,
      invitedAt: DateTime.parse(json['invited_at'] as String),
      expiresAt: DateTime.parse(json['expires_at'] as String),
      usedAt: json['used_at'] == null
          ? null
          : DateTime.parse(json['used_at'] as String),
      usedBy: json['used_by'] as String?,
    );

Map<String, dynamic> _$$InvitationModelImplToJson(
        _$InvitationModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'phone': instance.phone,
      'role': instance.role,
      'status': _$InvitationStatusEnumMap[instance.status]!,
      'invited_by': instance.invitedBy,
      'invited_at': instance.invitedAt.toIso8601String(),
      'expires_at': instance.expiresAt.toIso8601String(),
      'used_at': instance.usedAt?.toIso8601String(),
      'used_by': instance.usedBy,
    };

const _$InvitationStatusEnumMap = {
  InvitationStatus.pending: 'pending',
  InvitationStatus.used: 'used',
  InvitationStatus.expired: 'expired',
  InvitationStatus.revoked: 'revoked',
};

_$CreateInvitationRequestImpl _$$CreateInvitationRequestImplFromJson(
        Map<String, dynamic> json) =>
    _$CreateInvitationRequestImpl(
      phone: json['phone'] as String,
      role: json['role'] as String? ?? 'owner',
      expiresInDays: (json['expiresInDays'] as num?)?.toInt() ?? 7,
    );

Map<String, dynamic> _$$CreateInvitationRequestImplToJson(
        _$CreateInvitationRequestImpl instance) =>
    <String, dynamic>{
      'phone': instance.phone,
      'role': instance.role,
      'expiresInDays': instance.expiresInDays,
    };
